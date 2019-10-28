//
//  MonkeyRunner.m
//  LLDebugToolDemo
//
//  Created by haleli on 2019/6/5.
//  Copyright © 2019 li. All rights reserved.
//

#import "MonkeyRunner.h"
#import "LLDebugTool.h"
#import "LLTool.h"
#import "CCMonkeyHelper.h"
#import "LLIOSMonkeySettingHelper.h"
#import "MonkeyScriptHelper.h"
@interface MonkeyRunner(){
    NSMutableDictionary* _allMonkeyScriptDictWithClass ;
    NSMutableDictionary *_allMonkeyScriptDictWithVC ;
}
@end

@implementation MonkeyRunner

- (instancetype)initWithAlgorithm: (id<MonkeyAlgorithmDelegate>)algorithm blacklist:(NSMutableArray*)blacklist whitelist:(NSMutableArray*)whitelist interval :(NSTimeInterval)interval{
    self = [super init] ;
    if(self){
        _preTree = nil ;
        _curTree = nil ;
        _preElement = nil ;
        _algorithm = algorithm ;
        _blacklist =  blacklist ;
        if(!_blacklist){
            _blacklist = [[NSMutableArray alloc] init] ;
        }
        [_blacklist addObjectsFromArray:@[@"UIActivityViewController",@"UIAlertController",@"TestCrashViewController",@"LLOtherVC",@"UIViewController",@"debugCenter",@"parentCenter"]] ;
        _whitelist = whitelist ;
        if(!_whitelist){
            _whitelist = [[NSMutableArray alloc] init] ;
        }
        [_whitelist addObjectsFromArray:@[@"reading_action",@"school_action"]] ;
        _interval = interval ;
        
        //通过Runtime获取到的MonkeyScript子类列表转换为字典{classStr,class}
        NSArray *monkeyClassList = [[MonkeyScriptHelper sharedHelper] loadAllTestCases] ;
        _allMonkeyScriptDictWithClass =  [[NSMutableDictionary alloc] initWithCapacity:monkeyClassList.count];
        for(int i=0;i<monkeyClassList.count;i++){
            id target = [monkeyClassList objectAtIndex:i] ;
            NSString *str = NSStringFromClass([target class]) ;
            [_allMonkeyScriptDictWithClass addEntriesFromDictionary:@{str:target}] ;
        }
        
        
        //将用户在脚本界面设置的列表转换为字典{controllerName:scriptName}
        NSMutableArray<NSDictionary<NSString *,NSString*>*> *monkeyScriptList = [LLIOSMonkeySettingHelper sharedHelper].monkeySettingModel.monkeyScriptList ;
        _allMonkeyScriptDictWithVC = [[NSMutableDictionary alloc]  initWithCapacity:monkeyScriptList.count] ;
        for(int i=0;i<monkeyScriptList.count;i++){
            [_allMonkeyScriptDictWithVC addEntriesFromDictionary:[monkeyScriptList objectAtIndex:i]] ;
        }
    }
    return self ;
}

-(void)tryFindingWhiteChildren:(out NSMutableArray *)whiteChildren finallyChildren:(out NSMutableArray*)finallyChildren backChild:(out NSMutableDictionary*)backChild withOriginalChildren:(NSArray*)children{
    //1、是否包含back控件，如果包含，保存back控件用于返回，进行下一次循环。
    //2、是否包含白名单控件，如果包含，添加白名单控件到whiteChildren
    //3、是否包含黑名单控件，如果包含，去除黑名单的控件，如果不包含，添加控件到finallyChildren
    
    for(int i=0;i<children.count;i++){
        //获取控件名字
        NSDictionary *child = [children objectAtIndex:i] ;
        NSString *name = [child objectForKey:@"name"] ;
        
        //back控件
        if([[name lowercaseString] containsString:@"back"]){
            [backChild addEntriesFromDictionary:child] ;
            continue ;
        }
        //白名单控件
        if([_whitelist containsObject:name]){
            NSLog(@"捕获到白名单控件，一定要点击白名单的控件") ;
            [whiteChildren addObject:child] ;
        }
        if([_blacklist containsObject:name]){
            NSLog(@"捕获到黑名单控件,不添加到数组里面") ;
        }else{
            [finallyChildren addObject:child] ;
        }
        
        
    }
}


