//
//  LLWebViewConfig.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 performance type
 **/
typedef NS_ENUM(NSUInteger, LLPerformanceType) {
    whiteScreenType,
    firstScreenType,
};

@interface LLWebViewConfig : NSObject

@property (nonatomic,assign) NSInteger performanceType ;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
