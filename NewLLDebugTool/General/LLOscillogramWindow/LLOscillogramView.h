//
//  LLOscillogramView.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/15.
//  Copyright © 2019 li. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLPoint : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

@end

@interface LLOscillogramView : UIScrollView

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) NSInteger numberOfPoints;

- (void)addHeightValue:(CGFloat)showHeight andTipValue:(NSString *)tipValue;

- (void)setLowValue:(NSString *)value;

- (void)setHightValue:(NSString *)value;

- (void)clear;



@end

NS_ASSUME_NONNULL_END
