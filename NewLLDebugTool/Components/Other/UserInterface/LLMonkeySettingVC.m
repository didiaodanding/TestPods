//
//  LLMonkeySettingVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/6/18.
//  Copyright © 2019 li. All rights reserved.
//
#import "LLConfig.h"
#import "LLBaseTableViewCell.h"
#import "LLMonkeySettingVC.h"
#import "LLMacros.h"
#import "LLMonkeyAlgorithmVC.h"
#import "LLMonkeyDateVC.h"
#import "UIColor+LL_Utils.h"
#import "ViewBoundConfig.h"
#import "LLDebugTool.h"
#import "KIF.h"
#import "Actions.h"
#import "LLIOSMonkeySettingHelper.h"
#import "LLCocosMonkeySettingHelper.h"
#import "LLMonkeySettingConfig.h"
#import "LLMonkeyListVC.h"
#import "LLMonkeyHelper.h"
#import "LLMonkeyScriptVC.h"

static NSString *const kLLMonkeySettingVCCellID = @"LLMonkeySettingVCCellID";
static NSString *const kLLMonkeySettingVCButtonCellID = @"LLMonkeySettingVCButtonCellID";
static NSString *const kLLMonkeySettingVCSwitchCellID = @"LLMonkeySettingVCSwitchCellID";
static NSString *const kLLMonkeySettingVCNoneCellID = @"LLMonkeySettingVCNoneCellID";
static NSString *const kLLMonkeySettingVCHeaderID = @"LLMonkeySettingVCHeaderID";
static NSString *const kLLMonkeySettingVCSpaceHeaderID = @"LLMonkeySettingVCSpaceHeaderID";


@interface LLMonkeySettingVC (){
}

@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation LLMonkeySettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = [self monkeyInfos];
    if([LLMonkeySettingConfig defaultConfig].monkeyType == IOSMonkeyType){
        self.navigationItem.title = @"IOS Monkey设置";
    }else{
        self.navigationItem.title = @"Cocos Monkey设置";
    }
    
    [self.tableView reloadData] ;
}

- (NSArray *)algorithmInfos {
    NSString *algorithm = nil ;
    if([LLMonkeySettingConfig defaultConfig].monkeyType == IOSMonkeyType){
        algorithm = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.algorithm ;
    }else{
        algorithm = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.algorithm ;
    }
    return @[@{@"算法" : algorithm}];
}

- (NSArray *)listInfos {
    return @[@{@"黑名单设置" : @""},
             @{@"白名单设置" : @""}];
    
}
- (NSArray *)timeInfos {
    NSString *date = nil ;
    if([LLMonkeySettingConfig defaultConfig].monkeyType == IOSMonkeyType){
        date = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.date ;
    }else{
        date = [LLCocosMonkeySettingHelper sharedHelper].monkeySettingModel.date ;
    }
    return @[@{@"运行时间设置" : date}];
}

- (NSArray *)coverageInfos {
    return @[@{@"覆盖率显示" : @""},
             @{@"点击控件显示" :@""}];
    
}

- (NSArray *)heartBeatReport{
    return @[@{@"心跳上报(仅限内部使用)":@""}] ;
}

- (NSArray *)scriptInfos{
    return @[@{@"脚本设置":@""}] ;
}

- (NSArray *)expectedInfos {
    return @[@{@"更多设置" : @""}];
}

- (NSArray *)monkeyButton {
    return @[@{@"Monkey一下" : @""}];
}

- (NSMutableArray <NSArray <NSDictionary *>*>*)monkeyInfos {
    
    //算法设置
    NSArray *algorithm = [self algorithmInfos];
    
    //黑白名单设置
    NSArray *list = [self listInfos];
    
    //执行时间
    NSArray *time = [self timeInfos] ;
    
    //心跳上报
    NSArray *heartBeatReport = [self heartBeatReport] ;
    
    //覆盖率
    NSArray *coverage = [self coverageInfos] ;
    
    //脚本设置
    NSArray *script = [self scriptInfos] ;
    
    // expected
    NSArray *expected = [self expectedInfos];
    
    //monkey button
    NSArray *monkeyButton = [self monkeyButton] ;
    
    return [[NSMutableArray alloc] initWithObjects:algorithm ,list, time, heartBeatReport,coverage,script,expected, monkeyButton,nil];
}

- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLMonkeySettingVCHeaderID];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLMonkeySettingVCSpaceHeaderID];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case 0:{
            //算法设置
            LLMonkeyAlgorithmVC* vc = [[LLMonkeyAlgorithmVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
            break ;
        }
        case 1:{
            //黑白名单功能
            if(indexPath.row == 0){
                //黑名单
                [LLMonkeySettingConfig defaultConfig].listType = BlackListType ;
                LLMonkeyListVC *vc = [[LLMonkeyListVC alloc] init] ;
                [self.navigationController pushViewController:vc animated:YES] ;
            }else if(indexPath.row==1){
                //白名单
                [LLMonkeySettingConfig defaultConfig].listType = WhiteListType ;
                LLMonkeyListVC *vc = [[LLMonkeyListVC alloc] init] ;
                [self.navigationController pushViewController:vc animated:YES] ;
                
            }
            break ;
        }
        case 2:{
            //执行时间
            LLMonkeyDateVC* vc = [[LLMonkeyDateVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
            break ;
        }
        case 3:
            //心跳上报
            break ;
        case 4:
            //覆盖率
            break ;
        case 5:{
            //脚本设置
            LLMonkeyScriptVC* vc = [[LLMonkeyScriptVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
            break ;
        }
        case 6:
            //敬请期待
            break ;
        case 7:{
            if([LLMonkeySettingConfig defaultConfig].monkeyType == IOSMonkeyType){
                //ios Monkey Button
                BOOL isOn = [[LLDebugTool sharedTool] iosMonkeySwitch] ;
                if(isOn){
                    [self stopIOSMonkey] ;
                }else{
                    [self startIOSMonkey] ;
                }
            }else{
                //coocs Monkey Button
                BOOL isOn = [[LLDebugTool sharedTool] cocosMonkeySwitch] ;
                if(isOn){
                    [self stopCocosMonkey] ;
                }else{
                    [self startCocosMonkey] ;
                }
            }
            break ;
        }
    }
    
}
-(LLBaseTableViewCell *)getSwithCell:(UITableView*) tableView switchTag:(NSInteger)tag switchOn:(BOOL)on{
    //switch cell
    UISwitch *myswitch = [[UISwitch alloc]init];
    myswitch.tag = tag ;
    [myswitch setOn:on] ;
    [myswitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    LLBaseTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:kLLMonkeySettingVCSwitchCellID];
    if (!switchCell) {
        switchCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLMonkeySettingVCSwitchCellID];
        switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    switchCell.accessoryView = myswitch ;
    return switchCell ;
}

-(LLBaseTableViewCell *)getButtonCell:(UITableView*)tableView{
    //button cell
    LLBaseTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:kLLMonkeySettingVCButtonCellID];
    if (!buttonCell) {
        buttonCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLMonkeySettingVCButtonCellID];
        buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        buttonCell.accessoryType = UITableViewCellAccessoryNone ;
        
    }
    buttonCell.textLabel.textAlignment = NSTextAlignmentCenter ;
    buttonCell.textLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    return buttonCell ;
}
-(LLBaseTableViewCell *)getNoneCell:(UITableView*)tableView{
    //None cell
    LLBaseTableViewCell *NoneCell = [tableView dequeueReusableCellWithIdentifier:kLLMonkeySettingVCNoneCellID];
    if (!NoneCell) {
        NoneCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLMonkeySettingVCButtonCellID];
        NoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NoneCell.accessoryType = UITableViewCellAccessoryNone ;
    }
    return NoneCell ;
}
-(LLBaseTableViewCell *)getTextCell:(UITableView*)tableView{
    //text cell
    LLBaseTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:kLLMonkeySettingVCCellID];
    if (!textCell) {
        textCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLLMonkeySettingVCCellID];
        textCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        textCell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        textCell.detailTextLabel.minimumScaleFactor = 0.5;
        textCell.selectionStyle = UITableViewCellSelectionStyleNone;
        textCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    }
    return textCell ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLBaseTableViewCell *cell = nil ;
   
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    switch(indexPath.section){
        case 0:
            //算法
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            cell.detailTextLabel.text = dic.allValues.firstObject;
            break ;
        case 1:
            //黑名单
            if(indexPath.row == 0){
                cell = [self getTextCell:tableView] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 1){
                //白名单
                cell = [self getTextCell:tableView] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
        case 2:
            //执行时间
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            cell.detailTextLabel.text = dic.allValues.firstObject ;
            break ;
        case 3:
            //心跳上报
            if([LLMonkeySettingConfig defaultConfig].monkeyType == IOSMonkeyType){
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagMonkeyHeartBeatReport switchOn: [[LLDebugTool sharedTool] monkeyHeartBeatReportSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else{
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagCocosMonkeyHeartBeatReport switchOn: [[LLDebugTool sharedTool] cocosMonkeyHeartBeatReportSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
        case 4:
            //覆盖率显示
            if(indexPath.row == 0){
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagCoverageText switchOn: [LLMonkeySettingConfig defaultConfig].coverageTextEnable] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row ==1){
                //点击控件显示
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagCoverageBound switchOn: [ViewBoundConfig defaultConfig].enable] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
        case 5:
            //脚本设置
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        case 6:
            //更多设置
            cell = [self getNoneCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        case 7:
            //monkey button
            cell = [self getButtonCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
    }
    return cell ;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(UITableViewHeaderFooterView*)getHeaderFooterView:(UITableView*)tableView{
     UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLMonkeySettingVCHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = [LLCONFIG_TEXT_COLOR colorWithAlphaComponent:0.2];
    }
    return view ;
}

-(UITableViewHeaderFooterView*)getHeaderFooterViewWithSpace:(UITableView*)tableView{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLMonkeySettingVCSpaceHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = LLCONFIG_BACKGROUND_COLOR;
    }
    return view ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = nil ;
    if (section == 0) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"算法设置";
    } else if (section == 1) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"黑白名单设置";
    }else if (section == 2){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"运行时间设置" ;
    }else if(section==3){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"心跳上报" ;
    }else if(section ==4){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"覆盖率设置" ;
    }else if(section == 5){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"脚本设置" ;
    }else if (section == 6) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"敬请期待";
    }else if(section == 7){
        view = [self getHeaderFooterViewWithSpace:tableView] ;
    }
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    if (![header.textLabel.textColor isEqual:LLCONFIG_TEXT_COLOR]) {
        header.textLabel.textColor = LLCONFIG_TEXT_COLOR;
    }
}

- (void)switchAction:(id)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    
    if(switchButton.tag == LLConfigSwitchTagCoverageText){
        [LLMonkeySettingConfig defaultConfig].coverageTextEnable = isButtonOn ;
    }else if(switchButton.tag == LLConfigSwitchTagCoverageBound){
        [ViewBoundConfig defaultConfig].enable = isButtonOn;
    }else if(switchButton.tag == LLConfigSwitchTagMonkeyHeartBeatReport){
        [[LLDebugTool sharedTool] saveMonkeyHeartBeatReportSwitch:isButtonOn] ;
    }else if(switchButton.tag == LLConfigSwitchTagCocosMonkeyHeartBeatReport){
        [[LLDebugTool sharedTool] saveCocosMonkeyHeartBeatReportSwitch:isButtonOn] ;
    }
}



-(void)startIOSMonkey{
    [[LLMonkeyHelper sharedHelper] startIOSMonkey] ;
}

-(void)stopIOSMonkey{
    [[LLMonkeyHelper sharedHelper] stopIOSMonkey] ;
}

-(void) startCocosMonkey{
    [[LLMonkeyHelper sharedHelper] startCocosMonkey] ;
}

-(void)stopCocosMonkey{
    [[LLMonkeyHelper sharedHelper] stopCocosMonkey] ;
}
@end
