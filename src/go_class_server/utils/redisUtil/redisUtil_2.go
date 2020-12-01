package redisUtil

import (
	"go_class_server/utils"
	"go_class_server/utils/stringUtil"
	"time"

	"github.com/sirupsen/logrus"

	"github.com/astaxie/beego/logs"

	"github.com/pkg/errors"

	"encoding/json"
	"fmt"
	"reflect"

	"github.com/astaxie/beego"
	"github.com/garyburd/redigo/redis"
)

type RedisClient struct {
	pool *redis.Pool
}

func (c *RedisClient) InitPool(addr, password string, dbIndex int) error {
	logs.Info("-------------- redis2 initPool with URL ", addr, password, dbIndex)
	if c == nil {
		logs.Debug("c == nil")
	}

	if len(password) > 0 {
		c.pool = c.newPool(addr, password, dbIndex)
	} else {
		logs.Info("-------------- redis2 not configure password ")

		localPool := c.newPool(addr, "", dbIndex)

		if localPool == nil {
			logs.Debug("localPool2 == nil")
		} else {
			logs.Debug("redis pool2: %v ", localPool)
		}

		if c == nil {
			logs.Debug("c == nil")
		}

		c.pool = localPool

		logs.Debug("newPool finished")
	}

	if c.pool == nil {
		return errors.New("redis init pool failed")
	}

	return nil
}

func (c *RedisClient) newPool(server, password string, db int) *redis.Pool {

	logs.Debug("newPool processing")

	localPool := &redis.Pool{
		MaxIdle:     10,
		IdleTimeout: 240 * time.Second,
		Dial: func() (redis.Conn, error) {
			con, err := redis.Dial("tcp", server)
			if err != nil {
				logs.Error("redis dial error:", err.Error())
				return nil, err
			}
			if len(password) > 0 {
				_, err = con.Do("AUTH", password)
				if err != nil {
					return nil, err
				}
			}
			_, err = con.Do("SELECT", db)
			if err != nil {
				return nil, err
			}
			return con, nil
		},
		TestOnBorrow: func(con redis.Conn, t time.Time) error {
			_, err := con.Do("PING")
			return err
		},
	}

	if localPool == nil {
		logs.Debug("localPool == nil")
	} else {
		logs.Debug("redis pool: %v ", localPool)
	}

	return localPool
}

func (c *RedisClient) GetPool() *redis.Pool {
	if c.pool == nil {
		logs.Error("redis pool is nil")
		panic("redis pool is nil")
	}
	return c.pool
}

//设置key多少秒后超时
func (c *RedisClient) Expire(key string, seconds int) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := conn.Do("EXPIRE", key, seconds)
	if err != nil {
		logs.Error("redisUtil Expire error: ", err.Error())
	}
	return nil
}

func (c *RedisClient) Delete(key string) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("DEL", key); err != nil {
		logs.Error("redisUtil Delete error: ", err.Error())
		return err
	}
	return nil
}

func (c *RedisClient) SetComplexObject(key string, value interface{}) error {
	bytes, _ := json.Marshal(value)
	if err := c.SetString(key, string(bytes)); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SetComplexObjectExpire(key string, value interface{}, expire int) error {
	bytes, _ := json.Marshal(value)
	logs.Info("SetComplexObjectExpire %v %v", key, string(bytes))
	if err := c.SetStringWithExpire(key, string(bytes), expire); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) GetComplexObject(key string, value interface{}) error {
	str, err := c.GetString(key)
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

func (c *RedisClient) SetObjectWithExpire(key string, value interface{}, expire int) error {
	beego.Info(FormatLog("SetObjectWithExpire", key, "", nil))
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("HMSET", redis.Args{}.Add(key).AddFlat(value)...); err != nil {
		logs.Info(FormatLog("SetObjectWithExpire", key, value, err))
		return err
	}
	Expire(key, expire)
	return nil
}

func (c *RedisClient) SetStringWithExpire(key string, value string, expire int) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("SET", key, value, "EX", expire); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SetValueWithExpire(key string, value interface{}, expire int) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("SET", key, value, "EX", expire); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SetString(key string, value string) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("SET", key, value); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) GetString(key string) (string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.String(conn.Do("GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return "", nil
		}
		return "", err
	}
	return v, nil
}

func (c *RedisClient) GetInt64(key string) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.String(conn.Do("GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return 0, nil
		}
		return 0, err
	}
	return stringUtil.StringToInt64(v), nil
}
func (c *RedisClient) GetInt(key string) (int, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.String(conn.Do("GET", key))
	if err != nil {
		if err == redis.ErrNil {
			return 0, nil
		}
		return 0, err
	}
	return stringUtil.StringToInt(v), nil
}
func (c *RedisClient) Exists(key string) bool {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.Bool(conn.Do("EXISTS", key))
	if err != nil {
		logs.Error("redis Exists failed, err:%s", err.Error())
		return false
	}
	return v
}

