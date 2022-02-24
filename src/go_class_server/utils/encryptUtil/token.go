package encryptUtil

import (
	"crypto/md5"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

//appid,app_sign是控制台上申请账号的时候获得，这里的userID需要和web sdk前端传入的userID一致，
//否则校验失败(因为这里的userID是为了校验和前端传进来的userID是否一致)。
func MakeAppToken(appid uint32, app_sign string, userID string, expired_add int64) (ret string, err error) {
	nonce := userID
	expired := time.Now().Unix() + expired_add //单位:秒

	app_sign = strings.Replace(app_sign, "0x", "", -1)
	app_sign = strings.Replace(app_sign, ",", "", -1)
	if len(app_sign) < 32 {
		return "", fmt.Errorf("app_sign wrong")
	}

	app_sign_32 := app_sign[0:32]
	source := fmt.Sprintf("%d%s%s%s%d", appid, app_sign_32, userID, nonce, expired)

	m := md5.New()
	_, err = m.Write([]byte(source))
	if err != nil {
		return "", err
	}
	buff := fmt.Sprintf("%x", m.Sum(nil))

	var token struct {
		Ver     int64  `json:"ver"`
		Hash    string `json:"hash"`
		Nonce   string `json:"nonce"`
		Expired int64  `json:"expired"`
	}

	token.Ver = 1
	token.Hash = buff
	token.Nonce = nonce
	token.Expired = expired

	buf, err := json.Marshal(token)
	if err != nil {
		return "", err
	}

	encodeString := base64.StdEncoding.EncodeToString(buf)
	return encodeString, nil
}
