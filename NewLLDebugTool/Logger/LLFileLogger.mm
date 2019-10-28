//
//  LLFileLogger.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/6.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLFileLogger.h"
#import "LLDebugLogger.h"
#import <sys/time.h>
#import <stdio.h>
#include <fstream>
#include <string>
#include <vector>
#include <map>

class CFileLogWriter{
public:
    CFileLogWriter(){
        NSString* cachePath = getLogDir();
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:NULL]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        m_fp = NULL;
        m_lastDate = NULL;
    }
    ~CFileLogWriter(){
    }
    
    void addLog(NSString* str)
    {
        if (str.length <= 0) {
            return;
        }
        
        NSMutableString* tmp = [NSMutableString stringWithString:str];
        [tmp replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, tmp.length)];
        
        const char* log = [tmp cStringUsingEncoding:NSASCIIStringEncoding];
        
        if (!log) {
            log = "unnormal string.";
        }
        
        static NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
        });
        
        NSDate* date = [NSDate date];
        NSString* datestr = [dateFormat stringFromDate:date];
        NSArray* arr = [datestr componentsSeparatedByString:@"-"];
        
        double timeStamp = [date timeIntervalSince1970];
        struct tm timeNow = { 0 };
        
        if (arr.count == 3) {
            timeNow.tm_year = [[arr firstObject] intValue];
            timeNow.tm_mon = [[arr objectAtIndex:1] intValue];
            timeNow.tm_mday = [[arr objectAtIndex:2] intValue];
        }
        else
        {
            if (m_lastDate) {
                timeNow = *m_lastDate;
            }
            else
            {
                //时间异常
                return;
            }
        }
        
        
        bool anothorDay = false;
        
        if (!m_lastDate) {
            m_lastDate = new struct tm(timeNow);
            anothorDay = true;
        }
        else
        {
            if (m_lastDate->tm_year != timeNow.tm_year || m_lastDate->tm_mon != timeNow.tm_mon || m_lastDate->tm_mday != timeNow.tm_mday) {
                anothorDay = true;
                delete m_lastDate;
                m_lastDate = new struct tm(timeNow);
            }
        }
        
        if (anothorDay) {
            char buf[256] = {0};
            sprintf(buf, "%d%02d%02d.log",m_lastDate->tm_year,m_lastDate->tm_mon,m_lastDate->tm_mday);
            openLogFile(buf);
        }
        
        if (m_fp) {
            fprintf(m_fp, "%f\t%s\n",timeStamp,log);
        }
    }
    
    void flushLog()
    {
        if (m_fp) {
            fflush(m_fp);
        }
    }
    
    void closeLog()
    {
        if (m_fp) {
            fflush(m_fp);
            fclose(m_fp);
            m_fp = NULL;
        }
    }
    
    static void getLog(NSString* beginDay, unsigned int beginTime, NSString* endDay,unsigned int endTime, NSMutableData* data,unsigned int size)
    {
        if (!beginDay || !endDay || !data) {
            LL_LogDebug("NewLLDebugTool log report : error param.") ;
            return;
        }
        
        if ([beginDay isEqualToString:endDay]) {
            getLog(beginDay, beginTime, endTime, data,size);
        }
        else
        {
            unsigned int timeStamp = [LLFileLogger getTimestampWithDateStr:beginDay hour:23 min:59 sec:59];
            getLog(beginDay, beginTime, timeStamp, data,size);
            
            int beginDayValue = [beginDay intValue];
            int endDayValue = [endDay intValue];
            
            while (endDayValue - beginDayValue > 1) {
                ++beginDayValue;
                NSString* day = [NSString stringWithFormat:@"%d",beginDayValue];
                timeStamp = [LLFileLogger getTimestampWithDateStr:day hour:0 min:0 sec:0];
                unsigned int endStamp = [LLFileLogger getTimestampWithDateStr:day hour:23 min:59 sec:59];
                getLog(day, timeStamp, endStamp, data,size);
            }
            
            timeStamp = [LLFileLogger getTimestampWithDateStr:endDay hour:0 min:0 sec:0];
            getLog(endDay, timeStamp, endTime, data,size);
        }
    }
    
    static NSString* getLogDir()
    {
        return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/LLDebugToolLog"];
    }
