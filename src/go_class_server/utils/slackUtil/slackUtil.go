package slackUtil

import (
	"fmt"
	"github.com/astaxie/beego"
	"github.com/bluele/slack"
	"github.com/prometheus/common/log"
	"net"
)

func SendMessage(message string) {
	go sendMessage(message)
}

func getToken() string {
	return beego.AppConfig.String("slackToken")
}

func getChannelName() string {
	return beego.AppConfig.String("slackChannel")
}

func isSlackOpen() bool {
	isOpen, err := beego.AppConfig.Bool("slackOpen")
	if err != nil {
		return false
	}
	return isOpen
}

func sendMessage(message string) {
	if !isSlackOpen() {
		log.Debug("slack is turned off")
		return
	}

	api := slack.New(getToken())
	channel, err := api.FindChannelByName(getChannelName())
	if err != nil {
		return
	}
	if channel == nil {
	}

	message = fmt.Sprintf("%s, server ip: %s", message, getServerIp())

	err = api.ChatPostMessage(channel.Id, message, nil)
	if err != nil {
		log.Error("send slack message failed")
	}
}

func getServerIp() string {
	ifaces, err := net.Interfaces()
	if err != nil {
		return "mock ip"
	}
	for _, i := range ifaces {
		addrs, err := i.Addrs()
		if err != nil {
			return "mock ip"
		}
		// handle err
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			if ip == nil || ip.IsLoopback() {
				continue
			}
			ip = ip.To4()
			if ip == nil {
				continue // not an ipv4 address
			}
			return ip.String()
		}
	}
	return "mock ip"
}