func (c *RedisClient) HExists(key string, detailKey string) bool {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.Bool(conn.Do("HEXISTS", key, detailKey))
	if err != nil {
		logs.Error("redis HExists failed, err:%s", err.Error())
		return false
	}
	return v
}

func (c *RedisClient) AddGeoIndex(indexName string, geoKey string, latitude float32, longitude float32) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := conn.Do("GEOADD", indexName, latitude, longitude, geoKey)
	if err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) GetKeysByPrefix(prefix string) ([]string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	keys, err := redis.Strings(conn.Do("KEYS", prefix+"*"))
	if err != nil {
		return nil, err
	}
	return keys, nil
}

//往redis里面插入键值，如果键已存在，返回False，不执行
//如果键不存在，插入键值,返回成功
func (c *RedisClient) SetStringIfNotExist(key, value string, expire int) (bool, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	result, err := redis.String(conn.Do("SET", key, value, "EX", expire, "NX"))
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
func (c *RedisClient) GetValue(key string, value interface{}) (err error) {
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

	conn := c.GetPool().Get()
	defer conn.Close()

	reply, err := redis.Values(conn.Do("MGET", key))
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
func (c *RedisClient) SetValue(key string, value interface{}, seconds ...int) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}
	v := reflect.ValueOf(value)
	isPtr := (v.Kind() == reflect.Ptr)
	if value == nil || (isPtr && v.IsNil()) {
		return errValueIsNil
	}

	conn := c.GetPool().Get()
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
	_, err = conn.Do("SET", args...)
	if err != nil {
		return err
	}
	logs.Info("redis: set success", key)
	return nil
}

