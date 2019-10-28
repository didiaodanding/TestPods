//
//  LLWebViewModel.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLStorageModel.h"

/**
 webview model. Save and show webview performance infos.
 */
@interface LLWebViewModel : LLStorageModel

/**
 webview request start date.
 */
@property (nonatomic , copy , nonnull) NSString *startDate;

/**
 webview request URL.
 */
@property (nonatomic , strong , nullable) NSURL *url;


/**
 webview request method.
 */
@property (nonatomic , copy , nullable) NSString *method;

/**
 webview request body.
 */
@property (nonatomic , copy , nullable) NSString *requestBody;

/**
 webview response body.
 */
@property (nonatomic , copy , nullable) NSString *responseBody;

/**
 webview request header.
 */
@property (nonatomic , strong , nullable) NSDictionary <NSString *,NSString *>*headerFields;

//应用程序缓存时间(domainLookupStart - fetchStart)
@property(copy,nonatomic,nullable)NSString * appCacheTime ;

//DNS查询耗时（domainLookupEnd - domainLookupStart）
@property(copy,nonatomic,nullable)NSString* domainLookupTime ;

//TCP链接耗时 （connectEnd - connectStart）
@property(copy,nonatomic,nullable)NSString* connectTime ;

//后端响应时间（responseStart - requestStart）
@property(copy,nonatomic,nullable)NSString* requestTime ;

//dom树准备时间(domLoading - responseStart)
@property(copy,nonatomic,nullable)NSString* domLoadingTime ;

//dom树解析完成时间（domInteractive - domLoading）
@property(copy,nonatomic,nullable)NSString *domInteractiveTime ;

//dom 加载完成时间（domComplete - domLoading）
@property(copy,nonatomic,nullable)NSString* domCompleteTime ;


//html页面下载时间（responseEnd - responseStart）
@property(copy,nonatomic,nullable)NSString* responseTime ;


//load事件回调时间（loadEventEnd - loadEventStart）
@property(copy,nonatomic,nullable)NSString* loadEventTime ;

//白屏时间（domLoading - fetchStart）
@property(copy,nonatomic,nullable)NSString* whiteScreenTime ;

//首页时间（ loadEventEnd - fetchStart）
@property(copy,nonatomic,nullable)NSString* firstScreenTime ;


//window.performance.timing性能参数时间点
@property(copy,nonatomic,nullable)NSString* fetchStart;
@property(copy,nonatomic,nullable)NSString* domainLookupStart;
@property(copy,nonatomic,nullable)NSString* domainLookupEnd;
@property(copy,nonatomic,nullable)NSString* connectStart;
@property(copy,nonatomic,nullable)NSString* connectEnd;
@property(copy,nonatomic,nullable)NSString* requestStart;
@property(copy,nonatomic,nullable)NSString* responseStart;
@property(copy,nonatomic,nullable)NSString* responseEnd;
@property(copy,nonatomic,nullable)NSString* domLoading;
@property(copy,nonatomic,nullable)NSString* domInteractive;
@property(copy,nonatomic,nullable)NSString* domContentLoadedEventStart;
@property(copy,nonatomic,nullable)NSString* domContentLoadedEventEnd;
@property(copy,nonatomic,nullable)NSString* domComplete;
@property(copy,nonatomic,nullable)NSString* loadEventStart;
@property(copy,nonatomic,nullable)NSString* loadEventEnd;

/**
 Model identity
 **/
@property (copy,nonatomic,readonly,nonnull) NSString *identity ;

#pragma mark - Quick Getter
/**
 String converted from headerFields.
 */
@property (nonatomic , copy , readonly , nonnull) NSString *headerString;

/**
 Convent [date] to NSDate.
 */
- (NSDate *_Nullable)dateDescription;

@end

