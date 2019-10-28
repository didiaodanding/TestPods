//
//  LLDebugTool.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLDebugTool.h"
#import "LLScreenshotHelper.h"
#import "LLStorageManager.h"
#import "LLNetworkHelper.h"
#import "LLCrashSignalHelper.h"
#import "LLCrashNSExceptionHelper.h"
#import "LLCrashMachHelper.h"
#import "LLLogHelper.h"
#import "LLAppHelper.h"
#import "LLBugReportSettingHelper.h"
#import "LLWindow.h"
#import "LLDebugToolMacros.h"
#import "LLLogHelperEventDefine.h"
#import "LLConfig.h"
#import "LLTool.h"
#import "LLNetworkModel.h"
#import "LLRoute.h"
#import "LLHomeWindow.h"
#import "LLMonkeyHelper.h"
#import "LLMockHelper.h"
#import "UIDevice+LL_Swizzling.h"
#import "SSZipArchive.h"
#import "LLANRHelper.h"
#import "LLCrashCPPExceptionHelper.h"
#import "LLDebugLogger.h"
#import "LLFileLogger.h"

#define Kboundary @"----WebKitFormBoundaryOhB08CzI96Eux6PO"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

static LLDebugTool *_instance = nil;

@interface LLDebugTool (){
    /**
     丢包个数
     */
    float _packetCount;
}

@property (nonatomic , strong , nonnull) LLWindow *window;

@property (nonatomic , copy , nonnull) NSString *versionNumber;

@end

@implementation LLDebugTool

/**
 * Singleton
 @return Singleton
 */
+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLDebugTool alloc] init];
        [_instance initial];
    });
    return _instance;
}

- (void)startWorking{
    if (!_isWorking) {
        _isWorking = YES;
        LLConfigAvailableFeature available = [LLConfig sharedConfig].availables;
        if (available & LLConfigAvailableCrash) {
            
            // Open signal crash helper, 如果 signal crash 的开关是打开状态，继续监控signal crash ,默认是打开状态
            if([self signalCrashSwitch]){
                [[LLCrashSignalHelper sharedHelper] setEnable:YES];
            }
            
            // Open mach crash helper , 如果 mach crash 的开关是打开状态， 继续监控mach crash ，默认是关闭状态
            if([self machCrashSwitch]){
                [[LLCrashMachHelper sharedHelper] setEnable:YES] ;
            }
            
            // Open NSException crash helper , 如果 NSException crash 的开关是打开状态， 继续监控 NSException crash， 默认是打开状态
            if([self exceptionCrashSwitch]){
                [[LLCrashNSExceptionHelper sharedHelper] setEnable:YES] ;
            }
            
            // Open CPP Exception crash helper , 如果 CPP Exception crash的开关是打开状态，继续监控 CPP Exception crash, 默认是关闭状态
            if([self cppExceptionCrashSwitch]){
                [[LLCrashCPPExceptionHelper sharedHelper] setEnable:YES] ;
            }
        }
        
        if (available & LLConfigAvailableLog) {
            // Open log helper
            [[LLLogHelper sharedHelper] setEnable:YES];
        }
        if (available & LLConfigAvailableNetwork) {
            // Open network monitoring
            [[LLNetworkHelper sharedHelper] setEnable:NO];
        }
        if (available & LLConfigAvailableAppInfo) {
            // Open app monitoring
            [[LLAppHelper sharedHelper] setEnable:YES];
        }
        if (available & LLConfigAvailableScreenshot) {
            // Open screenshot
            [[LLScreenshotHelper sharedHelper] setEnable:YES];
        }
        
        //如果 mock 的开关是打开状态，继续 mock
        if([self mockSwitch]){
            [[LLMockHelper sharedHelper] startMock] ;
        }
        
        //如果 anr 的开关是打开状态，继续监控anr
        if([self anrSwitch]){
            [[LLANRHelper sharedHelper] setEnable:YES] ;
        }
        
        
        //如果iOS monkey 或者 cocos monkey的开关是打开状态，继续运行monkey
        if([self iosMonkeySwitch]){
            [[LLMonkeyHelper sharedHelper] startIOSMonkey] ;
        }else if([self cocosMonkeySwitch]){
            //因为这个是通过注入才能使用的方法，所以需要延迟10秒执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[LLMonkeyHelper sharedHelper] startCocosMonkey] ;
            });
        }
        else{
            // show window
            [self.window showWindow];
        }
    }
}

