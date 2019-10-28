//
//  MyScript.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/18.
//  Copyright © 2019 li. All rights reserved.
//

#import "LoginScript.h"
#import "Actions.h"

@implementation LoginScript
-(void)run{
    //UI 操作需要在主线程中执行
    if([[NSThread currentThread] isMainThread]){
        NSString* identifier = @"TBUIAutoTest_Property_UITextField_account" ;
        [UITextFieldActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:identifier text:@"Email"] ;
        
        identifier = @"TBUIAutoTest_Property_UITextField_password" ;
        [UITextFieldActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:identifier text:@"Password"] ;
        
        identifier = @"TBUIAutoTest_Property_UIButton_loginButton" ;
        [UIButtonActions tapButtonWithAccessibilityIdentifier:identifier] ;
    };
}
@end
