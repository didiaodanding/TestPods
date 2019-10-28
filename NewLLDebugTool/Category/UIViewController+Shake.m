//
//  UIViewController+Shake.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/7/13.
//  Copyright © 2019 li. All rights reserved.
//

#import "UIViewController+Shake.h"
#import "LLDebugTool.h"
#import "LLMonkeyHelper.h"
#import "LLMockHelper.h"

@implementation UIViewController (Shake)
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - 摇一摇动作处理
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"began");
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"cancel");
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"end");
    if(motion == UIEventSubtypeMotionShake){
        if([[LLDebugTool sharedTool] iosMonkeySwitch]){
            [[LLMonkeyHelper sharedHelper] pauseIOSMonkey] ;
            [self showAlertControllerWithMessage:@"确定关闭ios monkey?" handler:^(NSInteger action) {
                if(action == 0){
                    [[LLMonkeyHelper sharedHelper] continueIOSMonkey] ;
                }else {
                    [[LLMonkeyHelper sharedHelper] stopIOSMonkey] ;
                    [[LLMockHelper sharedHelper] stopMock] ;
                }
            }];
        }else if([[LLDebugTool sharedTool] cocosMonkeySwitch]){
            [[LLMonkeyHelper sharedHelper] pauseCocosMonkey] ;
            [self showAlertControllerWithMessage:@"确定关闭cocos monkey?" handler:^(NSInteger action) {
                if(action == 0){
                    [[LLMonkeyHelper sharedHelper] continueCocosMonkey] ;
                }else {
                    [[LLMonkeyHelper sharedHelper] stopCocosMonkey] ;
                    [[LLMockHelper sharedHelper] stopMock] ;
                }
            }];
        }
    }
}


- (void)showAlertControllerWithMessage:(NSString *)message handler:(void (^)(NSInteger action))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Note" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(0);
        }
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(1);
        }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
