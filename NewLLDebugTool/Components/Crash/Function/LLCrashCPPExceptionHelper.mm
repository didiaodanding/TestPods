//
//  LLCrashCPPExceptionHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/23.
//  Copyright © 2019 li. All rights reserved.
//

/**
 xcode 编译.m文件使用 C compiler (clang or llvm-gcc)编译器，
 而编译.mm时使用 clang++ 或 llvm-g++ 编译器。
 */

#import "LLCrashCPPExceptionHelper.h"
#import "LLCrashSignalHelper.h"
#import "LLDebugTool.h"
#import "LLCrashModel.h"
#import "NSObject+LL_Utils.h"
#import "LLTool.h"
#import "LLRoute.h"
#import "LLStorageManager.h"
#import "BSBacktraceLogger.h"

#include <execinfo.h>
#include <cxxabi.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <typeinfo>

#define DESCRIPTION_BUFFER_LENGTH 1000
#define MAX_BACKTRACE_LENGTH 50

// Compiler hints for "if" statements
#define likely_if(x) if(__builtin_expect(x,1))
#define unlikely_if(x) if(__builtin_expect(x,0))

static bool captureStackTrace = false;

static std::terminate_handler originalTerminateHandler;

uintptr_t backtraceBuffer[0];

int backtraceLength = 0 ;

static LLCrashCPPExceptionHelper *_instance = nil ;


@implementation LLCrashCPPExceptionHelper

+(instancetype)sharedHelper{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken , ^{
        _instance = [[LLCrashCPPExceptionHelper alloc] init] ;
    });
    return _instance ;
}


-(void)setEnable:(BOOL)enable{
    if(_enable != enable){
        _enable = enable ;
        captureStackTrace = enable;
        if(enable){
            [self registerCatch] ;
        }else{
            [self unregisterCatch] ;
        }
    }
}

-(void)registerCatch{
    NSLog(@"haleli >>> switch_cpp_crash : %@",@"开始") ;
    [[LLDebugTool sharedTool] saveCPPExceptionCrashSwitch:YES] ;
    
    originalTerminateHandler = std::set_terminate(CPPExceptionTerminate);
}

-(void)unregisterCatch{
    NSLog(@"haleli >>> switch_cpp_crash : %@",@"关闭") ;
    [[LLDebugTool sharedTool] saveCPPExceptionCrashSwitch:NO] ;
    
    std::set_terminate(originalTerminateHandler);
}

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================
typedef void (*cxa_throw_type)(void*, std::type_info*, void (*)(void*));

extern "C"
{
    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*)) __attribute__ ((weak));
    
    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*))
    {
        if(captureStackTrace)
        {
            backtraceLength = backtrace((void**)backtraceBuffer, MAX_BACKTRACE_LENGTH);
            
            /**不使用trace = backtrace_symbols(backtraceBuffer, backtraceLength);
            经验证没有 [BSBacktraceLogger bs_backtrace:backtraceBuffer backtraceLength:backtraceLength] ;翻译的精准*/
        }
        
        static cxa_throw_type orig_cxa_throw = NULL;
        unlikely_if(orig_cxa_throw == NULL)
        {
            orig_cxa_throw = (cxa_throw_type) dlsym(RTLD_NEXT, "__cxa_throw");
        }
        orig_cxa_throw(thrown_exception, tinfo, dest);
        __builtin_unreachable();
    }
}


static void CPPExceptionTerminate(void){
    NSLog(@"Trapped c++ exception");
    const char* name = NULL;
    std::type_info* tinfo = __cxxabiv1::__cxa_current_exception_type();
    if(tinfo != NULL){
        name = tinfo->name();
    }
    if(name == NULL || strcmp(name, "NSException") != 0){
        
        char descriptionBuff[DESCRIPTION_BUFFER_LENGTH];
        const char* description = descriptionBuff;
        descriptionBuff[0] = 0;
        
        NSLog(@"Discovering what kind of exception was thrown.");
        
        captureStackTrace = false;
        
        try
        {
            throw;
        }
        catch(std::exception& exc)
        {
            strncpy(descriptionBuff, exc.what(), sizeof(descriptionBuff));
        }
#define CATCH_VALUE(TYPE, PRINTFTYPE) \
catch(TYPE value)\
{ \
snprintf(descriptionBuff, sizeof(descriptionBuff), "%" #PRINTFTYPE, value); \
}
        CATCH_VALUE(char,                 d)
        CATCH_VALUE(short,                d)
        CATCH_VALUE(int,                  d)
        CATCH_VALUE(long,                ld)
        CATCH_VALUE(long long,          lld)
        CATCH_VALUE(unsigned char,        u)
        CATCH_VALUE(unsigned short,       u)
        CATCH_VALUE(unsigned int,         u)
        CATCH_VALUE(unsigned long,       lu)
        CATCH_VALUE(unsigned long long, llu)
        CATCH_VALUE(float,                f)
        CATCH_VALUE(double,               f)
        CATCH_VALUE(long double,         Lf)
        CATCH_VALUE(char*,                s)
        catch(...)
        {
            description = NULL;
        }
        captureStackTrace = true;
        
        NSString * callStackSymbols = [BSBacktraceLogger bs_backtrace:backtraceBuffer backtraceLength:backtraceLength] ;
        
        NSLog(@"cpp exception:%@",@"CPP Exception") ;
        NSLog(@"stack:%@",callStackSymbols) ;
        
        NSString *date = [LLTool stringFromDate:[NSDate date]];
        NSArray *appInfos = [LLRoute appInfos];
        LLCrashModel *model = [[LLCrashModel alloc] initWithName:@"CPP Exception" reason:[NSString stringWithFormat:@"抛出异常：%@",description?[NSString stringWithUTF8String:description]:@"Unknown"] userInfo:nil stackSymbols:@[callStackSymbols] date:date userIdentity:[LLConfig sharedConfig].userIdentity appInfos:appInfos launchDate:[NSObject LL_launchDate]];
        [LLCrashSignalHelper sharedHelper].crashModel = model;
        [[LLStorageManager sharedManager] saveModel:model complete:^(BOOL result) {
            NSLog(@"Save mach model success");
        } synchronous:YES];
        
    }else{
        NSLog(@"Detected NSException. Letting the current NSException handler deal with it.");
    }
    
    NSLog(@"Calling original terminate handler.");
    
    originalTerminateHandler() ;
}

@end
