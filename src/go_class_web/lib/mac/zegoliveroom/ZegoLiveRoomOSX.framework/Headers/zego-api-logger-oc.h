//
//  zego-logger-oc.h
//
//  Copyright © Shenzhen Zego Technology Company Limited
//
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

@interface ZegoEduLogger : NSObject

/**
 enum ZegoLoggerLevel
{
	kZegoLogLevelError = 1,
	kZegoLogLevelWarning = 2,
	kZegoLogLevelNotice = 3,
	kZegoLogLevelDebug = 4
};
 */
+(void) setFolder: (NSString *)folder
					level:(int)level
					size:(unsigned int)size;

/**
设置日志文件头部信息 (当前使用viewVersion作为headinfo)
 */
+(void) setHeadInfo: (NSString *)content;


/**
 打印一行日志
  
 @note 打印内容中包含时间、线程、内容，函数名、行号需自行在 content 中包含
 */
+(void) writeLog: (int)logLevel
                	content:(NSString *)content;


@end
