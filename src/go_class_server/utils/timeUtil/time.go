package timeUtil

import "time"

func MilliSecond() int64 {
	return time.Now().UnixNano() / 1e6
}
