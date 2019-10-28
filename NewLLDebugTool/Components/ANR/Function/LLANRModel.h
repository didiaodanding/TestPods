//
//  LLANRModel.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/8/16.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLStorageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLANRModel : LLStorageModel

/**
 ANR Name
 **/
@property (copy,nonatomic,nullable) NSString *name ;

/**
 ANR reason
 **/
@property (copy,nonatomic,nullable) NSString *reason ;

/**
 ANR stack symbols
 **/
@property (copy,nonatomic,nullable) NSString *stackSymbols ;

/**
 ANR Date (yyyy-MM-dd HH:mm:ss)
 **/
@property (copy,nonatomic,nullable) NSString *date ;


/**
 ANR duration
 **/
@property (copy,nonatomic,nullable) NSString *duration ;

/**
 App Infos
 **/
@property (strong,nonatomic,readonly , nullable) NSArray <NSArray<NSDictionary<NSString *,NSString*> * > *> *appInfos ;

/**
 Model identity
 **/
@property (copy,nonatomic,readonly,nonnull) NSString *identity ;

-(instancetype _Nonnull) initWithName:(NSString*_Nullable)name reason:(NSString*_Nullable)reason stackSymbols:(NSString *_Nullable)stackSymbols date:(NSString *_Nullable)date duration:(NSString*)duration appInfos:(NSArray <NSArray<NSDictionary<NSString *,NSString*> * > *> *_Nullable)appInfos identity:(NSString*_Nullable)identity ;


@end
NS_ASSUME_NONNULL_END