- (void)stopWorking {
    if (_isWorking) {
        _isWorking = NO;
        // Close screenshot
        [[LLScreenshotHelper sharedHelper] setEnable:NO];
        // Close app monitoring
        [[LLAppHelper sharedHelper] setEnable:NO];
        // Close network monitoring
        [[LLNetworkHelper sharedHelper] setEnable:NO];
        // Close log helper
        [[LLLogHelper sharedHelper] setEnable:NO];
        
        // Close crash helper
        [[LLCrashSignalHelper sharedHelper] setEnable:NO];
        [[LLCrashNSExceptionHelper sharedHelper] setEnable:NO] ;
        [[LLCrashMachHelper sharedHelper] setEnable:NO] ;
        
        // hide window
        [self.window hideWindow];
    }
}

- (void)showDebugViewControllerWithIndex:(NSInteger)index {
//    [[LLHomeWindow shareInstance] showDebugViewControllerWithIndex:index];
}

- (void)logInFile:(NSString *)file function:(NSString *)function lineNo:(NSInteger)lineNo level:(LLConfigLogLevel)level onEvent:(NSString *)onEvent message:(NSString *)message {
    if (![LLConfig sharedConfig].showDebugToolLog) {
        NSArray *toolEvent = @[kLLLogHelperDebugToolEvent,kLLLogHelperFailedLoadingResourceEvent];
        if ([toolEvent containsObject:onEvent]) {
            return;
        }
    }
    [[LLLogHelper sharedHelper] logInFile:file function:function lineNo:lineNo level:level onEvent:onEvent message:message];
}

#pragma mark - Primary
/**
 Initial something.
 */
- (void)initial {
    
    //重新启动的时候，把所有的开关关掉

    [self saveLowNetworkSwitch:NO];
    [self saveLowMemorySwitch:NO];
    
    //anr开关保留原有状态，重启以后可以继续监控anr
//    [self saveANRSwitch:NO] ;
    
    //mock开关保留原有状态，重启以后可以继续mock
//    [self saveMockSwitch:NO];
    
    //monkey开关保留原有状态，重启以后可以继续运行
//    [self saveIOSMonkeySwitch:NO];
//    [self saveCocosMonkeySwitch:NO];
    
    //提单开关保留原有状态，重启以后可以继续提单
//    [self saveBugReportSwitch:NO] ;
    
    
    //monkey
    //monkey数据上报开关保留原有状态，重启以后可以继续上报
//    [self saveMonkeyHeartBeatReportSwitch:NO] ;
//    [self saveCocosMonkeyHeartBeatReportSwitch:NO] ;
    
    [self savePrivateNetworkSwitch:NO];
    
    [self saveFpsPerformanceCurveSwitch:NO] ;
    
    [self saveCocosFpsPerformanceCurveSwitch:NO] ;
  
    [self saveWebViewSwitch:NO] ;
    
    // Set Default
    _packetCount = 0.0 ;
    
    _cmd_to_send = [[NSMutableString alloc] init];
    
    _cmd_to_receive = [[NSMutableString alloc] init];
    
    _cmd_seq_dict = [[NSMutableDictionary alloc] init];
    
    _isBetaVersion = NO;

    _versionNumber = @"1.2.2";

    _version = _isBetaVersion ? [_versionNumber stringByAppendingString:@"(BETA)"] : _versionNumber;
    
    
    // Check version.
    [self checkVersion];
    
    // Set window.
    CGFloat windowWidth = [LLConfig sharedConfig].suspensionBallWidth;
    self.window = [[LLWindow alloc] initWithFrame:CGRectMake(0, 0, windowWidth, windowWidth)];
}

