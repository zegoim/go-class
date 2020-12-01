package redisUtil

import (
	"go_class_server/utils/slackUtil"
	"go_class_server/utils/stringUtil"

	"encoding/json"
	"fmt"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"github.com/pkg/errors"
	"reflect"
	"sync"
	"time"
)

var GlobalPool *redis.Pool
var once sync.Once
var REDIS_NIL = redis.ErrNil
var ROOT_KEY = "zego:talkline:"
var SetNxTrue = int64(1)
var SetNxFalse = int64(0)

var (
	errKeyIsBlank        = errors.New("Redis: err Key Is Blank")
	errValueIsNotPointer = errors.New("Redis: err Value Is Not Pointer")
	errValueIsNil        = errors.New("Redis: err Value Is Nil")
	ErrKeyNotFound       = errors.New("Redis: Err Key Not Found")
	ErrRedisHget         = errors.New("Redis: Err Redis Hget")
)

const (
	THIRTY_DAYS     = 86400 * 30
	DAY         int = 24 * 3600
	MINUTE      int = 60
)

func InitPool() {
	initReidsPool()
}

func initReidsPool() {
	url := beego.AppConfig.String("redisSvrAddr")
	password := beego.AppConfig.String("redisSvrPassword")
	db, _ := beego.AppConfig.Int("redisSvrDB")
	logs.Info("-------------- redis initPool with URL ", url, password, db)
	if len(password) > 0 {
		GlobalPool = newPool(url, string(password), db)
	} else {
		logs.Info("-------------- not configure password ")
		GlobalPool = newPool(url, "", db)
	}
}

func newPool(server, password string, db int) *redis.Pool {
	logs.Info("newPool :%v %v %v", server, password, db)
	return &redis.Pool{
		MaxIdle:     10,
		IdleTimeout: 240 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", server)
			if err != nil {
				logs.Error("redis dial error:", err.Error())
				return nil, err
			}
			if len(password) > 0 {
				_, err = c.Do("AUTH", password)
				if err != nil {
					return nil, err
				}
			}
			_, err = c.Do("SELECT", db)
			if err != nil {
				return nil, err
			}
			return c, err
		},
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			_, err := c.Do("PING")
			return err
		},
	}
}

func getPool() *redis.Pool {
	if GlobalPool == nil {
		once.Do(initReidsPool)
	}

	if GlobalPool == nil {
		logs.Error("redis GlobalPool is nil, init fail.")
	}
	return GlobalPool
}

var SetObject = func(key string, value interface{}) error {
	conn := getPool().Get()
	defer conn.Close()

	if _, err := do(conn, "HMSET", redis.Args{}.Add(key).AddFlat(value)...); err != nil {
		logs.Error("redisUtil SetObject error:", err.Error())
		return err
	}
	return nil
}

var GetObject = func(key string, value interface{}) (err error) {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.Values(do(conn, "HGETALL", key))
	if err != nil {
		logs.Error("redisUtil GetObject error:", err)
		return err
	}

	logs.Info("redisUtil GetObject v:", v)

	if err := redis.ScanStruct(v, value); err != nil {
		logs.Error("Redist Util Error for getting", key, err.Error())
		return err
	}
	logs.Info("redisUtil GetObject value:", value)
	return nil
}

//设置key多少秒后超时
func Expire(key string, seconds int) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "EXPIRE", key, seconds)
	if err != nil {
		logs.Error("redisUtil Expire error: ", err.Error())
	}
	return nil
}

func Delete(key string) error {
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "DEL", key); err != nil {
		logs.Error("redisUtil Delete error: ", err.Error())
		return err
	}
	return nil
}

func SetComplexObject(key string, value interface{}) error {
	bytes, _ := json.Marshal(value)
	if err := SetString(key, string(bytes)); err != nil {
		return err
	}
	return nil
}

func SetComplexObjectExpire(key string, value interface{}, expire int) error {
	bytes, _ := json.Marshal(value)
	logs.Info("SetComplexObjectExpire %v %v", key, string(bytes))
	if err := SetStringWithExpire(key, string(bytes), expire); err != nil {
		return err
	}
	return nil
}

func GetComplexObject(key string, value interface{}) error {
	str, err := GetString(key)
	if err != nil {
		return err
	}

	if str == "" {
		return redis.ErrNil
	}

	if err := json.Unmarshal([]byte(str), value); err != nil {
		logs.Error(FormatLog("GetComplexObject", key, str, err))
		return err
	}
	return nil
}

