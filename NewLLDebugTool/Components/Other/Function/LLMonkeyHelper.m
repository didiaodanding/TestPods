//
//  LLMonkeyHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/7/12.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLMonkeyHelper.h"
#import "LLDebugTool.h"
#import "LLIOSMonkeySettingHelper.h"
#import "LLCocosMonkeySettingHelper.h"
#import "QuickAlgorithm.h"
#import "RandomAlgorithm.h"
#import "MonkeyRunner.h"
#import "LLHomeWindow.h"
#import "MonkeyPaws.h"
#import "KIFTestActor+Monkey.h"
#import <objc/runtime.h>
#import "UIApplication+Monkey.h"
#import "LLMockHelper.h"
#import "LLMonkeyReportHelper.h"

/**
monkey run status
 **/
typedef NS_ENUM(NSUInteger, LLMonkeyRunStatus) {
    Init,
    Running,
    Finish,
    Pause,
    Lost,
};

static LLMonkeyHelper *_instance = nil;

@interface LLMonkeyHelper (){
    MonkeyRunner *runner ;
}

@end


@implementation LLMonkeyHelper
+(instancetype _Nonnull) sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMonkeyHelper alloc] init] ;
    });
    return _instance ;
}

-(void)startIOSMonkey{
    if([LLDebugTool sharedTool].iosMonkeyTimer == nil){
        NSLog(@"haleli >>> switch_ios_monkey : %@",@"开始") ;
        
        [self heartBeatMonkeyReport:[NSString stringWithFormat:@"%tu",Init]];
    
        [[LLDebugTool sharedTool] saveIOSMonkeySwitch:YES] ;
        NSString* algorithm = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.algorithm ;
        NSString* date = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.date ;
        NSTimeInterval interval = [self getInterval:date] ;
        NSMutableArray *blacklist = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.blacklist ;
        NSMutableArray *whitelist = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.whitelist ;
        
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self swizzleMethods];
            [self swizzleMethods1] ;
            [self swizzleMethods2] ;
            [self swizzleMethods3] ;
            
            id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
            if (delegate) {
                UIWindow *window;
                if ([delegate respondsToSelector:@selector(window)]) {
                    window = [delegate window];
                } else {
                    NSLog(@"Delegate does not respond to selector (window).");
                    window = [[UIApplication sharedApplication] windows][0];
                }
                [LLDebugTool sharedTool].paws = [[MonkeyPaws alloc] initWithView:window tapUIApplication:YES];
            } else {
                NSLog(@"Delegate is nil.");
            }
        });
        
        if([algorithm isEqual:@"快速遍历算法"]){
            QuickAlgorithm *algorithm = [[QuickAlgorithm alloc] init];
            runner = [[MonkeyRunner alloc] initWithAlgorithm:algorithm blacklist:blacklist whitelist:whitelist interval:interval] ;
            [LLDebugTool sharedTool].iosMonkeyTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(quickAlgorithm) userInfo:nil repeats:YES];
            [LLDebugTool sharedTool].startDate = [NSDate date] ;
        }else if([algorithm isEqual:@"随机遍历算法"]){
            RandomAlgorithm *algorithm = [[RandomAlgorithm alloc] init] ;
            runner = [[MonkeyRunner alloc] initWithAlgorithm:algorithm blacklist:blacklist whitelist:whitelist interval:interval] ;
            [LLDebugTool sharedTool].iosMonkeyTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(randomAlgorithm) userInfo:nil repeats:YES];
            [LLDebugTool sharedTool].startDate = [NSDate date] ;
        }
        
        NSLog(@"haleli >>> 界面消失") ;
        [[LLHomeWindow shareInstance] hideWindow] ;
    }
}
-(void)pauseIOSMonkey{
    if([LLDebugTool sharedTool].iosMonkeyTimer != nil){
        [self heartBeatMonkeyReport:[NSString stringWithFormat:@"%tu",Pause]];
        NSLog(@"haleli >>> ios_monkey : %@",@"暂停") ;
        [[LLDebugTool sharedTool].iosMonkeyTimer  setFireDate:[NSDate distantFuture]];
    }
}

