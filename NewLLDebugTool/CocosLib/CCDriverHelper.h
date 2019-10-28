//
//  CCDriver.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/18.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCDriverHelper : NSObject

/**
  @return Singleton
 **/
+(instancetype _Nonnull) sharedHelper ;

/**
 @param  ccpath of node
 @return point of node
 */
- (NSDictionary*) get_touch_point:(NSString *)ccpath ;

/**
 
 @param ccpath of node  and property name
 @return property value
 
 */
- (NSString *) get_property:(NSString *)ccpath prop_name:(NSString *)prop_name ;


/**
 @return current scene name
 **/
- (NSString *) get_curr_scene ;


/**
 @param ccpath of node
 **/
- (BOOL) touch_node:(NSString *)ccpath ;


/**
 @param ccpath of node and text
 **/
- (BOOL) set_text:(NSString *)ccpath text:(NSString *)text ;


/**
 @return label text
 **/
- (NSString*) get_label_text:(NSString *)ccpath ;


/**
 @param ccpath of node
 **/
- (BOOL) find_node:(NSString *)ccpath ;


/**
 @return children
 **/
- (NSArray *) get_children:(NSString *)ccpath ;


/**
 @return event name
 **/
- (NSString *) get_click_event_name:(NSString *)ccpath ;

/**
 @param func js func
 **/
-(NSString *)js_evaluate_func:(NSString*)func ;

@end

NS_ASSUME_NONNULL_END