- (void)checkVersion {
    [LLTool createDirectoryAtPath:[LLConfig sharedConfig].folderPath];
    __block NSString *filePath = [[LLConfig sharedConfig].folderPath stringByAppendingPathComponent:@"LLDebugTool.plist"];
    NSMutableDictionary *localInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    if (!localInfo) {
        localInfo = [[NSMutableDictionary alloc] init];
    }
    NSString *version = localInfo[@"version"];
    // localInfo will be nil before version 1.1.2
    if (!version) {
        version = @"0.0.0";
    }
    
    if ([self.versionNumber compare:version] == NSOrderedDescending) {
        // Do update if needed.
        [self updateSomethingWithVersion:version completion:^(BOOL result) {
            if (!result) {
                NSLog(@"Failed to update old data");
            }
            [localInfo setObject:self.versionNumber forKey:@"version"];
            [localInfo writeToFile:filePath atomically:YES];
        }];
    }
    
    if (self.isBetaVersion) {
        // This method called in instancetype, can't use macros to log.
        [self logInFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] function:NSStringFromSelector(_cmd) lineNo:__LINE__ level:LLConfigLogLevelAlert onEvent:kLLLogHelperDebugToolEvent message:kLLLogHelperUseBetaAlert];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Check whether has a new LLDebugTool version.
        if ([LLConfig sharedConfig].autoCheckDebugToolVersion) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://cocoapods.org/pods/LLDebugTool"]];
            NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error == nil && data != nil) {
                    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSArray *array = [htmlString componentsSeparatedByString:@"http://cocoadocs.org/docsets/LLDebugTool/"];
                    if (array.count > 2) {
                        NSString *str = array[1];
                        NSArray *array2 = [str componentsSeparatedByString:@"/preview.png"];
                        if (array2.count >= 2) {
                            NSString *newVersion = array2[0];
                            if ([newVersion componentsSeparatedByString:@"."].count == 3) {
                                if ([self.version compare:newVersion] == NSOrderedAscending) {
                                    NSString *message = [NSString stringWithFormat:@"A new version for LLDebugTool is available, New Version : %@, Current Version : %@",newVersion,self.version];
                                    [self logInFile:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] function:NSStringFromSelector(_cmd) lineNo:__LINE__ level:LLConfigLogLevelAlert onEvent:kLLLogHelperDebugToolEvent message:message];
                                }
                            }
                        }
                    }
                }
            }];
            [dataTask resume];
        }
    });
}

- (void)updateSomethingWithVersion:(NSString *)version completion:(void (^)(BOOL result))completion {
    // Refactory database. Need rename tableName and table structure.
    if ([version compare:@"1.1.3"] == NSOrderedAscending) {
        [[LLStorageManager sharedManager] updateDatabaseWithVersion:@"1.1.3" complete:^(BOOL result) {
            if (completion) {
                completion(result);
            }
        }];
    }
}


- (void)addPrivateNetworkSendBlock:(void(^)(NSString *command))block{
    self.sendBlock = block ;
}

- (void)addPrivateNetworkReceiveBlock:(void(^)(NSString *command))block{
    self.receiveBlock = block ;
}


- (void)dealWithResponseData:(NSString *)command response:(NSData *)response request:(NSData *)request date:(NSDate *)date{
    LLNetworkModel *model = [[LLNetworkModel alloc] init];
    model.startDate = [LLTool stringFromDate:date];
    NSURLComponents *components = [NSURLComponents new] ;
    [components setHost:command] ;
    model.url = components.URL ;
    model.requestBody = [LLTool convertJSONStringFromData:request];
    model.responseData = response ;
    model.totalDuration = [NSString stringWithFormat:@"%fs",[[NSDate date] timeIntervalSinceDate:date]];
    
    //request 和 response 为解包后的 bzibuff ，所以统计的流量只有bzibuff的量大小，而包头以及bzibuff在实际传输过程中的压缩以及加密等均不考虑
    [[LLStorageManager sharedManager] saveModel:model complete:nil];
    
    [LLRoute updateRequestDataTraffic:model.requestDataTrafficValue responseDataTraffic:model.responseDataTrafficValue];
}


