//
//  UIWebViewVC.m
//  LLDebugToolDemo
//
//  Created by haleli on 2019/4/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "UIWebViewVC.h"

@interface UIWebViewVC ()

@end

@implementation UIWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO ;
    self.title = @"UIWebView";
    UIWebView * view = [[UIWebView alloc] initWithFrame:self.view.frame];
    [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:view];
}


@end
