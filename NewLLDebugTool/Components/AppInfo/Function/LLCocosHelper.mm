//
//  LLCocosHelper.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/12.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLCocosHelper.h"

NSNotificationName _Nonnull const LLCocosHelperDidUpdateAppInfosNotificationName = @"LLCocosHelperDidUpdateAppInfosNotificationName";
NSString * const LLCocosHelperFPSKey = @"LLCocosHelperFPSKey";

static bool g_enable = true;
static LLCocosHelper *_instance = nil ;

float frameRate = 0.0 ;
float secondsPerFrame = 0.0 ;
unsigned long currentCalls = 0 ;
unsigned long currentVerts = 0 ;

NSTimeInterval lastTime = 0.0 ;
int count = 0;
float fps = 0.0 ;

extern "C"
{
    void cocos_anr_hook(float _frameRate,float _secondsPerFrame,unsigned long _currentCalls,unsigned long _currentVerts) __attribute__((weak)) ;
    void cocos_anr_hook(float _frameRate,float _secondsPerFrame,unsigned long _currentCalls,unsigned long _currentVerts)
    {
        
        if(g_enable){
            
            if (lastTime < 0.000001) {
                lastTime = CFAbsoluteTimeGetCurrent();
                return;
            }
            count++;
            NSTimeInterval delta = CFAbsoluteTimeGetCurrent() - lastTime;
            
            if (delta < 1) return;
            lastTime = CFAbsoluteTimeGetCurrent();
            fps = count / delta;
            count = 0;
            
            
            fprintf(stderr,"haleli >>> cocos_anr_hook %.1f,%.3f,%6lu,%6lu",_frameRate,_secondsPerFrame,_currentCalls,_currentVerts) ;
            frameRate = _frameRate ;
            secondsPerFrame = _secondsPerFrame ;
            currentCalls = _currentCalls ;
            currentVerts = _currentVerts ;
            
            NSArray *cocosInfos = @[@{@"Frame Rate" :[NSString stringWithFormat:@"%.1f", frameRate]},
              @{@"Seconds Per Frame" : [NSString stringWithFormat:@"%.3f", secondsPerFrame]},
              @{@"Current Calls" : [NSString stringWithFormat:@"%6lu", currentCalls]},
              @{@"Current Verts" : [NSString stringWithFormat:@"%6lu", currentVerts]},
                                    @{@"FPS": [NSString stringWithFormat:@"%ld",(long)fps]}];
            if ([[NSThread currentThread] isMainThread]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LLCocosHelperDidUpdateAppInfosNotificationName object:cocosInfos userInfo:@{LLCocosHelperFPSKey:@(fps)}];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LLCocosHelperDidUpdateAppInfosNotificationName object:cocosInfos userInfo:@{LLCocosHelperFPSKey:@(fps)}];
                });
            }
        }
        
    }
}
@implementation LLCocosHelper
+(instancetype)sharedHelper{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken,^{
        _instance = [[LLCocosHelper alloc] init] ;
        [_instance initial] ;
    }) ;
    return _instance ;
}

/**
 Initialize something
 */
-(void)initial{
    
}

-(NSArray <NSDictionary *>*) cocosInfos{
    return @[@{@"Frame Rate" :[NSString stringWithFormat:@"%.1f", frameRate]},
             @{@"Seconds Per Frame" : [NSString stringWithFormat:@"%.3f", secondsPerFrame]},
             @{@"Current Calls" : [NSString stringWithFormat:@"%6lu", currentCalls]},
             @{@"Current Verts" : [NSString stringWithFormat:@"%6lu", currentVerts]},
             @{@"FPS": [NSString stringWithFormat:@"%ld",(long)fps]}];
}

-(void) setEnable:(BOOL)enable{
    if(g_enable != enable){
        g_enable = enable ;
    }
}

-(BOOL)isEnable{
    return g_enable ;
}

-(float)getFrameRate{
    if(g_enable){
        return frameRate ;
    }else{
        return 0.0 ;
    }
}

-(float)getSecondsPerFrame{
    if(g_enable){
        return secondsPerFrame ;
    }else{
        return 0.0 ;
    }
}

-(unsigned long)getCurrentCalls{
    if(g_enable){
        return currentCalls ;
    }else{
        return 0 ;
    }
}

-(unsigned long)getCurrentVerts{
    if(g_enable){
        return currentVerts ;
    }else{
        return 0 ;
    }
}

@end
