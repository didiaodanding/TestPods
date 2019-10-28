//
//  LLWebViewHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLWebViewHelper : NSObject

/**
 Singleton to control enable.
 
 @return Singleton
 */
+ (instancetype _Nonnull)sharedHelper;


/**
 Set enable to monitoring webview request.
 */
@property (nonatomic , assign , getter=isEnabled) BOOL enable;

@end

NS_ASSUME_NONNULL_END
