#lang racket

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         gregor
         json
         "../db/person.rkt"
         "../models/person.rkt")

(provide person-api-dispatcher
         get-all-people)

(define-values (person-api-dispatcher _)
  (dispatch-rules
   [("api" "person" (string-arg))
    (lambda (request id)
      (match (request-method request)
        ["GET" (get-person request id)]
        ["PUT" (put-person request id)]
        ["DELETE" (delete-person request id)]))]
   [("api" "person")
    (lambda (request)
      (match (request-method request)
        ["GET" (get-all-people request)]
        ["POST" (post-person request)]))]))

(define (get-all-people request)
  (define people (person-read-all))
  (response/jsexpr (map person->jsexpr people)))

(define (get-person request id-str)
  (define id (string->number id-str))
  (define p (person-read id))
  (if p
      (response/jsexpr (person->jsexpr p))
      (response/full 404 #"Not Found")))

(define (post-person request)
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define first-name (hash-ref json-body 'first-name))
  (define last-name (hash-ref json-body 'last-name))
  (define phone-number (hash-ref json-body 'phone-number))
  (define date-of-birth (and (hash-ref json-body 'date-of-birth #f) (iso8601->datetime (hash-ref json-body 'date-of-birth))))
  (define english-proficiency (hash-ref json-body 'english-proficiency))
  (define email-address (hash-ref json-body 'email-address))
  (define gender (hash-ref json-body 'gender))
  (define race (hash-ref json-body 'race))
  (define address-id (hash-ref json-body 'address-id))
  (define place-of-birth-id (hash-ref json-body 'place-of-birth-id))
  (define new-id (person-create first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id))
  (response/jsexpr (hasheq 'id new-id)))

(define (put-person request id-str)
  (define id (string->number id-str))
  (define json-body (bytes->jsexpr (request-post-data/raw request)))
  (define first-name (hash-ref json-body 'first-name))
  (define last-name (hash-ref json-body 'last-name))
  (define phone-number (hash-ref json-body 'phone-number))
  (define date-of-birth (and (hash-ref json-body 'date-of-birth #f) (iso8601->datetime (hash-ref json-body 'date-of-birth))))
  (define english-proficiency (hash-ref json-body 'english-proficiency))
  (define email-address (hash-ref json-body 'email-address))
  (define gender (hash-ref json-body 'gender))
  (define race (hash-ref json-body 'race))
  (define address-id (hash-ref json-body 'address-id))
  (define place-of-birth-id (hash-ref json-body 'place-of-birth-id))
  (person-update id first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id)
  (response/full 200 #"OK"))

(define (delete-person request id-str)
  (define id (string->number id-str))
  (person-delete id)
  (response/full 200 #"OK"))