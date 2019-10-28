//
//  TestUploadViewController.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/7/26.
//  Copyright © 2019 li. All rights reserved.
//

#import "TestUploadViewController.h"
#import "LLDebugTool.h"
#define Kboundary @"----WebKitFormBoundaryOhB08CzI96Eux6PO"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]


static NSString *const kCellID = @"cellID";

@interface TestUploadViewController ()

@end

@implementation TestUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.upload", nil);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.row == 0){
        cell.textLabel.text = NSLocalizedString(@"normal.nsurlconnection", nil) ;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        [self testNormalNSURLConnection] ;
    }
}

-(void) testNormalNSURLConnection{
    return ;
    NSString *filePath = @"ios_2019_07_31_21_07_11@iosmonkey.zip" ;
    NSURL *uploadFile = [[NSBundle mainBundle] URLForResource:filePath withExtension:nil] ;
    [[LLDebugTool sharedTool] uploadBugWithURL:uploadFile complete:^(BOOL result,NSString*zipPath) {
        if(result){
            NSLog(@"上传bug成功");
        }
    } synchronous:YES] ;
}
@end
