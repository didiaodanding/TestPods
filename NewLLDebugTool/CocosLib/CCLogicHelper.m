//
//  CCLogicHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/19.
//  Copyright © 2019 li. All rights reserved.
//

#import "CCLogicHelper.h"
#import "CCDriverHelper.h"
#import "ZSFakeTouch.h"

@implementation CCScene

-(instancetype)initWithLocator:(NSString *)locator{
    self = [super init] ;
    if(self){
        _ccpath = locator ;
    }
    return self ;
}

/**
场景是否出现
**/
- (BOOL)ready_state{
    NSString *scene = [[CCDriverHelper sharedHelper] get_curr_scene] ;
    if([scene isEqual:_ccpath]){
        return YES ;
    }else{
        return NO ;
    }
}

/**
 等待场景出现
 **/
- (void) wait_for_ready:(NSTimeInterval)timeout{
    NSDate *time0 = [NSDate date] ;
    while([[NSDate date] timeIntervalSinceDate:time0] < timeout){
        if([self ready_state]){
            return ;
        }
        [NSThread sleepForTimeInterval:0.5] ;
    }
    @throw [NSException exceptionWithName:@"[CCLogicHelper wait_for_ready] failed" reason:[NSString stringWithFormat:@"场景[%@]未在%d秒内加载完成",_ccpath,(int)timeout] userInfo:nil] ;
}

/**
 等待当前场景消失
 **/
-(void) wait_for_disappear:(NSTimeInterval)timeout{
    NSDate *time0 = [NSDate date] ;
    while([[NSDate date] timeIntervalSinceDate:time0] < timeout){
        if(![self ready_state]){
            return ;
        }
        [NSThread sleepForTimeInterval:0.5] ;
    }
    @throw [NSException exceptionWithName:@"[CCLogicHelper wait_for_disappear] failed" reason:[NSString stringWithFormat:@"场景[%@]未在操作完成%d秒后消失",_ccpath,(int)timeout] userInfo:nil] ;
}

@end

@implementation CCNode

-(instancetype)initWithLocator:(NSString *)locator{
    self = [super init] ;
    if(self){
        _ccpath = locator ;
    }
    return self ;
}

/**
 节点包含cc.Label组件的文本
 **/
-(NSString*) label{
    return [[CCDriverHelper sharedHelper] get_label_text:_ccpath] ;
}

/**
 节点名字
 **/
-(NSString *)name{
    return [[CCDriverHelper sharedHelper] get_property:_ccpath prop_name:@"name"] ;
}

/**
 设置节点包含的cc.EditBox的文本
 **/
-(BOOL)value:(NSString*)val{
    return [[CCDriverHelper sharedHelper] set_text:_ccpath text:val] ;
}

/**
 获取子节点列表
 **/
-(NSArray*)children{
    NSArray *children = [[CCDriverHelper sharedHelper] get_children:_ccpath] ;
    NSMutableArray* nodeList = [[NSMutableArray alloc] init] ;
    
    for(int i=0;i<children.count;i++){
        CCNode *node = [[CCNode alloc] initWithLocator:[NSString stringWithFormat:@"%@/%@[%d]",_ccpath,[children objectAtIndex:i],i]] ;
        [nodeList addObject:node] ;
    }
    return nodeList ;
}

/**
 元素是否存在
 **/
-(BOOL) exists{
    return [[CCDriverHelper sharedHelper] find_node:_ccpath] ;
}

/**
 节点是否在场景中激活
 **/
-(BOOL)activeInHierarchy{
    NSString *result = [[CCDriverHelper sharedHelper] get_property:_ccpath prop_name:@"activeInHierarchy"] ;
    if([[result lowercaseString] isEqual:@"true"]){
        return YES ;
    }else{
        return NO ;
    }
}

/**
 通过ccpath查找其子节点
 
 **/
-(CCNode*) get_child_by_ccpath:(NSString *)ccpath{
    NSString * child_locator = [NSString stringWithFormat:@"%@/%@",_ccpath,ccpath] ;
    CCNode *child_node = [[CCNode alloc] initWithLocator:child_locator] ;
    [child_node wait_for_exist:60 interval:0.5] ;
    return child_node ;
}

