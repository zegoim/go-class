//
//  zego-api-error.h
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#ifndef zego_api_error_h
#define zego_api_error_h

#include <string>
#include "zego-api-defines.h"

namespace ZEGO
{
    namespace BASE
    {
        const unsigned int kOK                            = 0;
        const unsigned int kEnd                           = 1;
    
        const unsigned int kNoneAppIdError                = 10000101;
        const unsigned int kNotLoginError                 = 10000105;
        const unsigned int kPublishBadNameError           = 10000106;
        
        const unsigned int kInvalidParamError             = 10001001;
        const unsigned int kInvalidChannelError           = 10001002;
        const unsigned int kNullPointerError              = 10001003;
        const unsigned int kInvalidUserIDError            = 10001004;
        const unsigned int kInvalidRoomIDError            = 10001005;
        const unsigned int kNoFreeChannelError            = 10001101;
        const unsigned int kFormatUrlError                = 10001102;
        const unsigned int kInvalidExtraUrlError          = 10001103;
        const unsigned int kNoPushIpError                 = 10001104;
        const unsigned int kUnmatchStreamIDError          = 10002001;
        const unsigned int kUnmatchSeqError               = 10002002;
        const unsigned int kNoneSeqError                  = 10002003;
        const unsigned int kUnmatchStateError             = 10002004;
        const unsigned int kRedirectError                 = 10003001;
        const unsigned int kOutOfMemeryError              = 10004001;
        const unsigned int kStartThreadError              = 10004002;
        const unsigned int kNotMallocEnoughMemError       = 10004003;
        const unsigned int kStartRequestError             = 10005001;
        const unsigned int kStartUpdateStreamInfoError    = 10006001;
        const unsigned int kNoMultiRoomLoginRole          = 10007001; //没有多房间权限，而调用多房间接口
        const unsigned int kMultiRoomIDMappingOther       = 10007002;  //该roomid 已经在多房间另一套接口中使用
        const unsigned int kNetWorkProbeNoUrl             = 10007003;  
        const unsigned int kNetWorkProbeStopPublish       = 10007004; 
        const unsigned int kNetWorkProbeStopPlay          = 10007005; 
        const unsigned int kFetalError1                   = 10007101;
        const unsigned int kFetalError2                   = 10007102;
        const unsigned int kFetalError3                   = 10007103;
        const unsigned int kFetalError4                   = 10007104;
        const unsigned int kFetalError5                   = 10007105;
        const unsigned int kFetalError6                   = 10007106;
        const unsigned int kFetalError7                   = 10007107;
        const unsigned int kSDKNoMoudleFunction           = 10008001; //sdk 没有编译此模块的功能 而你调用了该接口，联系技术支持 提供支持此功能的SDK
        const unsigned int kSDKNotInit                    = 10008002; //sdk 没有初始化

        const unsigned int kDeviceError                   = 10009001; //设备错误
        const unsigned int kNetTypeChangeTimeOut          = 10009002; //网络类型改变，导致推拉流重试超过最大重试时间

        const unsigned int kNetworkNotConnectError        = 11000101;
        const unsigned int kNetworkDnsResolveError        = 11000404;
        
        const unsigned int kEngineCreateError             = 12101001;
        const unsigned int kEngineStatusError             = 12101002;
        const unsigned int kEngineStartError              = 12101003;
        const unsigned int kDeniedMaxRetryError           = 12101004;
        const unsigned int kDeniedDisableSwitchLineError  = 12101005;
        
        const unsigned int kEngineNoPlayDataError         = 12102001;
        const unsigned int kEngineNoPublishDataError      = 12102002;
        const unsigned int kEnginePlayTimeoutError        = 12102003;
        const unsigned int kEnginePublishTimeoutError     = 12102004;
        
        const unsigned int kEngineUnknownError            = 12200000;
        const unsigned int kEngineConnectServerError      = 12200001;
        const unsigned int kEngineRtmpHandshakeError      = 12200002;
        const unsigned int kEngineRtmpAppConnectError     = 12200003;
        const unsigned int kEngineRtmpCreateStreamError   = 12200004;
        const unsigned int kEngineRtmpPublishBadNameError = 12200005;
        const unsigned int kEngineServerDisconnectError   = 12200006;
        
