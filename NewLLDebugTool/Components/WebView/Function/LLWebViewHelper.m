//
//  LLWebViewHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewHelper.h"
#import <objc/runtime.h>
#import "UIWebView+Swizzling.h"
#import "WKWebView+Swizzling.h"
#import "LLDebugTool.h"

static LLWebViewHelper *_instance = nil;

@implementation LLWebViewHelper

+ (instancetype)sharedHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLWebViewHelper alloc] init];
    });
    return _instance;
}


- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        if (enable) {
            NSLog(@"haleli >>> switch_webview : %@",@"开始") ;
            [[LLDebugTool sharedTool] saveWebViewSwitch:YES] ;
            static dispatch_once_t onceToken1;
            dispatch_once(&onceToken1, ^{
                Class class = [UIWebView class];
                
                SEL originalSelector = @selector(setDelegate:);
                SEL swizzledSelector = @selector(swizzledSetDelegate:);
                
                Method originalMethod = class_getInstanceMethod(class, originalSelector);
                Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
                method_exchangeImplementations(originalMethod, swizzledMethod);
                
            });
            
            static dispatch_once_t onceToken2;
            dispatch_once(&onceToken2, ^{
                Class class = [WKWebView class];
                
                SEL originalSelector = @selector(setNavigationDelegate:);
                SEL swizzledSelector = @selector(swizzledNavigationDelegate:);
                
                Method originalMethod = class_getInstanceMethod(class, originalSelector);
                Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
                method_exchangeImplementations(originalMethod, swizzledMethod);
            });
        } else {
            NSLog(@"haleli >>> switch_webview : %@",@"关闭") ;
            [[LLDebugTool sharedTool] saveWebViewSwitch:NO] ;
            NSLog(@"webview helper disabled") ;
        }
    }
}

@end
