//
//  LLWebViewContentDetailCell.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/8.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewContentDetailCell.h"

@interface LLWebViewContentDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation LLWebViewContentDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithTitle:(NSString *)title  date:(NSString*)date detail:(NSString*)detail{
   
    self.titleLabel.text = title;
    self.dateLabel.text = date;
    self.detailLabel.text = detail;
    
}

#pragma mark - Primary
- (void)initial {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
}

@end
