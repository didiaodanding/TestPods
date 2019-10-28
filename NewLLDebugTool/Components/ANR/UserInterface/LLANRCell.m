//
//  LLANRCell.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLANRCell.h"

@interface LLANRCell()
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) LLANRModel *model ;

@end

@implementation LLANRCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial] ;
}

-(void)confirmWithModel:(LLANRModel *)model{
    _model = model ;
    _nameLabel.text = model.name ;
    _reasonLabel.text = model.reason ;
    _dateLabel.text = [NSString stringWithFormat:@"[ %@ ]",model.date] ;
}

#pragma mark - Primary
-(void)initial{
    self.reasonLabel.font = [UIFont boldSystemFontOfSize:17] ;
}

@end