func SetObjectWithExpire(key string, value interface{}, expire int) error {
	beego.Info(FormatLog("SetObjectWithExpire", key, "", nil))
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "HMSET", redis.Args{}.Add(key).AddFlat(value)...); err != nil {
		logs.Info(FormatLog("SetObjectWithExpire", key, value, err))
		return err
	}
	Expire(key, expire)
	return nil
}

func SetStringWithExpire(key string, value string, expire int) error {
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "SET", key, value, "EX", expire); err != nil {
		return err
	}
	return nil
}

func SetString(key string, value string) error {
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "SET", key, value); err != nil {
		return err
	}
	return nil
}

func GetString(key string) (string, error) {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.String(do(conn, "GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return "", nil
		}
		return "", err
	}
	return v, nil
}

func GetInt64(key string) (int64, error) {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.String(do(conn, "GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return 0, nil
		}
		return 0, err
	}
	return stringUtil.StringToInt64(v), nil
}
func GetInt(key string) (int, error) {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.String(do(conn, "GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return 0, nil
		}
		return 0, err
	}
	return stringUtil.StringToInt(v), nil
}
func Exists(key string) bool {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.Bool(do(conn, "EXISTS", key))
	if err != nil {
		logs.Error("redis Exists failed, err:%s", err.Error())
		return false
	}
	return v
}

func HExists(key string, detailKey string) bool {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.Bool(do(conn, "HEXISTS", key, detailKey))
	if err != nil {
		logs.Error("redis HExists failed, err:%s", err.Error())
		return false
	}
	return v
}

func AddGeoIndex(indexName string, geoKey string, latitude float32, longitude float32) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "GEOADD", indexName, latitude, longitude, geoKey)
	if err != nil {
		return err
	}
	return nil
}

func GetKeysByPrefix(prefix string) ([]string, error) {
	conn := getPool().Get()
	defer conn.Close()
	keys, err := redis.Strings(do(conn, "KEYS", prefix+"*"))
	if err != nil {
		return nil, err
	}
	return keys, nil
}

//往redis里面插入键值，如果键已存在，返回False，不执行
//如果键不存在，插入键值,返回成功
func SetStringIfNotExist(key, value string, expire int) (bool, error) {
	conn := getPool().Get()
	defer conn.Close()
	result, err := redis.String(do(conn, "SET", key, value, "EX", expire, "NX"))
	if err != nil {
		if err == redis.ErrNil {
			return false, nil
		} else {
			return false, err
		}
	}

	logs.Debug("SetStringIfNotExist result:%v", result)

	if result == "OK" {
		return true, nil
	} else {
		return false, nil
	}
}

// GetValue key should not be blank and value must be non-nil pointer to int/bool/string/struct ...
// because a value can set only if it is addressable
// if key not found will return ErrKeyNotFound
func GetValue(key string, value interface{}) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}
	v := reflect.ValueOf(value)
	if v.Kind() != reflect.Ptr {
		return errValueIsNotPointer
	}
	if v.IsNil() {
		return errValueIsNil
	}

	conn := getPool().Get()
	defer conn.Close()

	reply, err := redis.Values(do(conn, "MGET", key))
	if err != nil {
		return err
	}
	if len(reply) == 0 || reply[0] == nil {
		return ErrKeyNotFound
	}

	if v.Elem().Kind() == reflect.Struct {
		err = json.Unmarshal(reply[0].([]byte), value)
	} else {
		_, err = redis.Scan(reply, value)
	}
	if err != nil {
		return err
	}
	logs.Info("redis: get success", key)
	return nil
}

// SetValue key should not be blank and value should not be nil
// Struct or pointer to struct values will encoding as JSON objects
func SetValue(key string, value interface{}, seconds ...int) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}
	v := reflect.ValueOf(value)
	isPtr := (v.Kind() == reflect.Ptr)
	if value == nil || (isPtr && v.IsNil()) {
		return errValueIsNil
	}

	conn := getPool().Get()
	defer conn.Close()

	if v.Kind() == reflect.Struct || (isPtr && v.Elem().Kind() == reflect.Struct) {
		bs, err := json.Marshal(value)
		if err != nil {
			return err
		}
		value = string(bs)
	} else {
		if isPtr { // *int/*bool/*string ...
			value = v.Elem()
		}
	}
	exArgs := []interface{}{}
	if len(seconds) > 0 {
		exArgs = append(exArgs, "EX", seconds[0])
	}
	args := append([]interface{}{key, value}, exArgs...)
	_, err = do(conn, "SET", args...)
	if err != nil {
		return err
	}
	logs.Info("redis: set success", key)
	return nil
}

