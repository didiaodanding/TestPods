//
//  TestSlideANR.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "TestSlideANR.h"

@interface TestSlideANR ()

@end

@implementation TestSlideANR

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"slide.anr", nil) ;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 50) {
        usleep(3 * 1000 * 1000); // 3秒
        cell.textLabel.text = @"卡咯(3秒)";
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    }
    
    return cell;
}

@end