//cocos monkey
-(void)runOneCocosRandomStep{
    
    //判断monkey运行时间是否结束
    NSDate *currentDate = [NSDate date] ;
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:[LLDebugTool sharedTool].startDate];
    if(_interval > 0 && _interval < interval){
        [LLTool loadingMessage:@"monkey运行时间已完成，请杀掉进程重启app"];
        return ;
    }
    
    UIViewController *controller = [FindTopController topController] ;
    //cocos 页面
    if([controller isKindOfClass:[[UIApplication sharedApplication].keyWindow.rootViewController class]]){
        NSLog(@"haleli >>>> 页面 属于 cocos") ;
        int width = [[UIScreen mainScreen] bounds].size.width ;
        int height = [[UIScreen mainScreen] bounds].size.height ;
        int x = arc4random() % width  ;
        int y = arc4random() % height ;
        int seed = arc4random() % 10 ;
        
        //查找cocos控件树
        if([LLDebugTool sharedTool].runScript && [LLDebugTool sharedTool].jsEvaluateFunc){
            NSDictionary *tree = [[CCMonkeyHelper sharedHelper] dumpVisibleAndTouchableNode] ;
            NSArray *children = [tree objectForKey:@"children"] ;
            
            NSMutableArray *whiteChildren = [[NSMutableArray alloc] init] ;
            NSMutableArray *finallyChildren = [[NSMutableArray alloc] init] ;
            NSMutableDictionary *backChild = [[NSMutableDictionary alloc] init] ;
           
            [self tryFindingWhiteChildren:whiteChildren finallyChildren:finallyChildren backChild:backChild withOriginalChildren:children] ;
            
            //需要点击的控件
            NSDictionary *child = nil ;
            //含有白名单控件
            if([whiteChildren count] != 0){
                int random = arc4random() % ([whiteChildren count]);
                child = [whiteChildren objectAtIndex:random] ;
                
                NSLog(@"haleli >>>> test monkey,ui action , click name : %@ ",[child objectForKey:@"name"]) ;
                //有可点击的控件
            }else if([finallyChildren count] != 0){
                //20%的概率发送滑动事件
                if(seed<2){
                    int endX = arc4random() % width ;
                    int endY = arc4random() % height ;
                    NSLog(@"haleli >>>> test monkey,swip(%d,%d) to (%d,%d)",x,y,endX,endY) ;
                    [self swapWithPoint:CGPointMake(x, y) endPoint:CGPointMake(endX, endY)] ;
                    //10%的返回事件
                }else if(seed<3){
                    NSLog(@"haleli >>>> test monkey,back action") ;
                    if(backChild==nil || [backChild count]==0){
                        [self touchesWithPoint:CGPointMake(344,32)];
                        return ;
                    }else{
                        child = backChild ;
                    }
                    //50%的概率发送click事件
                }else if(seed<8){
                    NSLog(@"haleli >>>> test monkey,click(%d,%d)",x,y) ;
                    [self touchesWithPoint:CGPointMake(x,y)];
                    //20%的概率发送UI事件
                }else if(seed < 10){
                    int random = arc4random() % [finallyChildren count];
                    child = [finallyChildren objectAtIndex:random] ;
                    
                    NSLog(@"haleli >>>> test monkey,ui action , click name : %@ ",[child objectForKey:@"name"]) ;
                }
            }else{
                //30%的概率发送滑动事件
                if(seed<3){
                    int endX = arc4random() % width ;
                    int endY = arc4random() % height ;
                    NSLog(@"haleli >>>> test monkey,swip(%d,%d) to (%d,%d)",x,y,endX,endY) ;
                    [self swapWithPoint:CGPointMake(x, y) endPoint:CGPointMake(endX, endY)] ;
                    //10%的返回事件
                }
                else if(seed<4){
                    NSLog(@"haleli >>>> test monkey,back action") ;
                    if(backChild==nil || [backChild count]==0){
                        [self touchesWithPoint:CGPointMake(344,32)];
                    }else{
                        child = backChild ;
                    }
                    //60%的概率发送click事件
                }
                else if(seed<10){
                    NSLog(@"haleli >>>> test monkey,click(%d,%d)",x,y) ;
                    [self touchesWithPoint:CGPointMake(x,y)];
                }
            }
            if(child){
                NSDictionary *payload = [child objectForKey:@"payload"] ;
                
                NSArray *pos = [payload objectForKey:@"pos"] ;
                
                
                double x = [[pos objectAtIndex:0] doubleValue] * width;
                double y = [[pos objectAtIndex:1] doubleValue] * height;
                [self touchesWithPoint:CGPointMake(x,y)];
            }
        }else{
            NSLog(@"cocos creator don't get tree") ;
            //30%的概率发送滑动事件
            if(seed<3){
                int endX = arc4random() % width ;
                int endY = arc4random() % height ;
                NSLog(@"haleli >>>> test monkey,swip(%d,%d) to (%d,%d)",x,y,endX,endY) ;
                [self swapWithPoint:CGPointMake(x, y) endPoint:CGPointMake(endX, endY)] ;
                //10%的返回事件
            }
            else if(seed<4){
                NSLog(@"haleli >>>> test monkey,back action") ;
                [self touchesWithPoint:CGPointMake(344,32)];
                
                //60%的概率发送click事件
            }
            else if(seed<10){
                NSLog(@"haleli >>>> test monkey,click(%d,%d)",x,y) ;
                [self touchesWithPoint:CGPointMake(x,y)];
            }
        }
        //ios 页面
    }else{
        NSLog(@"haleli >>>> 页面 属于 iOS") ;
        [self runOneRandomStep] ;
    }
}

