//
//  CCMonkeyHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/18.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCMonkeyHelper : NSObject

/**
 @return Singleton
 **/
+(instancetype _Nonnull) sharedHelper ;

-(NSDictionary *)dumpVisibleAndTouchableNode ;

@end

NS_ASSUME_NONNULL_END
