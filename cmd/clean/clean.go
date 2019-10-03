//
// Copyright (c) 2019-present Codist <countstarlight@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
// Written by Codist <countstarlight@gmail.com>, October 2019
//

package main

import (
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"time"
)

type Namesilo struct {
	XMLName xml.Name `xml:"namesilo"`
	Text    string   `xml:",chardata"`
	Request struct {
		Text      string `xml:",chardata"`
		Operation string `xml:"operation"`
		Ip        string `xml:"ip"`
	} `xml:"request"`
	Reply struct {
		Text   string `xml:",chardata"`
		Code   string `xml:"code"`
		Detail string `xml:"detail"`
	} `xml:"reply"`
}

func main() {
	domain := os.Getenv("CERTBOT_DOMAIN")
	tmpDir := path.Join(os.TempDir(), "CERTBOT_"+domain)
	// Check and create dir
	if _, err := os.Stat(tmpDir); os.IsNotExist(err) {
		_ = os.Mkdir(tmpDir, os.ModePerm)
	}
	apiKey := os.Getenv("NAMESILO_API")
	if len(apiKey) == 0 {
		log.Fatal("Need set 'NAMESILO_API' in env")
	}

	// Read record id
	b, err := ioutil.ReadFile(path.Join(tmpDir, "RECORD_ID"))
	if err != nil {
		log.Fatal(err)
	}

	// Build request
	apiUrl := fmt.Sprintf("https://www.namesilo.com/api/dnsDeleteRecord?"+
		"version=1&type=xml&key=%s&domain=%s&rrid=%s", apiKey, domain, string(b))
	urlLink, err := url.Parse(apiUrl)
	if err != nil {
		log.Fatal("Parse url failed: " + err.Error())
	}
	req, err := http.NewRequest("GET", apiUrl, nil)
	if err != nil {
		log.Fatal("Build request failed: " + err.Error())
	}
	req.Header.Set("Host", urlLink.Host)
	req.Header.Set("User-Agent", " Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36")
	req.Header.Set("Referer", apiUrl)

	// Request
	http.DefaultClient.Timeout = 20 * time.Second
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatal("Request failed: " + err.Error())
	}
	if resp.StatusCode != http.StatusOK {
		log.Fatal("Status code != 200: " + string(resp.StatusCode))
	}

	// Parse response
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("Read response body failed: " + err.Error())
	}
	var result Namesilo
	err = xml.Unmarshal(data, &result)
	if err != nil {
		log.Fatal("Unmarshal response body to xml failed: " + err.Error())
	}
	if result.Reply.Code != "300" {
		log.Fatalf("%s: %s {%s}", domain, result.Reply.Detail, result.Reply.Code)
	}
	_ = os.Remove(path.Join(tmpDir, "RECORD_ID"))
}
