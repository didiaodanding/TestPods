//
//  IOSUITest.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/22.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHUnit.h"
#import "Actions.h"
#import "LLHomeWindow.h"
#import "LLConfig.h"

@interface IOSUITest : GHTestCase {
    
}
@end

@implementation IOSUITest

- (void)setUpClass{
}

- (void)test1{
    //UI 操作需要在主线程中执行
    for(int i=0;i<4;i++){
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString* identifier = @"TBUIAutoTest_Property_UITableView_tableView" ;
            [UITableViewCellActions tapTableViewCellWithAccessibilityIdentifier:identifier section:i row:0] ;
            [BackActions back] ;
        });
    }
}

- (void)test2{
    //UI 操作需要在主线程中执行
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString* identifier = @"TBUIAutoTest_Property_UITextField_account" ;
        [UITextFieldActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:identifier text:@"Email"] ;
        
        identifier = @"TBUIAutoTest_Property_UITextField_password" ;
        [UITextFieldActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:identifier text:@"Password"] ;
        
        identifier = @"TBUIAutoTest_Property_UIButton_loginButton" ;
        [UIButtonActions tapButtonWithAccessibilityIdentifier:identifier] ;
        
    });
}
- (void)test3{
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNil(string1, nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
    [NSThread sleepForTimeInterval:5] ;
}


- (void)tearDown{

}
- (void) tearDownClass{

}


@end