        const unsigned int kEngineRtpConnectServerError        = 12200100;
        const unsigned int kEngineRtpHelloTimeoutError         = 12200101;
        const unsigned int kEngineRtpCreateSessionTimeoutError = 12200102;
        const unsigned int kEngineRtpCreateSessionFailError    = 12200103;
        const unsigned int kEngineRtpPlayOrPublishTimeoutError = 12200104;
        const unsigned int kEngineRtpPlayOrPublishDeniedError  = 12200105;
        const unsigned int kEngineRtpTimeoutError              = 12200106;
        const unsigned int kEngineRtpDecryptError              = 12200107;
        const unsigned int kEngineRtpDecryptNotSupport         = 12200108;
        const unsigned int kEngineRtpSockError                 = 12200109;
        const unsigned int kEngineRtpHbFrozenError             = 12200110;
        const unsigned int kEngineHttpFlvProtocolError         = 12200200;
        const unsigned int kEngineHttpFlvHttpCodeError         = 12200201;
        const unsigned int kEngineHttpFlvParseFlvError         = 12200202;
        const unsigned int kEngineHttpFlvServerDisconnectError = 12200203;
        const unsigned int kEngineHttpFlvRedirectError         = 12200204;
        
        const unsigned int kPlayStreamNotExistError       = 12301004;
        const unsigned int kMediaServerForbidError        = 12301011;
        const unsigned int kMediaServerPublishBadNameError= 12301012;
        const unsigned int kMediaServerStopPublishError   = 12301014;
        
        const unsigned int kConfigDecryptError              = 20000001;
        const unsigned int kConfigOfflineError              = 20000002;
        const unsigned int kConfigDomainError               = 20000003;
        const unsigned int kConfigMediaNetworkNoneError     = 20000004;
        const unsigned int kConfigMediaNetworkNoUrlError    = 20000005;
        const unsigned int kConfigServerCouldntConnectError = 21200007;
        const unsigned int kConfigServerTimeoutError        = 21200028;
        const unsigned int kConfigServerSslCaCertError      = 21200060;
        
        const unsigned int kDispatchServerInvalidError    = 30000001;
        const unsigned int kDispatchNoIpError             = 30000404;
        const unsigned int kDispatchServerCouldntConnectError = 31200007;
        const unsigned int kDispatchServerTimeoutError    = 31200028;
        const unsigned int kDispatchServerSslCaCertError  = 31200060;
        const unsigned int kDispatchNotChangedError       = 32000001;
        const unsigned int kDispatchEmptyPublishIpsError  = 32001002;
        const unsigned int kDispatchEmptyPlayIpsError     = 32001003;
        const unsigned int kDispatchStreamNotExistError   = 32001004;
        const unsigned int kDispatchAgentTimeoutError     = 35500001;
        const unsigned int kDispatchAgentDroppedError     = 35500002;
        
        const unsigned int kLogicServerNoUrlError         = 40000404;
        const unsigned int kLogicServerNoIpError          = 40000405;
        const unsigned int kLogicServerNoStreamInfoError  = 40000406;
        const unsigned int kLogicServerFetalError1        = 40700001;
        const unsigned int kLogicServerCouldntConnectError= 41200007;
        const unsigned int kLogicServerTimeoutError       = 41200028;
        const unsigned int kLogicServerSslCaCertError     = 41200060;
        const unsigned int kLoginAgentTimeoutError        = 45500001;
        const unsigned int kLoginAgentDroppedError        = 45500002;
        
        const unsigned int kLiveRoomRequestParamError     = 50001001;
        const unsigned int kLiveRoomHBTimeoutError        = 50001002;
        const unsigned int kLiveRoomNoPushServerAddrError = 50001003;
        const unsigned int kLiveRoomNoPushCryptoKeyError  = 50001004;
        const unsigned int kLiveRoomNoPushTokenError      = 50001005;
        const unsigned int kLiveRoomAutoRetryMaxTimeOut   = 50001006;
        const unsigned int kLiveRoomRetryRightNow         = 50001009;
        const unsigned int kLiveRoomWaitNetOKWillRetry    = 50001010; 
        const unsigned int kLiveRoomLogoutWhenLogining    = 50001011;
        const unsigned int kLiveRoomLogoutUserCancel      = 50001012;

