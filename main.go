package main

import (
	"fmt"
	"log"
	"net/http"
)

func viewHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, "working 😀")
}

func main() {
    http.HandleFunc("/", viewHandler)
	fmt.Println("Listening on port :8080")
	fmt.Println("To use: GET localhost:8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
