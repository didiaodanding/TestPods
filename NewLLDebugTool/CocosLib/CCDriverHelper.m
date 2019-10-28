//
//  CCDriver.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "CCDriverHelper.h"
#import "LLTool.h"
#import "LLDebugTool.h"

static CCDriverHelper* _instance = nil ;

@implementation CCDriverHelper

+ (instancetype)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CCDriverHelper alloc] init]  ;
        [_instance initial] ;
    });
    return _instance ;
}

/**
 Initial something
 */
-(void)initial{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cc_driver_lib" ofType:@"js"] ;
    if([self eval_script:path]){
        NSLog(@"run cc_driver_lib script success") ;
    }else{
        NSLog(@"run cc_driver_lib script fail") ;
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

/**
获取节点的屏幕坐标
 */
- (NSDictionary*) get_touch_point:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.getTouchPointByXpath('%@')",ccpath] ;
    NSString *rst_str = [self js_evaluate_func:js] ;
    NSDictionary *position = [LLTool dictWithJsonString:rst_str] ;
    
    double x = [[position objectForKey:@"x"] doubleValue] * [[UIScreen mainScreen] bounds].size.width;
    double y = [[position objectForKey:@"y"] doubleValue] * [[UIScreen mainScreen] bounds].size.height;
    
    NSDictionary *newPosition = @{@"x":@(x),@"y":@(y)} ;
    return newPosition ;
}

/**
获取节点属性
 */
- (NSString *) get_property:(NSString *)ccpath prop_name:(NSString *)prop_name{
    NSString *js = [NSString stringWithFormat:@"_node = cc_driver_lib.find('%@');_node.%@",ccpath,prop_name] ;
    NSString *rst_str = [self js_evaluate_func:js] ;
    return rst_str ;
}


/**
获取当前场景
 **/
- (NSString *) get_curr_scene{
    NSString *js = @"cc_driver_lib.getCurrSceneName()" ;
    return  [self js_evaluate_func:js] ;
}


/**
通过js注入的方式点击
 **/
- (BOOL) touch_node:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.clickByXpath('%@')",ccpath] ;
    NSString *rst = [self js_evaluate_func:js] ;
    if([[rst lowercaseString] isEqual:@"true"]){
        return true ;
    }else{
        return false ;
    }
    
}


/**
通过js注入输入文本
 **/
- (BOOL) set_text:(NSString *)ccpath text:(NSString *)text{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.inputByXpath('%@', '%@')",ccpath,text] ;
    NSString *rst = [self js_evaluate_func:js] ;
    if([[rst lowercaseString] isEqual:@"true"]){
        return true ;
    }else{
        return false ;
    }
}


/**
 通过调试js注入获取label文本
 **/
- (NSString*) get_label_text:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.getTextByXpath('%@')",ccpath] ;
    return  [self js_evaluate_func:js] ;
}


/**
 查找节点
 **/
- (BOOL) find_node:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.find('%@')",ccpath] ;
    
    id node =  [self js_evaluate_func:js] ;
    if(node){
        return true ;
    }else{
        return false ;
    }
}


/**
 获取子节点的名称列表
 **/
- (NSArray *) get_children:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.getChildren('%@')",ccpath] ;
    NSString *rst_str = [self js_evaluate_func:js];
    NSArray *children = [LLTool arrayWithJsonString:rst_str] ;
    return children ;
}


/**
 获取节点绑定事件名字
 **/
- (NSString *) get_click_event_name:(NSString *)ccpath{
    NSString *js = [NSString stringWithFormat:@"cc_driver_lib.getClickEventNameByXpath('%@')",ccpath] ;
    return [self js_evaluate_func:js] ;
}

@end
