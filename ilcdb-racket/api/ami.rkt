#lang racket

(provide ami-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         json
         "../db/ami.rkt"
         "../models/ami.rkt")

(define-values (ami-api-dispatcher _)
  (dispatch-rules
   [("api" "ami")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-amis req)]
        ["POST" (post-ami req)]))]
   [("api" "ami" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-ami req id)]
        ["PUT" (put-ami req id)]
        ["DELETE" (delete-ami req id)]))]))

(define (get-all-amis request)
  (let ([amis (ami-read-all)])
    (response/jsexpr (map ami->jsexpr amis))))

(define (get-ami request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([a (ami-read id)])
        (if a
            (response/jsexpr (ami->jsexpr a))
            (response/full 404 #"Not Found"))))))

(define (post-ami request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [label (hash-ref json-body 'label)]
         [level (hash-ref json-body 'level)])
    (let ([new-id (ami-create label level)])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-ami request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [label (hash-ref json-body 'label)]
         [level (hash-ref json-body 'level)])
    (ami-update id label level)
    (response/full 200 #"OK")))

(define (delete-ami request id-str)
  (let ([id (string->number id-str)])
    (ami-delete id)
    (response/full 200 #"OK")))