#lang racket

(provide person-api-dispatcher)

(require web-server/servlet-env
         web-server/dispatch
         web-server/http
         web-server/http/request-structs
         racket/match
         gregor
         json
         db/base
         "../db/person.rkt"
         "../models/person.rkt")

(define-values (person-api-dispatcher _)
  (dispatch-rules
   [("api" "person")
    (lambda (req)
      (match (request-method req)
        ["GET" (get-all-people req)]
        ["POST" (post-person req)]))]
   [("api" "person" (string-arg))
    (lambda (req id)
      (match (request-method req)
        ["GET" (get-person req id)]
        ["PUT" (put-person req id)]
        ["DELETE" (delete-person req id)]))]))

(define (get-all-people request)
  (let ([people (person-read-all)])
    (response/jsexpr (map person->jsexpr people))))

(define (get-person request id-str)
  (let ([id (string->number id-str)])
    (with-handlers ([exn:fail? (lambda (e) (response/full 404 #"Not Found"))])
      (let ([p (person-read id)])
        (if p
            (response/jsexpr (person->jsexpr p))
            (response/full 404 #"Not Found"))))))

(define (post-person request)
  (let* ([json-body (bytes->jsexpr (request-post-data/raw request))]
         [address-id (hash-ref json-body 'address-id)]
         [english-proficiency (hash-ref json-body 'english-proficiency #f)]
         [first-name (hash-ref json-body 'first-name)]
         [last-name (hash-ref json-body 'last-name)]
         [gender (hash-ref json-body 'gender #f)]
         [email-address (hash-ref json-body 'email-address #f)]
         [date-of-birth (hash-ref json-body 'date-of-birth #f)]
         [phone-number (hash-ref json-body 'phone-number #f)]
         [place-of-birth-id (hash-ref json-body 'place-of-birth-id #f)]
         [race (hash-ref json-body 'race #f)])
    (let ([new-id (person-create address-id english-proficiency first-name last-name gender email-address
                                 (and date-of-birth (iso8601->datetime date-of-birth))
                                 phone-number place-of-birth-id race)])
      (response/jsexpr (hasheq 'id new-id)))))

(define (put-person request id-str)
  (let* ([id (string->number id-str)]
         [json-body (bytes->jsexpr (request-post-data/raw request))]
         [address-id (hash-ref json-body 'address-id)]
         [english-proficiency (hash-ref json-body 'english-proficiency #f)]
         [first-name (hash-ref json-body 'first-name)]
         [last-name (hash-ref json-body 'last-name)]
         [gender (hash-ref json-body 'gender #f)]
         [email-address (hash-ref json-body 'email-address #f)]
         [date-of-birth (hash-ref json-body 'date-of-birth #f)]
         [phone-number (hash-ref json-body 'phone-number #f)]
         [place-of-birth-id (hash-ref json-body 'place-of-birth-id #f)]
         [race (hash-ref json-body 'race #f)])
    (person-update id address-id english-proficiency first-name last-name gender email-address
                   (and date-of-birth (iso8601->datetime date-of-birth))
                   phone-number place-of-birth-id race)
    (response/full 200 #"OK")))

(define (delete-person request id-str)
  (let ([id (string->number id-str)])
    (person-delete id)
    (response/full 200 #"OK")))