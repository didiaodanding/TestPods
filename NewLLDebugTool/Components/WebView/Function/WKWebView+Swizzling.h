//
//  WKWebView+Swizzling.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (Swizzling)

- (void)swizzledNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate ;

@end

NS_ASSUME_NONNULL_END
