//
//  LLANRModel.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/16.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLANRModel.h"

@implementation LLANRModel
-(instancetype _Nonnull)initWithName:(NSString *)name reason:(NSString *)reason stackSymbols:(NSString *)stackSymbols date:(NSString *)date duration:(NSString*)duration appInfos:(NSArray<NSArray<NSDictionary<NSString *,NSString *> *> *> *)appInfos identity:(NSString *)identity{
    if(self = [super init]){
        _name = name ;
        _reason = reason ;
        _stackSymbols = stackSymbols;
        _date = date ;
        _duration = duration ;
        _appInfos = [appInfos copy] ;
        _identity = identity ;
    }
    return self ;
}

-(NSString *)storageIdentity{
    return self.identity ;
}

@end
