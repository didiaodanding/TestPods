//
//  LLANRCell.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBaseTableViewCell.h"
#import "LLANRModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLANRCell : LLBaseTableViewCell

@property (weak, nonatomic,readonly,nullable) IBOutlet UILabel *reasonLabel;

- (void)confirmWithModel:(LLANRModel *_Nonnull) model ;

@end

NS_ASSUME_NONNULL_END
