//
//  LLOscillogramViewController.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/6/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLOscillogramViewController.h"
#import "LLMacros.h"
#import "LLOscillogramWindowManager.h"

@interface LLOscillogramViewController ()
//每秒运行一次
@property (nonatomic, strong) NSTimer *secondTimer;
@end

@implementation LLOscillogramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)startRecord{
    if(!_secondTimer){
        _secondTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(doSecondFunction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_secondTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)doSecondFunction{
    
}

- (void)endRecord{
    if(_secondTimer){
        [_secondTimer invalidate];
        _secondTimer = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LLOscillogramWindowManager shareInstance] resetLayout];
    });
}

//Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
    return YES;
}
//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    UIViewController* vc = [[[UIApplication sharedApplication].delegate window] rootViewController];
    // 支持竖屏
    if(vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait ){
        return UIInterfaceOrientationMaskPortrait ;
    }else{
        //不支持竖屏
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController* vc = [[[UIApplication sharedApplication].delegate window] rootViewController];
    // 支持竖屏
    if(vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait ){
        return UIInterfaceOrientationPortrait ;
    }else{
        //不支持竖屏
        return UIInterfaceOrientationLandscapeRight;
    }
}

@end
