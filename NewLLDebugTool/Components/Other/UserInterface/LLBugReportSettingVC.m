//
//  LLBugReportSettingVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/7/31.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBugReportSettingVC.h"
#import "LLBaseTableViewCell.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLBugReportSettingHelper.h"
#import "LLTool.h"
#import "LLDebugTool.h"

static NSString *const kLLBugReportSettingVCCellID = @"LLBugReportSettingVCCellID";
static NSString *const kLLBugReportSettingVCButtonCellID = @"LLBugReportSettingVCButtonCellID";
static NSString *const kLLBugReportSettingVCNoneCellID = @"LLBugReportSettingVCNoneCellID";
static NSString *const kLLBugReportSettingVCHeaderID = @"LLBugReportSettingVCHeaderID";
static NSString *const kLLBugReportSettingVCSpaceHeaderID = @"LLBugReportSettingVCSpaceHeaderID";

/**
 field type
 **/
typedef NS_ENUM(NSUInteger, LLFieldType) {
    WORKSPACEID = 5 ,
    CRASHOWNER = 4,
    JSEXCEPTIONOWNER= 3,
    VERSION = 2 ,
    CREATOR = 1,
};

@interface LLBugReportSettingVC ()

@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation LLBugReportSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = [self bugReportInfos];
    self.navigationItem.title = @"提单设置";
    
    [self.tableView reloadData] ;
}

- (NSArray *)workspaceIdInfos {
    NSString *workspaceId = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.workspaceId ;
    return @[@{@"workspace_id" : workspaceId}];
}

- (NSArray *)ownerInfos {
    NSString *crashOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.crashOwner ;
    NSString *JSExceptionOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.JSExceptionOwner ;
    return @[@{@"Crash Owner" : crashOwner},
             @{@"JS Exception Owner" : JSExceptionOwner}];
    
}
- (NSArray *)versionInfos{
    NSString *version = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.version;
    return @[@{@"version" : version}];
}

- (NSArray *)creatorInfos{
    NSString *creator = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.creator;
    return @[@{@"creator" : creator}];
}

- (NSArray *)expectedInfos {
    return @[@{@"更多设置" : @""}];
}

- (NSArray *)bugReportButton {
    NSString *info = nil ;
    if([[LLDebugTool sharedTool] bugReportSwitch]){
        info = @"关闭提单功能" ;
    }else{
        info = @"开启提单功能" ;
    }
    return @[@{info : @""}];
}

- (NSMutableArray <NSArray <NSDictionary *>*>*)bugReportInfos {
    
    //workspace_id设置
    NSArray *workspaceId = [self workspaceIdInfos];
    
    //owner 设置
    NSArray *owner = [self ownerInfos];
    
    //version 设置
    NSArray *version = [self versionInfos] ;
    
    //creator 设置
    NSArray *creator = [self creatorInfos] ;
    
    // expected
    NSArray *expected = [self expectedInfos];
    
    //提单 button
    NSArray *bugReportButton = [self bugReportButton] ;
    return [[NSMutableArray alloc] initWithObjects:workspaceId ,owner, version,creator ,expected,bugReportButton,nil];
}

- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLBugReportSettingVCHeaderID];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLBugReportSettingVCSpaceHeaderID];
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
            //workspace_id 设置
            [self confirmAction:WORKSPACEID tableView:tableView indexPath:indexPath] ;
            break ;
        }
        case 1:{
            //crash owner设置
            if(indexPath.row == 0){
                [self confirmAction:CRASHOWNER tableView:tableView indexPath:indexPath] ;
            }else if(indexPath.row == 1){
                //JSException owner设置
                [self confirmAction:JSEXCEPTIONOWNER  tableView:tableView indexPath:indexPath] ;
            }
            
            break ;
        }
        case 2:{
            //version 设置
            [self confirmAction:VERSION  tableView:tableView indexPath:indexPath] ;
            break ;
        }
        case 3:
            //creator 设置
            [self confirmAction:CREATOR  tableView:tableView indexPath:indexPath] ;
            break ;
        case 4:
            //敬请期待
            break ;
        case 5:{
            if([self infoCheck]){
                //提单button
                if([[LLDebugTool sharedTool] bugReportSwitch]){
                    [[LLDebugTool sharedTool] saveBugReportSwitch:NO] ;
                }else{
                    [[LLDebugTool sharedTool] saveBugReportSwitch:YES] ;
                }
                [self refreshCell:tableView indexPath:indexPath] ;
            }
            break ;
        }
    }
    
}
-(BOOL)infoCheck{
    NSString *workspaceId = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.workspaceId ;
    NSString *crashOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.crashOwner ;
    NSString *JSExceptionOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.JSExceptionOwner ;
    NSString *version = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.version;
    NSString *creator = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.creator;
    if([workspaceId isEqualToString:@""]){
        [LLTool toastMessage:@"项目设置不能为空"];
        return false ;
    }
    if([crashOwner isEqualToString:@""]){
        [LLTool toastMessage:@"Crash Owner不能为空"];
        return false ;
    }
    if([JSExceptionOwner isEqualToString:@""]){
        [LLTool toastMessage:@"JSException Owner不能为空"];
        return false ;
    }
    if([version isEqualToString:@""]){
        [LLTool toastMessage:@"版本设置不能为空"];
        return false ;
    }
    if([creator isEqualToString:@""]){
        [LLTool toastMessage:@"提单人不能为空"] ;
        return false ;
    }
    return true ;
}
- (void)confirmAction:(LLFieldType)fieldType tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    NSString *message = nil ;
    switch(fieldType){
        case WORKSPACEID:{
            message = @"更改项目设置" ;
            break ;
        }
        case CRASHOWNER:{
            message = @"更改Crash处理人" ;
            break ;
        }
        case JSEXCEPTIONOWNER:{
            message = @"更改JSException处理人" ;
            break ;
        }
        case VERSION:{
            message = @"更改版本设置" ;
            break ;
        }
        case CREATOR:{
            message = @"更改提单人" ;
            break ;
        }
    }
    __weak __block typeof(self) weakSelf = self;
    __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Note" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text =alert.textFields.firstObject.text?:@"" ;
        
        //开启提单功能
        if([[LLDebugTool sharedTool] bugReportSwitch]){
            if(text && text.length==0){
                [LLTool toastMessage:[NSString stringWithFormat:@"提单功能开启中，%@ 不能为空.",message]] ;
            }else{
                [weakSelf doConfirmAction:text fieldType:fieldType tableView:tableView indexPath:indexPath];
            }
        }else{
            [weakSelf doConfirmAction:text fieldType:fieldType tableView:tableView indexPath:indexPath];
        }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doConfirmAction:(NSString *)name fieldType:(LLFieldType)fieldType tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    BOOL result = false ;
    switch(fieldType){
        case WORKSPACEID:{
            result = [[LLBugReportSettingHelper sharedHelper] setWorkspaceID:name] ;
            break ;
        }
        case CRASHOWNER:{
            result = [[LLBugReportSettingHelper sharedHelper] setCrashOwner:name] ;
            break ;
        }
        case JSEXCEPTIONOWNER:{
            result = [[LLBugReportSettingHelper sharedHelper] setJSExceptionOwner:name] ;
            break ;
        }
        case VERSION:{
            result = [[LLBugReportSettingHelper sharedHelper] setVersion:name] ;
            break ;
        }
        case CREATOR:{
            result = [[LLBugReportSettingHelper sharedHelper] setCreator:name] ;
            break ;
        }
    }
    
    if(result){
        [self refreshCell:tableView indexPath:indexPath] ;
    }else{
        [self showAlertControllerWithMessage:@"save data fail" handler:^(NSInteger action) {
            if (action == 1) {
                [self _loadData];
            }
        }];
    }
}

