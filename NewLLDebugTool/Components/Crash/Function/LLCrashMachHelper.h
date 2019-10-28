//
//  LLMachCrashHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/19.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLCrashMachHelper : NSObject

/**
 Singleton to control enable.
 
 @return Singleton
 */

+(instancetype _Nonnull)sharedHelper ;

/**
 Set enable to catch crash.
 */

@property(nonatomic,assign ,getter = isEnabled) BOOL enable ;

@end

NS_ASSUME_NONNULL_END
