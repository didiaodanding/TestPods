//
//  LLMonkeyReportHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/14.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLMonkeyReportHelper.h"
#import "LLTool.h"
#import "LLDebugTool.h"
#import "LLAppHelper.h"
//该code仅限内部使用，是Monkey后台创建任务产生的验证码
static NSString *g_code = @"639545" ;

//验证验证码
static NSString *CheckCodeURL = @"https://monkey.qq.com/users/check_code";
//拉取配置
static NSString *ConfigURL = @"https://monkey.qq.com/tasks/config" ;
//获取任务运行实例
static NSString *InstanceURL = @"https://monkey.qq.com/tasks/instance" ;
//monkey心跳
static NSString *HeartBeatURL = @"https://monkey.qq.com/tasks/heartbeat" ;

static LLMonkeyReportHelper *_instance = nil;

@interface LLMonkeyReportHelper (){
    NSString *_codeID ;
    NSString *_taskID ;
    NSString *_taskName ;
}
@end

@implementation LLMonkeyReportHelper
+(instancetype _Nonnull) sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMonkeyReportHelper alloc] init] ;
        [_instance initial];
    });
    return _instance ;
}

/**
 Initial something.
 */
- (void)initial {
   
}

-(NSString*)codeID{
    if(!_codeID){
        NSString* request = CheckCodeURL;
        NSDictionary *parameters = @{@"code":g_code} ;
        NSDictionary *header = @{@"Content-Type":@"application/json; charset=utf-8"} ;
        NSDictionary *response = [LLTool postWithRequest:request header:header parameters:parameters] ;
        NSNumber *ret = [response objectForKey:@"success"] ;
        if(ret.boolValue){
            _codeID = [[response objectForKey:@"data"] objectForKey:@"id"] ;
        }
    }
    return _codeID ;
}

- (NSString *)taskName{
    if(!_taskName){
        NSString *request = ConfigURL ;
        NSDictionary *parameters = @{@"timestamp":@"0",@"platform":@"2"} ;
        NSDictionary *header = [self getHead] ;
        NSDictionary *response = [LLTool getWithRequest:request header:header parameters:parameters] ;
        NSNumber *ret = [response objectForKey:@"success"] ;
        if(ret.boolValue){
            _taskName = [[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"task_name"] ;
        }
    }
    return _taskName ;
}

- (NSString*)taskID{
    if(!_taskID){
        NSString *request= InstanceURL ;
        NSDictionary *parameters = @{@"task_name":[self taskName],
                       @"deviceid":[[LLAppHelper sharedHelper] deviceID] ,
                       @"device_model":[[LLAppHelper sharedHelper] deviceModel] ,
                       @"display": [[LLAppHelper sharedHelper] screenResolution] ,
                       @"platform":@"2",
                       @"os_version":[[LLAppHelper sharedHelper] systemVersion],
                       @"data_source":@"2",
                       @"apk_name":@"随身版Monkey_MonkeyDemo.apk",
                       } ;
        NSDictionary *header = [self getHead];
        NSDictionary *response = [LLTool postWithRequest:request header:header parameters:parameters] ;
        NSNumber *ret = [response objectForKey:@"success"] ;
        if(ret.boolValue){
            _taskID = [[response objectForKey:@"data"] objectForKey:@"task_id"] ;
        }
    }
    return _taskID ;
}

- (NSDictionary *)getHead{
    NSString *timeStamp = [NSString stringWithFormat:@"%lld",(UInt64)[[NSDate date] timeIntervalSince1970] *1000] ;
    NSString *randomData = [NSString stringWithFormat:@"%d",arc4random()%1000] ;
    NSString *token = [[LLTool md5:[NSString stringWithFormat:@"%@%@%@%@",timeStamp,randomData,[self codeID],g_code]] lowercaseString] ;
    return @{@"Content-Type":@"application/json",
             @"timestamp":timeStamp,
             @"random":randomData,
             @"codeId":[self codeID],
             @"token":token
             } ;
}

- (BOOL) heartBeatReport:(NSString *)status{

    NSString* request = HeartBeatURL ;
    NSDictionary *parameters = @{@"task_id":[self taskID],
                                 @"status":status,
                                 @"phone_free_memory":@"Unknown",
                                 @"sdcard_free_size":@"Unknown",
                                 @"tool_version":@"Unknown",
                                 @"widget_coverage":@"0",
                                 @"event_coverage":@"0",
                                 @"activity_coverage":@"0",
                                 @"code_coverage":@"0"
                                 } ;
    NSDictionary *header = [self getHead];
    NSDictionary *response = [LLTool postWithRequest:request header:header parameters:parameters] ;
    if(response){
        NSNumber *ret = [response objectForKey:@"success"] ;
        return ret.boolValue ;
    }
    return false ;
}

@end
