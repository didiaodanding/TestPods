//
//  WKWebViewDelegateVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import "WKWebViewDelegateVC.h"
#import <WebKit/WebKit.h>

@interface WKWebViewDelegateVC()<WKNavigationDelegate>

@end


@implementation WKWebViewDelegateVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO ;
    self.title = @"WKWebView";
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.view.frame];
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:webView];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    self.title = @"wkwebview loading";
    NSLog(@"%@",@"wkwebview loading") ;
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.title = @"wkwebview finish";
    NSLog(@"%@",@"wkwebview finish") ;
    
}
@end
