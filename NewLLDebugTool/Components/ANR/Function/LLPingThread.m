//
//  LLPingThread.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/15.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLPingThread.h"
#import <UIKit/UIKit.h>
#import "BSBacktraceLogger.h"

@interface LLPingThread()

/**
 应用是否在活跃状态
 */
@property (nonatomic,assign) BOOL isApplicationActive ;

/**
 控制ping主线程的信号量
 */
@property (nonatomic,strong) dispatch_semaphore_t semaphore ;

/**
 卡顿阈值
 */
@property (nonatomic,assign) double threshold ;

/**
 卡顿回调
 */
@property (nonatomic,copy) LLANRInfoBlock completion ;

/**
 主线程是否阻塞
 */
@property (nonatomic,assign) BOOL isMainThreadANR ;

/**
 ANR堆栈
 */
@property (nonatomic,copy) NSString *stackInfo ;

/**
 每一次 ping 开始的时间
 */
@property (nonatomic , assign) double startPingTime ;


@end


@implementation LLPingThread

-(instancetype)initWithThreshold:(double)threshold completion:(LLANRInfoBlock)completion{
    self = [super init] ;
    if(self){
        _isApplicationActive = YES ;
        _semaphore = dispatch_semaphore_create(0) ;
        _threshold = threshold ;
        _completion = completion ;
        _isMainThreadANR = NO ;
        _stackInfo = @"" ;
        _startPingTime = 0.0 ;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil] ;
    }
    return self ;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

-(void)main{
    //处理ANR的block
    __weak typeof(self) weakSelf = self ;
    void (^handleANR)(void) = ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        if([strongSelf.stackInfo isEqualToString:@""]){
            
        }else{
            if(strongSelf.completion){
                double currentTime = floor([[NSDate date] timeIntervalSince1970] * 1000) ;
                double duration = (currentTime - strongSelf.startPingTime) / 1000.0 ;
    
                strongSelf.completion(@{
                                        @"stackSymbols":strongSelf.stackInfo,
                                        @"duration":[NSString stringWithFormat:@"%.2f",duration]
                                        }) ;
            }
            strongSelf.stackInfo = @"" ;
        }
    };
    
    while(!self.cancelled){
        if(_isApplicationActive){
            self.isMainThreadANR = YES ;
            self.stackInfo = @"" ;
            self.startPingTime = floor([[NSDate date] timeIntervalSince1970] * 1000) ;
            
            //如果主线程未阻塞，会执行该代码
            dispatch_async(dispatch_get_main_queue(),^{
                self.isMainThreadANR = NO ;
                dispatch_semaphore_signal(self.semaphore) ;
            });
            
            //线程休眠
            [NSThread sleepForTimeInterval:self.threshold] ;
            
            //主线程卡顿
            if(self.isMainThreadANR){
                self.stackInfo = [BSBacktraceLogger bs_backtraceOfMainThread] ;
                handleANR() ;
            }
            
            //主线程卡顿，等待唤醒
            dispatch_wait(self.semaphore, DISPATCH_TIME_FOREVER) ;
            
        }else{
            [NSThread sleepForTimeInterval:self.threshold] ;
        }
    }
}


#pragma mark - Notification
- (void)applicationDidBecomeActive{
    _isApplicationActive = YES ;
}

- (void)applicationDidEnterBackground{
    _isApplicationActive = NO ;
}

@end