//随机便利算法的一步
-(void)runOneRandomStep{
    
    //判断monkey运行时间是否结束
    NSDate *currentDate = [NSDate date] ;
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:[LLDebugTool sharedTool].startDate];
    if(_interval > 0 && _interval < interval){
        [LLTool loadingMessage:@"monkey运行时间已完成，请杀掉进程重启app"];
        return ;
    }

    NSString* treeId =[[App sharedApp] getCurrentTreeId] ;
    
    //执行脚本逻辑
    if(treeId){
        NSString *scriptName = [_allMonkeyScriptDictWithVC objectForKey:treeId] ;
        if(scriptName){
            NSException *exception = nil;
            NSTimeInterval interval ;
            id target = [_allMonkeyScriptDictWithClass objectForKey:scriptName] ;
            if(target){
                LLTestCase *test = [[MonkeyScriptHelper sharedHelper] loadTestFromTarget:target];
                if(test){
                    [[MonkeyScriptHelper sharedHelper] runTestWithTarget:test.target selector:test.selector exception:&exception interval:&interval reraiseExceptions:NO] ;
                    return ;
                }
            }
        }
    }
    
    
    //黑名单的控件不允许点击
    if(treeId){
        if([_blacklist containsObject:treeId]){
            NSLog(@"点击到黑名单控件或者UIActivityViewController或者UIAlertController") ;
            _preTree = nil ;
            _curTree = nil ;
            [BackActions back] ;
            return ;
        }
    }
    
    int width = [[UIScreen mainScreen] bounds].size.width ;
    int height = [[UIScreen mainScreen] bounds].size.height ;
    int x = arc4random() % width  ;
    int y = arc4random() % height ;
    int seed = arc4random() % 10 ;


    //查找控件树
    Tree* tree =[[App sharedApp] getCurrentTree] ;
    
    //从树里面选择一个控件
    Element *element = [_algorithm chooseElementFromTree:tree] ;
    
    if(element == nil){
        //30%的概率发送滑动事件
        if(seed<3){
            int endX = arc4random() % width ;
            int endY = arc4random() % height ;
            NSLog(@"haleli >>>> test monkey,swip(%d,%d) to (%d,%d)",x,y,endX,endY) ;
            [self swapWithPoint:CGPointMake(x, y) endPoint:CGPointMake(endX, endY)] ;
            //10%的返回事件
        }
        else if(seed<4){
            NSLog(@"haleli >>>> test monkey,back action") ;
            [BackActions back] ;
            //60%的概率发送click事件
        }
        else if(seed<10){
            NSLog(@"haleli >>>> test monkey,click(%d,%d)",x,y) ;
            [self touchesWithPoint:CGPointMake(x,y)];
        }
    }else{
        //20%的概率发送滑动事件
        if(seed<2){
            int endX = arc4random() % width ;
            int endY = arc4random() % height ;
            NSLog(@"haleli >>>> test monkey,swip(%d,%d) to (%d,%d)",x,y,endX,endY) ;
            [self swapWithPoint:CGPointMake(x, y) endPoint:CGPointMake(endX, endY)] ;
            //10%的返回事件
        }
        else if(seed<3){
            NSLog(@"haleli >>>> test monkey,back action") ;
            [BackActions back] ;
            //50%的概率发送click事件
        }
        else if(seed<8){
            NSLog(@"haleli >>>> test monkey,click(%d,%d)",x,y) ;
            [self touchesWithPoint:CGPointMake(x,y)];
            //20%的概率发送UI事件
        }else if(seed<10){
            @try {
                [self OperateElement:element] ;
            } @catch (NSException *exception) {
                NSLog(@"haleli >>>> test monkey,exception : %@",exception.name);
            } @finally {
                ;
            }
        }
    }
}