func do(c redis.Conn, commandName string, args ...interface{}) (reply interface{}, err error) {
	reply, err = c.Do(commandName, args...)
	if err != nil {
		handleAlertError(err)
	}
	return reply, err
}

func getRedisUrl() string {
	return beego.AppConfig.String("redisUrl")
}

func handleAlertError(err error) {
	if err == nil {
		return
	}
	message := fmt.Sprintf("redis error with redisUrl : %s , error is %s", getRedisUrl(), err.Error())
	slackUtil.SendMessage(message)
}

func SAddString(key string, s string, seconds ...int) error {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()
	var err error

	if err = conn.Send("SADD", key, s); err != nil {
		return err
	}

	if err = conn.Flush(); err != nil {
		return err
	}
	_, err = conn.Do("")
	if err != nil {
		return err
	}
	if len(seconds) > 0 {
		_, err = conn.Do("EXPIRE", key, seconds[0])
		if err != nil {
			return err
		}
	}
	return nil
}

func SRemString(key string, s string) error {
	conn := getPool().Get()
	defer conn.Close()
	var err error

	if err = conn.Send("SREM", key, s); err != nil {
		return err
	}
	return nil
}

func SRemStrings(key string, ss ...interface{}) error {
	conn := getPool().Get()
	defer conn.Close()

	var args []interface{}
	args = append(args, key)
	args = append(args, ss...)

	_, err := conn.Do("SREM", args...)
	if err != nil {
		return err
	}

	return nil
}

func SMembersString(key string) ([]string, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()
	ss, err := redis.Strings(conn.Do("SMEMBERS", key))
	if err != nil {
		return nil, err
	}
	return ss, nil
}

func Scard(key string) (int, error) {
	conn := getPool().Get()
	defer conn.Close()
	cnt, err := redis.Int(conn.Do("SCARD", key))
	if err != nil {
		return 0, err
	}

	return cnt, nil
}

func Incr(key string) (*int, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()

	id, err := redis.Int(conn.Do("INCR", key))
	if err != nil {
		return nil, err
	}
	return &id, nil
}

func IncrWithExpire(key string, second int) (*int, error) {
	id, err := Incr(key)
	if err != nil {
		return nil, err
	}
	err = Expire(key, second)
	if err != nil {
		return nil, err
	}
	return id, nil
}

//SET if Not exists
func SetValueNX(key string, value interface{}, seconds ...int) (err error) {
	if Exists(key) {
		return nil
	}
	if len(key) == 0 {
		return errKeyIsBlank
	}
	v := reflect.ValueOf(value)
	isPtr := (v.Kind() == reflect.Ptr)
	if value == nil || (isPtr && v.IsNil()) {
		return errValueIsNil
	}

	conn := getPool().Get()
	defer conn.Close()

	if v.Kind() == reflect.Struct || (isPtr && v.Elem().Kind() == reflect.Struct) {
		bs, err := json.Marshal(value)
		if err != nil {
			return err
		}
		value = string(bs)
	} else {
		if isPtr { // *int/*bool/*string ...
			value = v.Elem()
		}
	}
	exArgs := []interface{}{}
	if len(seconds) > 0 {
		exArgs = append(exArgs, "EX", seconds[0])
	}
	args := append([]interface{}{key, value}, exArgs...)
	_, err = do(conn, "SET", args...)
	if err != nil {
		return err
	}
	return nil
}

//SET Hash string
func SetHashStringWithExpire(key, field, value string, seconds ...int) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()

	if err = conn.Send("HSET", key, field, value); err != nil {
		return err
	}

	if err = conn.Flush(); err != nil {
		return err
	}
	_, err = conn.Do("")
	if err != nil {
		return err
	}
	if len(seconds) > 0 {
		_, err = conn.Do("EXPIRE", key, seconds[0])
		if err != nil {
			return err
		}
	}
	return nil
}

func DeleteHashString(key, field string) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()

	if err = conn.Send("HDEL", key, field); err != nil {
		return err
	}

	return nil
}

func GetHashStrings(key string) ([]string, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := getPool().Get()
	defer conn.Close()
	ss, err := redis.Strings(conn.Do("HGETALL", key))
	if err != nil {
		return nil, err
	}
	return ss, nil
}