-(void)continueIOSMonkey{
    if([LLDebugTool sharedTool].iosMonkeyTimer != nil){
        NSLog(@"haleli >>> ios_monkey : %@",@"继续") ;
        [[LLDebugTool sharedTool].iosMonkeyTimer  setFireDate:[NSDate date]];
    }
}

-(void)stopIOSMonkey{
    if([LLDebugTool sharedTool].iosMonkeyTimer != nil){
        [self heartBeatMonkeyReport:[NSString stringWithFormat:@"%tu",Finish]];
        NSLog(@"haleli >>> switch_ios_monkey : %@",@"关闭") ;
        [[LLDebugTool sharedTool] saveIOSMonkeySwitch:NO] ;
        [[LLDebugTool sharedTool].iosMonkeyTimer  invalidate];
        [LLDebugTool sharedTool].iosMonkeyTimer  = nil;
    }
}

-(void)startCocosMonkey{
    if([LLDebugTool sharedTool].cocosMonkeyTimer == nil){
        NSLog(@"haleli >>> switch_cocos_monkey : %@",@"开始") ;
        
        [self heartBeatCocosMonkeyReport:[NSString stringWithFormat:@"%tu",Init]];
        
        [[LLDebugTool sharedTool] saveCocosMonkeySwitch:YES] ;
        NSString* algorithm = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.algorithm ;
        NSString* date = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.date ;
        NSTimeInterval interval = [self getInterval:date] ;
        NSMutableArray *blacklist = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.blacklist ;
        NSMutableArray *whitelist = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.whitelist ;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self swizzleMethods];
            [self swizzleMethods1] ;
            [self swizzleMethods2] ;
            [self swizzleMethods3] ;
            
            id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
            if (delegate) {
                UIWindow *window;
                if ([delegate respondsToSelector:@selector(window)]) {
                    window = [delegate window];
                } else {
                    NSLog(@"Delegate does not respond to selector (window).");
                    window = [[UIApplication sharedApplication] windows][0];
                }
                [LLDebugTool sharedTool].paws = [[MonkeyPaws alloc] initWithView:window tapUIApplication:YES];
            } else {
                NSLog(@"Delegate is nil.");
            }
        });
        
        if([algorithm isEqual:@"快速遍历算法"]){
            QuickAlgorithm *algorithm = [[QuickAlgorithm alloc] init];
            runner = [[MonkeyRunner alloc] initWithAlgorithm:algorithm blacklist:blacklist whitelist:whitelist interval:interval] ;
            [LLDebugTool sharedTool].cocosMonkeyTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(randomCocosAlgorithm) userInfo:nil repeats:YES];
            [LLDebugTool sharedTool].startDate = [NSDate date] ;
        }else if([algorithm isEqual:@"随机遍历算法"]){
            RandomAlgorithm *algorithm = [[RandomAlgorithm alloc] init] ;
            runner = [[MonkeyRunner alloc] initWithAlgorithm:algorithm blacklist:blacklist whitelist:whitelist interval:interval] ;
            [LLDebugTool sharedTool].cocosMonkeyTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(randomCocosAlgorithm) userInfo:nil repeats:YES];
            [LLDebugTool sharedTool].startDate = [NSDate date] ;
        }
        
        NSLog(@"haleli >>> 界面消失") ;
        [[LLHomeWindow shareInstance] hideWindow] ;
    }
}

-(void)pauseCocosMonkey{
    if([LLDebugTool sharedTool].cocosMonkeyTimer != nil){
        NSLog(@"haleli >>> cocos_monkey : %@",@"暂停") ;
        
        [self heartBeatCocosMonkeyReport:[NSString stringWithFormat:@"%tu",Pause]];
        
        [[LLDebugTool sharedTool].cocosMonkeyTimer  setFireDate:[NSDate distantFuture]];
    }
}

