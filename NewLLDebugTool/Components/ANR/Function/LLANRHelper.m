//
//  LLANRHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/15.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLANRHelper.h"
#import "LLPingThread.h"
#import "LLANRModel.h"
#import "LLTool.h"
#import "LLRoute.h"
#import "LLStorageManager.h"
#import "LLDebugTool.h"

//卡顿阈值
static double threshold = 2.0 ;

static LLANRHelper *_instance = nil ;

@interface LLANRHelper()

/**
用于Ping主线程的线程实类
**/
@property(strong,nonatomic,nullable)LLPingThread *pingThread ;

@end

@implementation LLANRHelper

+ (instancetype _Nonnull)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLANRHelper alloc] init];
        [_instance initial];
    });
    return _instance;
}

/**
 Initial something
 */
-(void)initial{
    _enable = false ;
}

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        if (enable) {
            [self startMonitorANR];
        } else {
            [self stopMonitorANR];
        }
    }
}

-(void)startMonitorANR{
    if(self.pingThread == nil){
        
        NSLog(@"haleli >>> switch_anr : %@",@"开始") ;
        [[LLDebugTool sharedTool] saveANRSwitch:YES] ;
        
        __weak typeof(self) weakSelf = self ;
        self.pingThread = [[LLPingThread alloc] initWithThreshold:threshold completion:^(NSDictionary *info) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            [strongSelf saveANR:info] ;
        }] ;
        [self.pingThread start] ;
    }
}

-(void)saveANR:(NSDictionary *)info{
    
    NSString *date = [LLTool stringFromDate:[NSDate date]] ;
    NSArray *appInfos = [LLRoute appInfos] ;
    
    NSString *stackSymbols = [info objectForKey:@"stackSymbols"] ;
    NSString *duration = [info objectForKey:@"duration"] ;
    
    NSLog(@"haleli >>> %@",stackSymbols) ;
    NSLog(@"haleli >>> %@",duration) ;
    LLANRModel *model = [[LLANRModel alloc] initWithName:@"ANR" reason:@"Catch ANR" stackSymbols:stackSymbols date:date duration:duration appInfos:appInfos identity:date] ;
    
    [[LLStorageManager sharedManager] saveModel:model complete:^(BOOL result){
        NSLog(@"Save anr model success") ;
    } synchronous:YES] ;
}

-(void)stopMonitorANR{
    if(self.pingThread !=nil){
        
        NSLog(@"haleli >>> switch_anr : %@",@"关闭") ;
        [[LLDebugTool sharedTool] saveANRSwitch:NO] ;
        
        [self.pingThread cancel] ;
        self.pingThread = nil ;
    }
}


@end
