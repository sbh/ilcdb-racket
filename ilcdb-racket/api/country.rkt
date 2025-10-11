#lang racket

(provide country-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/country.rkt"
         "../models/country.rkt")

(define-values (country-api-dispatcher _)
  (dispatch-rules
   [("api" "country")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-countries req)]
        ["POST" (post-country req)]))]
   [("api" "country" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-country req id)]
        ["PUT" (put-country req id)]
        ["DELETE" (delete-country req id)]))]))

(define (get-all-countries request)
  (let ([countries (country-read-all)])
    (response/jsexpr (map country->jsexpr countries))))

(define (get-country request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([c (country-read id)])
        (if c
            (response/jsexpr (country->jsexpr c))
            (response/full 404 #"Not Found"))))))

(define (post-country request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [name (hash-ref json-body 'name)])
    (let ([new-id (country-create name)])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-country request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [name (hash-ref json-body 'name)])
    (country-update id name)
    (response/full 200 #"OK")))

(define (delete-country request id-str)
  (let ([id (string->number id-str)])
    (country-delete id)
    (response/full 200 #"OK")))