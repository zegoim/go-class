package model

import "reflect"

func isNull(iface interface{}) bool {
	switch iface.(type) {
	case string:
		return iface.(string) == ""
	case int8:
		return iface.(int8) == 0
	case int16:
		return iface.(int16) == 0
	case int32:
		return iface.(int32) == 0
	case int:
		return iface.(int) == 0
	case int64:
		return iface.(int64) == 0
	case uint8:
		return iface.(uint8) == 0
	case uint16:
		return iface.(uint16) == 0
	case uint32:
		return iface.(uint32) == 0
	case uint:
		return iface.(uint) == 0
	case uint64:
		return iface.(uint64) == 0
	case RoleEnum:
		return iface.(RoleEnum) == 0
	case bool:
		return iface.(bool) == false
	default:
		return false
	}
}

func encode2Fields(iface interface{}) (fields []string, values []interface{}) {
	t := reflect.TypeOf(iface)
	v := reflect.ValueOf(iface)

	for i := 0; i < t.NumField(); i++ {
		if !isNull(v.Field(i).Interface()) {
			fields = append(fields, t.Field(i).Tag.Get("redis"))
			values = append(values, v.Field(i).Interface())
		}
	}
	return
}
