#lang racket

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/birth-place.rkt"
         "../models/birth-place.rkt")

(provide birth-place-api-dispatcher
         get-all-birth-places)

(define-values (birth-place-api-dispatcher _)
  (dispatch-rules
   [("api" "birth-place" (string-arg))
    (lambda (request id)
      (match (request-method request)
        ["GET" (get-birth-place request id)]
        ["PUT" (put-birth-place request id)]
        ["DELETE" (delete-birth-place request id)]))]
   [("api" "birth-place")
    (lambda (request)
      (match (request-method request)
        ["GET" (get-all-birth-places request)]
        ["POST" (post-birth-place request)]))]))

(define (get-all-birth-places request)
  (define birth-places (birth-place-read-all))
  (response/jsexpr (map birth-place->jsexpr birth-places)))

(define (get-birth-place request id-str)
  (define id (string->number id-str))
  (define bp (birth-place-read id))
  (if bp
      (response/jsexpr (birth-place->jsexpr bp))
      (response/full 404 #"Not Found")))

(define (post-birth-place request)
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define city (hash-ref json-body 'city))
  (define state (hash-ref json-body 'state))
  (define country-id (hash-ref json-body 'country-id))
  (define new-id (birth-place-create city state country-id))
  (response/jsexpr (hasheq 'id new-id)))

(define (put-birth-place request id-str)
  (define id (string->number id-str))
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define city (hash-ref json-body 'city))
  (define state (hash-ref json-body 'state))
  (define country-id (hash-ref json-body 'country-id))
  (birth-place-update id city state country-id)
  (response/full 200 #"OK"))

(define (delete-birth-place request id-str)
  (define id (string->number id-str))
  (birth-place-delete id)
  (response/full 200 #"OK"))