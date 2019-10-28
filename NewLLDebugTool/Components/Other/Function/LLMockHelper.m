//
//  LLMockHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/1.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLMockHelper.h"
#import "LLDebugTool.h"
#import "OHHTTPStubs.h"

static LLMockHelper *_instance = nil;
static id<OHHTTPStubsDescriptor> mockStub = nil; // Note: no need to retain this value, it is retained by the OHHTTPStubs itself already

@implementation LLMockHelper
+(instancetype _Nonnull) sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMockHelper alloc] init] ;
    });
    return _instance ;
}

-(void)startMock{
    [[LLDebugTool sharedTool] saveMockSwitch:YES];
    //默认是关闭的
    [OHHTTPStubs setEnabled:YES];
    
    // Install
    mockStub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        // This stub will only configure stub requests for "*.txt" files
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        // Stub txt files with this
        OHHTTPStubsResponse *ohHTTPStubsResponse = [[[OHHTTPStubsResponse alloc] init]  isOnlineMock:true] ;
        return ohHTTPStubsResponse ;
    }];
    mockStub.name = @"mock stub";
}

-(void)stopMock{
    [[LLDebugTool sharedTool] saveMockSwitch:NO];
    //默认是关闭的
    [OHHTTPStubs setEnabled:NO];
    
    // Uninstall
    [OHHTTPStubs removeStub:mockStub];
}
@end
