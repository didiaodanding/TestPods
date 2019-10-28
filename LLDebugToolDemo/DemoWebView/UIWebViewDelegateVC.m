//
//  UIWebViewDelegateVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/28.
//  Copyright © 2019 li. All rights reserved.
//

#import "UIWebViewDelegateVC.h"

@interface UIWebViewDelegateVC ()<UIWebViewDelegate>

@end

@implementation UIWebViewDelegateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO ;
    self.title = @"UIWebView";
    UIWebView * view = [[UIWebView alloc] initWithFrame:self.view.frame];
    view.delegate =self;
    [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:view];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.title = @"uiwebview loading";
    NSLog(@"%@",@"uiwebview loading") ;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = @"uiwebview finish";
    NSLog(@"%@",@"uiwebview finish") ;
    
}

@end
