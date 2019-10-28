//
//  BSBacktraceLogger.h
//  BSBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

#define BSLOG NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfCurrentThread]);
#define BSLOG_MAIN NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfMainThread]);
#define BSLOG_ALL NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfAllThread]);

@interface BSBacktraceLogger : NSObject

+ (NSString *)bs_backtraceOfAllThread;
+ (NSString *)bs_backtraceOfCurrentThread;
+ (NSString *)bs_backtraceOfMainThread;
+ (NSString *)bs_backtraceOfNSThread:(NSThread *)thread;

/**
 mach thread need the api.
 */
+ (NSString *)bs_backtraceOfThread:(thread_t)thread  ;

/*
 A stack overflow should return KERN_INVALID_ADDRESS, but
 when a stack blasts through the guard pages at the top of the stack,
 it generates KERN_PROTECTION_FAILURE. Correct for this.
 
 need the api to correct for this
 */
+ (BOOL)bs_isStackOverflow:(thread_t)thread ;

+ (NSString *)bs_backtrace:(uintptr_t *)backtraceBuffer backtraceLength:(int)backtraceLength ;

@end
