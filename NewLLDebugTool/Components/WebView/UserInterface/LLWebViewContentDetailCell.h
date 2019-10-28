//
//  LLWebViewContentDetailCell.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/8.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLWebViewContentDetailCell : LLBaseTableViewCell

- (void)confirmWithTitle:(NSString *)title  date:(NSString*)date detail:(NSString*)detail;

@end

NS_ASSUME_NONNULL_END
