//
//  LLTool.m
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

#import "LLTool.h"
#import "LLConfig.h"
#import "LLMacros.h"
#import "LLRoute.h"
#import <CommonCrypto/CommonDigest.h>

static LLTool *_instance = nil;

static NSDateFormatter *_dateFormatter = nil;
static NSDateFormatter *_dayDateFormatter = nil;
static NSDateFormatter *_staticDateFormatter = nil;
static NSDateFormatter *_detailDateFormatter = nil;

static UILabel *_toastLabel = nil;
static UILabel *_loadingLabel = nil;
static NSTimer *_loadingTimer = nil;

static unsigned long long _absolutelyIdentity = 0;

@implementation LLTool

#pragma mark - Class Method
+ (NSString *)absolutelyIdentity {
    @synchronized (self) {
        _absolutelyIdentity++;
        return [NSString stringWithFormat:@"%lld",_absolutelyIdentity];
    }
}

+ (NSString *)stringFromDate:(NSDate *)date {
    return [[self dateFormatter] stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [[self dateFormatter] dateFromString:string];
}

+ (NSString *)dayStringFromDate:(NSDate *)date {
    return [[self dayDateFormatter] stringFromDate:date];
}

+ (NSDate *)dayDateFromString:(NSString *)string {
    return [[self dayDateFormatter] dateFromString:string];
}

+ (NSString *)staticStringFromDate:(NSDate *)date {
    return [[self staticDateFormatter] stringFromDate:date];
}

+ (NSDate *)staticDateFromString:(NSString *)string {
    return [[self staticDateFormatter] dateFromString:string];
}

+ (NSString *)detailStringFromDate:(NSDate*)date{
    return [[self detailDateFormatter] stringFromDate:date];
}

+ (NSDate *)detailDateFromString:(NSString *)string{
    return [[self detailDateFormatter] dateFromString:string];
}

+ (UIView *)lineView:(CGRect)frame superView:(UIView *)superView {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = LLCONFIG_TEXT_COLOR;
    if (superView) {
        [superView addSubview:view];
    }
    return view;
}

#pragma mark -json串转换成数组
+(NSArray *)arrayWithJsonString:(NSString *)json{
    if(!json) return nil ;
    
    NSError *error = nil ;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error] ;
    
    if(!arr){
        NSLog(@"parse json array error : %@" ,error) ;
    }
    
    return arr ;
}

#pragma mark -json串转换成字典
+(NSDictionary*)dictWithJsonString:(NSString *)json {
    if(!json) return nil;
    
    NSError* error = nil;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if(!dict) {
        NSLog(@"parse json dict error:%@", error);
    }
    
    return dict;
}

+ (NSString *)convertJSONStringFromData:(NSData *)data
{
    if ([data length] == 0) {
        return @"";
    }
    NSString *prettyString = @"";
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        // NSJSONSerialization escapes forward slashes. We want pretty json, so run through and unescape the slashes.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString ?: @"";
}

+ (NSString *)convertJSONStringFromDictionary:(NSDictionary *)dictionary {
    
    if (dictionary.allKeys.count == 0) {
        return @"";
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];

    NSString *jsonString = @"";
    
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString ?: @"";
}

+ (BOOL)createDirectoryAtPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager  defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [LLRoute logWithMessage:[NSString stringWithFormat:@"Create folder fail, path = %@, error = %@",path,error.description] event:kLLDebugToolEvent];
            NSAssert(!error, error.description);
            return NO;
        }
        return YES;
    }
    return YES;
}

+ (CGRect)rectWithPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint {
    
    CGFloat x = MIN(point.x, otherPoint.x);
    CGFloat y = MIN(point.y, otherPoint.y);
    CGFloat maxX = MAX(point.x, otherPoint.x);
    CGFloat maxY = MAX(point.y, otherPoint.y);
    CGFloat width = maxX - x;
    CGFloat height = maxY - y;
    // Return rect nearby
    CGFloat gap = 1 / 2.0;
    if (width == 0) {
        width = gap;
    }
    if (height == 0) {
        height = gap;
    }
    return CGRectMake(x, y, width, height);
}

+ (void)toastMessage:(NSString *)message toastTime:(CGFloat) toastTime{
    if (_toastLabel) {
        [_toastLabel removeFromSuperview];
        _toastLabel = nil;
    }
    
    __block UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, LL_SCREEN_WIDTH - 40, 100)];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.frame.size.width + 20, label.frame.size.height + 10);
    label.layer.cornerRadius = label.font.lineHeight / 2.0;
    label.layer.masksToBounds = YES;
    label.center = CGPointMake(LL_SCREEN_WIDTH / 2.0, LL_SCREEN_HEIGHT / 2.0);
    label.alpha = 0;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    [[self lastWindow] addSubview:label];
    _toastLabel = label;
    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(toastTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.1 animations:^{
                _toastLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [_toastLabel removeFromSuperview];
                _toastLabel = nil;
            }];
        });
    }];
}

+ (void)toastMessage:(NSString *)message {
    [self toastMessage:message toastTime:2.0] ;
}

+(UIWindow *)lastWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        //键盘window过滤掉
        if([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]){
            continue ;
        }
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    return [UIApplication sharedApplication].keyWindow;
}