-(void)stopCocosMonkey{
    if([LLDebugTool sharedTool].cocosMonkeyTimer != nil){
        NSLog(@"haleli >>> switch_cocos_monkey : %@",@"关闭") ;
        [self heartBeatCocosMonkeyReport:[NSString stringWithFormat:@"%tu",Finish]];
        [[LLDebugTool sharedTool] saveCocosMonkeySwitch:NO] ;
        [[LLDebugTool sharedTool].cocosMonkeyTimer  invalidate];
        [LLDebugTool sharedTool].cocosMonkeyTimer  = nil;
    }
}

-(void)continueCocosMonkey{
    if([LLDebugTool sharedTool].cocosMonkeyTimer != nil){
        NSLog(@"haleli >>> coocos_monkey : %@",@"继续") ;
        [[LLDebugTool sharedTool].cocosMonkeyTimer  setFireDate:[NSDate date]];
    }
}

-(BOOL)swizzleMethods
{
    Class class = [KIFTestActor class];
    SEL originalSelector = @selector(failWithError:stopTest:);
    SEL swizzledSelector = @selector(monkey_failWithError:stopTest:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return YES;
}


-(BOOL)swizzleMethods1
{
    Class class = [UIApplication class];
    SEL originalSelector = @selector(canOpenURL:);
    SEL swizzledSelector = @selector(monkey_canOpenURL:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

-(BOOL)swizzleMethods2
{
    Class class = [UIApplication class];
    SEL originalSelector = @selector(openURL:);
    SEL swizzledSelector = @selector(monkey_openURL:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

-(BOOL)swizzleMethods3
{
    Class class = [UIApplication class];
    SEL originalSelector = @selector(openURL:options:completionHandler:);
    SEL swizzledSelector = @selector(monkey_openURL:options:completionHandler:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}


-(NSTimeInterval)getInterval:(NSString*)date{
    if([date isEqual:@"连续运行"]){
        return -1 ;
    }else if([date isEqual:@"5分钟"]){
        return 5 * 60 ;
    }else if([date isEqual:@"10分钟"]){
        return 10 * 60 ;
    }else if([date isEqual:@"20分钟"]){
        return 20 * 60 ;
    }else if([date isEqual:@"30分钟"]){
        return 30 * 60 ;
    }else if([date isEqual:@"60分钟"]){
        return 60 * 60 ;
    }else if([date isEqual:@"120分钟"]){
        return 120 * 60 ;
    }
    
    return -1 ;
}

//快速遍历算法
-(void)quickAlgorithm{
    [self heartBeatMonkeyReport:[NSString stringWithFormat:@"%tu",Running]];
    [runner runOneQuickStep] ;
    
}

//随机遍历算法
-(void)randomAlgorithm{
    [self heartBeatMonkeyReport:[NSString stringWithFormat:@"%tu",Running]];
    [runner runOneRandomStep] ;
}

//cococ 随机遍历算法
- (void)randomCocosAlgorithm{
    [self heartBeatCocosMonkeyReport:[NSString stringWithFormat:@"%tu",Running]];
    [runner runOneCocosRandomStep] ;
}


- (BOOL) heartBeatCocosMonkeyReport:(NSString *)status{
    if([[LLDebugTool sharedTool] cocosMonkeyHeartBeatReportSwitch]){
        BOOL isMock = [[LLDebugTool sharedTool] mockSwitch] ;
        if(isMock){
            [[LLMockHelper sharedHelper] stopMock] ;
        }
        BOOL flag = [[LLMonkeyReportHelper sharedHelper] heartBeatReport:status];
        if(isMock){
            [[LLMockHelper sharedHelper] startMock] ;
        }
        return flag ;
    }
    return false ;
}

- (BOOL) heartBeatMonkeyReport:(NSString *)status{
    if([[LLDebugTool sharedTool] monkeyHeartBeatReportSwitch]){
        BOOL isMock = [[LLDebugTool sharedTool] mockSwitch] ;
        if(isMock){
            [[LLMockHelper sharedHelper] stopMock] ;
        }
        BOOL flag = [[LLMonkeyReportHelper sharedHelper] heartBeatReport:status];
        if(isMock){
            [[LLMockHelper sharedHelper] startMock] ;
        }
        return flag ;
    }
    return false ;
}
@end
