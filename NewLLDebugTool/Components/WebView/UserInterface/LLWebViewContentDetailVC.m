//
//  LLWebViewContentDetailVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewContentDetailVC.h"
#import "LLBaseTableViewCell.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLWebViewConfig.h"
#import "LLSubTitleTableViewCell.h"
#import "LLWebViewContentDetailCell.h"

static NSString *const kLLWebViewContentDetailVCPerformanceCellID = @"LLWebViewContentDetailVCPerformanceCellID";
static NSString *const kLLWebViewContentDetailVCHeaderID = @"LLWebViewContentDetailVCHeaderID";
static NSString *const kLLWebViewContentDetailVCCellID = @"LLWebViewContentDetailVCCellID";

@interface LLWebViewContentDetailVC ()<LLSubTitleTableViewCellDelegate>

@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation LLWebViewContentDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (NSArray *)performanceInfos{
    return @[@{@"fetchStart":self.model.fetchStart},
             @{@"domainLookupStart":self.model.domainLookupStart},
             @{@"domainLookupEnd":self.model.domainLookupEnd},
             @{@"connectStart":self.model.connectStart},
             @{@"connectEnd":self.model.connectEnd},
             @{@"requestStart":self.model.requestStart},
             @{@"responseStart":self.model.responseStart},
             @{@"responseEnd":self.model.responseEnd},
             @{@"domLoading":self.model.domLoading},
             @{@"domInteractive":self.model.domInteractive},
             @{@"domContentLoadedEventStart":self.model.domContentLoadedEventStart},
             @{@"domContentLoadedEventEnd":self.model.domContentLoadedEventEnd},
             @{@"domComplete":self.model.domComplete},
             @{@"loadEventStart":self.model.loadEventStart},
             @{@"loadEventEnd":self.model.loadEventEnd}] ;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([LLWebViewConfig defaultConfig].performanceType == whiteScreenType){
        self.navigationItem.title = @"White Screen Time";
        NSMutableArray *data = [[NSMutableArray alloc] initWithObjects:@[@{@"应用程序缓存时间" :@[self.model.appCacheTime,@"domainLookupStart - fetchStart"]},
                                                                         @{@"DNS查询耗时":@[self.model.domainLookupTime,@"domainLookupEnd - domainLookupStart"]},
                                                                         @{@"TCP链接耗时":@[self.model.connectTime,@"connectEnd - connectStart"]},
                                                                         @{@"后端响应时间":@[self.model.requestTime,@"responseStart - requestStart"]},
                                                                         @{@"dom树准备时间":@[self.model.domLoadingTime,@"domLoading - responseStart"]}
                                                                         ] ,[self performanceInfos],nil] ;
        self.dataArray = data ;
    }else{
        self.navigationItem.title = @"First Screen Time";
        NSMutableArray *data = [[NSMutableArray alloc] initWithObjects:@[@{@"应用程序缓存时间" : @[self.model.appCacheTime,@"domainLookupStart - fetchStart"]},
                                                                         @{@"DNS查询耗时":@[self.model.domainLookupTime,@"domainLookupEnd - domainLookupStart"]},
                                                                         @{@"TCP链接耗时":@[self.model.connectTime,@"connectEnd - connectStart"]},
                                                                         @{@"后端响应时间":@[self.model.requestTime,@"responseStart - requestStart"]},
                                                                         @{@"dom树准备时间":@[self.model.domLoadingTime,@"domLoading - responseStart"]},
                                                                         @{@"dom树解析完成时间":@[self.model.domInteractiveTime,@"domInteractive - domLoading"]},
                                                                         @{@"dom树加载完成时间":@[self.model.domCompleteTime,@"domComplete - domLoading"]},
                                                                         @{@"load事件回调时间":@[self.model.loadEventTime,@"loadEventEnd - loadEventStart"]}
                                                                         ] ,[self performanceInfos],nil] ;
        self.dataArray = data ;
        
    }
    
}

#pragma mark - Primary
- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kLLWebViewContentDetailVCHeaderID];
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig sharedConfig].XIBBundle] forCellReuseIdentifier:kLLWebViewContentDetailVCPerformanceCellID];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LLWebViewContentDetailCell" bundle:[LLConfig sharedConfig].XIBBundle] forCellReuseIdentifier:kLLWebViewContentDetailVCCellID];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    
    if(indexPath.section==0){
        LLWebViewContentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kLLWebViewContentDetailVCCellID forIndexPath:indexPath];
        [cell confirmWithTitle:dic.allKeys.firstObject date:[dic.allValues.firstObject objectAtIndex:0]  detail:[dic.allValues.firstObject objectAtIndex:1] ] ;
        return cell;
    }else if(indexPath.section==1){
        LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLLWebViewContentDetailVCPerformanceCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = dic.allKeys.firstObject;
        cell.contentText = dic.allValues.firstObject;
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    return nil ;
}

#pragma mark - LLSubTitleTableViewCellDelegate
- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLLWebViewContentDetailVCHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        view.backgroundView.backgroundColor = [LLCONFIG_TEXT_COLOR colorWithAlphaComponent:0.2];
    }
    
    if (section == 0) {
        if([LLWebViewConfig defaultConfig].performanceType == whiteScreenType){
            view.textLabel.text = @"白屏时间";
        }else{
            view.textLabel.text = @"首页时间";
        }
    }else if(section ==1){
        view.textLabel.text = @"性能参数" ;
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
