//
//  WKWebViewVC.m
//  LLDebugToolDemo
//
//  Created by haleli on 2019/4/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "WKWebViewVC.h"
#import <WebKit/WebKit.h>

@interface WKWebViewVC ()

@end

@implementation WKWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO ;
    self.title = @"WKWebView";
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:webView];
}

@end
