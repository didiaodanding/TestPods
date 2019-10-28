//
//  MonkeyScriptHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/18.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface LLTestCase:NSObject
@property (strong, nonatomic) id target;
@property (assign, nonatomic) SEL selector;
- (instancetype)initWithTarget:(id)target selector:(SEL)selector ;
@end

@interface MonkeyScriptHelper : NSObject
/**
 Singleton to control monkey script.
 
 @return Singleton
 */
+ (instancetype)sharedHelper  ;

/**
 obtain sel from target
 **/

- (LLTestCase *)loadTestFromTarget:(id)target ;

/**
 obtain all monkey script
 **/
- (NSArray *)loadAllTestCases ;

/**
 run monkey script
 **/
- (BOOL)runTestWithTarget:(id)target selector:(SEL)selector exception:(NSException **)exception interval:(NSTimeInterval *)interval
        reraiseExceptions:(BOOL)reraiseExceptions ;
@end

NS_ASSUME_NONNULL_END
