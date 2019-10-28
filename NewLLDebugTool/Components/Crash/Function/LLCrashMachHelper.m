//
//  LLMachCrashHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/19.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCrashMachHelper.h"
#import <mach/exception_types.h>
#import <mach/mach.h>
#import <pthread/pthread.h>
#import "LLTool.h"
#import "LLRoute.h"
#import "LLCrashModel.h"
#import "NSObject+LL_Utils.h"
#import "LLStorageManager.h"
#import "LLAppHelper.h"
#import "BSBacktraceLogger.h"
#import "LLCrashSignalHelper.h"
#import "LLDebugTool.h"

// The exception message, straight from mach/exc.defs (following MIG processing) // copied here for ease of reference.
typedef struct
{
    mach_msg_header_t Head;
    /* start of the kernel processed data */
    mach_msg_body_t msgh_body;
    mach_msg_port_descriptor_t thread;
    mach_msg_port_descriptor_t task;
    /* end of the kernel processed data */
    NDR_record_t NDR;
    exception_type_t exception;
    mach_msg_type_number_t codeCnt;
    integer_t code[2];
    int flavor;
    mach_msg_type_number_t old_stateCnt;
    natural_t old_state[144];
} MachExceptionMessage;

/** A mach reply message (according to ux_exception.c, xnu-1699.22.81).
 */
typedef struct
{
    /** Mach header. */
    mach_msg_header_t header;
    
    /** Network Data Representation. */
    NDR_record_t      NDR;
    
    /** Return code. */
    kern_return_t     returnCode;
} MachReplyMessage;

static mach_port_t exceptionPort = MACH_PORT_NULL ;
static pthread_t thread ;

static LLCrashMachHelper *_instance = nil ;

@implementation LLCrashMachHelper

+(instancetype)sharedHelper{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken , ^{
        _instance = [[LLCrashMachHelper alloc] init] ;
    });
    return _instance ;
}

-(void)setEnable:(BOOL)enable{
    if(_enable != enable){
        _enable = enable ;
        if(enable){
            [self registerCatch] ;
        }else{
            [self unregisterCatch] ;
        }
    }
}


#define EXC_UNIX_BAD_SYSCALL 0x10000 /* SIGSYS */
#define EXC_UNIX_BAD_PIPE    0x10001 /* SIGPIPE */
#define EXC_UNIX_ABORT       0x10002 /* SIGABRT */
static NSString* signalNameForMachException(exception_type_t exception, mach_exception_code_t code)
{
    switch(exception)
    {
        case EXC_ARITHMETIC:
            return @"SIGFPE";
        case EXC_BAD_ACCESS:
            return code == KERN_INVALID_ADDRESS ? @"SIGSEGV" : @"SIGBUS";
        case EXC_BAD_INSTRUCTION:
            return @"SIGILL";
        case EXC_BREAKPOINT:
            return @"SIGTRAP";
        case EXC_EMULATION:
            return @"SIGEMT";
        case EXC_SOFTWARE:
        {
            switch (code)
            {
                case EXC_UNIX_BAD_SYSCALL:
                    return @"SIGSYS";
                case EXC_UNIX_BAD_PIPE:
                    return @"SIGPIPE";
                case EXC_UNIX_ABORT:
                    return @"SIGABRT";
                case EXC_SOFT_SIGNAL:
                    return @"SIGKILL";
            }
            break;
        }
    }
    return @"Unknown signal";
}