        const unsigned int kLiveRoomHBErrorNoResp         = 50001050;
        const unsigned int kLiveRoomHBErrorByHttpTiemout  = 50001051;

        const unsigned int kLiveRoomReliableMessageParseBufError     = 50001200;
        const unsigned int kLiveRoomReliableMessageTransChannelError = 50001201;
        const unsigned int kLiveRoomReliableUserMessageBufEmpty      = 50001202;
        const unsigned int kLiveRoomReliableUserMessageParseBufError = 50001203;
        const unsigned int kLiveRoomGetUserListParseBufError         = 50001204;
        const unsigned int kLiveRoomHttpNullPtrError                 = 50001205;

        const unsigned int kLiveRoomMultiZPushSessionIDNotMatchError = 50005021;
        const unsigned int kLiveRoomMultiLimitRoomCountError         = 50005022;

        const unsigned int kLiveRoomCouldntConnectError   = 51200007;
        const unsigned int kLiveRoomTimeoutError          = 51200028;
        const unsigned int kLiveRoomSslCaCertError        = 51200060;
        const unsigned int kLiveRoomInvalidRspError       = 51400003;
        const unsigned int kLiveRoomInputParamsError      = 52000002;
        const unsigned int kLiveRoomRoomAuthError         = 52000101;
        const unsigned int kLiveRoomRoomNotExistError     = 52000104;
        const unsigned int kLiveRoomNotLoginError         = 52000105;
        const unsigned int kLiveRoomSetStreamInfoError    = 52000123;
        const unsigned int kLiveRoomStreamInfoNotExist    = 52000138;
        const unsigned int kLiveRoomSessionError          = 52000141;
        const unsigned int kLiveRoomSessionIdError        = 52000152;
        const unsigned int kLiveRoomQpsLimitError         = 52000201;
        const unsigned int kLiveRoomLuaSessionError       = 52001001;
        const unsigned int kLiveRoomAddUserError          = 52001002;
        const unsigned int kLiveRoomDelUserError          = 52001003;
        const unsigned int kLiveRoomAddTransError         = 52001009;
        const unsigned int kLiveRoomMaxUserCountError     = 52001105;
        const unsigned int kLiveRoomPublishBadNameError   = 52001012;
        const unsigned int kLiveRoomRequiredReloginError  = 52002001;
        const unsigned int kLiveRoomThirdTokenAuthError   = 52002002;
        const unsigned int kLiveRoomNetBrokenTimeoutError = 52002003;
        const unsigned int kLiveRoomBlackListErrcode      = 52005030;
        const unsigned int kLiveRoomTokenBlackListErrcode = 52005035;
        const unsigned int kLiveRoomAgentTimeoutError     = 55500001;
        const unsigned int kLiveRoomAgentDroppedError     = 55500002;
        
        
        const unsigned int kRoomConnectError                 = 60001001;
        const unsigned int kRoomDoHandShakeReqError          = 60001002;
        const unsigned int kRoomDoLoginReqError              = 60001003;
        const unsigned int kRoomTimeoutError                 = 60001004;
        const unsigned int kRoomHbTimeoutError               = 60001005;
        const unsigned int kRoomStartConnectError            = 60001006;
        const unsigned int kRoomReconnectFailError           = 60001008;
        const unsigned int kRoomLoginZPushNoCryptoKey        = 60001009; 
        const unsigned int kRoomLoginCheckMD5Fail            = 60001010; 
        const unsigned int kRoomRetryIPOver                  = 60001011; 
        const unsigned int kRoomRetryActiveIPError           = 60001012; 
        const unsigned int kRoomSendLoginNoZPushRsp          = 60001013;  
        const unsigned int kRoomDoSendLoginMultiRoomReqError = 60001014; 
        const unsigned int kRoomZPushTcpClosed               = 60001015;
        const unsigned int kRoomConnectErrorQuic             = 60001016;
        

