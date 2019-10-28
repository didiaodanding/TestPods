//
//  UIWebView+Swizzling.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/27.
//  Copyright © 2019 li. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (Swizzling)

- (void)swizzledSetDelegate:(id<UIWebViewDelegate>)delegate ;

@end

NS_ASSUME_NONNULL_END
