//
//  LLMonkeyReportHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/14.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLMonkeyReportHelper : NSObject
/**
 monkey codeID for verify interface
 */
- (NSString*_Nullable) codeID ;

/**
monkey taskID
 */
- (NSString*_Nullable) taskID ;

/**
 monkey taskName
 */
- (NSString *_Nullable) taskName ;

/**
 monkey heart beat
 */
- (BOOL) heartBeatReport:(NSString *)status ;
/**
 Singleton to control report.
 
 @return Singleton
 */
+(instancetype _Nonnull)sharedHelper;

@end

NS_ASSUME_NONNULL_END
