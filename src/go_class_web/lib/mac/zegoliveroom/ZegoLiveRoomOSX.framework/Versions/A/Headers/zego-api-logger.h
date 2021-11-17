#ifndef zego_api_edu_logger_h
#define zego_api_edu_logger_h

#include "zego-api-logger-constant.h"

#ifdef __cplusplus
extern "C" {
#endif

	/**
	 设置和开启日志功能
	*/
	ZEGOEDU_API void zego_api_logger_set_folder(const char* log_folder, enum ZegoLoggerLevel level, unsigned int limit_size);

	/**
	 设置日志文件头部信息 (当前使用viewVersion作为headinfo)
	 */
	ZEGOEDU_API void zego_api_logger_set_headinfo(const char* headinfo);

	/**
	 打印一行日志
	 */
	ZEGOEDU_API void zego_api_logger_write(enum ZegoLoggerLevel level, const char* content);
#ifdef __cplusplus
} // __cplusplus defined.
#endif

#endif