- (void)dealWithHttpResponseData:(NSString *)command response:(NSData *)response request:(NSData *)request date:(NSDate *)date{
    LLNetworkModel *model = [[LLNetworkModel alloc] init];
    model.startDate = [LLTool stringFromDate:date];
    
    
    //request
    NSDictionary* req_dict = [NSJSONSerialization JSONObjectWithData:request options:NSJSONReadingAllowFragments error:nil];
    
    NSString *jce_body = [req_dict objectForKey:@"jce_body"] ;
    NSString *jce_method = [req_dict objectForKey:@"jce_method"] ;
    NSString *jce_header = [req_dict objectForKey:@"jce_header"] ;
    NSString *jce_domain = [req_dict objectForKey:@"jce_domain"] ;
    
    NSURLComponents *components = [NSURLComponents new] ;
    [components setHost:command] ;
    model.url = components.URL ;
    model.requestBody = jce_body;
    model.method = jce_method ;
    model.headerFields = [NSDictionary dictionaryWithObject:jce_header forKey:@"headers"] ;
    
    
    //rsponse
    NSDictionary* response_dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    NSString *httpResponseStatusCode = [response_dict objectForKey:@"httpResponseStatusCode"] ;
    NSString *httpResponseVersion = [response_dict objectForKey:@"httpResponseVersion"] ;
    NSDictionary *httpResponseHeader = [response_dict objectForKey:@"httpResponseHeader"] ;
    NSString *httpResponseBody = [response_dict objectForKey:@"httpResponseBody"] ;
    
    model.statusCode = httpResponseStatusCode ;
    model.responseData = [httpResponseBody dataUsingEncoding:NSUTF8StringEncoding] ;
    model.responseHeaderFields = httpResponseHeader ;
    
    
    model.totalDuration = [NSString stringWithFormat:@"%fs",[[NSDate date] timeIntervalSinceDate:date]];
    
    //request 和 response 为解包后的 bzibuff ，所以统计的流量只有bzibuff的量大小，而包头以及bzibuff在实际传输过程中的压缩以及加密等均不考虑
    [[LLStorageManager sharedManager] saveModel:model complete:nil];
    
    [LLRoute updateRequestDataTraffic:model.requestDataTrafficValue responseDataTraffic:model.responseDataTrafficValue];
}


static NSString * const kLLMockKey = @"ll_mock_key";
static NSString * const kLLLowNetworkKey = @"ll_low_network_key";
static NSString * const kLLLowMemoryKey = @"ll_low_memory_key";
static NSString * const kLLIOSMonkeyKey = @"ll_ios_monkey_key";
static NSString * const kLLCocosMonkeyKey = @"ll_cocos_monkey_key";
static NSString * const kLLPrivateNetworkKey = @"ll_private_network_key";
static NSString * const kLLBugReportKey = @"ll_bug_report_key";
static NSString * const kLLANRKey = @"ll_anr_key" ;
static NSString * const kLLSignalCrashKey = @"ll_signal_crash_key" ;
static NSString * const kLLMachCrashKey = @"ll_mach_crash_key" ;
static NSString * const kLLExceptionCrashKey = @"ll_exception_crash_key" ;
static NSString * const kLLCPPExceptionCrashKey = @"ll_cpp_exception_crash_key" ;
static NSString * const kLLFpsPerformanceCurveKey = @"ll_fps_performance_curve_key" ;
static NSString * const kLLCocosFpsPerformanceCurveKey = @"ll_cocos_fps_performance_curve_key" ;
static NSString * const kLLWebViewKey = @"ll_webview_key" ;
static NSString * const kLLMonkeyHeartBeatReportKey = @"ll_monkey_heartbeat_report_key" ;
static NSString * const kLLCocosMonkeyHeartBeatReportKey = @"ll_cocos_monkey_heartbeat_report_key" ;



- (void)saveMockSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLMockKey];
    [defaults synchronize];
}

- (BOOL)mockSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLMockKey];
}


- (void)saveLowNetworkSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLLowNetworkKey];
    [defaults synchronize];
}

- (BOOL)lowNetworkSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLLowNetworkKey];
}

- (void)saveLowMemorySwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLLowMemoryKey];
    [defaults synchronize];
}

