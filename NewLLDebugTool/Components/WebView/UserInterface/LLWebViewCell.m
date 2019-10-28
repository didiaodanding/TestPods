//
//  LLWebViewCell.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewCell.h"

@interface LLWebViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *paramLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong , nonatomic) LLWebViewModel *model;
@end

@implementation LLWebViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLWebViewModel *)model {
    if (_model != model) {
        _model = model;
        self.hostLabel.text = _model.url.host;
        self.paramLabel.text = _model.url.path;
        self.dateLabel.text = [_model.startDate substringFromIndex:11];
    }
}

#pragma mark - Primary
- (void)initial {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.hostLabel.font = [UIFont boldSystemFontOfSize:19];
    self.hostLabel.adjustsFontSizeToFitWidth = YES;
}

@end