//快速遍历算法的一步
-(void)runOneQuickStep{
    
    //判断monkey是否已经遍历完所有控件
    if([App sharedApp].isClickedDone){
        [LLTool loadingMessage:@"monkey已经遍历完所有控件，请杀掉进程重启app"];
        return ;
    }
    
    
    NSDate *currentDate = [NSDate date] ;
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:[LLDebugTool sharedTool].startDate];
    if(_interval > 0 && _interval < interval){
        [LLTool loadingMessage:@"monkey运行时间已完成，请杀掉进程重启app"];
        return ;
    }
    
    Tree* tree =[[App sharedApp] getCurrentTree] ;
    
    if(tree){
        if([_blacklist containsObject:tree.treeID]){
            NSLog(@"点击到黑名单控件或者UIActivityViewController或者UIAlertController") ;
            _preTree = nil ;
            _curTree = nil ;
            [BackActions back] ;
            return ;
        }
    }
    //更新树
    [[App sharedApp] updateTree: tree] ;

    if(_preTree && _preElement && tree && !_preElement.isMenu && [_preTree isSameTreeId:tree]){
        _preElement.isBack = YES ;
        _preTree = nil ;
        _curTree = nil ;
    }

    if(_curTree && tree && _preElement && ![_curTree isSameTreeId:tree] && !_preElement.isBack && _preElement.isMenu){
        _preElement.isJumped = true ;
        _preTree = nil ;
        _curTree = nil ;
    }else if(_curTree && tree && _preElement && ![_curTree isSameTreeId:tree] && !_preElement.isBack && !_preElement.isMenu){
        _preElement.isJumped = true ;
        _preElement.toTree = [[App sharedApp] getTree:tree.treeID] ;
    }else if(_curTree && tree && _preElement && ![_curTree isSameTree: tree] && !_preElement.isBack && !_preElement.isMenu){
        _preElement.isTreeChanged = true ;
    }

    if(tree && _curTree && ![tree isSameTreeId:_curTree]){
        _preTree = _curTree ;
    }

    _curTree = tree ;

    //从树里面选择一个控件
    Element *element = [_algorithm chooseElementFromTree:_curTree] ;

    if(element == nil){
        //需要返回上一个界面
        _preTree = nil ;
        _curTree = nil ;
        if(![BackActions back]){
            //返回失败，表示已经遍历完毕
            [App sharedApp].isClickedDone = true ;
        }

    }else{
        _preElement = element ;
        
        @try {
             [self OperateElement:element] ;
        } @catch (NSException *exception) {
            NSLog(@"haleli >>>> test monkey,exception : %@",exception.name);
        } @finally {
            ;
        }
        
        element.clickTimes = element.clickTimes + 1 ;
        if([element.type isEqual:@"UITabBarButton"]){
            element.isMenu = true ;
        }
    }
    
}

