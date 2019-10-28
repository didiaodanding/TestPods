//
//  UICollectionViewActions.h
//  LLDebugToolDemo
//
//  Created by haleli on 2019/4/16.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIF.h"
NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewActions : NSObject
+(void)swipeCollectionViewWithAccessibilityIdentifier:(NSString *)identifier;
+(void)tapItemAtIndexPathWithAccessibilityIdentifier:(NSString *)identifier ;
@end

NS_ASSUME_NONNULL_END