        const unsigned int kRoomInvalidSocketError        = 60002001;
        const unsigned int kRoomInvalidRspError           = 60003001;
        const unsigned int kRoomZPushKickOutNeedRetry     = 60004000;

        const unsigned int kRoomDecodeSignError           = 62001001;
        const unsigned int kRoomDecodeLoginError          = 62001002;
        const unsigned int kRoomReplayAttacksError        = 62002001;
        const unsigned int kRoomThirdTokenAuthError       = 62002002;
        const unsigned int kRoomBlackListErrcode          = 62005030;
        const unsigned int kRoomTokenBlackListErrcode     = 62005035;
        const unsigned int kRoomLoginCreateUserError      = 62010001;
        const unsigned int kRoomLoginSameCreateUserError  = 62010002;
        const unsigned int kRoomStatusTimeoutError        = 62010005;
        const unsigned int kRoomStatusRspError            = 62010006;
        const unsigned int kRoomDispatchTokenBuildError   = 62030011;
        const unsigned int kRoomDispatchTokenDecodeError  = 62030012;
        const unsigned int kRoomDispatchTokenInvalidError = 62030013;
        const unsigned int kRoomDispatchTokenExpiredError = 62030014;
        const unsigned int kRoomEncodeZPushTokenError     = 62030015;
        const unsigned int kRoomDecodeZPushTokenError     = 62030016;
        const unsigned int kRoomInvaildZPushTokenError    = 62030017;
        const unsigned int kRoomZPushTokenExpiredError    = 62030018;
        const unsigned int kRoomCheckZPushTokenError      = 62030019;
        const unsigned int kRoomCheckSessionNotMatchError = 62030020;
        const unsigned int kRoomSendLiveRoomError         = 62031001;
        const unsigned int kRoomLiveRoomTimeOutError      = 62031002;
        const unsigned int kRoomLiveRoomRspError          = 62031003;

        const unsigned int kRoomServerSwitchCluster       = 62040001;  //服务切换集群错误
        const unsigned int kRoomServerNeedForceDispatchEnd= 62040100;  //错误码62040001 - 62040100段 sdk需要强制dispatch重试
        const unsigned int kRoomMultipleLoginKickoutError = 63000001;
        const unsigned int kRoomManualKickoutError        = 63000002;
        const unsigned int kRoomSessionErrorKickoutError  = 63000003;
        const unsigned int kRoomDispatchError             = 64000001;
        const unsigned int kRoomDispatchResultNotMatch    = 64000002;
        const unsigned int kRoomNoDispatchToken           = 64000003;
        const unsigned int kRoomSdkZpushError             = 65000001;  //sdk内部调用zpush错误
        //混流错误码定义
        const unsigned int kMixStreamNoneMixConfigError   = 80000001; //没有混流配置信息
        const unsigned int kMixStreamCouldntConnectError  = 81200007; //混流服务连接失败
        const unsigned int kMixStreamTimeoutError         = 81200028; //混流服务响应超时
        const unsigned int kMixStreamSslCaCertError       = 81200060; //混流服务证书错误
        const unsigned int kMixStreamFailError            = 82000001; //混流失败
        const unsigned int kMixStreamInputError           = 82000002; //混流请求包解析错误
        const unsigned int kMixStreamAuthError            = 82000003; //混流鉴权失败
        const unsigned int kMixStreamNotExistError        = 82000150; //混流的输入流不存在
        const unsigned int kMixStreamStartMixError        = 82000151; //启动混流失败
        const unsigned int kMixStreamStopMixError         = 82000152; //停止混流失败
        const unsigned int kMixStreamInputFormatError     = 82000155; //混流输入格式错误
        const unsigned int kMixStreamOutputFormatError    = 82000156; //混流输出格式错误
        const unsigned int kMixStreamNotOpenError         = 82000157; //混流没开
        const unsigned int kMixStreamInputExceedError     = 82000158; //混流输入流数超限
        const unsigned int kMixStreamDispatchError        = 82000159; //混流Dispatch失败
        const unsigned int kMixStreamStopMixOwnerError    = 82000160; //非创建者停止混流错误
        const unsigned int kMixStreamWaterMarkParamError  = 82000170; //混流水印参数错误
        const unsigned int kMixStreamWaterMarkImageError  = 82000171; //混流水印image错误
        const unsigned int kMixStreamQpsOverloadError     = 82000190; //混流请求qps超限错误
        const unsigned int kMixStreamAgentTimeoutError    = 85500001;
        const unsigned int kMixStreamAgentDroppedError    = 85500002;

