//
//  LLCrashNSExceptionHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/21.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCrashNSExceptionHelper.h"
#import "LLDebugTool.h"
#import "LLCrashSignalHelper.h"
#import "LLTool.h"
#import "NSObject+LL_Utils.h"
#import "LLRoute.h"
#import "LLStorageManager.h"

static LLCrashNSExceptionHelper *_instance = nil ;

@implementation LLCrashNSExceptionHelper

+(instancetype)sharedHelper{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken,^{
        _instance = [[LLCrashNSExceptionHelper alloc] init] ;
    }) ;
    return _instance ;
}


- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        if (enable) {
            [self registerCatch];
        } else {
            [self unregisterCatch];
        }
    }
}

#pragma mark - Primary
- (void)registerCatch {
    NSLog(@"haleli >>> switch_nsexception : %@",@"开始") ;
    [[LLDebugTool sharedTool] saveExceptionCrashSwitch:YES] ;
    
    NSSetUncaughtExceptionHandler(&HandleException);
}

- (void)unregisterCatch {
    NSLog(@"haleli >>> switch_nsexception : %@",@"关闭") ;
    [[LLDebugTool sharedTool] saveExceptionCrashSwitch:NO] ;
    
    NSSetUncaughtExceptionHandler(nil);
}

//捕获NSException,触发产生 NSException 会同时产生SIGABRT signal异常

//NSException：应用级异常，它是未被捕获的Objective-C异常，导致程序向自身发送了SIGABRT信号而崩溃，对于未捕获的Objective-C异常，是可以通过try catch来捕获的，或者通过NSSetUncaughtExceptionHandler()机制来捕获。
void HandleException(NSException *exception)
{
    [[LLCrashNSExceptionHelper sharedHelper] saveException:exception];
    
    //将crash的有用信息转换成字典
    NSDictionary *crashInfo = [NSDictionary dictionaryWithObjectsAndKeys:exception.name, @"name",
                               exception.reason,@"reason",
                               [exception.callStackSymbols componentsJoinedByString:@"\n"],@"stack",nil] ;
    
    [[LLDebugTool sharedTool] uploadBugWithDict:crashInfo exceptionType:CRASH files:nil takeScreenshot:NO complete:^(BOOL result,NSString* zipPath) {
        if(result){
            NSLog(@"上传bug成功");
            [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
        };
        
    } synchronous:YES] ;
    
    [exception raise];
    
}

- (void)saveException:(NSException *)exception {
    NSString *date = [LLTool stringFromDate:[NSDate date]];
    NSArray *appInfos = [LLRoute appInfos];
    
    //保存NSException异常
    LLCrashModel *model = [[LLCrashModel alloc] initWithName:exception.name reason:exception.reason userInfo:exception.userInfo stackSymbols:exception.callStackSymbols date:date userIdentity:[LLConfig sharedConfig].userIdentity appInfos:appInfos launchDate:[NSObject LL_launchDate]];
    [LLCrashSignalHelper sharedHelper].crashModel = model;
    [[LLStorageManager sharedManager] saveModel:model complete:^(BOOL result) {
        NSLog(@"Save crash model success");
    } synchronous:YES];
}

@end
