//
//  Debug.h
//  Market
//
//  Created by backup on 13-7-30.
//  Copyright (c) 2013年 liwu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __DEBUG__ 
#define __DEBUG_TIME__
#define LOG_PATH  [[NSString stringWithFormat:@"%@/Documents/debug.txt", NSHomeDirectory()] cStringUsingEncoding:NSASCIIStringEncoding]
//"/var/mobile/Library/Keyboard/Market.log"



@interface Debug : NSObject
@property(nonatomic,assign)BOOL enableLog;
+ (instancetype)defaultDebug;

@end

#ifdef __DEBUG__
#import <UIKit/UIKit.h>
void bd_show_view_hierarchy(UIView *view, NSInteger level);
#define BD_SHOW_VIEW(x) bd_show_view_hierarchy((x), 0)
#else
#define BD_SHOW_VIEW(x)
#endif //__DEBUG__
//@end



#ifdef __DEBUG__
//程序日志
#define __FLOG(format, ...)\
if ([Debug defaultDebug].enableLog) {\
do\
{\
FILE *log_file; \
if((log_file = fopen(LOG_PATH, "a+")))\
{\
printf(format, ##__VA_ARGS__);\
printf("\n");\
fprintf(log_file, format, ##__VA_ARGS__);\
fprintf(log_file, "|"); \
fprintf(log_file, "%s",[[[NSDate date] description] cStringUsingEncoding:NSASCIIStringEncoding]);\
fprintf(log_file, "\n"); \
fclose(log_file);\
}\
}while(0);\
}

#define __THALOG(format, ...) do\
{\
FILE *log_file; \
if((log_file = fopen(HOT_AREA_LOG_PATH, "a+")))\
{\
printf(format, ##__VA_ARGS__);\
printf("\n");\
fprintf(log_file, format, ##__VA_ARGS__);\
fprintf(log_file, "\n"); \
fclose(log_file);\
}\
}while(0)

#else

#define __FLOG(format, ...)   ((void)0)

#define __THALOG(format, ...) ((void)0)

#endif



// Log-level based logging macros.
#if BI_LOG_LEVEL_ERROR <= BI_LOG_LEVEL_MAX
#define BIDERROR(xx, ...)  __FLOG(xx, ##__VA_ARGS__)
#else
#define BIDERROR(xx, ...)  ((void)0)
#endif // #if BI_LOG_LEVEL_ERROR <= BI_LOG_LEVEL_MAX

#if BI_LOG_LEVEL_WARNING <= BI_LOG_LEVEL_MAX
#define BIDWARNING(xx, ...)  __FLOG(xx, ##__VA_ARGS__)
#else
#define BIDWARNING(xx, ...)  ((void)0)
#endif // #if BI_LOG_LEVEL_WARNING <= BI_LOG_LEVEL_MAX



#if BI_LOG_LEVEL_ALL <= BI_LOG_LEVEL_MAX
#define BIDSTART()  __FLOG("<<< %s", __PRETTY_FUNCTION__)
#define BIDEND()  __FLOG(">>> %s", __PRETTY_FUNCTION__)

#else
#define BIDSTART()  ((void)0)
#define BIDEND()  ((void)0)

#endif // #if BI_LOG_LEVEL_ALL <= BI_LOG_LEVEL_MAX


#ifdef __DEBUG_TIME__

#define BIDT1()     NSDate* date = [NSDate date];
//#define BIDT2()     do{BIDERROR("%s cost: %f", __PRETTY_FUNCTION__, [date timeIntervalSinceNow]*-1000);}while(0)
#define BIDT2()     do{NSLog(@"%s cost: %f", __PRETTY_FUNCTION__, [date timeIntervalSinceNow]*-1000);}while(0)

#else

#define BIDT1()     ((void)0)
#define BIDT2()      ((void)0)

#endif


#if 0
#ifdef __DEBUG__
    #define NIDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    int NIIsInDebugger(void);
    #if TARGET_IPHONE_SIMULATOR
// We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
// a "breakInDebugger" function.
        #define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); \
        if (NIIsInDebugger()) { __asm__("int $3\n" : : ); } } \
        } ((void)0)
    #else
        #define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); \
        if (NIIsInDebugger()) { raise(SIGTRAP); } } \
        }((void)0)
    #endif // #if TARGET_IPHONE_SIMULATOR

#else
    #define NIDPRINT(xx, ...)  ((void)0)
    #define NIDASSERT(xx) ((void)0)
#endif // #if defined(DEBUG) || defined(NI_DEBUG)


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
BOOL NIIsArrayWithObjects(id object);
BOOL NIIsPad(void);
BOOL NIIsStringWithAnyText(id object);
#endif
