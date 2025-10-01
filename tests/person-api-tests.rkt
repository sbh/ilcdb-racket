#lang racket

(require rackunit
         json
         web-server/http
         web-server/http/request-structs
         web-server/http/response-structs
         net/url
         "../api/person.rkt")

(test-suite
 "Person API Tests"

 (test-case
  "Get all people"
  (let* ([request (request #"GET" (url "http" #f "localhost" #f #t '() '() #f))]
         [response (get-all-people request)])
    (check-true (response? response))
    (check-equal? (response-code response) 200)
    (let* ([p (open-output-bytes)]
           [output-proc (response-output response)])
      (output-proc p)
      (let ([body (bytes->jsexpr (get-output-bytes p))])
        (check-true (list? body)))))))