-(void)refreshCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    //更新数据源
    self.dataArray = [self bugReportInfos] ;
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)_loadData {
    //更新数据源
    self.dataArray = [self bugReportInfos] ;
    [self.tableView reloadData] ;
}

-(LLBaseTableViewCell *)getButtonCell:(UITableView*)tableView{
    //button cell
    LLBaseTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:kLLBugReportSettingVCButtonCellID];
    if (!buttonCell) {
        buttonCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLBugReportSettingVCButtonCellID];
        buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        buttonCell.accessoryType = UITableViewCellAccessoryNone ;
        
    }
    buttonCell.textLabel.textAlignment = NSTextAlignmentCenter ;
    buttonCell.textLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    return buttonCell ;
}
-(LLBaseTableViewCell *)getNoneCell:(UITableView*)tableView{
    //None cell
    LLBaseTableViewCell *NoneCell = [tableView dequeueReusableCellWithIdentifier:kLLBugReportSettingVCNoneCellID];
    if (!NoneCell) {
        NoneCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLLBugReportSettingVCButtonCellID];
        NoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NoneCell.accessoryType = UITableViewCellAccessoryNone ;
    }
    return NoneCell ;
}
-(LLBaseTableViewCell *)getTextCell:(UITableView*)tableView{
    //text cell
    LLBaseTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:kLLBugReportSettingVCCellID];
    if (!textCell) {
        textCell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLLBugReportSettingVCCellID];
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
            //workspace_id
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            cell.detailTextLabel.text = dic.allValues.firstObject;
            break ;
        case 1:
            //crash owner
            if(indexPath.row == 0){
                cell = [self getTextCell:tableView] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
                cell.detailTextLabel.text = dic.allValues.firstObject;
            }else if(indexPath.row == 1){
                //js exception owner
                cell = [self getTextCell:tableView] ;
                cell.textLabel.text = dic.allKeys.firstObject ;
                cell.detailTextLabel.text = dic.allValues.firstObject;
            }
            break ;
        case 2:
            //version
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            cell.detailTextLabel.text = dic.allValues.firstObject ;
            break ;
        case 3:
            //creator
            cell = [self getTextCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            cell.detailTextLabel.text = dic.allValues.firstObject ;
            break ;
        case 4:
            //更多设置
            cell = [self getNoneCell:tableView] ;
            cell.textLabel.text = dic.allKeys.firstObject ;
            break ;
        case 5:
            //提单button
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
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLBugReportSettingVCHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = [LLCONFIG_TEXT_COLOR colorWithAlphaComponent:0.2];
    }
    return view ;
}

-(UITableViewHeaderFooterView*)getHeaderFooterViewWithSpace:(UITableView*)tableView{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLBugReportSettingVCSpaceHeaderID];
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
        view.textLabel.text = @"项目设置";
    } else if (section == 1) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"处理人设置";
    }else if (section == 2){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"版本设置" ;
    }else if(section ==3){
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"提单人设置" ;
    }
    else if (section == 4) {
        view = [self getHeaderFooterView:tableView] ;
        view.textLabel.text = @"敬请期待";
    }else if(section == 5){
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
@end
