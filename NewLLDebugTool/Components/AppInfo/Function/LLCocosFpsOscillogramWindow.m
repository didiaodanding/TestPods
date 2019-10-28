//
//  LLCocosFpsOscillogramWindow.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/16.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCocosFpsOscillogramWindow.h"
#import "LLCocosFpsOscillogramViewController.h"

@implementation LLCocosFpsOscillogramWindow

+ (LLCocosFpsOscillogramWindow *)shareInstance{
    static dispatch_once_t once;
    static LLCocosFpsOscillogramWindow *instance;
    dispatch_once(&once, ^{
        instance = [[LLCocosFpsOscillogramWindow alloc] initWithFrame:CGRectZero];
    });
    return instance;
}

- (void)addRootVc{
    LLCocosFpsOscillogramViewController *vc = [[LLCocosFpsOscillogramViewController alloc] init];
    self.rootViewController = vc;
    self.vc = vc;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    // 默认曲线图不拦截触摸事件，只有在关闭按钮之类才响应
    LLCocosFpsOscillogramViewController *currentVC = (LLCocosFpsOscillogramViewController*)self.vc ;
    if (CGRectContainsPoint(currentVC.closeBtn.frame, point)) {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}


@end
