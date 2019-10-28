//
//  LLCocosFpsOscillogramViewController.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/16.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLOscillogramViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLCocosFpsOscillogramViewController : LLOscillogramViewController

/**
 title
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 chart
 */
@property (nonatomic, strong) LLOscillogramView *oscillogramView;

/**
 close button
 */
@property (nonatomic, strong) UIButton *closeBtn;

@end

NS_ASSUME_NONNULL_END
