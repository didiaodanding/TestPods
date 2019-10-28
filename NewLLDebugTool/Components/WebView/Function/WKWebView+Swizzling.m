//
//  WKWebView+Swizzling.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 li. All rights reserved.
//

#import "WKWebView+Swizzling.h"
#import <objc/runtime.h>
#import "DelegateProxy.h"
#import "LLTool.h"
#import "LLWebViewModel.h"
#import "LLStorageManager.h"

@interface _WKWebViewProxy : DelegateProxy

@end

@implementation _WKWebViewProxy

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"webView:didFinishNavigation:"]) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [super forwardInvocation:invocation];
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"webView:didFinishNavigation:"]) {
        __unsafe_unretained WKWebView *webView;
        [invocation getArgument:&webView atIndex:2];
        
        if (![webView.URL.scheme isEqualToString:@"http"] &&
            ![webView.URL.scheme isEqualToString:@"https"]) {
            return ;
        }
        
        if (@available(iOS 10.0, *)) {
            [webView evaluateJavaScript:@"JSON.stringify(window.performance.timing.toJSON())" completionHandler:^(NSString * _Nullable timingStr, NSError * _Nullable error) {
                if (!error) {
                    [webView evaluateJavaScript:@"document.documentElement.outerHTML.toString()" completionHandler:^(NSString * _Nullable responseStr, NSError * _Nullable error) {
                        if(!error){
                            NSDictionary<NSString*,NSString*> *dict = [LLTool dictWithJsonString:timingStr] ;
                            
                            //获取的性能参数
                            //            long long navigationStart = [dict objectForKey:@"navigationStart"].longLongValue ;
                            //            long long redirectStart = [dict objectForKey:@"redirectStart"].longLongValue ;
                            //            long long redirectEnd = [dict objectForKey:@"redirectEnd"].longLongValue ;
                            long long fetchStart = [dict objectForKey:@"fetchStart"].longLongValue ;
                            long long domainLookupStart = [dict objectForKey:@"domainLookupStart"].longLongValue ;
                            long long domainLookupEnd = [dict objectForKey:@"domainLookupEnd"].longLongValue ;
                            long long connectStart = [dict objectForKey:@"connectStart"].longLongValue ;
                            long long connectEnd = [dict objectForKey:@"connectEnd"].longLongValue ;
                            long long requestStart = [dict objectForKey:@"requestStart"].longLongValue ;
                            long long responseStart = [dict objectForKey:@"responseStart"].longLongValue ;
                            long long responseEnd = [dict objectForKey:@"responseEnd"].longLongValue ;
                            long long domLoading = [dict objectForKey:@"domLoading"].longLongValue ;
                            long long domInteractive = [dict objectForKey:@"domInteractive"].longLongValue ;
                            //            long long domContentLoadedEventStart = [dict objectForKey:@"domContentLoadedEventStart"].longLongValue ;
                            //            long long domContentLoadedEventEnd = [dict objectForKey:@"domContentLoadedEventEnd"].longLongValue ;
                            long long domComplete = [dict objectForKey:@"domComplete"].longLongValue ;
                            long long loadEventStart = [dict objectForKey:@"loadEventStart"].longLongValue;
                            long long loadEventEnd = [dict objectForKey:@"loadEventEnd"].longLongValue ;
                            
                            //白屏时间（domLoading - fetchStart）
                            //1、domainLookupStart - fetchStart
                            //2、domainLookupEnd - domainLookupStart
                            //3、connectEnd - connectStart
                            //4、responseStart - requestStart
                            //5、domLoading - responseStart
                            
                            
                            //首页时间（全部加载完毕）loadEventEnd - fetchStart
                            //6、domInteractive - domLoading
                            //7、domComplete - domInteractive
                            //8、loadEventEnd - loadEventStart
                            
                            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"fetchStart"] doubleValue]/1000.0];
                            
                            //            NSTimeZone *zone = [NSTimeZone systemTimeZone] ;
                            //            NSInteger interval = [zone secondsFromGMTForDate:startDate] ;
                            //            NSDate *localStartDate = [startDate dateByAddingTimeInterval:interval] ;
                            
                            LLWebViewModel *model = [[LLWebViewModel alloc] init];
                            
                            //时区已经转换了
                            model.startDate = [LLTool stringFromDate:startDate];
                            
                            NSURLRequest *request = [NSURLRequest requestWithURL:webView.URL] ;
                            
                            model.url = request.URL;
                            model.method = request.HTTPMethod;
                            model.headerFields = [request.allHTTPHeaderFields mutableCopy];
                            if (request.HTTPBody) {
                                model.requestBody = [LLTool convertJSONStringFromData:request.HTTPBody];
                            } else if (request.HTTPBodyStream) {
                                NSData* data = [self dataFromInputStream:request.HTTPBodyStream];
                                model.requestBody = [LLTool convertJSONStringFromData:data];
                            }
                            model.responseBody = responseStr ;
                            model.appCacheTime = [NSString stringWithFormat:@"%lldms",(domainLookupStart - fetchStart)] ;
                            model.domainLookupTime = [NSString stringWithFormat:@"%lldms",(domainLookupEnd - domainLookupStart)] ;
                            model.connectTime =[NSString stringWithFormat:@"%lldms",(connectEnd - connectStart)] ;
                            model.requestTime =[NSString stringWithFormat:@"%lldms",(responseStart - requestStart)] ;
                            model.responseTime = [NSString stringWithFormat:@"%lldms",(responseEnd - responseStart)] ;
                            model.domLoadingTime =  [NSString stringWithFormat:@"%lldms",(domLoading - responseStart)] ;
                            model.domInteractiveTime = [NSString stringWithFormat:@"%lldms",(domInteractive - domLoading)] ;
                            model.domCompleteTime = [NSString stringWithFormat:@"%lldms",(domComplete - domInteractive)] ;
                            model.loadEventTime = [NSString stringWithFormat:@"%lldms",(loadEventEnd - loadEventStart)] ;
                            model.whiteScreenTime = [NSString stringWithFormat:@"%lldms",(domLoading - fetchStart)] ;
                            model.firstScreenTime = [NSString stringWithFormat:@"%lldms",(loadEventEnd - fetchStart)] ;
                            
                            

                            model.fetchStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"fetchStart"] doubleValue]/1000.0]];
                            model.domainLookupStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domainLookupStart"] doubleValue]/1000.0]];
                            model.domainLookupEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domainLookupEnd"] doubleValue]/1000.0]];
                            model.connectStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"connectStart"] doubleValue]/1000.0]];
                            model.connectEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"connectEnd"] doubleValue]/1000.0]];
                            model.requestStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"requestStart"] doubleValue]/1000.0]];
                            model.responseStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"responseStart"] doubleValue]/1000.0]];
                            model.responseEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"responseEnd"] doubleValue]/1000.0]];
                            model.domLoading = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domLoading"] doubleValue]/1000.0]];
                            model.domInteractive = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domInteractive"] doubleValue]/1000.0]];
                            model.domContentLoadedEventStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domContentLoadedEventStart"] doubleValue]/1000.0]];
                            model.domContentLoadedEventEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domContentLoadedEventEnd"] doubleValue]/1000.0]];
                            model.domComplete = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domComplete"] doubleValue]/1000.0]];
                            model.loadEventStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"loadEventStart"] doubleValue]/1000.0]];
                            model.loadEventEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"loadEventEnd"] doubleValue]/1000.0]];
                            
                            [[LLStorageManager sharedManager] saveModel:model complete:nil];
                        }
                    }] ;
                    
                    
                }
            }];
        }else{
            NSString *funcStr = @"function flatten(obj) {"
            "var ret = {}; "
            "for (var i in obj) { "
            "ret[i] = obj[i];"
            "}"
            "return ret;}";
            [webView evaluateJavaScript:funcStr completionHandler:^(NSString *_Nullable result, NSError * _Nullable error) {
                if (!error) {
                    [webView evaluateJavaScript:@"JSON.stringify(flatten(window.performance.timing))" completionHandler:^(NSString * _Nullable timingStr, NSError * _Nullable error) {
                        if (!error) {
                            [webView evaluateJavaScript:@"document.documentElement.outerHTML.toString()" completionHandler:^(NSString * _Nullable responseStr, NSError * _Nullable error) {
                                if(!error){
                                    NSDictionary<NSString*,NSString*> *dict = [LLTool dictWithJsonString:timingStr] ;
                                    
                                    //获取的性能参数
                                    //            long long navigationStart = [dict objectForKey:@"navigationStart"].longLongValue ;
                                    //            long long redirectStart = [dict objectForKey:@"redirectStart"].longLongValue ;
                                    //            long long redirectEnd = [dict objectForKey:@"redirectEnd"].longLongValue ;
                                    long long fetchStart = [dict objectForKey:@"fetchStart"].longLongValue ;
                                    long long domainLookupStart = [dict objectForKey:@"domainLookupStart"].longLongValue ;
                                    long long domainLookupEnd = [dict objectForKey:@"domainLookupEnd"].longLongValue ;
                                    long long connectStart = [dict objectForKey:@"connectStart"].longLongValue ;
                                    long long connectEnd = [dict objectForKey:@"connectEnd"].longLongValue ;
                                    long long requestStart = [dict objectForKey:@"requestStart"].longLongValue ;
                                    long long responseStart = [dict objectForKey:@"responseStart"].longLongValue ;
                                    long long responseEnd = [dict objectForKey:@"responseEnd"].longLongValue ;
                                    long long domLoading = [dict objectForKey:@"domLoading"].longLongValue ;
                                    long long domInteractive = [dict objectForKey:@"domInteractive"].longLongValue ;
                                    //            long long domContentLoadedEventStart = [dict objectForKey:@"domContentLoadedEventStart"].longLongValue ;
                                    //            long long domContentLoadedEventEnd = [dict objectForKey:@"domContentLoadedEventEnd"].longLongValue ;
                                    long long domComplete = [dict objectForKey:@"domComplete"].longLongValue ;
                                    long long loadEventStart = [dict objectForKey:@"loadEventStart"].longLongValue;
                                    long long loadEventEnd = [dict objectForKey:@"loadEventEnd"].longLongValue ;
                                    
                                    //白屏时间（domLoading - fetchStart）
                                    //1、domainLookupStart - fetchStart
                                    //2、domainLookupEnd - domainLookupStart
                                    //3、connectEnd - connectStart
                                    //4、responseStart - requestStart
                                    //5、domLoading - responseStart
                                    
                                    
                                    //首页时间（全部加载完毕）loadEventEnd - fetchStart
                                    //6、domInteractive - domLoading
                                    //7、domComplete - domInteractive
                                    //8、loadEventEnd - loadEventStart
                                    
                                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"fetchStart"] doubleValue]/1000.0];
                                    
                                    //            NSTimeZone *zone = [NSTimeZone systemTimeZone] ;
                                    //            NSInteger interval = [zone secondsFromGMTForDate:startDate] ;
                                    //            NSDate *localStartDate = [startDate dateByAddingTimeInterval:interval] ;
                                    
                                    LLWebViewModel *model = [[LLWebViewModel alloc] init];
                                    
                                    //时区已经转换了
                                    model.startDate = [LLTool stringFromDate:startDate];
                                    
                                    NSURLRequest *request = [NSURLRequest requestWithURL:webView.URL] ;
                                    
                                    model.url = request.URL;
                                    model.method = request.HTTPMethod;
                                    model.headerFields = [request.allHTTPHeaderFields mutableCopy];
                                    if (request.HTTPBody) {
                                        model.requestBody = [LLTool convertJSONStringFromData:request.HTTPBody];
                                    } else if (request.HTTPBodyStream) {
                                        NSData* data = [self dataFromInputStream:request.HTTPBodyStream];
                                        model.requestBody = [LLTool convertJSONStringFromData:data];
                                    }
                                    model.responseBody = responseStr ;
                                    model.appCacheTime = [NSString stringWithFormat:@"%lldms",(domainLookupStart - fetchStart)] ;
                                    model.domainLookupTime = [NSString stringWithFormat:@"%lldms",(domainLookupEnd - domainLookupStart)] ;
                                    model.connectTime =[NSString stringWithFormat:@"%lldms",(connectEnd - connectStart)] ;
                                    model.requestTime =[NSString stringWithFormat:@"%lldms",(responseStart - requestStart)] ;
                                    model.responseTime = [NSString stringWithFormat:@"%lldms",(responseEnd - responseStart)] ;
                                    
                                    model.domLoadingTime =  [NSString stringWithFormat:@"%lldms",(domLoading - responseStart)] ;
                                    model.domInteractiveTime = [NSString stringWithFormat:@"%lldms",(domInteractive - domLoading)] ;
                                    model.domCompleteTime = [NSString stringWithFormat:@"%lldms",(domComplete - domInteractive)] ;
                                    
                                    model.loadEventTime = [NSString stringWithFormat:@"%lldms",(loadEventEnd - loadEventStart)] ;
                                    model.whiteScreenTime = [NSString stringWithFormat:@"%lldms",(domLoading - fetchStart)] ;
                                    model.firstScreenTime = [NSString stringWithFormat:@"%lldms",(loadEventEnd - fetchStart)] ;
                                    
                                    
   
                                    model.fetchStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"fetchStart"] doubleValue]/1000.0]];
                                    model.domainLookupStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domainLookupStart"] doubleValue]/1000.0]];
                                    model.domainLookupEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domainLookupEnd"] doubleValue]/1000.0]];
                                    model.connectStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"connectStart"] doubleValue]/1000.0]];
                                    model.connectEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"connectEnd"] doubleValue]/1000.0]];
                                    model.requestStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"requestStart"] doubleValue]/1000.0]];
                                    model.responseStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"responseStart"] doubleValue]/1000.0]];
                                    model.responseEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"responseEnd"] doubleValue]/1000.0]];
                                    model.domLoading = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domLoading"] doubleValue]/1000.0]];
                                    model.domInteractive = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domInteractive"] doubleValue]/1000.0]];
                                    model.domContentLoadedEventStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domContentLoadedEventStart"] doubleValue]/1000.0]];
                                    model.domContentLoadedEventEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domContentLoadedEventEnd"] doubleValue]/1000.0]];
                                    model.domComplete = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"domComplete"] doubleValue]/1000.0]];
                                    model.loadEventStart = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"loadEventStart"] doubleValue]/1000.0]];
                                    model.loadEventEnd = [LLTool detailStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"loadEventEnd"] doubleValue]/1000.0]];
                                    
                                    [[LLStorageManager sharedManager] saveModel:model complete:nil];
                                }
                            }] ;
                        }
                    }];
                }
            }];
        }
        
        
    }
}

#pragma mark - Primary
- (NSData *)dataFromInputStream:(NSInputStream *)stream {
    NSMutableData *data = [[NSMutableData alloc] init];
    if (stream.streamStatus != NSStreamStatusOpen) {
        [stream open];
    }
    NSInteger readLength;
    uint8_t buffer[1024];
    while((readLength = [stream read:buffer maxLength:1024]) > 0) {
        [data appendBytes:buffer length:readLength];
    }
    return data;
}

@end




@implementation WKWebView (Swizzling)

- (void)swizzledNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    if (navigationDelegate) {
        _WKWebViewProxy *proxy = [[_WKWebViewProxy alloc] initWithTarget:navigationDelegate];
        objc_setAssociatedObject(navigationDelegate ,@"_WKWebViewProxy" ,proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self swizzledNavigationDelegate:(id<WKNavigationDelegate>)proxy];
    }else{
        [self swizzledNavigationDelegate:navigationDelegate];
    }
}

@end
