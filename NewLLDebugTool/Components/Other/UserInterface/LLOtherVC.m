//
//  LLOtherVC.m
//  LLDebugToolDemo
//
//  Created by haleli on 2019/2/15.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLOtherVC.h"
#import "LLBaseTableViewCell.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLDebugTool.h"
#import "ZSFakeTouch.h"
#import "FindElementTree.h"
#import "LLMonkeySettingVC.h"
#import "LLMonkeySettingConfig.h"
#import "LLNetworkHelper.h"
#import "OHHTTPStubs.h"
#import "LLBugReportSettingVC.h"
#import "LLMockHelper.h"
#import "LLANRHelper.h"
#import "LLCrashMachHelper.h"
#import "LLCrashSignalHelper.h"
#import "LLCrashNSExceptionHelper.h"
#import "LLCrashCPPExceptionHelper.h"
#import "LLFpsOscillogramWindow.h"
#import "LLCocosFpsOscillogramWindow.h"
#import "LLWebViewHelper.h"
//#ifdef ISLOCAL
//#import "LLDebugToolDemo-Swift.h"
//#else
////#import "NewLLDebugTool-Swift.h"
//#import "NewLLDebugTool/NewLLDebugTool-Swift.h"
//#endif

static NSString *const kLLOtherVCCellID = @"LLOtherVCCellID";
static NSString *const kLLOtherVCSwitchCellID = @"LLOtherVCSwitchCellID";
static NSString *const kLLOtherVCNoneCellID = @"LLOtherVCNoneCellID";
static NSString *const kLLOtherVCLogCellID = @"LLOtherVCLogCellID";
static NSString *const kLLOtherVCHeaderID = @"LLOtherHeaderID";
@interface LLOtherVC (){
    Byte  *_addMemory;
}

@property (nonatomic , strong) NSMutableArray *dataArray;
@end



@implementation LLOtherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = [self otherInfos];
    self.navigationItem.title = @"更多功能";
}

- (NSArray *)monitorInfos{
    return @[@{@"ANR监控开关":@""},
             @{@"WebView监控开关":@""},
             @{@"Signal Crash监控开关":@""},
             @{@"NSException Crash监控开关":@""},
             @{@"Mach Crash监控开关":@""},
             @{@"Cpp Crash监控开关":@""}] ;
}

- (NSArray *)mockInfos {
    return @[@{@"mock开关" : @""}];
}

- (NSArray *)lowResourcesInfos {
    return @[@{@"网络延时开关(默认2s)" :  @""},
             @{@"低内存开关" : @""}];
}

- (NSArray *)privateNetworkInfos {
    return @[@{@"网络显示开关" : @""}];
}

- (NSArray *)commonToolsInfos {
    return @[@{@"日志上传" : @""}];
}

- (NSArray *)bugReportInfos {
    return @[@{@"提单功能(仅限内部使用)" : @""}];
}

- (NSArray *)performanceCurves{
    return @[@{@"fps曲线显示":@""},
             @{@"cocos fps曲线显示(仅限内部使用)":@""}] ;
}

- (NSArray *)expectedInfos {
    return @[@{@"更多功能" : @""}];
}


- (NSMutableArray <NSArray <NSDictionary *>*>*)otherInfos {
    
    //监控功能
    NSArray *monitor = [self monitorInfos] ;
    
    //mock功能
    NSArray *mock = [self mockInfos];
    
    // low resource
    NSArray *lowResources = [self lowResourcesInfos];
    
    //private network
    NSArray *privateNetwork = [self privateNetworkInfos] ;
    
    //common tools
    NSArray *commonTools = [self commonToolsInfos] ;
    
    //bug report
    NSArray *bugReport = [self bugReportInfos] ;
    
    //performance curve
    NSArray *performanceCurve = [self performanceCurves] ;
    
    // expected
    NSArray *expected = [self expectedInfos];
    
    return [[NSMutableArray alloc] initWithObjects:monitor ,mock ,lowResources, privateNetwork,commonTools,bugReport , performanceCurve ,expected, nil];
}



- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLOtherVCHeaderID];
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
            //监控功能
            break ;
        }
        
        case 1:{
            //随机mock功能
            break ;
        }
        case 2:{
            //低资源模拟功能
            break ;
        }
        case 3:{
            //私有包显示功能
            break ;
        }
        case 4:{
            //常用工具
            if(indexPath.row == 0){
                //日志上传
                if([LLDebugTool sharedTool].uploadLog){
                    [self showAlertControllerWithMessage:@"Sure to upload log ?" handler:^(NSInteger action) {
                        if (action == 1) {
                            [LLDebugTool sharedTool].uploadLog() ;
                        }
                    }];
                    
                }
            }
            break ;
        }
        case 5:{
            //提单功能
            LLBugReportSettingVC *vc = [[LLBugReportSettingVC alloc] initWithStyle:UITableViewStylePlain] ;
            [self.navigationController pushViewController:vc animated:YES] ;
            break ;
        }
        case 6:{
            //性能曲线
            break ;
        }
        case 7:{
            //敬请期待
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
    LLBaseTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:kLLOtherVCSwitchCellID];
    if (!switchCell) {
        switchCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLOtherVCSwitchCellID];
        switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switchCell.accessoryView = myswitch ;
    return switchCell ;
}

