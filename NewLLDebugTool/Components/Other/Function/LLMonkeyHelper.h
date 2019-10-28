//
//  LLMonkeyHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/7/12.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLMonkeyHelper : NSObject

/**
 Singleton to control monkey.
 
 @return Singleton
 */
+(instancetype _Nonnull)sharedHelper;

/**
 start ios monkey
 */
-(void)startIOSMonkey ;

/**
 pause ios monkey
 */
-(void)pauseIOSMonkey ;

/**
 continue ios monkey
 */
-(void)continueIOSMonkey ;

/**
 stop ios monkey
 */
-(void)stopIOSMonkey ;

/**
 start cocos monkey
 */
-(void)startCocosMonkey ;

/**
 pause cocos monkey
 */
-(void)pauseCocosMonkey ;

/**
 continue coocs monkey
 */
-(void)continueCocosMonkey ;

/**
 stop cocos monkey
 */
-(void)stopCocosMonkey ;

@end

NS_ASSUME_NONNULL_END