func (c *RedisClient) SAddString(key string, s string, seconds ...int) error {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
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

func (c *RedisClient) SAdd(key string, value interface{}, seconds ...int) error {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	var err error

	if err = conn.Send("SADD", key, value); err != nil {
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

func (c *RedisClient) SRemString(key string, s string) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	var err error

	if err = conn.Send("SREM", key, s); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SRemInt64(key string, value int64) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	var err error

	if err = conn.Send("SREM", key, value); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SMembersString(key string) ([]string, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	ss, err := redis.Strings(conn.Do("SMEMBERS", key))
	if err != nil {
		return nil, err
	}
	return ss, nil
}

func (c *RedisClient) SMembersInt64s(key string) ([]int64, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	ss, err := redis.Int64s(conn.Do("SMEMBERS", key))
	if err != nil {
		return nil, err
	}
	return ss, nil
}

func (c *RedisClient) SIsMember(key, val string) (bool, error) {
	if len(key) == 0 {
		return false, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	b, err := redis.Bool(conn.Do("SISMEMBER", key, val))
	return b, err
}

func (c *RedisClient) SRandMember(key string, count int) ([]string, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	strs, err := redis.Strings(conn.Do("SRANDMEMBER", key, count))
	return strs, err
}

func (c *RedisClient) Incr(key string) (*int, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()

	id, err := redis.Int(conn.Do("INCR", key))
	if err != nil {
		return nil, err
	}
	return &id, nil
}

func (c *RedisClient) IncrWithExpire(key string, second int) (*int, error) {
	id, err := c.Incr(key)
	if err != nil {
		return nil, err
	}
	err = c.Expire(key, second)
	if err != nil {
		return nil, err
	}
	return id, nil
}

//SET if Not exists
func (c *RedisClient) SetValueNX(key string, value interface{}, seconds ...int) (err error) {
	if c.Exists(key) {
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

	conn := c.GetPool().Get()
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
	_, err = conn.Do("SET", args...)
	if err != nil {
		return err
	}
	return nil
}

//SET Hash string
func (c *RedisClient) SetHashStringWithExpire(key, field, value string, seconds ...int) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
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

//SET Hash string
func (c *RedisClient) SetHashWithExpire(key, field string, value interface{}, seconds ...int) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
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

func (c *RedisClient) DeleteHashString(key, field string) (err error) {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()

	if err = conn.Send("HDEL", key, field); err != nil {
		return err
	}

	return nil
}

func (c *RedisClient) GetHashStrings(key string) ([]string, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	ss, err := redis.Strings(conn.Do("HGETALL", key))
	if err != nil {
		return nil, err
	}
	return ss, nil
}

func (c *RedisClient) GetAllHashMap(key string) (map[string]interface{}, error) {
	if len(key) == 0 {
		return nil, errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	kvs, err := conn.Do("HGETALL", key)
	if err != nil {
		return nil, err
	}

	res := kvs.([]interface{})

	resMap := make(map[string]interface{}, 0)

	if len(res)%2 != 0 {
		return nil, ErrRedisHget
	} else {
		for a := 0; a < len(res)/2; a++ {
			logs.Debug("first:%v, second:%v", res[2*a], res[2*a+1])
			resMap[string(res[2*a].([]byte))] = res[2*a+1]
		}
	}

	return resMap, nil
}

func (c *RedisClient) GetAllHash(key string) (map[string]string, error) {
	//var fields, values []string
	kvs, err := c.GetHashStrings(key)
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
func (c *RedisClient) GetHashString(key, field string) (string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.String(conn.Do("HGET", key, field))
	if err != nil {
		if err == redis.ErrNil {
			return "", nil
		}
		return "", err
	}
	return v, nil
}

//GET Hash string
func (c *RedisClient) GetHashInt64(key, field string) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	v, err := redis.Int64(conn.Do("HGET", key, field))
	if err != nil {
		if err == redis.ErrNil {
			return 0, nil
		}
		return 0, err
	}
	return v, nil
}

func (c *RedisClient) GetHashStruct(key string, target interface{}) error {
	if len(key) == 0 {
		return errKeyIsBlank
	}

	conn := c.GetPool().Get()
	defer conn.Close()
	values, err := redis.Values(conn.Do("HGETALL", key))
	if err != nil {
		return err
	} else if 0 == len(values) {
		return redis.ErrNil
	}

	err = redis.ScanStruct(values, target)
	return err
}

func (c *RedisClient) LpushString(key, value string) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	if _, err := conn.Do("LPUSH", key, value); err != nil {
		return err
	}
	return nil
}

func (c *RedisClient) SetNxWithExpire(key, value string, expire int) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	reply, err := conn.Do("SETNX", key, value)
	if err != nil {
		return 0, err
	}
	if _, err := conn.Do("EXPIRE", key, expire); err != nil {
		return 0, err
	}
	return reply.(int64), nil
}

func (c *RedisClient) SetNxWithExpire2(key, value string, expire int64, isMilli bool) (bool, error) {
	conn := c.GetPool().Get()
	defer conn.Close()
	op := "EX"
	if isMilli {
		op = "PX"
	}
	logs.Debug("redis: SET %s %s %s %d NX", key, value, op, expire)
	reply, err := conn.Do("SET", key, value, op, expire, "NX")
	if err != nil {
		return false, err
	}
	//to check
	return reply == "OK", nil
}

func (c *RedisClient) ZAdd(key string, score int64, value interface{}) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := conn.Do("zadd", key, score, value)

	return err
}

func (c *RedisClient) ZAddNx(key string, score int64, value interface{}) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := do(conn, "zadd", key, "nx", score, value)

	return err
}

func (c *RedisClient) ZRem(key string, value interface{}) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := conn.Do("zrem", key, value)

	return err
}

func (c *RedisClient) ZCount(key string, min, max string) (count int64, err error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	count, err = redis.Int64(conn.Do("zcount", key, min, max))

	return
}

func (c *RedisClient) ZCard(key string) (count int64, err error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	count, err = redis.Int64(conn.Do("zcard", key))

	return
}

func (c *RedisClient) ZRank(key string, detailKey string) (rank int64, err error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	rank, err = redis.Int64(conn.Do("zrank", key, detailKey))

	return
}

func (c *RedisClient) ZRevRange(key, start, stop string) ([]string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.Strings(conn.Do("zrevrange", key, start, stop))
}

func (c *RedisClient) ZRange(key, start, stop string) ([]string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.Strings(conn.Do("zrange", key, start, stop))
}

func (c *RedisClient) ZScore(key, member string) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.Int64(conn.Do("zscore", key, member))
}

