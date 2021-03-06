//
//  ViewController.m
//  LLDebugToolDemo
//
//  Created by Li on 2018/3/15.
//  Copyright © 2018年 li. All rights reserved.
//

#import "ViewController.h"

// If you integrate with cocoapods, used #import <LLDebug.h>.
#import "LLDebug.h"

// Used to example.
#import "NetTool.h"
#import <Photos/PHPhotoLibrary.h>

#import "TestNetworkViewController.h"
#import "TestLogViewController.h"
#import "TestCrashViewController.h"
#import "TestANRViewController.h"
#import "TestColorStyleViewController.h"
#import "TestWindowStyleViewController.h"
#import "TestUploadViewController.h"

#import "LLStorageManager.h"
#import "PrivateNetwork.h"
#import "LoginVC.h"
#import "UIView-Debugging.h"
#import "WKWebViewVC.h"
#import "UIWebViewVC.h"
#import "MockViewController.h"
#import "UIWebViewDelegateVC.h"
#import "WKWebViewDelegateVC.h"

static NSString *const kCellID = @"cellID";

@interface ViewController () <UITableViewDelegate , UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Try to get album permission, and if possible, screenshots are stored in the album at the same time.
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
    }];
    
    // LLDebugTool need time to start.
    sleep(0.5);
    __block __weak typeof(self) weakSelf = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"openCrash"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"openCrash"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:2];
        });

    }
    
    //Network Request
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525346881086&di=b234c66c82427034962131d20e9f6b56&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F011cf15548caf50000019ae9c5c728.jpg%402o.jpg"]];
    [urlRequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!connectionError) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                weakSelf.imgView.image = image;
            }
        });
    }];
    
    
    // Json Response
    [[NetTool sharedTool].afHTTPSessionManager GET:@"http://baike.baidu.com/api/openapi/BaikeLemmaCardApi?&format=json&appid=379020&bk_key=%E7%81%AB%E5%BD%B1%E5%BF%8D%E8%80%85&bk_length=600" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    //NSURLSession
    NSMutableURLRequest *htmlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://cocoapods.org/pods/LLDebugTool"]];
    [htmlRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask *dataTask = [[NetTool sharedTool].session dataTaskWithRequest:htmlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Not important. Just check to see if the current Demo version is consistent with the latest version.
        // 只是检查一下当前Demo版本和最新版本是否一致，不一致就提示一下新版本。
        NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [htmlString componentsSeparatedByString:@"http://cocoadocs.org/docsets/LLDebugTool/"];
        if (array.count > 2) {
            NSString *str = array[1];
            NSArray *array2 = [str componentsSeparatedByString:@"/preview.png"];
            if (array2.count >= 2) {
                NSString *newVersion = array2[0];
                if ([newVersion componentsSeparatedByString:@"."].count == 3) {
                    if ([[LLDebugTool sharedTool].version compare:newVersion] == NSOrderedAscending) {
                        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Note" message:[NSString stringWithFormat:@"%@\nNew Version : %@\nCurrent Version : %@",NSLocalizedString(@"new.version", nil),newVersion,[LLDebugTool sharedTool].version] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"I known" style:UIAlertActionStyleDefault handler:nil];
                        [vc addAction:action];
                        [self presentViewController:vc animated:YES completion:nil];
                    }
                }
            }
        }
    }];
    [dataTask resume];
    
    // Log.
    // NSLocalizedString is used for multiple languages.
    // You can just use as LLog(@"What you want to pring").
    LLog(NSLocalizedString(@"initial.log", nil));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Actions
- (void)testAppInfo {
    [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:3];
}

- (void)testSandbox {
    [[LLDebugTool sharedTool] showDebugViewControllerWithIndex:4];
}



#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return 1;
    }
    if (section == 3) {
        return 1;
    }
    if (section == 4) {
        return 1;
    }
    if (section == 5) {
        return 2;
    }
    if (section == 6){
        return 1 ;
    }
    if (section == 7){
        return 1 ;
    }
    if(section == 8){
        return 1 ;
    }
    if(section == 9){
        return 1 ;
    }
    if(section == 10){
        return 4 ;
    }
    if(section == 11){
        return 2 ;
    }
    if(section == 12){
        return 1 ;
    }
    if(section == 13){
        return 1 ;
    }
    if(section == 14){
        return 1 ;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = nil;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"test.network.request", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"test.log", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = NSLocalizedString(@"test.crash", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 3) {
        cell.textLabel.text = NSLocalizedString(@"app.info", nil);
    } else if (indexPath.section == 4) {
        cell.textLabel.text = NSLocalizedString(@"sandbox.info", nil);
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"test.color.style", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch ([LLConfig sharedConfig].colorStyle) {
                case LLConfigColorStyleHack:{
                    cell.detailTextLabel.text = @"LLConfigColorStyleHack";
                }
                    break;
                case LLConfigColorStyleSimple:{
                    cell.detailTextLabel.text = @"LLConfigColorStyleSimple";
                }
                    break;
                case LLConfigColorStyleSystem:{
                    cell.detailTextLabel.text = @"LLConfigColorStyleSystem";
                }
                    break;
                case LLConfigColorStyleCustom:{
                    cell.detailTextLabel.text = @"LLConfigColorStyleCustom";
                }
                    break;
                default:
                    break;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"test.window.style", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch ([LLConfig sharedConfig].windowStyle) {
                case LLConfigWindowSuspensionBall:{
                    cell.detailTextLabel.text = @"LLConfigWindowSuspensionBall";
                }
                    break;
                case LLConfigWindowPowerBar:{
                    cell.detailTextLabel.text = @"LLConfigWindowPowerBar";
                }
                    break;
                case LLConfigWindowNetBar:{
                    cell.detailTextLabel.text = @"LLConfigWindowNetBar";
                }
                    break;
                default:
                    break;
            }
        }
    }else if(indexPath.section == 6){
        cell.textLabel.text = NSLocalizedString(@"test.swizzle", nil);
    }else if(indexPath.section == 7){
        cell.textLabel.text = NSLocalizedString(@"test.share", nil) ;
    }else if(indexPath.section == 8){
        cell.textLabel.text = NSLocalizedString(@"test.login",nil) ;
    }else if(indexPath.section==9){
        cell.textLabel.text = NSLocalizedString(@"test.tree", nil) ;
    }else if(indexPath.section == 10){
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"test.uiwebview", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if(indexPath.row ==1){
            cell.textLabel.text = NSLocalizedString(@"test.uiwebviewdelegate", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"test.wkwebview", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 3){
            cell.textLabel.text = NSLocalizedString(@"test.wkwebviewdelegate", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if(indexPath.section == 11){
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"test.block1", nil) ;
        }else if(indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"test.block2", nil) ;
        }
    }else if(indexPath.section == 12){
        cell.textLabel.text = NSLocalizedString(@"test.mock",nil) ;
    }else if(indexPath.section == 13){
        cell.textLabel.text = NSLocalizedString(@"test.upload",nil) ;
    }else if(indexPath.section == 14){
        cell.textLabel.text = NSLocalizedString(@"test.anr",nil) ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

static TestLogViewController *extracted() {
    return [TestLogViewController alloc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TestNetworkViewController *vc = [[TestNetworkViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1) {
        TestLogViewController *vc = [extracted() initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 2) {
        TestCrashViewController *vc = [[TestCrashViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 3) {
        [self testAppInfo];
    } else if (indexPath.section == 4) {
        [self testSandbox];
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            TestColorStyleViewController *vc = [[TestColorStyleViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 1) {
            TestWindowStyleViewController *vc = [[TestWindowStyleViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (indexPath.section == 6){
        PrivateNetwork *pn = [[PrivateNetwork alloc] init] ;
        [pn sendBizData:@"test"] ;
       
    }else if(indexPath.section == 7){
        NSString *textToShare = @"要分享的文本内容";
        NSURL *urlToShare = [NSURL URLWithString:@"http://blog.csdn.net/hitwhylz"];
        NSArray *activityItems = @[textToShare,urlToShare];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }else if(indexPath.section == 8){
        LoginVC *vc = [[LoginVC alloc] init] ;
        [self.navigationController pushViewController:vc animated:YES] ;
    }else if(indexPath.section == 9){
        [UIView printViewHierarchy] ;
    }else if(indexPath.section == 10){
        if (indexPath.row == 0) {
            UIWebViewVC *vc = [[UIWebViewVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
        }else if(indexPath.row ==1){
            UIWebViewDelegateVC *vc = [[UIWebViewDelegateVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
        }else if (indexPath.row == 2) {
            WKWebViewVC *vc = [[WKWebViewVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 3){
            WKWebViewDelegateVC *vc = [[WKWebViewDelegateVC alloc] init] ;
            [self.navigationController pushViewController:vc animated:YES] ;
        }
    }else if(indexPath.section==11){
        if(indexPath.row == 0){
            [[LLDebugTool sharedTool] addRunScript:^(NSString *path){
                NSLog(@"%@",path) ;
                return YES ;
            }];
            if([LLDebugTool sharedTool].runScript) {
                
                BOOL flag = [LLDebugTool sharedTool].runScript(@"test") ;
                if(flag){
                    NSLog(@"%@",@"true") ;
                }else{
                    NSLog(@"%@",@"false") ;
                }
            }else{
                NSLog(@"no implementation") ;
            }
        }else if(indexPath.row == 1){
            [[LLDebugTool sharedTool] addUploadLog:^(){
                return ;
            }] ;
            if([LLDebugTool sharedTool].uploadLog){
                NSLog(@"upload log") ;
            }
        }
    }else if(indexPath.section ==12){
        MockViewController *vc = [[MockViewController alloc] initWithNibName:@"MockViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:vc animated:YES] ;
    }else if(indexPath.section == 13){
        TestUploadViewController *vc = [[TestUploadViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 14){
        TestANRViewController *vc = [[TestANRViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Network Request";
    } else if (section == 1) {
        return @"Log";
    } else if (section == 2) {
        return @"Crash";
    } else if (section == 3) {
        return @"App Info";
    } else if (section == 4) {
        return @"Sandbox Info";
    } else if (section == 5) {
        return @"LLConfig";
    } else if (section == 6){
        return @"swizzling" ;
    } else if (section == 7){
        return @"share" ;
    } else if (section == 8){
        return @"login" ;
    } else if(section == 9){
        return @"tree" ;
    } else if(section == 10){
        return @"webview" ;
    } else if(section ==11){
        return @"block" ;
    }else if(section == 12){
        return @"mock" ;
    }else if(section == 13){
        return @"upload" ;
    }else if(section == 14){
        return @"anr" ;
    }
    return nil;
}



@end
