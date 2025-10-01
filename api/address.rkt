#lang racket

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/address.rkt"
         "../models/address.rkt")

(provide address-api-dispatcher
         get-all-addresses)

(define-values (address-api-dispatcher _)
  (dispatch-rules
   [("api" "address" (string-arg))
    (lambda (request id)
      (match (request-method request)
        ["GET" (get-address request id)]
        ["PUT" (put-address request id)]
        ["DELETE" (delete-address request id)]))]
   [("api" "address")
    (lambda (request)
      (match (request-method request)
        ["GET" (get-all-addresses request)]
        ["POST" (post-address request)]))]))

(define (get-all-addresses request)
  (define addresses (address-read-all))
  (response/jsexpr (map address->jsexpr addresses)))

(define (get-address request id-str)
  (define id (string->number id-str))
  (define a (address-read id))
  (if a
      (response/jsexpr (address->jsexpr a))
      (response/full 404 #"Not Found")))

(define (post-address request)
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define street (hash-ref json-body 'street))
  (define city (hash-ref json-body 'city))
  (define county (hash-ref json-body 'county #f))
  (define state (hash-ref json-body 'state))
  (define postal-code (hash-ref json-body 'postal-code))
  (define country-id (hash-ref json-body 'country-id))
  (define person-id (hash-ref json-body 'person-id))
  (define new-id (address-create street city county state postal-code country-id person-id))
  (response/jsexpr (hasheq 'id new-id)))

(define (put-address request id-str)
  (define id (string->number id-str))
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define street (hash-ref json-body 'street))
  (define city (hash-ref json-body 'city))
  (define county (hash-ref json-body 'county #f))
  (define state (hash-ref json-body 'state))
  (define postal-code (hash-ref json-body 'postal-code))
  (define country-id (hash-ref json-body 'country-id))
  (address-update id street city county state postal-code country-id)
  (response/full 200 #"OK"))

(define (delete-address request id-str)
  (define id (string->number id-str))
  (address-delete id)
  (response/full 200 #"OK"))