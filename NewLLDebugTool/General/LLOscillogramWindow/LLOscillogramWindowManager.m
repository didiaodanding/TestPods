//
//  LLOscillogramWindowManager.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/6/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLOscillogramWindowManager.h"
#import "CoverageOscillogramWindow.h"
#import "LLFpsOscillogramWindow.h"
#import "LLCocosFpsOscillogramWindow.h"
#import "LLMacros.h"
#import "LLAppHelper.h"

@interface LLOscillogramWindowManager()
@property (nonatomic, strong) CoverageOscillogramWindow *coverageWindow;
@property (nonatomic, strong) LLFpsOscillogramWindow *fpsWindow ;
@property (nonatomic,strong) LLCocosFpsOscillogramWindow *cocosFpsWindow ;
@end

@implementation LLOscillogramWindowManager
+ (LLOscillogramWindowManager *)shareInstance{
    static dispatch_once_t once;
    static LLOscillogramWindowManager *instance;
    dispatch_once(&once, ^{
        instance = [[LLOscillogramWindowManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _coverageWindow = [CoverageOscillogramWindow shareInstance];
        _fpsWindow = [LLFpsOscillogramWindow shareInstance] ;
        _cocosFpsWindow = [LLCocosFpsOscillogramWindow shareInstance] ;
    }
    return self;
}

- (void)resetLayout{
    CGFloat offsetY = 0;
    CGFloat width = 0;
    CGFloat height = kLLSizeFrom750_Landscape(240);
    if (kInterfaceOrientationPortrait){
        width = LL_SCREEN_WIDTH;
        offsetY = IPHONE_TOPSENSOR_HEIGHT;
    }else{
        width = MAX(LL_SCREEN_HEIGHT,LL_SCREEN_WIDTH);
    }
    if (!_coverageWindow.hidden) {
        _coverageWindow.frame = CGRectMake(0, offsetY, width, height);
        offsetY += _coverageWindow.frame.size.height+kLLSizeFrom750(4);
    }
    if (!_fpsWindow.hidden) {
        _fpsWindow.frame = CGRectMake(0, offsetY, width, height);
        offsetY += _fpsWindow.frame.size.height+kLLSizeFrom750_Landscape(4);
    }
    if (!_cocosFpsWindow.hidden) {
        _cocosFpsWindow.frame = CGRectMake(0, offsetY, width, height);
        offsetY += _cocosFpsWindow.frame.size.height+kLLSizeFrom750_Landscape(4);
    }
}

@end
