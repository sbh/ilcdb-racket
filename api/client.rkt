#lang racket

(provide client-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         gregor
         json
         "../db/client.rkt"
         "../models/client.rkt")

(define-values (client-api-dispatcher _)
  (dispatch-rules
   [("api" "client")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-clients req)]
        ["POST" (post-client req)]))]
   [("api" "client" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-client req id)]
        ["PUT" (put-client req id)]
        ["DELETE" (delete-client req id)]))]))

(define (get-all-clients request)
  (let ([clients (client-read-all)])
    (response/jsexpr (map client->jsexpr clients))))

(define (get-client request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([c (client-read id)])
        (if c
            (response/jsexpr (client->jsexpr c))
            (response/full 404 #"Not Found"))))))

(define (post-client request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [person-id (hash-ref json-body 'person-id)]
         [first-visit (hash-ref json-body 'first-visit #f)]
         [household-income-level (hash-ref json-body 'household-income-level #f)]
         [number-in-household (hash-ref json-body 'number-in-household #f)]
         [file-location (hash-ref json-body 'file-location #f)]
         [ami-id (hash-ref json-body 'ami-id)])
    (let ([new-id (client-create person-id (and first-visit (iso8601->datetime first-visit)) household-income-level number-in-household file-location ami-id)])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-client request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [person-id (hash-ref json-body 'person-id)]
         [first-visit (hash-ref json-body 'first-visit #f)]
         [household-income-level (hash-ref json-body 'household-income-level #f)]
         [number-in-household (hash-ref json-body 'number-in-household #f)]
         [file-location (hash-ref json-body 'file-location #f)]
         [ami-id (hash-ref json-body 'ami-id)])
    (client-update id person-id (and first-visit (iso8601->datetime first-visit)) household-income-level number-in-household file-location ami-id)
    (response/full 200 #"OK")))

(define (delete-client request id-str)
  (let ([id (string->number id-str)])
    (client-delete id)
    (response/full 200 #"OK")))