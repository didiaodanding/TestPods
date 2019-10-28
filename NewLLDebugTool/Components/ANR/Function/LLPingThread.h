//
//  LLPingThread.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/15.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LLANRInfoBlock)(NSDictionary *info) ;

/**
 
 用于Ping主线程的线程类
 通过信号量控制来Ping主线程，判断主线程是否卡顿
 
 */

@interface LLPingThread : NSThread

/**
 初始化Ping主线程的线程类
 @para threshold 主线程卡顿阈值
 @para completion 监控到卡顿回调
 */

-(instancetype)initWithThreshold:(double)threshold completion:(LLANRInfoBlock)completion ;

@end

