//
//  MonkeyScriptHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "MonkeyScriptHelper.h"
#import <objc/runtime.h>



@implementation LLTestCase
- (instancetype)initWithTarget:(id)target selector:(SEL)selector{
    if(self=[super init]){
        _target = target ;
        _selector = selector ;
    }
    return self ;
}
@end

static MonkeyScriptHelper *_instance = nil;

BOOL isLLTestFixtureOfClass(Class aClass, Class testCaseClass) {
    if (testCaseClass == NULL) return NO;
    BOOL iscase = NO;
    Class superclass;
    for (superclass = class_getSuperclass(aClass);
         !iscase && superclass;
         superclass = class_getSuperclass(superclass)) {
        iscase = superclass == testCaseClass ? YES : NO;
    }
    return iscase;
}

NSInteger LLClassSort(id a, id b, void *context) {
    const char *nameA = class_getName([a class]);
    const char *nameB = class_getName([b class]);
    return strcmp(nameA, nameB);
}

static NSInteger LLMethodSort(id a, id b, void *context) {
    NSInvocation *invocationA = a;
    NSInvocation *invocationB = b;
    const char *nameA = sel_getName([invocationA selector]);
    const char *nameB = sel_getName([invocationB selector]);
    return strcmp(nameA, nameB);
}

@interface MonkeyScriptHelper(){
    NSMutableArray *_testCaseClassNames;
}

@end

@implementation MonkeyScriptHelper

+ (instancetype)sharedHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MonkeyScriptHelper alloc] init];
        [_instance initial];
    });
    return _instance;
}

/**
 Initialize something
 */
- (void)initial {
    _testCaseClassNames = [NSMutableArray arrayWithObjects:
                           @"MonkeyScript",
                           nil];
}

- (NSArray *)loadAllTestCases {
    NSMutableArray *testCases = [NSMutableArray array];
    
    int count = objc_getClassList(NULL, 0);
    NSMutableData *classData = [NSMutableData dataWithLength:sizeof(Class) * count];
    Class *classes = (Class*)[classData mutableBytes];
    NSAssert(classes, @"Couldn't allocate class list");
    objc_getClassList(classes, count);
    
    for (int i = 0; i < count; ++i) {
        Class currClass = classes[i];
        
        id testcase = nil;
        
        if ([self isTestCaseClass:currClass]) {
            testcase = [[currClass alloc] init];
        } else {
            continue;
        }
        
        [testCases addObject:testcase];
    }
    
    return testCases;
}


- (BOOL)isTestCaseClass:(Class)aClass {
    for(NSString *className in _testCaseClassNames) {
        if (isLLTestFixtureOfClass(aClass, NSClassFromString(className))) return YES;
    }
    return NO;
}


- (LLTestCase *)loadTestFromTarget:(id)target {
    LLTestCase *testCase = nil;
    
    Class currentClass = [target class] ;
    if(currentClass && currentClass != [NSObject class]){
        unsigned int methodCount;
        Method *methods = class_copyMethodList(currentClass, &methodCount);
        if(methods){
            for (size_t i = 0; i < methodCount; ++i) {
                Method currMethod = methods[i];
                SEL sel = method_getName(currMethod);
                const char *name = sel_getName(sel);
                char *returnType = NULL;
                if ([[NSString stringWithUTF8String:name] isEqual:@"run"]) {
                    returnType = method_copyReturnType(currMethod);
                    if (returnType
                        && strcmp(returnType, @encode(void)) == 0
                        && method_getNumberOfArguments(currMethod) == 2) {
                        NSMethodSignature *sig = [[target class] instanceMethodSignatureForSelector:sel];
                        NSInvocation *invocation
                        = [NSInvocation invocationWithMethodSignature:sig];
                        [invocation setSelector:sel];
                        testCase = [[LLTestCase alloc] initWithTarget:target selector:invocation.selector] ;
                    }
                    if (returnType != NULL) free(returnType);
                }
            }
        }
        if (methods != NULL) free(methods);
    }
    return testCase ;
}

- (BOOL)runTestWithTarget:(id)target selector:(SEL)selector exception:(NSException **)exception interval:(NSTimeInterval *)interval
        reraiseExceptions:(BOOL)reraiseExceptions {

    if (reraiseExceptions) return [self runTestOrRaiseWithTarget:target selector:selector exception:exception interval:interval];

    NSDate *startDate = [NSDate date];
    NSException *testException = nil;
    
    @autoreleasepool {
        
        @try {
            // Runs the test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop

        } @catch (NSException *exception) {
            if (!testException) testException = exception;
        }
    }
    if (interval) *interval = [[NSDate date] timeIntervalSinceDate:startDate];
    if (exception) *exception = testException;
    BOOL passed = (!testException);
    return passed;
}

- (BOOL)runTestOrRaiseWithTarget:(id)target selector:(SEL)selector exception:(NSException **)exception interval:(NSTimeInterval *)interval {

    NSDate *startDate = [NSDate date];
    NSException *testException = nil;
    @autoreleasepool {
        // Runs the test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector];
#pragma clang diagnostic pop
    }

    if (interval) *interval = [[NSDate date] timeIntervalSinceDate:startDate];
    if (exception) *exception = testException;
    BOOL passed = (!testException);
    return passed;
}

@end

