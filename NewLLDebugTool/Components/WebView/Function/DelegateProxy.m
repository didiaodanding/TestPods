//
//  DelegateProxy.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/27.
//  Copyright © 2019 li. All rights reserved.
//

#import "DelegateProxy.h"

@implementation DelegateProxy

- (instancetype)initWithTarget:(id)target
{
    self.target = target;
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.target respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    if (!self.target) {
        return [NSMethodSignature signatureWithObjCTypes:"v@"];
    }
    return [self.target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (!self.target) {
        return;
    }
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}


@end
