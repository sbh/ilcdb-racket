#lang racket

(provide address-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         db/base
         "../db/address.rkt"
         "../models/address.rkt")

(define-values (address-api-dispatcher _)
  (dispatch-rules
   [("api" "address")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-addresses req)]
        ["POST" (post-address req)]))]
   [("api" "address" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-address req id)]
        ["PUT" (put-address req id)]
        ["DELETE" (delete-address req id)]))]))

(define (get-all-addresses request)
  (let ([addresses (address-read-all)])
    (response/jsexpr (map address->jsexpr addresses))))

(define (get-address request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([a (address-read id)])
        (if a
            (response/jsexpr (address->jsexpr a))
            (response/full 404 #"Not Found"))))))

(define (post-address request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [street (hash-ref json-body 'street)]
         [city (hash-ref json-body 'city)]
         [county (hash-ref json-body 'county #f)]
         [state (hash-ref json-body 'state)]
         [postal-code (hash-ref json-body 'postal-code)]
         [country-id (hash-ref json-body 'country-id)]
         [person-id (hash-ref json-body 'person-id #f)])
    (let ([new-id (address-create street city county state postal-code country-id (if person-id person-id sql-null))])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-address request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [street (hash-ref json-body 'street)]
         [city (hash-ref json-body 'city)]
         [county (hash-ref json-body 'county #f)]
         [state (hash-ref json-body 'state)]
         [postal-code (hash-ref json-body 'postal-code)]
         [country-id (hash-ref json-body 'country-id)]
         [person-id (hash-ref json-body 'person-id #f)])
    (address-update id street city county state postal-code country-id (if person-id person-id sql-null))
    (response/full 200 #"OK")))

(define (delete-address request id-str)
  (let ([id (string->number id-str)])
    (address-delete id)
    (response/full 200 #"OK")))