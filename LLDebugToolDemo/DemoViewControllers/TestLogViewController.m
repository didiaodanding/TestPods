//
//  TestLogViewController.m
//  LLDebugToolDemo
//
//  Created by admin10000 on 2018/8/29.
//  Copyright © 2018年 li. All rights reserved.
//

#import "TestLogViewController.h"
#import "LLDebugToolMacros.h"
#import "LLDebugLogger.h"
#import "LLDebugTool.h"
#import "LLDebugLogger.h"

static void logger(LLLoggerLevel level, const char* log) {
    NSLog(@"%s",log);
}

@interface TestLogViewController ()

@end

@implementation TestLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.log", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"insert.log", nil);
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"insert.error.log", nil);
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"insert.call.log", nil);
    } else if (indexPath.row == 3){
        cell.textLabel.text = NSLocalizedString(@"insert.console.log", nil);
    } else if (indexPath.row == 4){
        cell.textLabel.text = NSLocalizedString(@"insert.console.error.log", nil);
    } else if (indexPath.row == 5){
        cell.textLabel.text = NSLocalizedString(@"insert.console.call.log", nil);
    } else if (indexPath.row == 6){
        cell.textLabel.text = NSLocalizedString(@"insert.file.log", nil);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testNormalLog];
    } else if (indexPath.row == 1) {
        [self testErrorLog];
    } else if (indexPath.row == 2) {
        [self testEventLog];
    } else if (indexPath.row == 3){
        [self testNormalConsoleLog] ;
    } else if (indexPath.row == 4){
        [self testErrorConsoleLog] ;
    } else if (indexPath.row == 5){
        [self testEventConsoleLog] ;
    } else if (indexPath.row == 6){
        [self testNormalFileLog] ;
    }
    
}

#pragma mark - Actions
- (void)testNormalLog {
    LLog(NSLocalizedString(@"normal.log.info", nil));
    [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:1];
}

- (void)testErrorLog {
    LLog_Error(NSLocalizedString(@"error.log.info", nil));
    [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:1];
}

- (void)testEventLog {
    LLog_Error_Event(NSLocalizedString(@"call", nil),NSLocalizedString(@"call.log.info", nil));
    [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:1];
}

- (void)testNormalConsoleLog{
    [[LLDebugTool sharedTool] registerLogCallback:logger] ;
    LL_LogInfo("%s", [NSLocalizedString(@"normal.console.log.info",nil) UTF8String]);
}

- (void)testErrorConsoleLog{
    [[LLDebugTool sharedTool] registerLogCallback:logger] ;
    LL_LogDebug("%s", [NSLocalizedString(@"error.console.log.info",nil) UTF8String]) ;
}

- (void)testEventConsoleLog{
    [[LLDebugTool sharedTool] registerLogCallback:logger] ;
    LL_LogEvent("%s", [NSLocalizedString(@"call.console.log.info",nil) UTF8String]) ;
}

- (void)testNormalFileLog{
    [[LLDebugTool sharedTool] addFileLog:@"test"] ;
    [[LLDebugTool sharedTool] flushFileLog] ;
}
@end
