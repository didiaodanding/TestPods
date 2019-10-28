//
//  CoverageOscillogramViewController.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/6/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "CoverageOscillogramViewController.h"
#import "App.h"
#import "LLMacros.h"

@interface CoverageOscillogramViewController ()

@end

@implementation CoverageOscillogramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = [self title];
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:kLLSizeFrom750_Landscape(50)];
    _titleLabel.textColor = [UIColor yellowColor];
    [self.view addSubview:_titleLabel];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(kLLSizeFrom750_Landscape(20), kLLSizeFrom750_Landscape(10), LL_SCREEN_WIDTH, _titleLabel.frame.size.height);
}

- (NSString *)title{
    return @"当前界面控件覆盖率：\nApp控件覆盖率：";
}

- (void)drawTitleViewWithValue:(NSString *)title{
    _titleLabel.text = title ;
}

//每一秒钟采样一次控件覆盖率
- (void)doSecondFunction{
    CGFloat appCoverage = [[App sharedApp] getCoverage];
    CGFloat treeCoverage = 0.0;
    UIViewController *controller = [FindTopController topController] ;
    NSString * treeId = NSStringFromClass([controller class]) ;
    Tree* tree = [[App sharedApp] getTree:treeId] ;
    if(tree){
        treeCoverage = [tree getCoverage] ;
    }
    NSString *title = [NSString stringWithFormat:@"当前界面控件覆盖率：%.2f%%\nApp控件覆盖率：%.2f%%",treeCoverage,appCoverage];
    [self drawTitleViewWithValue:title] ;
}
@end
