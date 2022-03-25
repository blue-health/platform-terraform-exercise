package main

import (
	"embed"
	"fmt"
	"log"
	"net/http"
)

/*
 * Here we statically load the static.json
 * file into the compiled binary
 */

//go:embed static.json
var staticFs embed.FS

const port = 8080

func main() {
	http.Handle("/", http.FileServer(http.FS(staticFs)))

	log.Printf("Listening on :%d...\n", port)

	if err := http.ListenAndServe(fmt.Sprintf(":%d", port), nil); err != nil {
		log.Fatal(err)
	}
}
