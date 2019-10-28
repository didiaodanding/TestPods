//
//  LLWebViewContentVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewContentVC.h"
#import "LLSubTitleTableViewCell.h"
#import "LLConfig.h"
#import "LLWebViewContentDetailVC.h"
#import "LLWebViewConfig.h"

static NSString *const kWebViewContentCellID = @"WebViewContentCellID";


@interface LLWebViewContentVC ()<LLSubTitleTableViewCellDelegate>

@property (nonatomic , strong) NSMutableArray *titleArray;

@property (nonatomic , strong) NSMutableArray *contentArray;

@property (nonatomic , strong) NSArray *canCopyArray;

@end

@implementation LLWebViewContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int MAXSTRLENGTH = 8000 ;
    NSString* str = self.contentArray[indexPath.row];
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWebViewContentCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    if(str.length > MAXSTRLENGTH){
        //显示过多，造成页面卡顿
        cell.contentText = [str substringToIndex:MAXSTRLENGTH] ;
    }else{
        cell.contentText = str;
    }
    cell.delegate = self;
    
    NSString *title = self.titleArray[indexPath.row];
    if ([title isEqualToString:@"White Screen Time(白屏时间)"] || [title isEqualToString:@"First Screen Time(首页时间)"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleArray[indexPath.row];
    if([title isEqualToString:@"White Screen Time(白屏时间)"]){
        LLWebViewContentDetailVC *vc = [[LLWebViewContentDetailVC alloc] initWithStyle:UITableViewStyleGrouped];
        [LLWebViewConfig defaultConfig].performanceType = whiteScreenType ;
        vc.model = self.model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([title isEqualToString:@"First Screen Time(首页时间)"]){
        LLWebViewContentDetailVC *vc = [[LLWebViewContentDetailVC alloc] initWithStyle:UITableViewStyleGrouped];
        [LLWebViewConfig defaultConfig].performanceType = firstScreenType ;
        vc.model = self.model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([self.canCopyArray containsObject:title]) {
        id obj = self.contentArray[indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            [[UIPasteboard generalPasteboard] setString:obj];
            [self toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
        }
    }
}

#pragma mark - LLSubTitleTableViewCellDelegate
- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Primary
/**
 * initial method
 */
- (void)initial {
    self.navigationItem.title = @"Details";
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig sharedConfig].XIBBundle] forCellReuseIdentifier:kWebViewContentCellID];
    [self loadData];
}

- (void)loadData {
    if (self.model) {
        self.titleArray = [[NSMutableArray alloc] init];
        self.contentArray = [[NSMutableArray alloc] init];
        [self.titleArray addObject:@"Request Url"];
        
        if(self.model.url.absoluteString && [self.model.url.absoluteString hasPrefix:@"//"]){
            [self.contentArray addObject:[self.model.url.absoluteString substringFromIndex:[@"//" length]]];
        }else{
            [self.contentArray addObject:self.model.url.absoluteString?:@"unknown"];
        }
        if (self.model.method) {
            [self.titleArray addObject:@"Method"];
            [self.contentArray addObject:self.model.method];
        }
        
        if (self.model.headerFields.count) {
            [self.titleArray addObject:@"Header Fields"];
            NSMutableString *string = [[NSMutableString alloc] init];
            for (NSString *key in self.model.headerFields) {
                [string appendFormat:@"%@ : %@\n",key,self.model.headerFields[key]];
            }
            [self.contentArray addObject:string];
        }

        if (self.model.startDate) {
            [self.titleArray addObject:@"Start Date"];
            [self.contentArray addObject:self.model.startDate];
        }
     
        if (self.model.whiteScreenTime) {
            [self.titleArray addObject:@"White Screen Time(白屏时间)"] ;
            [self.contentArray addObject:self.model.whiteScreenTime] ;
        }
        
        if (self.model.firstScreenTime){
            [self.titleArray addObject:@"First Screen Time(首页时间)"] ;
            [self.contentArray addObject:self.model.firstScreenTime] ;
        }
        
        
        [self.titleArray addObject:@"Request Body"];
        [self.contentArray addObject:self.model.requestBody ?: @"Null"];
        
        [self.titleArray addObject:@"Response Body"] ;
        [self.contentArray addObject:self.model.responseBody?: @"Null"] ;
    }
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Request Url" ,  @"Header Fields" ,@"Request Body"];
    }
    return _canCopyArray;
}


@end