- (BOOL)lowMemorySwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLLowMemoryKey];
}

- (BOOL)iosMonkeySwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLIOSMonkeyKey];
}

- (void)saveIOSMonkeySwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLIOSMonkeyKey];
    [defaults synchronize];
}

- (BOOL)cocosMonkeySwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLCocosMonkeyKey];
}

- (void)saveCocosMonkeySwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLCocosMonkeyKey];
    [defaults synchronize];
}

- (BOOL)privateNetworkSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLPrivateNetworkKey];
}

- (void)savePrivateNetworkSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLPrivateNetworkKey];
    [defaults synchronize];
}

- (BOOL)bugReportSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kLLBugReportKey];
}

- (void)saveBugReportSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kLLBugReportKey];
    [defaults synchronize];
}

- (BOOL)anrSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLANRKey] ;
}

-(void)saveANRSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLANRKey] ;
    [defaults synchronize] ;
}

//默认为true
- (BOOL)signalCrashSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:kLLSignalCrashKey]?[defaults boolForKey:kLLSignalCrashKey]:true ;
}

- (void)saveSignalCrashSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLSignalCrashKey] ;
    [defaults synchronize] ;
}

- (BOOL) machCrashSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLMachCrashKey] ;
}
- (void) saveMachCrashSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLMachCrashKey] ;
    [defaults synchronize] ;
}

//默认为true
- (BOOL) exceptionCrashSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:kLLExceptionCrashKey] ? [defaults boolForKey:kLLExceptionCrashKey] : true;
}

- (void) saveExceptionCrashSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLExceptionCrashKey] ;
    [defaults synchronize] ;
}

- (BOOL) cppExceptionCrashSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLCPPExceptionCrashKey] ;
}

- (void) saveCPPExceptionCrashSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey: kLLCPPExceptionCrashKey] ;
    [defaults synchronize] ;
}

- (BOOL) fpsPerformanceCurveSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLFpsPerformanceCurveKey] ;
}

- (void) saveFpsPerformanceCurveSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLFpsPerformanceCurveKey] ;
    [defaults synchronize] ;
}

- (BOOL) cocosFpsPerformanceCurveSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLCocosFpsPerformanceCurveKey] ;
}

- (void) saveCocosFpsPerformanceCurveSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLCocosFpsPerformanceCurveKey] ;
    [defaults synchronize] ;
}

- (void) saveWebViewSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLWebViewKey] ;
    [defaults synchronize] ;
}

- (BOOL) webViewSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:kLLWebViewKey] ;
}

//默认为true
- (BOOL) monkeyHeartBeatReportSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:kLLMonkeyHeartBeatReportKey]? [defaults boolForKey:kLLMonkeyHeartBeatReportKey] : true;
} ;

- (void) saveMonkeyHeartBeatReportSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLMonkeyHeartBeatReportKey] ;
    [defaults synchronize] ;
}

//默认为true
- (BOOL) cocosMonkeyHeartBeatReportSwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:kLLCocosMonkeyHeartBeatReportKey]? [defaults boolForKey:kLLCocosMonkeyHeartBeatReportKey] : true;
}

- (void)saveCocosMonkeyHeartBeatReportSwitch:(BOOL)on{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setBool:on forKey:kLLCocosMonkeyHeartBeatReportKey] ;
    [defaults synchronize] ;
}

//丢包率为0.08
- (BOOL)isPacketLoss:(float)increase{
    NSLog(@"haleli >>> packet_count : %f",_packetCount) ;
    _packetCount = _packetCount + increase ;
    if(_packetCount > 1){
        _packetCount = 0.0 ;
        return TRUE ;
    }
    return FALSE ;
}
- (void)setPacketCount:(float)packetCount{
    _packetCount = packetCount ;
}

- (void)simulateDirectTakeScreenshot:(NSString *)imagePath{
    [[LLScreenshotHelper sharedHelper] simulateDirectTakeScreenshot:imagePath] ;
}