+ (void)loadingMessage:(NSString *)message {
    if (_loadingLabel) {
        [_loadingLabel removeFromSuperview];
        _loadingLabel = nil;
    }
    
    __block UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, LL_SCREEN_WIDTH - 40, 100)];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.frame.size.width + 40, label.frame.size.height + 10);
    label.layer.cornerRadius = label.font.lineHeight / 2.0;
    label.layer.masksToBounds = YES;
    label.center = CGPointMake(LL_SCREEN_WIDTH / 2.0, LL_SCREEN_HEIGHT / 2.0);
    label.alpha = 0;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    [[self lastWindow] addSubview:label];
    _loadingLabel = label;
    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    [self startLoadingMessageTimer];
}

+ (void)hideLoadingMessage {
    if (_loadingLabel.superview) {
        [self removeLoadingMessageTimer];
        [UIView animateWithDuration:0.1 animations:^{
            _loadingLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [_loadingLabel removeFromSuperview];
            _loadingLabel = nil;
        }];
    }
}

+ (void)startLoadingMessageTimer {
    [self removeLoadingMessageTimer];
    _loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadingMessageTimerAction:) userInfo:nil repeats:YES];
}

+ (void)removeLoadingMessageTimer {
    if ([_loadingTimer isValid]) {
        [_loadingTimer invalidate];
        _loadingTimer = nil;
    }
}

+ (void)loadingMessageTimerAction:(NSTimer *)timer {
    if (_loadingLabel.superview) {
        if ([_loadingLabel.text hasSuffix:@"..."]) {
            _loadingLabel.text = [_loadingLabel.text substringToIndex:_loadingLabel.text.length - 3];
        } else {
            _loadingLabel.text = [_loadingLabel.text stringByAppendingString:@"."];
        }
    } else {
        [self removeLoadingMessageTimer];
    }
}

#pragma mark - Lazy load
+ (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [LLConfig sharedConfig].dateFormatter;
    }
    return _dateFormatter;
}

+ (NSDateFormatter *)dayDateFormatter {
    if (!_dayDateFormatter) {
        _dayDateFormatter = [[NSDateFormatter alloc] init];
        _dayDateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return _dayDateFormatter;
}

+ (NSDateFormatter *)staticDateFormatter {
    if (!_staticDateFormatter) {
        _staticDateFormatter = [[NSDateFormatter alloc] init];
        _staticDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _staticDateFormatter;
}

+ (NSDateFormatter *)detailDateFormatter{
    if(!_detailDateFormatter){
        _detailDateFormatter = [[NSDateFormatter alloc] init] ;
        _detailDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS" ;
    }
    return _detailDateFormatter ;
}

#pragma mark - DEPRECATED

+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLTool alloc] init];
    });
    return _instance;
}

- (NSString *)absolutelyIdentity {
    return [LLTool absolutelyIdentity];
}

- (NSString *)stringFromDate:(NSDate *)date {
    return [LLTool stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    return [LLTool dateFromString:string];
}

- (NSString *)dayStringFromDate:(NSDate *)date {
    return [LLTool dayStringFromDate:date];
}

- (NSDate *)staticDateFromString:(NSString *)string {
    return [LLTool staticDateFromString:string];
}

- (NSString *)staticStringFromDate:(NSDate *)date {
    return [LLTool staticStringFromDate:date];
}

- (void)toastMessage:(NSString *)message {
    [LLTool toastMessage:message];
}

+ (NSString *)md5:(NSString *)string {
    if(!string) {
        return @"";
    }
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

+(NSDictionary *)getWithRequest:(NSString*)request header:(NSDictionary*)header parameters:(NSDictionary*)parameters{
    
    //有参数
    if(parameters && [parameters count]!=0){
        request = [request stringByAppendingString:@"?"] ;
        for(NSString* key in parameters){
            NSString* value = [parameters objectForKey:key] ;
            NSString *param = [NSString stringWithFormat:@"%@=%@&",key,value] ;
            request = [request stringByAppendingString:param] ;
        }
        request = [request substringToIndex:  [request length] - 1 ] ;
    }
    
    //1、确定请求路径
    NSURL *url = [NSURL URLWithString:request];
    //2、创建可变的请求对象
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    //3、 设置请求方法
    requestM.HTTPMethod = @"GET";
    //4、设置请求头信息
    for(NSString *key in header){
        NSString* value = [header objectForKey:key] ;
         [requestM setValue:value forHTTPHeaderField:key] ;
    }
    
    //同步请求
    NSData *data= [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:nil] ;
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    NSDictionary *dict = [self dictWithJsonString:result] ;
    return dict ;
}

+(NSDictionary *)postWithRequest:(NSString*)request header:(NSDictionary*)header parameters:(NSDictionary*)parameters{
    //1、确定请求路径
    NSURL *url = [NSURL URLWithString:request];
    //2、创建可变的请求对象
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    //3、 设置请求方法
    requestM.HTTPMethod = @"POST";
    //4、设置请求头信息
    for(NSString *key in header){
        NSString* value = [header objectForKey:key] ;
        [requestM setValue:value forHTTPHeaderField:key] ;
    }
    //5、设置请求体信息
    requestM.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    //同步请求
    NSData *data= [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:nil] ;
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    NSDictionary *dict = [self dictWithJsonString:result] ;
    return dict ;
}
@end