        const unsigned int kNetworkTraceGetDetectURLError        = 120000001;
        const unsigned int kNetworkTraceDownDetectConfigError    = 120000002;
        const unsigned int kNetworkTraceDecryptionURLBufError    = 120000003;
        const unsigned int kNetworkTraceReqDownDetectConfigError = 120000004;

        /**
         是否初始化SDK错误
         */
        ZEGOAVKIT_API bool IsInitSDKError(unsigned int error);

        /**
         是否未登录错误
         */
        ZEGOAVKIT_API bool IsNotLoginError(unsigned int error);
        /**
         是否媒体服务器连接失败错误
         */
        ZEGOAVKIT_API bool IsMediaServerNetWorkError(unsigned int error);
        /**
         是否逻辑服务器连接失败错误
         */
        ZEGOAVKIT_API bool IsLogicServerNetWrokError(unsigned int error);
        /**
         是否混流的流不存在错误
         */
        ZEGOAVKIT_API bool IsMixStreamNotExistError(unsigned int error);
        /**
         是否拉的流不存在错误
         */
        ZEGOAVKIT_API bool IsPlayStreamNotExistError(unsigned int error);
        
        /**
         是否推流重复流名错误
         */
        ZEGOAVKIT_API bool IsPublishBadNameError(unsigned int error);
        
        /**
         是否禁止推流错误
         */
        ZEGOAVKIT_API bool IsPublishForbidError(unsigned int error);
        
        /**
         是否停止推流错误
         */
        ZEGOAVKIT_API bool IsPublishStopError(unsigned int error);
        
        /**
         是否推流Denied错误
         */
        ZEGOAVKIT_API bool IsPublishDeniedError(unsigned int error);
        
        /**
         是否禁止拉流错误
         */
        ZEGOAVKIT_API bool IsPlayForbidError(unsigned int error);
        
        /**
         是否拉流Denied错误
         */
        ZEGOAVKIT_API bool IsPlayDeniedError(unsigned int error);
        
        /**
         是否DNSResolve错误
         */
        ZEGOAVKIT_API bool IsDNSResolveError(unsigned int error);
        
        /**
         是否Network不可达错误
         */
        ZEGOAVKIT_API bool IsNetworkUnreachError(unsigned int error);
        
        /**
         是否Http协议错误
         */
        ZEGOAVKIT_API bool IsHttpProtocolError(unsigned int error);
        
        /**
         是否超过服务请求频率错误
         */
        ZEGOAVKIT_API bool IsReqFrequencyLimitError(unsigned int error);
        
        /**
         是否访问LiveRoom服务错误
         */
        ZEGOAVKIT_API bool IsLiveRoomError(unsigned int error);
        
        /**
         是否该账户多点登录被踢出错误
         */
        ZEGOAVKIT_API bool IsMultiLoginError(unsigned int error);
        
        /**
         是否该账户被手动踢出错误
         */
        ZEGOAVKIT_API bool IsManualKickoutError(unsigned int error);
        
        /**
         是否房间会话错误
         */
        ZEGOAVKIT_API bool IsRoomSessionError(unsigned int error);
        
        /**
         获取error msg
         @attention 建议传入的msg的长度msglen不小于128字节
         */
        ZEGOAVKIT_API void getErrorMsg(unsigned int error, char *msg, unsigned int msglen);
    }
}

#endif /* zego_api_error_h */