-(void)OperateElement:(Element *)element{
  
    NSString *accessibilityIdentifier = element.elementId;
    NSString *className = element.type ;

    if([className isEqual:@"UITableView"]){
        NSLog(@"haleli >>>> test monkey,UITableView swipe action") ;
        [UITableViewActions swipeTableViewWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UISwitch"]){
        NSLog(@"haleli >>>> test monkey,UISwitch tap action") ;
        [UISwitchActions setSwitchWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UITabBar"]){
        NSLog(@"haleli >>>> test monkey,UITabBar tap action") ;
        [UITabBarActions tapTabBarWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UINavigationBar"]){
        NSLog(@"haleli >>>> test monkey,UINavigationBar tap action") ;
        [UINavigationBarActions tapNavigationBarWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UITextField"]){
        NSLog(@"haleli >>>> test monkey,UITextFieldActions enter text action") ;
        [UITextFieldActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UITextView"]){
        NSLog(@"haleli >>>> test monkey,UITextViewActions enter text action") ;
        [UITextViewActions clearTextFromAndThenEnterTextWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UIButton"]){
        NSLog(@"haleli >>>> test monkey,UIButton tap action") ;
        [UIButtonActions tapButtonWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UISegmentedControl"]){
        NSLog(@"haleli >>>> test monkey,UISegmentedControl tap action") ;
        [UISegmentedControlActions tapSegmentedControlWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UICollectionView"]){
        NSLog(@"haleli >>>> test monkey,UICollectionView swipe action") ;
        [UICollectionViewActions swipeCollectionViewWithAccessibilityIdentifier:accessibilityIdentifier] ;
        
    }else if([className isEqual:@"UITableViewCell"]){
        NSLog(@"haleli >>>> test monkey,UITableViewCell tap action") ;
        if([element.info count] > 0){
            NSInteger section = [[element.info objectForKey:@"section"] intValue];
            NSInteger row = [[element.info objectForKey:@"row"] intValue];
            NSString *accessibilityIdentifier = [element.info objectForKey:@"accessibilityIdentifier"] ;
            [UITableViewCellActions tapTableViewCellWithAccessibilityIdentifier:accessibilityIdentifier section:section row:row] ;
        }
    }else if([className isEqual:@"UICollectionViewCell"]){
        NSLog(@"haleli >>>> test monkey,UICollectionViewCell tap action") ;
        if([element.info count] > 0){
            NSInteger section = [[element.info objectForKey:@"section"] intValue];
            NSInteger item = [[element.info objectForKey:@"item"] intValue];
            NSString *accessibilityIdentifier = [element.info objectForKey:@"accessibilityIdentifier"] ;
            [UICollectionViewCellActions tapCollectionViewCellWithAccessibilityIdentifier:accessibilityIdentifier section:section item:item] ;
        }
    }else if([className isEqual:@"UITabBarButton"]){
        NSLog(@"haleli >>>> test monkey,UITabBarButton tap action") ;
        [UITabBarButtonActions tapTabBarButtonWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }else if([className isEqual:@"UIPickerView"]){
        NSLog(@"haleli >>>> test monkey,UIPickerView select action") ;
        [UIPickerViewActions selectPickerViewRowWithAccessibilityIdentifier:accessibilityIdentifier] ;
    }
    else{
        NSLog(@"haleli >>>> test monkey,no support view : %@",className) ;
    }
}


-(void)touchesWithPoint:(CGPoint)zspoint{
    [ZSFakeTouch beginTouchWithPoint:zspoint];
    [ZSFakeTouch endTouchWithPoint:zspoint];
}

-(void)swapWithPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    [ZSFakeTouch beginTouchWithPoint:startPoint];
    [ZSFakeTouch moveTouchWithPoint:endPoint];
    [ZSFakeTouch endTouchWithPoint:endPoint];
}
@end
