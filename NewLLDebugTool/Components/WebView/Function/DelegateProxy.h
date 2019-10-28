//
//  DelegateProxy.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/27.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DelegateProxy : NSProxy

@property (nonatomic, weak) id target;

- (instancetype)initWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