- (NSMutableArray *)copySourceFileArr:(NSArray*)sourceFileArr toDestDir:(NSString*)destDir{
    NSMutableArray* tempFiles = [[NSMutableArray alloc] init];
    for(NSString* filePath in sourceFileArr) {
        NSString* name = [[[filePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
        NSString* newPath = [destDir stringByAppendingPathComponent:name];
        if([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
        }
        [[NSFileManager defaultManager] copyItemAtPath:filePath
                                                toPath:newPath
                                                 error:nil];
        [tempFiles addObject:newPath];
        
    }
    
    return tempFiles ;
    
}

- (void)addCocosCreatorANR:(CocosCreatorANR)ccANR{
    self.ccANR = ccANR ;
}

- (void)addRunScript:(RunScript)runScript{
    self.runScript = runScript ;
}

- (void)addJSEvaluateFunc:(JSEvaluateFunc)jsEvaluateFunc{
    self.jsEvaluateFunc = jsEvaluateFunc ;
}

- (void)addUploadLog:(UploadLog)uploadLog{
    self.uploadLog = uploadLog ;
}

-(void)uploadBugWithURL:(NSURL*_Nullable)furl complete:(UploadBugBoolBlock _Nullable)complete synchronous:(BOOL)synchronous{
    
    NSString *filename = [furl lastPathComponent] ;
    
    //1. 确定请求路径
    NSURL *url = [NSURL URLWithString:@"https://monkey.qq.com/bugs/api/upload_file/"];
    //2. 创建可变的请求对象
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    //3. 设置请求方法
    requestM.HTTPMethod = @"POST";
    
    //4. 设置请求头信息
    //Authorization：Token e24a863ca6fb88ee8d350d57c6480ac1f4876352\r\n;
    [requestM setValue:[NSString stringWithFormat:
                        @"Token e24a863ca6fb88ee8d350d57c6480ac1f4876352\r\n" ] forHTTPHeaderField:@"Authorization"];
    
    //Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryOhB08CzI96Eux6PO
    [requestM setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary] forHTTPHeaderField:@"Content-Type"];
    
    
    //5. 设置请求体数据
    NSMutableData *fileData = [NSMutableData data];
    //5.1 文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="file_path"; filename="xx.zip"
     Content-Type: application/octet-stream
     空行
     文件参数
     */
    [fileData appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // 拼接换行
    [fileData appendData:KNewLine];
    
    //name:file_path 服务器规定的参数
    //filename:xx.zip 文件保存到服务器上面的名称
    //Content-Type:文件的类型
    [fileData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file_path\"; filename=\"%@\"",filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:KNewLine];
    [fileData appendData:[@"Content-Type: application/octet-stream" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:KNewLine];
    [fileData appendData:KNewLine];
    
    //文件数据部分
    // NSURL --> NSData
    NSData *uploadData = [NSData dataWithContentsOfURL:furl];
    [fileData appendData:uploadData];
    [fileData appendData:KNewLine];
    
    //5.2 非文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="file_name"
     空行
     xx.zip
     */
    [fileData appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:KNewLine];
    [fileData appendData:[@"Content-Disposition: form-data; name=\"file_name\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:KNewLine];
    [fileData appendData:KNewLine];
    [fileData appendData:[filename dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:KNewLine];
    
    //5.3 结尾标识
    /*
     --分隔符--
     */
    [fileData appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //6. 设置请求体
    requestM.HTTPBody = fileData;
    
    //7. 发送请求
    if(synchronous){
        //同步请求
        BOOL isMock = [[LLDebugTool sharedTool] mockSwitch] ;
        if(isMock){
            [[LLMockHelper sharedHelper] stopMock] ;
        }
        NSData *data= [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:nil] ;
        NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
        NSLog(@"haleli >>> %@",result);
        NSDictionary *dict = [LLTool dictWithJsonString:result] ;
        NSNumber *ret = [dict objectForKey:@"success"] ;
        [self performBoolComplete:complete ret:ret filePath:furl.path] ;
        if(isMock){
            [[LLMockHelper sharedHelper] startMock] ;
        }
    }else{
        //异步请求
        BOOL isMock = [[LLDebugTool sharedTool] mockSwitch] ;
        if(isMock){
            [[LLMockHelper sharedHelper] stopMock] ;
        }
        [NSURLConnection sendAsynchronousRequest:requestM queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            
            //8.解析数据
            NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
            NSLog(@"haleli >>> %@",result);
            NSDictionary *dict = [LLTool dictWithJsonString:result] ;
            NSNumber *ret = [dict objectForKey:@"success"] ;
            [self performBoolComplete:complete ret:ret filePath:furl.path] ;
            
            if(isMock){
                [[LLMockHelper sharedHelper] startMock] ;
            }
        }];
    }
}

- (void)performBoolComplete:(UploadBugBoolBlock)complete ret:(NSNumber *)ret filePath:(NSString*)filePath{
    if (complete) {
        if ([[NSThread currentThread] isMainThread]) {
            complete(ret.boolValue,filePath);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performBoolComplete:complete ret:ret filePath:filePath];
            });
        }
    }
}

- (void)uploadBugWithDict:(NSDictionary*_Nullable)bugInfo exceptionType:(LLExceptionType)exceptionType files:(NSArray *)files complete:(UploadBugBoolBlock _Nullable)complete{
    [self uploadBugWithDict:bugInfo exceptionType:exceptionType files:files takeScreenshot:NO complete:complete synchronous:NO] ;
}

- (void)uploadBugWithDict:(NSDictionary*_Nullable)bugInfo exceptionType:(LLExceptionType)exceptionType files:(NSArray *)files takeScreenshot:(BOOL)takeScreenshot complete:(UploadBugBoolBlock _Nullable)complete synchronous:(BOOL)synchronous{
    
    if(![[LLDebugTool sharedTool] bugReportSwitch]){
        [LLTool toastMessage:@"发现了一个bug，但是没有开启提单功能，不进行提单"] ;
        return ;
    }
    NSString* stack = [bugInfo objectForKey:@"stack"] ;
    if(!stack){
        [LLTool toastMessage:@"bug堆栈信息不全，不进行提单"] ;
        return ;
    }
    NSString *workspaceId = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.workspaceId ;
    NSString *crashOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.crashOwner ;
    NSString *JSExceptionOwner = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.JSExceptionOwner ;
    NSString *version = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.version;
    NSString *creator = [LLBugReportSettingHelper sharedHelper].bugReportSettingModel.creator;
    if([workspaceId isEqualToString:@""]){
        [LLTool toastMessage:@"项目设置为空,不进行提单"];
        return ;
    }
    if([crashOwner isEqualToString:@""]){
        [LLTool toastMessage:@"Crash Owner为空，不进行提单"];
        return ;
    }
    if([JSExceptionOwner isEqualToString:@""]){
        [LLTool toastMessage:@"JSException Owner为空，不进行提单"];
        return ;
    }
    if([version isEqualToString:@""]){
        [LLTool toastMessage:@"版本设置为空，不进行提单"];
        return ;
    }
    if([creator isEqualToString:@""]){
        [LLTool toastMessage:@"提单人为空，不进行提单"] ;
        return ;
    }
    
    NSString* exceptionName = @"" ;
    NSString* owner = @"" ;
    switch (exceptionType) {
        case CRASH:{
            exceptionName =  @"crash exception" ;
            owner = crashOwner ;
            break;
        }
        case JSEXCEPTION:{
            exceptionName = @"js exception" ;
            owner = JSExceptionOwner ;
            break ;
        }
        default:{
            exceptionName =  @"crash exception" ;
            owner = crashOwner ;
            break;
        }
    }

    
    //发生异常的时间
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    NSString *exceptionTime = [dateFormatter stringFromDate:[NSDate date]] ;
    
    //保存title
    NSString *title = [NSString stringWithFormat:@"[自动化]在%@时间发生%@" , exceptionTime ,exceptionName] ;
    
    //产品bundle id
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString *bundleIdentifier = infoDic[@"CFBundleIdentifier"] ?:@"Unknown";
    
    //产品的版本
    NSString *appVersion = [NSString stringWithFormat:@"%@(%@)",infoDic[@"CFBundleShortVersionString"]?:@"Unknown",infoDic[@"CFBundleVersion"]?:@"Unknown"];
    //操作系统
    NSString *osType = @"IOS" ;
    
    //获取设备手机型号
    NSString* deviceModel = [UIDevice currentDevice].LL_modelName ?: @"Unknown";
    
    //获取设备系统版本
    NSString* deviceName = [UIDevice currentDevice].systemVersion ?: @"Unknown";
    

    NSMutableString *briefStr = [NSMutableString stringWithFormat:@"osType:%@\r\nexceptionName:%@\r\nappVersion:%@\r\ndeviceModel:%@\r\ndeviceName:%@\r\nbundleIdentifier:%@\r\nexceptionTime:%@\r\n",osType,exceptionName,appVersion,deviceModel,deviceName,bundleIdentifier,exceptionTime] ;
    
    [briefStr appendString:@"====================================\r\n"] ;
    
    //统一临时保存的目录 auto_bug
    NSString* tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"auto_bug"];
    
    BOOL isDir = NO;
    [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    //统一文件名
    NSString* fileName = [NSString stringWithFormat:@"ios_%@",exceptionTime] ;
    
    //zip包路径
    NSString* zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@@iosmonkey",fileName] stringByAppendingPathExtension:@"zip"]] ;
    
    //*crashbrief.txt文件路径
    NSString* crashBriefPath = [tempDir stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@@crashbrief",fileName] stringByAppendingPathExtension:@"txt"]] ;
    
    for(NSString *key in bugInfo){
        [briefStr appendFormat:@"%@:%@\r\n",key,[bugInfo objectForKey:key]] ;
    }
    
    //写*crashbrief.txt文件
    [briefStr writeToFile:crashBriefPath atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
    
    
    NSDictionary *reportInfo = @{@"workspace_id":workspaceId,@"analysis_tool":@"",@"creator":creator,@"dupSource":@"",@"device":deviceModel,@"owner":owner,@"stack":stack,@"baseline":@"",@"title":title,@"filepath":@"",@"feature":@"",@"priority":@"medium",@"version":version,@"task_name":@"",@"product_name":@""} ;
    
    // *bug.json文件路径
    NSString* reportPath = [tempDir stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@@bug",fileName] stringByAppendingPathExtension:@"json"]] ;
    //写 *bug.json 文件
     [[LLTool convertJSONStringFromDictionary:reportInfo] writeToFile:reportPath atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
    
    NSMutableArray *allFiles = [NSMutableArray arrayWithObjects:crashBriefPath,reportPath, nil] ;
    if(files){
        [allFiles addObjectsFromArray:files] ;
    }
    
    if(takeScreenshot){
        //1秒后执行截图方法
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //截图路径
            NSString* imagePath = [tempDir stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"png"]] ;
            [[LLDebugTool sharedTool] simulateDirectTakeScreenshot:imagePath];
            
            //将截图加入到压缩文件中
            [allFiles addObject:imagePath] ;
            
            if(![SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:allFiles]) {
                NSLog(@"haleli >>> 创建zip log失败, zipfile:%@ fileArr:%@", zipPath, allFiles);
            } else {
                NSLog(@"haleli >>> 创建zip log成功, zipfile:%@ fileArr:%@", zipPath, allFiles);
                [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
                [self uploadBugWithURL:[NSURL fileURLWithPath:zipPath] complete:complete synchronous:synchronous] ;
            }
        });
    }else{
        if(![SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:allFiles]) {
            NSLog(@"haleli >>> 创建zip log失败, zipfile:%@ fileArr:%@", zipPath, allFiles);
        } else {
            NSLog(@"haleli >>> 创建zip log成功, zipfile:%@ fileArr:%@", zipPath, allFiles);
            [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
            [self uploadBugWithURL:[NSURL fileURLWithPath:zipPath] complete:complete synchronous:synchronous] ;
        }
    }
    
}

- (void)registerLogCallback:(LL_Log_Callback)logger {
    ll_logger = logger;
}

- (void)addFileLog:(NSString *_Nullable)log{
    [[LLFileLogger getInstance] addLog:log] ;
}
- (void)flushFileLog{
    [[LLFileLogger getInstance] flushLog] ;
}
@end
