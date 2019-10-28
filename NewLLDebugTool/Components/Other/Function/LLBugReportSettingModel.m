//
//  LLBugReportSettingModel.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/3.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBugReportSettingModel.h"

@implementation LLBugReportSettingModel

- (instancetype _Nonnull)initWithIdentity:(NSString *_Nullable)identity{
    if (self = [super init]) {
        _identity = identity;
        _workspaceId = @"" ;
        _crashOwner = @"" ;
        _JSExceptionOwner = @"" ;
        _version = @"" ;
        _creator = @"" ;
    }
    return self;
}

- (NSString *)storageIdentity {
    return self.identity;
}

@end