func GetAllHash(key string) (map[string]string, error) {
	//var fields, values []string
	kvs, err := GetHashStrings(key)
	if err != nil {
		return nil, err
	}

	resMap := make(map[string]string, 0)

	if len(kvs)%2 != 0 {
		return nil, ErrRedisHget
	} else {
		for a := 0; a < len(kvs)/2; a++ {

			resMap[kvs[2*a]] = kvs[2*a+1]

			//fields = append(fields, kvs[2*a])
			//values = append(values, kvs[2*a+1])

		}
	}
	//if len(fields) != len(values) {
	//	return fields, values, ErrRedisHget
	//}
	//return fields, values, nil

	return resMap, nil
}

//GET Hash string
func GetHashString(key, field string) (string, error) {
	conn := getPool().Get()
	defer conn.Close()
	v, err := redis.String(do(conn, "HGET", key, field))
	if err != nil {
		if err == redis.ErrNil {
			return "", nil
		}
		return "", err
	}
	return v, nil
}

func LpushString(key, value string) error {
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "LPUSH", key, value); err != nil {
		return err
	}
	return nil
}

func SetNxWithExpire(key, value string, expire int) (int64, error) {
	conn := getPool().Get()
	defer conn.Close()
	reply, err := do(conn, "SETNX", key, value)
	if err != nil {
		return 0, err
	}
	if _, err := do(conn, "EXPIRE", key, expire); err != nil {
		return 0, err
	}
	return reply.(int64), nil
}

func ZAdd(key string, score int64, value interface{}) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "zadd", key, score, value)

	return err
}

func ZAddWithExpire(key string, score int64, value interface{}, expire int) error {
	conn := getPool().Get()
	defer conn.Close()
	if _, err := do(conn, "zadd", key, score, value); err != nil {
		return err
	}
	if _, err := do(conn, "EXPIRE", key, expire); err != nil {
		return err
	}
	return nil
}

func ZAddNX(key string, score int64, value interface{}) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "zadd", key, "NX", score, value)

	return err
}

func ZRem(key string, value interface{}) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "zrem", key, value)

	return err
}

func ZCount(key string, min, max string) (count int64, err error) {
	conn := getPool().Get()
	defer conn.Close()

	count, err = redis.Int64(do(conn, "zcount", key, min, max))

	return
}

func ZCard(key string) (count int64, err error) {
	conn := getPool().Get()
	defer conn.Close()

	count, err = redis.Int64(do(conn, "zcard", key))

	return
}

func ZRank(key string, detailKey string) (rank int64, err error) {
	conn := getPool().Get()
	defer conn.Close()

	rank, err = redis.Int64(do(conn, "zrank", key, detailKey))

	return
}

func ZRevRange(key, start, stop string) ([]string, error) {
	conn := getPool().Get()
	defer conn.Close()

	return redis.Strings(do(conn, "zrevrange", key, start, stop))
}

func ZRevRangeByScore(key, max, min string) ([]string, error) {
	conn := getPool().Get()
	defer conn.Close()

	return redis.Strings(do(conn, "zrevrangebyscore", key, max, min))
}

func ZRange(key, start, stop string) ([]string, error) {
	conn := getPool().Get()
	defer conn.Close()

	return redis.Strings(do(conn, "zrange", key, start, stop))
}

func Rpush(key string, value interface{}) error {
	conn := getPool().Get()
	defer conn.Close()
	_, err := do(conn, "RPUSH", key, value)

	return err
}

func Lpop(key string) (string, error) {
	conn := getPool().Get()
	defer conn.Close()

	return redis.String(do(conn, "LPOP", key))
}

func FormatLog(job, key string, value interface{}, err error) string {
	if err != nil {
		return fmt.Sprintf("%v[error] key:%v value:%v err:%v", job, key, value, err.Error())
	}
	return fmt.Sprintf("%v[success] key:%v value:%v err:%v", job, key, value, "")

}

func EvalLuaScript(script string, keys []string, args ...interface{}) (interface{}, error) {
	conn := getPool().Get()
	defer conn.Close()
	rScript := redis.NewScript(len(keys), script)

	var keysAndArgs []interface{}
	for _, key := range keys {
		keysAndArgs = append(keysAndArgs, key)
	}

	for _, arg := range args {
		keysAndArgs = append(keysAndArgs, arg)
	}

	return rScript.Do(conn, keysAndArgs...)
}