-(LLBaseTableViewCell *)getTextCell:(UITableView*)tableView{
    //text cell
    LLBaseTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:kLLOtherVCCellID];
    if (!textCell) {
        textCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLLOtherVCCellID];
        textCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        textCell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        textCell.detailTextLabel.minimumScaleFactor = 0.5;
        textCell.selectionStyle = UITableViewCellSelectionStyleNone;
        textCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    }
    return textCell ;
}

-(LLBaseTableViewCell *)getNoneCell:(UITableView*)tableView{
    //None cell
    LLBaseTableViewCell *NoneCell = [tableView dequeueReusableCellWithIdentifier:kLLOtherVCNoneCellID];
    if (!NoneCell) {
        NoneCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLOtherVCNoneCellID];
        NoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NoneCell.accessoryType = UITableViewCellAccessoryNone ;
    }
    return NoneCell ;
}

-(LLBaseTableViewCell *)getLogCell:(UITableView*)tableView{
    //Log cell
    LLBaseTableViewCell *LogCell = [tableView dequeueReusableCellWithIdentifier:kLLOtherVCLogCellID];
    if (!LogCell) {
        LogCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLOtherVCLogCellID];
        LogCell.selectionStyle = UITableViewCellSelectionStyleNone;
        LogCell.accessoryType = UITableViewCellAccessoryNone ;
        LogCell.textLabel.textColor = [[UIView alloc] init].tintColor ;
    }
    return LogCell ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LLBaseTableViewCell *cell = nil ;
    
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    
    switch (indexPath.section) {
        case 0:{
            //ANR 监控开关
            if(indexPath.row == 0){
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagANRMonior switchOn: [[LLDebugTool sharedTool] anrSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 1){
                //WebView监控开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagWebViewMonitor switchOn:[[LLDebugTool sharedTool] webViewSwitch]];
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 2){
                //Signal Crash监控开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagSignalCrashMonitor switchOn:[[LLDebugTool sharedTool] signalCrashSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 3){
                //NSException Crash监控开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagNSExceptionMonitor switchOn:[[LLDebugTool sharedTool] exceptionCrashSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 4){
                //Mach Crash监控开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagMachCrashMonitor switchOn:[[LLDebugTool sharedTool] machCrashSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 5){
                //Cpp crash监控开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagCPPExceptionMonitor switchOn:[[LLDebugTool sharedTool] cppExceptionCrashSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
        }
        case 1:{
            //mock 开关
            cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagMock switchOn: [[LLDebugTool sharedTool] mockSwitch] ];
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        }
        case 2:{
            //弱网开关
            if(indexPath.row == 0){
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagLowNetwork switchOn: [[LLDebugTool sharedTool] lowNetworkSwitch] ];
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 1){
                //低内存开关
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagLowMemory switchOn:[[LLDebugTool sharedTool] lowMemorySwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
            
        }
        case 3:{
            //私有包显示开关
            cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagPrivateNetwork switchOn:[[LLDebugTool sharedTool] privateNetworkSwitch]] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        }
        case 4:{
            //日志上传
            cell = [self getLogCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        }
        case 5:{
            //提单配置
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        }
        case 6:{
            //fps曲线
            if(indexPath.row==0){
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagFpsPerformanceCurve switchOn:[[LLDebugTool sharedTool] fpsPerformanceCurveSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }else if(indexPath.row == 1){
                //cocos fps曲线
                cell = [self getSwithCell:tableView switchTag:LLConfigSwitchTagCocosFpsPerformanceCurve switchOn:[[LLDebugTool sharedTool] cocosFpsPerformanceCurveSwitch]] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
            }
            break ;
        }
        case 7:{
            //更多功能
            cell = [self getNoneCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        }

    }
    return cell;
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
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLOtherVCHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = [LLCONFIG_TEXT_COLOR colorWithAlphaComponent:0.2];
    }
    return view ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = nil ;
    if (section == 0){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"监控功能" ;
    }if (section == 1) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"随机mock功能";
    } else if (section == 2) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"低资源模拟功能";
    }else if(section == 3){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"网络显示功能" ;
    }else if(section == 4){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"常用工具" ;
    }else if(section == 5){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"提单功能" ;
    }else if(section == 6){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"性能曲线" ;
    }else if (section == 7) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"敬请期待";
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
    if(switchButton.tag == LLConfigSwitchTagANRMonior){
        if(isButtonOn){
            [[LLANRHelper sharedHelper] setEnable:true] ;
        }else{
            [[LLANRHelper sharedHelper] setEnable:false] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagWebViewMonitor){
        if(isButtonOn){
            [[LLWebViewHelper sharedHelper] setEnable:YES] ;
        }else{
            [[LLWebViewHelper sharedHelper] setEnable:NO] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagSignalCrashMonitor){
        if(isButtonOn){
            [[LLCrashSignalHelper sharedHelper] setEnable:true] ;
        }else{
            [[LLCrashSignalHelper sharedHelper] setEnable:false] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagNSExceptionMonitor){
        if(isButtonOn){
            [[LLCrashNSExceptionHelper sharedHelper] setEnable:true] ;
        }else{
            [[LLCrashNSExceptionHelper sharedHelper] setEnable:false] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagMachCrashMonitor){
        if(isButtonOn){
            [[LLCrashMachHelper sharedHelper] setEnable:true] ;
        }else{
            [[LLCrashMachHelper sharedHelper] setEnable:false] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagCPPExceptionMonitor){
        if(isButtonOn){
            [[LLCrashCPPExceptionHelper sharedHelper] setEnable:true] ;
        }else{
            [[LLCrashCPPExceptionHelper sharedHelper] setEnable:false] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagMock){
        if(isButtonOn){
            [[LLMockHelper sharedHelper] startMock] ;
        }else{
            [[LLMockHelper sharedHelper] stopMock] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagLowNetwork){
        [[LLDebugTool sharedTool] saveLowNetworkSwitch:isButtonOn];
    }else if(switchButton.tag == LLConfigSwitchTagLowMemory){
        [[LLDebugTool sharedTool] saveLowMemorySwitch:isButtonOn];
        if(isButtonOn){
            if ([LLDebugTool sharedTool].memoryThread == nil){
                [LLDebugTool sharedTool].memoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(highMemoryOperate) object:nil];
                [LLDebugTool sharedTool].memoryThread.name = @"HighMemoryThread";
                NSLog(@"haleli >>> switch_low_memoryk : %@",@"开始") ;
                [[LLDebugTool sharedTool].memoryThread  start];
            }
        
        }else{
            if([LLDebugTool sharedTool].memoryThread != nil){
                NSLog(@"haleli >>> switch_low_memoryk : %@",@"关闭") ;
                [[LLDebugTool sharedTool].memoryThread  cancel];
                [LLDebugTool sharedTool].memoryThread  = nil;
            }
        }
    }else if(switchButton.tag == LLConfigSwitchTagPrivateNetwork){
        [[LLDebugTool sharedTool] savePrivateNetworkSwitch:isButtonOn];
        [[LLNetworkHelper sharedHelper] setEnable:isButtonOn];
    }else if(switchButton.tag == LLConfigSwitchTagFpsPerformanceCurve){
        [[LLDebugTool sharedTool] saveFpsPerformanceCurveSwitch:isButtonOn] ;
        if(isButtonOn){
            [[LLFpsOscillogramWindow shareInstance] show] ;
        }else{
            [[LLFpsOscillogramWindow shareInstance] hide] ;
        }
    }else if(switchButton.tag == LLConfigSwitchTagCocosFpsPerformanceCurve){
        [[LLDebugTool sharedTool] saveCocosFpsPerformanceCurveSwitch:isButtonOn] ;
        if(isButtonOn){
            [[LLCocosFpsOscillogramWindow shareInstance] show] ;
        }else{
            [[LLCocosFpsOscillogramWindow shareInstance] hide] ;
        }
    }
}

- (void)highMemoryOperate{
    //点击按钮，如果未释放，则释放
    @synchronized (self) {
        if (_addMemory) {
            NSLog(@"free memory") ;
            free(_addMemory);
            _addMemory = nil;
            
        }
    }
    int addedMemSize = 0;
    int interval = 2;
    BOOL needAddMem = TRUE ;
    
    while (TRUE) {
        if(needAddMem){
            addedMemSize = addedMemSize + 400 ;
        }
        
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        
        @synchronized (self) {
            if (!_addMemory) {
                _addMemory = malloc(1024*1024*addedMemSize);
                if (_addMemory) {
                    memset(_addMemory, 0, 1024*1024*addedMemSize);
                    NSLog(@"haleli >>> add memory :%d",addedMemSize) ;
                }else{
                    addedMemSize = addedMemSize - 400 ;
                    needAddMem = FALSE ;
                    NSLog(@"add mem failed!");
                }
                
            }
        }
        
        [NSThread sleepForTimeInterval:interval];
            
        @synchronized (self) {
            if (_addMemory) {
                NSLog(@"haleli >>> free memory : %d",addedMemSize) ;
                free(_addMemory);
                _addMemory = nil;
                
            }
        }
            
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        
        
        
        [NSThread sleepForTimeInterval:interval];
    }
}

@end
