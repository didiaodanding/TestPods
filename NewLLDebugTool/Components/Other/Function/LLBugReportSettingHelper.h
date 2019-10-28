//
//  LLBugReportSettingHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/3.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLBugReportSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLBugReportSettingHelper : NSObject

@property (nonatomic , strong , nullable) LLBugReportSettingModel *bugReportSettingModel;

/**
 Singleton to control enable.
 
 @return Singleton
 */
+ (instancetype _Nonnull)sharedHelper;

/**
 update workspace_id
 */
-(BOOL)setWorkspaceID:(NSString *)workspaceId ;

/**
 update crash owner
 */
-(BOOL)setCrashOwner:(NSString *)crashOwner ;

/**
 update JSException owner
 */
-(BOOL)setJSExceptionOwner:(NSString*)JSExceptionOwner ;

/**
 update version
 */
-(BOOL)setVersion:(NSString *)version ;

/**
 update creator
 */
-(BOOL)setCreator:(NSString *)creator ;

@end

NS_ASSUME_NONNULL_END
