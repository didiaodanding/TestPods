//
//  TestANRViewController.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "TestANRViewController.h"
#import "TestSlideANR.h"

@interface TestANRViewController ()

@end

@implementation TestANRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.anr", nil);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"mainthread.anr", nil);
    }else if(indexPath.row ==1){
        cell.textLabel.text = NSLocalizedString(@"slide.anr", nil) ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testMainThreadANR];
    }else if(indexPath.row == 1){
        TestSlideANR *vc = [[TestSlideANR alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)testMainThreadANR{
    NSLog(@"5秒钟的卡顿") ;
    [NSThread sleepForTimeInterval:5.0] ;
}

@end
