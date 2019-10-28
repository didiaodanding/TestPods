//
//  LLFileLogger.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/6.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLFileLogger : NSObject
+(LLFileLogger*)getInstance;
-(void)addLog:(NSString*)log;
-(void)flushLog;
-(NSData*)getLogWithBeginDate:(NSString*)beginDateStr beginHour:(int)beginhour beginMin:(int)beginmin endDateStr:(NSString*)endDateStr endHour:(int)endhour endMin:(int)endmin size:(unsigned int)size;
+(unsigned int)getTimestampWithDateStr:(NSString*)dateStr hour:(int)hour min:(int)min sec:(int)sec;
@end

NS_ASSUME_NONNULL_END
