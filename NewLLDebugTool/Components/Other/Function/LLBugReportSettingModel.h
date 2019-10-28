//
//  LLBugReportSettingModel.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/3.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLStorageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLBugReportSettingModel : LLStorageModel

/**
 * workspace_id
 */
@property (copy , nonatomic  , nonnull) NSString *workspaceId;

/**
 * crash owner
 */
@property (copy , nonatomic  , nonnull) NSString *crashOwner;

/**
 * js exception owner
 */
@property (copy , nonatomic  , nonnull) NSString *JSExceptionOwner;

/**
 * version
 */
@property (copy , nonatomic  , nonnull) NSString *version;

/**
 * creator
 */
@property (copy , nonatomic  , nonnull) NSString *creator;

/**
 Model identity.
 */
@property (nonatomic , copy , readonly , nonnull) NSString *identity;

- (instancetype _Nonnull)initWithIdentity:(NSString *_Nullable)identity ;

@end

NS_ASSUME_NONNULL_END
