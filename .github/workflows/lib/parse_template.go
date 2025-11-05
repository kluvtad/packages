package main

import (
	"flag"
	"os"
	"text/template"
)

func main() {
	var tpl_file string
	flag.StringVar(&tpl_file, "f", "", "File template")
	flag.Parse()

	if tpl_file == "" {
		panic("template file is required")
	}
	print(tpl_file)

	t, err := template.ParseFiles(tpl_file)
	if err != nil {
		panic(err)
	}

	err = t.Execute(os.Stdout, nil)
	if err != nil {
		panic(err)
	}
}
