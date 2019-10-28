//
//  CCLogicHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/19.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCScene:NSObject

@property (nonatomic,strong) NSString* ccpath ;
-(instancetype)initWithLocator:(NSString*)locator ;

/**
 等待场景出现
 **/
- (void) wait_for_ready:(NSTimeInterval)timeout;

/**
 等待当前场景消失
 **/
-(void) wait_for_disappear:(NSTimeInterval)timeout;

@end


@interface CCNode:NSObject

@property (nonatomic, strong) NSString *ccpath ;

-(instancetype)initWithLocator:(NSString*)locator ;


/**
 节点包含cc.Label组件的文本
 **/
-(NSString*) label ;

/**
 节点名字
 **/
-(NSString *)name;

/**
 设置节点包含的cc.EditBox的文本
 **/
-(BOOL)value:(NSString*)val;

/**
 获取子节点列表
 **/
-(NSArray*)children;

/**
 元素是否存在
 **/
-(BOOL) exists;

/**
 节点是否在场景中激活
 **/
-(BOOL)activeInHierarchy;

/**
 通过ccpath查找其子节点
 
 **/
-(CCNode*) get_child_by_ccpath:(NSString *)ccpath;

/**
 子节点名称列表
 **/
-(NSArray*) child_name_list;


/**
 节点点击
 **/
- (void) click ;


/**
 等待节点出现
 **/
- (void)wait_for_exist:(NSTimeInterval)timeout interval:(NSTimeInterval)interval;

/**
 等待节点激活
 **/
-(void)wait_for_active:(NSTimeInterval)timeout interval:(NSTimeInterval)interval;
/**
 滑动至目标节点位置
 **/
-(void) drag2node:(CCNode*)node;
/**
 节点绑定事件名字
 **/
-(NSString *)get_click_event_name;

@end

@interface CCLogicHelper : NSObject

+(instancetype) sharedHelper ;

-(NSString *)js_evaluate_func:(NSString*)func ;

- (NSString *) get_curr_scene ;

@end

NS_ASSUME_NONNULL_END