/**
 子节点名称列表
 **/
-(NSArray*) child_name_list{
    return [[CCDriverHelper sharedHelper] get_children:_ccpath] ;
}

/**
 节点点击
 **/
- (void) click{
    [self wait_for_exist:60 interval:0.5] ;
    [self wait_for_active:60 interval:0.5] ;
   
    BOOL clk_rst = [[CCDriverHelper sharedHelper] touch_node:_ccpath] ;
  
    if(!clk_rst){
        //无法通过调试js注入的方式点击
        NSDictionary *position = [[CCDriverHelper sharedHelper] get_touch_point:_ccpath] ;
        double x = [[position objectForKey:@"x"] doubleValue];
        double y = [[position objectForKey:@"y"] doubleValue];
        [self touchesWithPoint:CGPointMake(x,y)];
    }
    
}

/**
 等待节点出现
 **/
- (void)wait_for_exist:(NSTimeInterval)timeout interval:(NSTimeInterval)interval{
    NSDate *time0 = [NSDate date] ;
    while([[NSDate date] timeIntervalSinceDate:time0] < timeout){
        if([self exists]){
            return ;
        }
        [NSThread sleepForTimeInterval:interval] ;
    }
    @throw [NSException exceptionWithName:@"[CCLogicHelper wait_for_exist] failed" reason:[NSString stringWithFormat:@"节点：%@ 的%d秒内未找到",_ccpath,(int)timeout] userInfo:nil] ;
}

/**
 等待节点激活
 **/
-(void)wait_for_active:(NSTimeInterval)timeout interval:(NSTimeInterval)interval{
    NSDate *time0 = [NSDate date] ;
    while([[NSDate date] timeIntervalSinceDate:time0] < timeout){
        if([self activeInHierarchy]){
            return ;
        }
        [NSThread sleepForTimeInterval:interval] ;
    }
    @throw [NSException exceptionWithName:@"[CCLogicHelper wait_for_active] failed" reason:[NSString stringWithFormat:@"节点：%@ 的%d秒内未激活",_ccpath,(int)timeout] userInfo:nil] ;
    
}
/**
 滑动至目标节点位置
 **/
-(void) drag2node:(CCNode*)node{
    [self wait_for_exist:60 interval:0.5] ;
    [self wait_for_active:60 interval:0.5] ;
    
    [node wait_for_exist:60 interval:0.5] ;
    
    NSDictionary *positionSrc = [[CCDriverHelper sharedHelper] get_touch_point:_ccpath] ;
    NSDictionary *positionDest = [[CCDriverHelper sharedHelper] get_touch_point:node.ccpath] ;
    
    double sx = [[positionSrc objectForKey:@"x"] doubleValue] ;
    double sy = [[positionSrc objectForKey:@"y"] doubleValue] ;
    
    double dx = [[positionDest objectForKey:@"x"] doubleValue] ;
    double dy = [[positionDest objectForKey:@"y"] doubleValue] ;
    
    [self swapWithPoint:CGPointMake(sx, sy) endPoint:CGPointMake(dx, dy)] ;
}

/**
 节点绑定事件名字
 **/
-(NSString *)get_click_event_name{
    return [[CCDriverHelper sharedHelper] get_click_event_name:_ccpath] ;
}

-(void)touchesWithPoint:(CGPoint)zspoint{
    [ZSFakeTouch beginTouchWithPoint:zspoint];
    [ZSFakeTouch endTouchWithPoint:zspoint];
}

-(void)swapWithPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    [ZSFakeTouch beginTouchWithPoint:startPoint];
    [ZSFakeTouch moveTouchWithPoint:endPoint];
    [ZSFakeTouch endTouchWithPoint:endPoint];
}

@end


static CCLogicHelper *_instance = nil ;

@implementation CCLogicHelper

+(instancetype)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CCLogicHelper alloc] init] ;
    });
    return _instance ;
}
-(NSString *)js_evaluate_func:(NSString*)func{
    return [[CCDriverHelper sharedHelper] js_evaluate_func:func] ;
}

- (NSString *) get_curr_scene{
    return [[CCDriverHelper sharedHelper] get_curr_scene] ;
}
@end
