//
//  LLMonkeyScriptCell.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLMonkeyScriptCell.h"

@interface LLMonkeyScriptCell ()

@property (weak, nonatomic) IBOutlet UILabel *controllerTitleLabel;


@property (weak, nonatomic) IBOutlet UILabel *controllerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scriptNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scriptTitleLabel;



@end

@implementation LLMonkeyScriptCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
   
}
- (void)confirmWithControllerTitle:(NSString *)controllerTitle  controllerName:(NSString*)controllerName scriptTitle:(NSString*)scriptTitle scriptName:(NSString*)scriptName{
    self.controllerTitleLabel.text = controllerTitle ;
    self.controllerNameLabel.text = controllerName ;
    self.scriptTitleLabel.text = scriptTitle ;
    self.scriptNameLabel.text = scriptName ;
}

#pragma mark - Primary
- (void)initial {
    self.controllerTitleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.controllerTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.scriptTitleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.scriptTitleLabel.adjustsFontSizeToFitWidth = YES ;
}
@end
