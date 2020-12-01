package stringUtil

import (
	"fmt"
	"strconv"
	"strings"
)

func Int64Tostring(i64 int64) string {
	return strconv.FormatInt(i64, 10)
}

func StringToInt64(s string) int64 {
	i, _ := strconv.ParseInt(s, 10, 64)
	return i
}

func StringToInt(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func GetFileName(str string) string {
	list := strings.Split(str, "/")
	le := len(list)
	if le < 3 {
		return str
	}
	return fmt.Sprintf("%v/%v", list[le-2], list[le-1])
}

func GetFuncName(str string) string {
	list := strings.Split(str, ".")
	le := len(list)
	if le < 3 {
		return str
	}
	return fmt.Sprintf("func:%v", list[le-1])
}
