package encryptUtil

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/des"
	"errors"
	"fmt"
	"strings"

	"math"
	"strconv"

	"github.com/astaxie/beego"
)

// pad uses the PKCS#7 padding scheme to align the a payload to a specific block size
func PKCS7Padding(plaintext []byte, bsize int) ([]byte, error) {
	//pad := bsize
	//remainder := len(plaintext) % bsize
	//if remainder > 0 {
	//	pad = bsize - remainder
	//}
	remainder := len(plaintext) % bsize
	pad := bsize - remainder

	for i := 0; i < pad; i++ {
		//plaintext = append(plaintext, byte(32))
		plaintext = append(plaintext, byte(pad))
	}

	return plaintext, nil
}

func pad(plaintext []byte, bsize int) ([]byte, error) {
	remainder := len(plaintext) % bsize
	if remainder > 0 {
		pad := bsize - remainder

		for i := 0; i < pad; i++ {
			plaintext = append(plaintext, byte(32))
		}
	}

	return plaintext, nil
}

// unpad strips the padding previously added using the PKCS#7 padding scheme
//func unpad(paddedtext []byte) ([]byte, error) {
func unpad(paddedtext []byte) ([]byte, error) {
	le := len(paddedtext)
	pad := paddedtext[len(paddedtext)-1]
	if (le-int(pad)) > le || (le-int(pad)) < 0 {
		return []byte{}, errors.New(fmt.Sprintf("unpadding fail (le-int(pad)) > le:%v (le-int(pad)) < 0):%v", (le-int(pad)) > le, (le-int(pad)) < 0))
	}
	tmp := paddedtext[:len(paddedtext)-int(pad)]
	return tmp, nil
}

func AESEncrypt(key []byte, iv []byte, plaintext []byte) ([]byte, error) {
	paddedplaintext, err := PKCS7Padding(plaintext, aes.BlockSize)
	if err != nil {
		return nil, err
	}
	le := len(paddedplaintext)

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	ciphertext := make([]byte, le)

	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(ciphertext, paddedplaintext)

	return ciphertext, nil
}

func AESDecrypt(key []byte, iv []byte, ciphertext []byte) ([]byte, error) {
	if len(ciphertext) < aes.BlockSize {
		return nil, errors.New("ciphertext too short")
	}

	if len(ciphertext)%aes.BlockSize != 0 {
		return nil, errors.New("ciphertext is not a multiple of the block size")
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	mode := cipher.NewCBCDecrypter(block, iv)

	plaintext := make([]byte, len(ciphertext))
	mode.CryptBlocks(plaintext, ciphertext)

	if len(plaintext)%aes.BlockSize != 0 {
		return nil, errors.New("ciphertext is not a multiple of the block size")
	}

	return unpad(plaintext)
}

func PKCS5Padding(ciphertext []byte, blockSize int) []byte {
	padding := blockSize - len(ciphertext)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(ciphertext, padtext...)
}

func PKCS5UnPadding(origData []byte) []byte {
	length := len(origData)
	// 去掉最后一个字节 unpadding 次
	unpadding := int(origData[length-1])
	return origData[:(length - unpadding)]
}

// 3DES加密
func TripleDesEncrypt(key, origData []byte) ([]byte, error) {
	block, err := des.NewTripleDESCipher(key)
	if err != nil {
		return nil, err
	}
	origData = PKCS5Padding(origData, block.BlockSize())
	// origData = ZeroPadding(origData, block.BlockSize())
	blockMode := cipher.NewCBCEncrypter(block, key[:8])
	crypted := make([]byte, len(origData))
	blockMode.CryptBlocks(crypted, origData)
	return crypted, nil
}

// 3DES解密
func TripleDesDecrypt(key, crypted []byte) ([]byte, error) {
	block, err := des.NewTripleDESCipher(key)
	if err != nil {
		return nil, err
	}
	blockMode := cipher.NewCBCDecrypter(block, key[:8])
	origData := make([]byte, len(crypted))
	// origData := crypted
	blockMode.CryptBlocks(origData, crypted)
	origData = PKCS5UnPadding(origData)
	// origData = ZeroUnPadding(origData)
	return origData, nil
}

func TripleDesEncode(origData []byte) []byte {
	key := []byte(beego.AppConfig.String("3deskey"))
	rs, _ := TripleDesEncrypt(key, origData)
	return rs
}

func TripleDesDecode(crypted []byte) []byte {
	key := []byte(beego.AppConfig.String("3deskey"))
	rs, _ := TripleDesDecrypt(key, crypted)
	return rs
}

var tenToAny map[int]string = map[int]string{0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9", 10: "a", 11: "b", 12: "c", 13: "d", 14: "e", 15: "f", 16: "g", 17: "h", 18: "i", 19: "j", 20: "k", 21: "l", 22: "m", 23: "n", 24: "o", 25: "p", 26: "q", 27: "r", 28: "s", 29: "t", 30: "u", 31: "v", 32: "w", 33: "x", 34: "y", 35: "z", 36: ":", 37: ";", 38: "<", 39: "=", 40: ">", 41: "?", 42: "@", 43: "[", 44: "]", 45: "^", 46: "_", 47: "{", 48: "|", 49: "}", 50: "A", 51: "B", 52: "C", 53: "D", 54: "E", 55: "F", 56: "G", 57: "H", 58: "I", 59: "J", 60: "K", 61: "L", 62: "M", 63: "N", 64: "O", 65: "P", 66: "Q", 67: "R", 68: "S", 69: "T", 70: "U", 71: "V", 72: "W", 73: "X", 74: "Y", 75: "Z"}

//func main() {
//	fmt.Println(decimalToAny(9999, 76))
//	fmt.Println(anyToDecimal("1F[", 76))
//}

// 10进制转任意进制
func DecimalToAny(num, n int) string {
	new_num_str := ""
	var remainder int
	var remainder_string string
	for num != 0 {
		remainder = num % n
		if 76 > remainder && remainder > 9 {
			remainder_string = tenToAny[remainder]
		} else {
			remainder_string = strconv.Itoa(remainder)
		}
		new_num_str = remainder_string + new_num_str
		num = num / n
	}
	return new_num_str
}

// map根据value找key
func findkey(in string) int {
	result := -1
	for k, v := range tenToAny {
		if in == v {
			result = k
		}
	}
	return result
}

// 任意进制转10进制
func AnyToDecimal(num string, n int) int {
	var new_num float64
	new_num = 0.0
	nNum := len(strings.Split(num, "")) - 1
	for _, value := range strings.Split(num, "") {
		tmp := float64(findkey(value))
		if tmp != -1 {
			new_num = new_num + tmp*math.Pow(float64(n), float64(nNum))
			nNum = nNum - 1
		} else {
			break
		}
	}
	return int(new_num)
}
