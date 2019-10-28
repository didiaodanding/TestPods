//
//  LLWebViewCell.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBaseTableViewCell.h"
#import "LLWebViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLWebViewCell : LLBaseTableViewCell

- (void)confirmWithModel:(LLWebViewModel *_Nonnull)model;


@end

NS_ASSUME_NONNULL_END