private:
    void openLogFile(const char* logFile)
    {
        NSString* cachePath = [NSString stringWithFormat:@"%@/%s",getLogDir(),logFile];
        
        if (m_fp) {
            fclose(m_fp);
        }
        
        m_fp = fopen([cachePath UTF8String], "a+");
    }
    
    static void getLog(NSString* day,unsigned int beginTime,unsigned int endTime,NSMutableData* data,unsigned int size)
    {
        if (data.length >= size) {
            LL_LogDebug("NewLLDebugTool log report : log size exceed limit.");
            return;
        }
        
        LL_LogDebug("NewLLDebugTool log report : fetch log begin.");
        
        NSString* logPath = [getLogDir() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log",day]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:logPath isDirectory:NULL]) {
            LL_LogDebug("NewLLDebugTool log report : file not exist at %s",[logPath UTF8String]);
            return;
        }
        
        std::ifstream infile([logPath UTF8String]);
        
        if (!infile.is_open()) {
            LL_LogDebug("NewLLDebugTool open failed! with error : %d",errno);
            return;
        }
        
        bool logBegin = false;
        
        while (!infile.eof()) {
            std::string line;
            std::getline(infile,line);
            unsigned int timeStamp = atoi(line.c_str());
            
            if ((timeStamp >= beginTime && timeStamp <= endTime)) {
                logBegin = true;
                [data appendBytes:line.c_str() length:line.length()];
                [data appendBytes:"\n" length:1];
            }
            
            if (timeStamp > endTime) {
                if(line.find('.') != 10 )
                {
                    if (logBegin) {
                        [data appendBytes:line.c_str() length:line.length()];
                        [data appendBytes:"\n" length:1];
                    }
                    continue;
                }
                else
                {
                    break;
                }
            }
            
            if (data.length >= size) {
                break;
            }
        }
        
        infile.close();
    }
private:
    FILE* m_fp;
    struct tm* m_lastDate;
};

@interface LLFileLogger ()
{
    CFileLogWriter* _logWritter;
    dispatch_queue_t _queue;
}
@end

@implementation LLFileLogger

typedef void(^threadTask)(void);

-(void)work:(threadTask)task synchronous:(BOOL)synchronous{
    //Check thread.
    if(!synchronous && [[NSThread currentThread] isMainThread]){
        dispatch_async(_queue, ^{
            [self work:task synchronous:synchronous] ;
        });
        return ;
    }
    task() ;
}

-(id)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("LLDebugTool.LLFileLogger", DISPATCH_QUEUE_SERIAL);
        [self work:^{
           
            self->_logWritter = new CFileLogWriter;
        } synchronous:NO] ;
        
        [self addLog:@"********** BEGIN LOG **********"];
        [self checkOutdateFile];
    }
    
    return self;
}
-(void)dealloc
{
    [self work:^{
        self->_logWritter->closeLog();
    } synchronous:YES];
    
    delete _logWritter;
    _logWritter = NULL;
}

+(LLFileLogger*)getInstance
{
    static LLFileLogger* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLFileLogger alloc] init];
    });
    
    return instance;
}

-(void)addLog:(NSString *)log
{
    if (!log) {
        return;
    }
    
    NSString* tmp = [log copy];
    
    [self work:^{
        self->_logWritter->addLog(tmp);
    } synchronous:NO];
}

-(void)flushLog
{
    [self work:^{
        self->_logWritter->flushLog();
    } synchronous:NO];
}

+(unsigned int)getTimestampWithDateStr:(NSString*)dateStr hour:(int)hour min:(int)min sec:(int)sec
{
    int year = [dateStr intValue] / 10000;
    int mon = [dateStr intValue] % 10000 / 100;
    int day = [dateStr intValue] % 100;
    
    struct tm date = {0};
    
    date.tm_year = year - 1900;
    date.tm_mon = mon - 1;
    date.tm_mday = day;
    date.tm_hour = hour;
    date.tm_min = min;
    date.tm_sec = sec;
    date.tm_isdst = -1;
    
    return (unsigned int)mktime(&date);
}

-(NSData*)getLogWithBeginDate:(NSString*)beginDateStr beginHour:(int)beginhour beginMin:(int)beginmin endDateStr:(NSString*)endDateStr endHour:(int)endhour endMin:(int)endmin size:(unsigned int)size
{
    __block NSMutableData* data = [NSMutableData data];
    
    unsigned int beginTimeStamp = [LLFileLogger getTimestampWithDateStr:beginDateStr hour:beginhour min:beginmin sec:0];
    unsigned int endTimeStamp = [LLFileLogger getTimestampWithDateStr:endDateStr hour:endhour min:endmin sec:0];
    
    LL_LogDebug("NewLLDebugTool log report : begin : %u, end %u",beginTimeStamp,endTimeStamp);
    
    [self work:^{
        self->_logWritter->flushLog();
        CFileLogWriter::getLog(beginDateStr, beginTimeStamp, endDateStr, endTimeStamp, data,size);
    } synchronous:YES];
    
    return data;
}

-(void)checkOutdateFilePeriod
{
    NSString* dirString = CFileLogWriter::getLogDir();
    
    NSDate* curDate = [NSDate date];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    for (NSString* fileName in tempArray)
    {
        BOOL flag = YES;
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag])
        {
            if (!flag)
            {
                int maxDays = 7;
                
                NSError* error;
                NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath: fullPath error:&error];
                NSDate* createDate = (NSDate*)[fileAttributes objectForKey:NSFileCreationDate];
                
                NSTimeInterval ti = [curDate timeIntervalSinceDate:createDate];
                int days = ti / (24 * 60 *60);
                if(days < maxDays)
                {
                    continue;
                }
            }
            
            //删除文件或文件夹
            [fileMgr removeItemAtPath:fullPath error:nil];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * 60 * 24 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkOutdateFilePeriod];
    });
}

-(void)checkOutdateFile
{
    [self work:^{
        [self checkOutdateFilePeriod];
    } synchronous:NO];
}

@end
