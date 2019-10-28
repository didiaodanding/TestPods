//
//  CCMonkeyHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "CCMonkeyHelper.h"
#import "LLDebugTool.h"

static CCMonkeyHelper* _instance = nil ;

@implementation CCMonkeyHelper

+ (instancetype)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CCMonkeyHelper alloc] init]  ;
        [_instance initial] ;
    });
    return _instance ;
}

/**
 Initial something
 */
-(void)initial{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"monkey_driver" ofType:@"js"] ;
    if([self eval_script:path]){
        NSLog(@"run monkey_driver script success") ;
    }else{
        NSLog(@"run monkey_driver script fail") ;
    }
}

-(BOOL)eval_script:(NSString*)script{
    if([LLDebugTool sharedTool].runScript){
        return [LLDebugTool sharedTool].runScript(script) ;
    }else{
        NSLog(@"runScript not implement") ;
    }
    return false ;
}

-(NSString *)js_evaluate_func:(NSString*)func{
    if([LLDebugTool sharedTool].jsEvaluateFunc){
        return [LLDebugTool sharedTool].jsEvaluateFunc(func) ;
    }else{
        NSLog(@"jsEvaluateFunc not implement") ;
    }
    return nil ;
}

-(NSDictionary *)dumpVisibleAndTouchableNode{

    NSString *json = [self js_evaluate_func:@"mydriver.dumpVisibleAndTouchableNode()"] ;
    
    if(!json) return @{};
    
    NSError* error = nil;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if(!dict) {
        NSLog(@"parse json dict error:%@", error);
    }
    return dict;
}

@end
