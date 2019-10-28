//
//  LLCocosInfoVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/12.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCocosInfoVC.h"
#import "LLCocosHelper.h"
#import "LLBaseTableViewCell.h"
#import "LLMacros.h"
#import "LLConfig.h"

static NSString *const kLLCocosInfoVCCellID = @"LLCocosInfoVCCellID";
static NSString *const kLLCocosInfoVCHeaderID = @"LLCocosInfoVCHeaderID";

@interface LLCocosInfoVC ()

@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation LLCocosInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = [[NSMutableArray alloc] initWithObjects:[[LLCocosHelper sharedHelper] cocosInfos],nil] ;
    self.navigationItem.title = [UIDevice currentDevice].name ? : @"Cocos Infos";
    [self registerLLCocosHelperNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLLCocosHelperNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Primary
- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLCocosInfoVCHeaderID];
}

#pragma mark - LLCocosHelperNotification
- (void)registerLLCocosHelperNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLLCocosHelperDidUpdateAppInfosNotification:) name:LLCocosHelperDidUpdateAppInfosNotificationName object:nil];
}

- (void)unregisterLLCocosHelperNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LLCocosHelperDidUpdateAppInfosNotificationName object:nil];
}

- (void)didReceiveLLCocosHelperDidUpdateAppInfosNotification:(NSNotification *)notifi {
    NSArray *dynamic = notifi.object;
    [self.dataArray replaceObjectAtIndex:0 withObject:dynamic];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLLCocosInfoVCCellID];
    if (!cell) {
        cell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLLCocosInfoVCCellID];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.detailTextLabel.minimumScaleFactor = 0.5;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = dic.allKeys.firstObject;
    cell.detailTextLabel.text = dic.allValues.firstObject;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLCocosInfoVCHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = [LLCONFIG_TEXT_COLOR colorWithAlphaComponent:0.2];
    }
    
    if (section == 0) {
        view.textLabel.text = @"Cocos Information";
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
