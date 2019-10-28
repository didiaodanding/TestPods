//
//  LLDebugLogger.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/5.
//  Copyright © 2019 li. All rights reserved.
//

#ifndef LLDebugLogger_h
#define LLDebugLogger_h

#import <Foundation/Foundation.h>
#import "LLConfig.h"

extern LL_Log_Callback ll_logger;

#define LL_LogEvent(format, ...) \
do{ \
char *str = NULL; \
char *formatStr = NULL; \
if(ll_logger != NULL){ \
int ret = asprintf(&str, format, ##__VA_ARGS__);\
if(ret > 0){ \
asprintf(&formatStr,"[NewLLDebugToolLogEvent]: %s",str); \
ll_logger(LLLogLevel_Event,formatStr); \
free(formatStr); \
free(str);\
}\
}\
}while(0)

#define LL_LogInfo(format, ...) \
do{ \
char *str = NULL; \
char *formatStr = NULL; \
if(ll_logger != NULL){ \
int ret = asprintf(&str, format, ##__VA_ARGS__);\
if(ret > 0){ \
asprintf(&formatStr,"[NewLLDebugToolLogInfo]: %s",str); \
ll_logger(LLLogLevel_Info,formatStr); \
free(formatStr); \
free(str);\
}\
}\
}while(0)

#define LL_LogDebug(format, ...) \
do{ \
char *str = NULL; \
char *formatStr = NULL; \
if(ll_logger != NULL){ \
int ret = asprintf(&str, format, ##__VA_ARGS__);\
if(ret > 0){ \
asprintf(&formatStr,"[NewLLDebugToolLogDebug]: %s",str); \
ll_logger(LLLogLevel_Debug,formatStr); \
free(formatStr); \
free(str);\
}\
}\
}while(0)


#endif



