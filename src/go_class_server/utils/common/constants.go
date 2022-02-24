package common

const (
	PlatformNone              = 0
	PlatformWindow            = 1
	PlatformMacOS             = 2
	PlatformIOS               = 4
	PlatformAndroid           = 8
	PlatformWeChatMiniProgram = 16
	PlatformWeb               = 32
	PlatformH5                = 64
)

func IsNeedAppToken(pl int64) bool {
	return pl == PlatformWeChatMiniProgram || pl == PlatformWeb || pl == PlatformH5
}
