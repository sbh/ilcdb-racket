#lang racket

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/country.rkt"
         "../models/country.rkt")

(provide country-api-dispatcher
         get-all-countries)

(define-values (country-api-dispatcher _)
  (dispatch-rules
   [("api" "country" (string-arg))
    (lambda (request id)
      (match (request-method request)
        ["GET" (get-country request id)]
        ["PUT" (put-country request id)]
        ["DELETE" (delete-country request id)]))]
   [("api" "country")
    (lambda (request)
      (match (request-method request)
        ["GET" (get-all-countries request)]
        ["POST" (post-country request)]))]))

(define (get-all-countries request)
  (define countries (country-read-all))
  (response/jsexpr (map country->jsexpr countries)))

(define (get-country request id-str)
  (define id (string->number id-str))
  (define c (country-read id))
  (if c
      (response/jsexpr (country->jsexpr c))
      (response/full 404 #"Not Found")))

(define (post-country request)
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define name (hash-ref json-body 'name))
  (define new-id (country-create name))
  (response/jsexpr (hasheq 'id new-id)))

(define (put-country request id-str)
  (define id (string->number id-str))
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define name (hash-ref json-body 'name))
  (country-update id name)
  (response/full 200 #"OK"))

(define (delete-country request id-str)
  (define id (string->number id-str))
  (country-delete id)
  (response/full 200 #"OK"))