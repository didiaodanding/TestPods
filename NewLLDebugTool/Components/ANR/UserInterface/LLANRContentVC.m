//
//  LLANRContentVC.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLANRContentVC.h"
#import "LLSubTitleTableViewCell.h"
#import "LLConfig.h"
#import "LLTool.h"

static NSString *const kANRContentCellID = @"ANRContentCellID" ;

@interface LLANRContentVC ()<LLSubTitleTableViewCellDelegate>

@property (nonatomic , strong) NSMutableArray *titleArray ;

@property (nonatomic , strong) NSMutableArray *contentArray ;

@property (nonatomic , strong) NSArray *canCopyArray ;

@end

@implementation LLANRContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial] ;
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count ;
}

-(UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kANRContentCellID] ;
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    cell.titleLabel.text = self.titleArray[indexPath.row] ;
    cell.contentText = self.contentArray[indexPath.row] ;
    cell.delegate = self ;
    cell.accessoryType = UITableViewCellAccessoryNone ;
    return cell ;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSString *title = self.titleArray[indexPath.row] ;
    if([self.canCopyArray containsObject:title]){
        [[UIPasteboard generalPasteboard] setString:self.contentArray[indexPath.row]];
        [self toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
    }
}

- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Primary
- (void)initial {
    self.navigationItem.title = self.model.name;
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig sharedConfig].XIBBundle] forCellReuseIdentifier:kANRContentCellID];
    
    self.titleArray = [[NSMutableArray alloc] init];
    self.contentArray = [[NSMutableArray alloc] init];
    
    [self loadData];
}

- (void)loadData {
    
    [self.titleArray removeAllObjects];
    [self.contentArray removeAllObjects];
    
    if (_model.name) {
        [self.titleArray addObject:@"Name"];
        [self.contentArray addObject:_model.name];
    }
    
    if (_model.reason) {
        [self.titleArray addObject:@"Reason"];
        [self.contentArray addObject:_model.reason];
    }
    
   
    
    if (_model.date) {
        [self.titleArray addObject:@"Date"];
        [self.contentArray addObject:_model.date];
    }
    
    if (_model.duration){
        [self.titleArray addObject:@"Duration"] ;
        [self.contentArray addObject:[NSString stringWithFormat:@"至少卡顿%@秒",_model.duration]] ;
    }
    
    if (_model.stackSymbols){
        [self.titleArray addObject:@"Stack Symbols"];
        [self.contentArray addObject:_model.stackSymbols] ;
    }
    
    if (_model.appInfos.count) {
        [self.titleArray addObject:@"App Infos"];
        NSMutableString *str = [[NSMutableString alloc] init];
        for (NSArray *array in _model.appInfos) {
            for (NSDictionary *dic in array) {
                for (NSString *key in dic) {
                    [str appendFormat:@"%@ : %@\n",key,dic[key]];
                }
            }
            [str appendString:@"\n"];
        }
        [self.contentArray addObject:str];
    }
    [self.tableView reloadData];
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Name",@"Stack Symbols"];
    }
    return _canCopyArray;
}

@end
