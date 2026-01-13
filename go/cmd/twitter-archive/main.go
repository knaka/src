// 引数に取った CSV から、 ~/doc/$year/ 以下のファイルへアーカイブする
// export には右記を利用 — TwExporty https://chromewebstore.google.com/detail/twexportly-export-tweets/hbibehafoapglhcgfhlpifagloecmhfh
package main

import (
	"encoding/csv"
	"fmt"
	"html"
	"io"
	"log"
	"os"
	"path"
	"regexp"
	"sort"
	"strings"
	"time"

	"github.com/mitchellh/go-homedir"
)

func main() {
	//input, err := os.Open("/Users/knaka/doc/2023/TwExportly_knaka_tweets_2023_07_12.csv")
	input, err := os.Open(os.Args[1])
	if err != nil {
		log.Panicf("panic cf3208f (%v)", err)
	}
	reader := csv.NewReader(input)
	var recordHeader []string
	var records [][]string
	keyToIndex := make(map[string]int)
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Panicf("panic ba342c9 (%v)", err)
		}
		if recordHeader == nil {
			recordHeader = record
			for i, key := range recordHeader {
				keyToIndex[key] = i
			}
			continue
		}
		//_, _ = fmt.Fprintln(os.Stdout, record)
		records = append(records, record)
	}
	sort.Slice(records, func(i int, j int) bool {
		return strings.Compare(records[i][0], records[j][0]) > 0
	})
	//fmt.Println(os.Stdout, keyToIndex)
	userID := "knaka"
	// CSV には、ローカル時刻が入るようなんだよね。ブラウザ（日本時間設定）で fetch しているからか
	loc, _ := time.LoadLocation("Local")
	re := regexp.MustCompile(`\bhttps://t.co/[a-zA-Z0-9]+\b`)
	var monthPrev time.Month
	var yearPrev int
	filePostfix := ""
	var outputPath string
	now := time.Now()
	homeDir, _ := homedir.Dir()
	var output *os.File
	for _, record := range records {
		// TwExporty の出力に、single-quote で括られたフィールドがあるぞ？ CSV としては変だな
		tweetID := strings.Trim(record[keyToIndex["tweet_id"]], "'")
		createdAt := strings.Trim(record[keyToIndex["created_at"]], "'")
		permenentURL := fmt.Sprintf("https://twitter.com/%s/status/%s", userID, tweetID)
		t, _ := time.ParseInLocation("2006-01-02 15:04:05", createdAt, loc)
		yearCurrent := t.Year()
		monthCurrent := t.Month()
		if yearPrev != yearCurrent || monthPrev != monthCurrent {
			if now.Year() == yearCurrent && now.Month() == monthCurrent {
				filePostfix = "-tmp"
			} else {
				filePostfix = ""
			}
			outputPath = path.Join(
				homeDir,
				"doc",
				fmt.Sprintf("%04d", yearCurrent),
				fmt.Sprintf("%02d00tweets%s.tsv", monthCurrent, filePostfix),
			)
			info, err := os.Stat(outputPath)
			if os.IsNotExist(err) {
				//_, _ = fmt.Fprintf(os.Stdout, "Creates and switches to file %s\n", outputPath)
				_ = output.Close()
				//output, err := os.OpenFile(outputPath, os.O_CREATE|os.O_WRONLY, 0644)
				output, err = os.Create(outputPath)
				if err != nil {
					log.Panicf("panic 218a510 (%v)", err)
				}
			} else if err != nil || info.IsDir() {
				log.Panicf("panic a5dc12a (%v)", err)
			} else {
				if filePostfix != "" {
					//_, _ = fmt.Fprintf(os.Stdout, "Removes and switches to %s\n", outputPath)
					_ = os.Remove(outputPath)
					output, err = os.Create(outputPath)
					if err != nil {
						log.Panicf("panic 218a510 (%v)", err)
					}
				} else {
					break
				}
			}
		}
		text := record[keyToIndex["text"]]
		text = strings.ReplaceAll(text, "\n", " ")
		//text = strings.ReplaceAll(text, "\r", " ")
		text = html.UnescapeString(text)
		//fmt.Fprintf(os.Stderr, "ae9be4b: %s\n", text)
		i := 0
		urls := strings.Split(record[keyToIndex["urls"]], ",")
		text = re.ReplaceAllStringFunc(text, func(s string) string {
			ret := s
			if i < len(urls) {
				ret = urls[i]
				i = i + 1
			}
			return ret
		})
		_, _ = fmt.Fprintf(output, "%s\t%s\t%s\n", permenentURL, t.Format(time.RFC3339Nano), text)
		yearPrev = yearCurrent
		monthPrev = monthCurrent
	}
	_ = output.Close()
}
