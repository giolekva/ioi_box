package main

import (
	"fmt"

	"math/rand"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	// "io"
	// "os"
	// "time"
)

var addresses []string = []string{"localhost:8000", "185.212.252.108", "185.212.252.251", "185.212.252.242"}

func getBase(contest string) string {
	// return "https://cms.ejoi2020.ge"
	return "http://185.212.252.108" + contest
	return "http://" + addresses[rand.Intn(1)]
}

func delay() {
	// time.Sleep(time.Duration(rand.Intn(10)) * time.Millisecond)
}

func login(contest string, ch chan string) {
	delay()

	cookieJar, _ := cookiejar.New(nil)
	client := &http.Client{
		Jar: cookieJar,
	}

	// resp, err := client.Get(getBase() + "/" + contest)
	resp, err := client.Get(getBase(contest))
	if err != nil {
		fmt.Print(err)
		ch <- resp.Status
		return
	}
	var xsrf string
	for _, c := range resp.Cookies() {
		if c.Name == "_xsrf" {
			xsrf = c.Value
		}
	}
	if len(xsrf) == 0 {
		ch <- "No xsrf"
	}
	fmt.Printf("XSRF: %s\n", xsrf)
	v := url.Values{}
	v.Add("username", "lekva")
	v.Add("password", "AQDZAXhEB2u1tgDLpHE5SF2H1K8Yxix")
	v.Add("_xsrf", xsrf)
	delay()
	resp, err = client.PostForm(getBase(contest)+"/login", v)
	if err != nil {
		ch <- err.Error()
		return
	}
	//	io.Copy(os.Stdout, resp.Body)
	fmt.Printf("Login: %s\n", resp.Status)
	ch <- resp.Status
	return
	delay()
	resp, err = client.Get(getBase(contest) + "/tasks/game/statements/en")
	if err != nil {
		ch <- err.Error()
		return
	}
	fmt.Printf("Vector: %s\n", resp.Status)
	// io.Copy(os.Stdout, resp.Body)
	ch <- resp.Status
}

func main() {
	n := 300
	ch := make(chan string, 10000)
	for i := 0; i < n; i++ {
		// go login("Freeuni", ch)
		// go login("/Test", ch)
		go login("", ch)

		// go login("https://cms.geoi.ge", "Freeuni", ch)
	}
	for i := 0; i < n; i++ {
		fmt.Printf("%d %s\n", i, <-ch)
	}
}
