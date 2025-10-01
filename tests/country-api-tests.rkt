#lang racket

(require rackunit
         json
         web-server/http
         web-server/http/request-structs
         web-server/http/response-structs
         net/url
         "../api/country.rkt")

(test-suite
 "Country API Tests"

 (test-case
  "Get all countries"
  (let* ([request (request #"GET" (url "http" #f "localhost" #f #t '() '() #f))]
         [response (get-all-countries request)])
    (check-true (response? response))
    (check-equal? (response-code response) 200)
    (let* ([p (open-output-bytes)]
           [output-proc (response-output response)])
      (output-proc p)
      (let ([body (bytes->jsexpr (get-output-bytes p))])
        (check-true (list? body)))))))