func (c *RedisClient) Rpush(key string, value interface{}) error {
	conn := c.GetPool().Get()
	defer conn.Close()
	_, err := conn.Do("RPUSH", key, value)

	return err
}

func (c *RedisClient) Lpop(key string) (string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.String(conn.Do("LPOP", key))
}

func (c *RedisClient) Llen(key string) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.Int64(conn.Do("LLEN", key))
}

func (c *RedisClient) FormatLog(job, key string, value interface{}, err error) string {
	if err != nil {
		return fmt.Sprintf("%v[error] key:%v value:%v err:%v", job, key, value, err.Error())
	}
	return fmt.Sprintf("%v[success] key:%v value:%v err:%v", job, key, value, "")

}

func (c *RedisClient) EvalLuaScript(script string, keys []string, args ...interface{}) (interface{}, error) {
	conn := c.GetPool().Get()
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

func (c *RedisClient) GetValuesByKeys(keys []string) ([]string, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	err := conn.Send("MULTI")
	if err != nil {
		logs.Error("conn.Send('MULTI'):%v", err)
		return nil, err
	}
	for _, key := range keys {
		conn.Send("GET", key)
	}
	r, err := redis.Values(conn.Do("EXEC"))
	if err != nil {
		logs.Error("redis.Values(conn.Do('EXEC')):%v", err)
		return nil, err
	}
	ret := make([]string, len(keys))
	for i, v := range r {
		if v == nil {
			continue
		}
		switch v.(type) {
		case []uint8:
			tmp := v.([]uint8)
			ret[i] = string(tmp)
		default:
			msg := fmt.Sprintf("unexpected type %v %v\n", i, v)
			logs.Error("redis.Values(conn.Do('EXEC')):%v", msg)
			logrus.WithFields(logrus.Fields{"server_ip": utils.GlobalLocalIP, "log_type": "auto", "operate": "Redis.GetValuesByKeys", "code": -1, "str": v}).Info(msg)
		}
	}
	return ret, nil
}

func (c *RedisClient) Scard(key string) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return redis.Int64(conn.Do("SCARD", key))
}

func (c *RedisClient) PipeLineHset(key string, fields []string, values []interface{}) (int64, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	conn.Send("multi")

	for i, field := range fields {
		logs.Debug("PipeLineHset, field:%s, value:%v", field, values[i])
		conn.Send("hset", key, field, values[i])
	}

	_, err := conn.Do("EXEC")
	if err != nil {
		logs.Error("PipeLineHset failed, err:%v", err)
		return -1, err
	}

	return 0, nil
}

func (c *RedisClient) SScan(key string, cursor int64) (interface{}, error) {
	conn := c.GetPool().Get()
	defer conn.Close()

	return conn.Do("sscan", key, cursor)
}