#pragma mark - Primary
-(void)registerCatch{
    
    NSLog(@"haleli >>> switch_mach_crash : %@",@"开始") ;
    [[LLDebugTool sharedTool] saveMachCrashSwitch:YES];
    
    /**
     Masks for exception definitions
     **/
    exception_mask_t mask = EXC_MASK_BAD_ACCESS |
    EXC_MASK_BAD_INSTRUCTION |
    EXC_MASK_ARITHMETIC |
    EXC_MASK_SOFTWARE |
    EXC_MASK_BREAKPOINT;
    
    
    kern_return_t kr ;
    const task_t thisTask = mach_task_self() ;
    //分配端口
    if(exceptionPort == MACH_PORT_NULL){
        kr = mach_port_allocate(thisTask,MACH_PORT_RIGHT_RECEIVE,&exceptionPort) ;
        if(kr != KERN_SUCCESS){
            NSLog(@"haleli >>> failed to allocate exception port : %s",mach_error_string(kr)) ;
            return ;
        }else{
            NSLog(@"haleli >>> allocate exception port : %d",exceptionPort) ;
        }
        
        
        kr = mach_port_insert_right(thisTask, exceptionPort, exceptionPort, MACH_MSG_TYPE_MAKE_SEND);
        if(kr != KERN_SUCCESS){
            NSLog(@"haleli >>> failed to insert rights : %s",mach_error_string(kr)) ;
            return ;
        }
    }
    
    //设置端口监听异常
    kr = task_set_exception_ports(thisTask,
                                  mask,
                                  exceptionPort,
                                  EXCEPTION_DEFAULT,
                                  THREAD_STATE_NONE);

    if(kr != KERN_SUCCESS){
        NSLog(@"haleli >>> failed to set exception : %s",mach_error_string(kr)) ;
        return ;
    }

    int error = pthread_create(&thread,NULL,&handleExceptions,NULL) ;

    if(error !=0){
        NSLog(@"haleli >>> failed to create thread : %s",strerror(error)) ;
        return ;
    }
}
static NSString *machName(exception_type_t exception, mach_exception_code_t code) {
    switch(exception)
    {
        case EXC_ARITHMETIC:
            return @"EXC_ARITHMETIC";
        case EXC_BAD_ACCESS:
            return @"EXC_BAD_ACCESS";
        case EXC_BAD_INSTRUCTION:
            return @"EXC_BAD_INSTRUCTION";
        case EXC_BREAKPOINT:
            return @"EXC_BREAKPOINT";
        case EXC_EMULATION:
            return @"EXC_EMULATION";
        case EXC_SOFTWARE:
        {
            switch (code)
            {
                case EXC_UNIX_BAD_SYSCALL:
                    return @"EXC_UNIX_BAD_SYSCALL";
                case EXC_UNIX_BAD_PIPE:
                    return @"EXC_UNIX_BAD_PIPE";
                case EXC_UNIX_ABORT:
                    return @"EXC_UNIX_ABORT";
                case EXC_SOFT_SIGNAL:
                    return @"EXC_SOFT_SIGNAL";
            }
            break;
        }
    }
    return @"Unknown mach";
}


static void* handleExceptions(void *const userData){
    NSLog(@"haleli >>> exception handler is listining....") ;

    MachExceptionMessage exceptionMessage = {{0}} ;
    MachReplyMessage replyMessage = {{0}} ;
    mach_msg_return_t mr ;
    for(; ;){
        //等待mach exception，否则会阻塞
        mr = mach_msg(&exceptionMessage.Head, MACH_RCV_MSG, 0, sizeof(exceptionMessage), exceptionPort, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL) ;
        
        //捕获到mach exception，跳出循环
        if(mr == MACH_MSG_SUCCESS){
            break ;
        }
        NSLog(@"haleli >>> failed to handle exception : %s",mach_error_string(mr)) ;
    }
    
    NSString *callStackSymbols = [BSBacktraceLogger bs_backtraceOfThread:exceptionMessage.thread.name];
    NSString *date = [LLTool stringFromDate:[NSDate date]];
    NSArray *appInfos = [LLRoute appInfosForMach];
    
    mach_exception_code_t code = exceptionMessage.code[0] ;
    if( code == KERN_PROTECTION_FAILURE && [BSBacktraceLogger bs_isStackOverflow:exceptionMessage.thread.name])
    {
        // A stack overflow should return KERN_INVALID_ADDRESS, but
        // when a stack blasts through the guard pages at the top of the stack,
        // it generates KERN_PROTECTION_FAILURE. Correct for this.
        code = KERN_INVALID_ADDRESS;
    }
    
    NSLog(@"mach exception:%@",machName(exceptionMessage.exception, code) ) ;
    NSLog(@"signal:%@",signalNameForMachException(exceptionMessage.exception, code)) ;
    NSLog(@"stack:%@",callStackSymbols) ;
    
    LLCrashModel *model = [[LLCrashModel alloc] initWithName:machName(exceptionMessage.exception, code) reason:[NSString stringWithFormat:@"Catch Mach(抛出信号%@)",signalNameForMachException(exceptionMessage.exception, code)] userInfo:nil stackSymbols:@[callStackSymbols] date:date userIdentity:[LLConfig sharedConfig].userIdentity appInfos:appInfos launchDate:[NSObject LL_launchDate]];
    
    [LLCrashSignalHelper sharedHelper].crashModel = model;
    
    [[LLStorageManager sharedManager] saveModel:model complete:^(BOOL result) {
        NSLog(@"Save mach model success");
    } synchronous:YES];
    
    NSLog(@"replying to mach exception message .") ;
    //send a reply saying "I didn't handle this exception"
    replyMessage.header = exceptionMessage.Head ;
    replyMessage.NDR = exceptionMessage.NDR ;
    replyMessage.returnCode = KERN_FAILURE ;
    
    mach_msg(&replyMessage.header, MACH_SEND_MSG, sizeof(replyMessage), 0, MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL) ;
    
    return NULL ;
}

-(void)unregisterCatch{
    
    NSLog(@"haleli >>> switch_mach_crash : %@",@"关闭") ;
    [[LLDebugTool sharedTool] saveMachCrashSwitch:NO] ;
    
    pthread_cancel(thread) ;
    thread = 0 ;
    exceptionPort = MACH_PORT_NULL ;
}
@end
