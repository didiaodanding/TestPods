//
//  LLFpsOscillogramWindow.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/15.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLFpsOscillogramWindow.h"
#import "LLFpsOscillogramViewController.h"

@implementation LLFpsOscillogramWindow

+ (LLFpsOscillogramWindow *)shareInstance{
    static dispatch_once_t once;
    static LLFpsOscillogramWindow *instance;
    dispatch_once(&once, ^{
        instance = [[LLFpsOscillogramWindow alloc] initWithFrame:CGRectZero];
    });
    return instance;
}

- (void)addRootVc{
    LLFpsOscillogramViewController *vc = [[LLFpsOscillogramViewController alloc] init];
    self.rootViewController = vc;
    self.vc = vc;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    // 默认曲线图不拦截触摸事件，只有在关闭按钮之类才响应
    LLFpsOscillogramViewController *currentVC = (LLFpsOscillogramViewController*)self.vc ;
    if (CGRectContainsPoint(currentVC.closeBtn.frame, point)) {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}

@end
