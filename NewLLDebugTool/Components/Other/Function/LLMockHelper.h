//
//  LLMockHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/1.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLMockHelper : NSObject
/**
 Singleton to control mock.
 
 @return Singleton
 */
+(instancetype _Nonnull)sharedHelper;

/**
 start mock
 */
-(void)startMock ;

/**
 stop mock
 */
-(void)stopMock ;

@end

NS_ASSUME_NONNULL_END
