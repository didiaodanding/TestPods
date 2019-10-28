//
//  LLWebViewConfig.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewConfig.h"

@implementation LLWebViewConfig

+ (instancetype)defaultConfig
{
    static LLWebViewConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [LLWebViewConfig new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.performanceType = whiteScreenType ;
    }
    return self;
}

@end
