package service

import (
	"bytes"
	"encoding/hex"
	"encoding/json"
	"errors"
	"go_class_server/utils/timeUtil"

	"github.com/astaxie/beego"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/encryptUtil"
	"strings"
)

type Encrypt struct {
	IsEncrypted    bool
	key            []byte
	iv             []byte
	AESRequestBody []byte
}

func NewEncrypter() *Encrypt {
	return &Encrypt{}
}

func (this *Encrypt) DecryptBase(s, requestURI string, req *protocol.BaseRequest) error {
	if needEncrypt, _ := beego.AppConfig.Bool("needEncrypt"); needEncrypt && s == "" {
		return errors.New("encrypt data fail")
	}

	if s == "" {
		return nil
	}

	this.IsEncrypted = true
	this.key = []byte(beego.AppConfig.String("commonAPIKey"))
	this.iv = []byte(beego.AppConfig.String("commonAPIIV"))

	if strings.HasSuffix(requestURI, "/conference/query_global") {
		this.key = []byte(beego.AppConfig.String("queryGlobalConferenceKey"))
		this.iv = []byte(beego.AppConfig.String("queryGlobalConferenceIV"))
	}

	sData, err := hex.DecodeString(s)
	if err != nil {
		return err
	}

	reqBody, err := encryptUtil.AESDecrypt(this.key, this.iv, sData)
	if err != nil {
		return err
	}

	this.AESRequestBody = reqBody

	err = json.Unmarshal(reqBody, req)
	if err != nil {
		return err
	}
	req.S = ""
	return nil
}

func (this *Encrypt) EncryptBaseWithCode(code int, msg string, resp interface{}) interface{} {
	if resp == nil {
		resp = protocol.CommonRsp{
			Ret: protocol.CommonResult{
				Code:      code,
				Message:   msg,
				Timestamp: timeUtil.MilliSecond(),
			},
		}
	}

	buf := new(bytes.Buffer)
	encoder := json.NewEncoder(buf)
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(resp); err != nil {
		return nil
	}

	if this.IsEncrypted {
		cipherText, _ := encryptUtil.AESEncrypt(this.key, this.iv, buf.Bytes())
		s := make(map[string]interface{})
		s["s"] = hex.EncodeToString(cipherText)
		return s
	}

	return resp
}
