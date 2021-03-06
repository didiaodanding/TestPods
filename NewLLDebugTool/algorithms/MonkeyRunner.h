//
//  MonkeyRunner.h
//  LLDebugToolDemo
//
//  Created by haleli on 2019/6/5.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Element.h"
#import "Tree.h"
#import "App.h"
#import "FindElementTree.h"
#import "MonkeyAlgorithmDelegate.h"
#import "Actions.h"
NS_ASSUME_NONNULL_BEGIN

@interface MonkeyRunner : NSObject
@property (nonatomic , strong) Tree *preTree ;
@property (nonatomic , strong) Tree *curTree ;
@property (nonatomic , strong) Element *preElement ;
@property (nonatomic , strong) id<MonkeyAlgorithmDelegate> algorithm ;
@property (nonatomic , strong) NSMutableArray *blacklist ;
@property (nonatomic , strong) NSMutableArray *whitelist ;
@property (nonatomic, assign) NSTimeInterval interval ;
- (instancetype)initWithAlgorithm: (id<MonkeyAlgorithmDelegate>)algorithm blacklist:(NSMutableArray*)blacklist whitelist:(NSMutableArray*)whitelist interval :(NSTimeInterval)interval ;
-(void)runOneCocosRandomStep ;
-(void)runOneRandomStep ;
-(void)runOneQuickStep ;
@end

NS_ASSUME_NONNULL_END
