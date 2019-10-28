//
//  LLCocosHelper.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/12.
//  Copyright © 2019 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSNotificationName _Nonnull const LLCocosHelperDidUpdateAppInfosNotificationName;
UIKIT_EXTERN NSString *_Nonnull const LLCocosHelperFPSKey ;

/**
 Monitoring cocos's properties.
 */
@interface LLCocosHelper : NSObject
/**
 Singleton to monitoring cocosinfos .
 
 @return Singleton
 */

+(instancetype _Nonnull)sharedHelper ;

/**
 Get cocos infos . include "frame rate" , "seconds per frame" , "current calls", "current verts". Get these infos need change cocos engine code to support hook
 */
- (NSArray <NSDictionary *>* _Nonnull)cocosInfos;

/**
 Set enable to monitoring cocos info
 */
-(void) setEnable:(BOOL)enable ;

/**
 return enable to monitoring cocos info
 **/
-(BOOL) isEnable ;

/**
 return frame rate
 **/
-(float)getFrameRate ;

/**
 return seconds per frame
 **/
-(float)getSecondsPerFrame ;

/**
 return draw calls count
 **/
-(unsigned long)getCurrentCalls ;

/**
 return verts
 **/
-(unsigned long)getCurrentVerts ;
@end

