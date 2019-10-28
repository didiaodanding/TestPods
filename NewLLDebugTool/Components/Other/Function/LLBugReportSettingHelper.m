//
//  LLBugReportSettingHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/3.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBugReportSettingHelper.h"
#import "LLConfig.h"
#import "LLStorageManager.h"

static LLBugReportSettingHelper *_instance = nil;

@implementation LLBugReportSettingHelper

+ (instancetype _Nonnull)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLBugReportSettingHelper alloc] init];
        [_instance initial];
    });
    return _instance;
}

/**
 Initial something.
 */
- (void)initial {
    __weak typeof(self) weakSelf = self;
    _bugReportSettingModel = [[LLBugReportSettingModel alloc] initWithIdentity:kBugReportIdentity] ;
    [[LLStorageManager sharedManager] getModels:[LLBugReportSettingModel class] launchDate:@"" storageIdentity:_bugReportSettingModel.storageIdentity complete:^(NSArray<LLBugReportSettingModel *> *result) {
        if(result.count==0){
            [[LLStorageManager sharedManager] saveModel:weakSelf.bugReportSettingModel complete:nil];
        }else{
            weakSelf.bugReportSettingModel = [result objectAtIndex:0] ;
        }
    } synchronous:YES];
}

- (BOOL)update{
    __block BOOL flag = false ;
    [[LLStorageManager sharedManager] updateModel:_bugReportSettingModel complete:^(BOOL result) {
        flag = result ;
    } synchronous:YES];
    return flag ;
}

-(BOOL)setWorkspaceID:(NSString *)workspaceId{
    _bugReportSettingModel.workspaceId = workspaceId ;
    return [self update] ;
}

-(BOOL)setCrashOwner:(NSString *)crashOwner{
    _bugReportSettingModel.crashOwner = crashOwner ;
    return [self update] ;
}

-(BOOL)setJSExceptionOwner:(NSString*)JSExceptionOwner{
    _bugReportSettingModel.JSExceptionOwner = JSExceptionOwner ;
    return [self update] ;
}

-(BOOL)setVersion:(NSString *)version{
    _bugReportSettingModel.version = version ;
    return [self update] ;
}

-(BOOL)setCreator:(NSString *)creator{
    _bugReportSettingModel.creator = creator ;
    return [self update] ;
}

@end
