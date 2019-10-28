//
//  LLCocosFpsOscillogramViewController.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/16.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCocosFpsOscillogramViewController.h"
#import "LLMacros.h"
#import "LLImageNameConfig.h"
#import "LLDebugTool.h"
#import "LLCocosFpsOscillogramWindow.h"
#import "LLCocosHelper.h"

@interface LLCocosFpsOscillogramViewController ()

@end

@implementation LLCocosFpsOscillogramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = [self title];
    _titleLabel.font = [UIFont systemFontOfSize:kLLSizeFrom750_Landscape(20)];
    _titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_titleLabel];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(kLLSizeFrom750_Landscape(20), kLLSizeFrom750_Landscape(10), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[[UIImage LL_imageNamed:kCloseImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _closeBtn.frame = CGRectMake((kInterfaceOrientationPortrait ? LL_SCREEN_WIDTH :  MAX(LL_SCREEN_HEIGHT,LL_SCREEN_WIDTH))-kLLSizeFrom750_Landscape(60), 0, kLLSizeFrom750_Landscape(60), kLLSizeFrom750_Landscape(60));
    [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    
    _oscillogramView = [[LLOscillogramView alloc] initWithFrame:CGRectMake(0, (_titleLabel.frame.origin.y+_titleLabel.frame.size.height)+kLLSizeFrom750_Landscape(12), (kInterfaceOrientationPortrait ? LL_SCREEN_WIDTH :  MAX(LL_SCREEN_HEIGHT,LL_SCREEN_WIDTH)), kLLSizeFrom750_Landscape(184))];
    _oscillogramView.backgroundColor = [UIColor clearColor];
    [_oscillogramView setLowValue:[self lowValue]];
    [_oscillogramView setHightValue:[self highValue]];
    [self.view addSubview:_oscillogramView];
}

- (NSString *)title{
    return @"cocos fps检测";
}

- (NSString *)lowValue{
    return @"0";
}

- (NSString *)highValue{
    return @"60";
}


- (void)closeBtnClick{
    [[LLDebugTool sharedTool] saveCocosFpsPerformanceCurveSwitch:NO] ;
    [[LLCocosFpsOscillogramWindow shareInstance] hide];
}

- (void)startRecord{
    
}

- (void)endRecord{
    [self.oscillogramView clear];
}

- (void)doSecondFunction{
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerLLAppHelperNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLLAppHelperNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - LLAppHelperNotification
- (void)registerLLAppHelperNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLLCocosHelperDidUpdateAppInfosNotification:) name:LLCocosHelperDidUpdateAppInfosNotificationName object:nil];
}

- (void)unregisterLLAppHelperNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LLCocosHelperDidUpdateAppInfosNotificationName object:nil];
}


#pragma mark - LLAppHelperNotification
- (void)didReceiveLLCocosHelperDidUpdateAppInfosNotification:(NSNotification *)notifi {
    NSDictionary *userInfo = notifi.userInfo;
    long fps = (long)[userInfo[LLCocosHelperFPSKey] floatValue];
    
    // 0~60  对应 高度0~_self.oscillogramView.frame.size.height
    NSLog(@"haleli >>> cocos fps : %ld",fps) ;
    [self.oscillogramView addHeightValue:fps*self.oscillogramView.frame.size.height/60. andTipValue:[NSString stringWithFormat:@"%ld",fps]];
    
}

@end
