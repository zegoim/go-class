#ifndef ZEGO_EDU_DEFINES_H
#define ZEGO_EDU_DEFINES_H

#ifdef _MSC_VER
#pragma warning(disable : 4503)
#ifndef _SCL_SECURE_NO_WARNINGS
#define _SCL_SECURE_NO_WARNINGS
#endif
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
#ifndef _CRT_NONSTDC_NO_DEPRECATE
#define _CRT_NONSTDC_NO_DEPRECATE
#endif
#endif

#include <stddef.h>
#include "stdbool.h"

#ifdef __GNUC__
#define DEPRECATED(func) func __attribute__ ((deprecated))
#elif defined(_MSC_VER)
#define DEPRECATED(func) __declspec(deprecated) func
#else
#pragma message("WARNING: You need to implement DEPRECATED for this compiler")
#define DEPRECATED(func) func
#endif

/* You should define ZEGO_EXPORTS *only* when building the DLL. */
#ifdef WIN32
#ifdef ZEGO_EXPORTS
#define ZEGOEDU_API __declspec(dllexport)
#define ZEGOEDUCALL __cdecl
#elif defined ZEGO_SDK_STATIC
#define ZEGOEDU_API
#define ZEGOEDUCALL
#else
#define ZEGOEDU_API __declspec(dllimport)
#define ZEGOEDUCALL __cdecl
#endif
#else
#define ZEGOEDU_API __attribute__((visibility("default")))
#define ZEGOEDUCALL
#endif

typedef int ZegoCode;
typedef int ZegoError;
typedef unsigned int ZegoSeq;

#define IMAGE_SIZE		(1024 * 1024 * 10)
#define CUSTOM_IMAGE_SIZE (1024 * 500)
#define kZegoSucceed 0
#define kZegoSeqInvalid 0

#define kZegoErrorInvalidParam 10001001
#define kZegoErrorAlreadyEnterRoom 10000001

#define kZegoErrorImageUploadFailed			1
#define kZegoErrorImageDownloadFailed		2
#define kZegoErrorImageTypeNotSupport		3
#define kZegoErrorImageSizeLimit			4
#define kZegoErrorImageIllegalUrl			5
#define kZegoErrorVersionNotMatch			6

#endif
