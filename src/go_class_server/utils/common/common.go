package common

func Map_GetBool(m *map[string]interface{}, field string) (ret bool, ok bool) {
	if t, ok := (*m)[field]; ok {
		if ret, ok = t.(bool); ok {
			return ret, ok
		}
	}

	return false, false
}

func Map_GetInt(m *map[string]interface{}, field string) (ret int, ok bool) {
	if t, ok := (*m)[field]; ok {
		if ret, ok = t.(int); ok {
			return ret, ok
		}
	}

	return 0, false
}

func Map_GetInt64(m *map[string]interface{}, field string) (ret int64, ok bool) {
	if t, ok := (*m)[field]; ok {
		if ret, ok = t.(int64); ok {
			return ret, ok
		}
	}

	return 0, false
}

func Map_GetFloat64(m *map[string]interface{}, field string) (ret float64, ok bool) {
	if t, ok := (*m)[field]; ok {
		if ret, ok = t.(float64); ok {
			return ret, ok
		}
	}

	return 0, false
}

func Map_GetString(m *map[string]interface{}, field string) (ret string, ok bool) {
	if t, ok := (*m)[field]; ok {
		if ret, ok = t.(string); ok {
			return ret, ok
		}
	}

	return "", false
}
