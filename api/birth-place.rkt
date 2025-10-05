#lang racket

(provide birth-place-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/birth-place.rkt"
         "../models/birth-place.rkt")

(define-values (birth-place-api-dispatcher _)
  (dispatch-rules
   [("api" "birth-place")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-birth-places req)]
        ["POST" (post-birth-place req)]))]
   [("api" "birth-place" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-birth-place req id)]
        ["PUT" (put-birth-place req id)]
        ["DELETE" (delete-birth-place req id)]))]))

(define (get-all-birth-places request)
  (let ([birth-places (birth-place-read-all)])
    (response/jsexpr (map birth-place->jsexpr birth-places))))

(define (get-birth-place request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([bp (birth-place-read id)])
        (if bp
            (response/jsexpr (birth-place->jsexpr bp))
            (response/full 404 #"Not Found"))))))

(define (post-birth-place request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [city (hash-ref json-body 'city)]
         [state (hash-ref json-body 'state)]
         [country-id (hash-ref json-body 'country-id)])
    (let ([new-id (birth-place-create city state country-id)])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-birth-place request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [city (hash-ref json-body 'city)]
         [state (hash-ref json-body 'state)]
         [country-id (hash-ref json-body 'country-id)])
    (birth-place-update id city state country-id)
    (response/full 200 #"OK")))

(define (delete-birth-place request id-str)
  (let ([id (string->number id-str)])
    (birth-place-delete id)
    (response/full 200 #"OK")))