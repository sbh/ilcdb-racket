#lang racket

(provide person-create
         person-read
         person-read-all
         person-update
         person-delete)

(require db
         db/base
         "../models/person.rkt"
         "./address.rkt"
         "./birth-place.rkt"
         "connection.rkt")

(define select-cols "SELECT `id`, `version`, `address_id`, `english_proficiency`, `first_name`, `last_name`, `gender`, `email_address`, `date_of_birth`, `phone_number`, `place_of_birth_id`, `race` FROM `person`")

(define (row->person-struct row)
  (let ([address-id (vector-ref row 2)]
        [place-of-birth-id (vector-ref row 10)])
    (make-person (vector-ref row 0)    ; id
                 (vector-ref row 1)    ; version
                 (address-read address-id) ; address
                 (vector-ref row 3)    ; english_proficiency
                 (vector-ref row 4)    ; first_name
                 (vector-ref row 5)    ; last_name
                 (vector-ref row 6)    ; gender
                 (vector-ref row 7)    ; email_address
                 (vector-ref row 8)    ; date_of_birth
                 (vector-ref row 9)    ; phone_number
                 (and place-of-birth-id (birth-place-read place-of-birth-id)) ; place_of_birth
                 (vector-ref row 11)))) ; race

(define (person-create address-id english-proficiency first-name last-name gender email-address date-of-birth phone-number place-of-birth-id race)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `person` (`version`, `address_id`, `english_proficiency`, `first_name`, `last_name`, `gender`, `email_address`, `date_of_birth`, `phone_number`, `place_of_birth_id`, `race`) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    address-id english-proficiency first-name last-name gender email-address date-of-birth phone-number place-of-birth-id race)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (person-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn (string-append select-cols " WHERE `id` = ?") id)])
    (disconnect conn)
    (and result (row->person-struct result))))

(define (person-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn select-cols)])
    (disconnect conn)
    (map row->person-struct result)))

(define (person-update id address-id english-proficiency first-name last-name gender email-address date-of-birth phone-number place-of-birth-id race)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `person` SET `address_id` = ?, `english_proficiency` = ?, `first_name` = ?, `last_name` = ?, `gender` = ?, `email_address` = ?, `date_of_birth` = ?, `phone_number` = ?, `place_of_birth_id` = ?, `race` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    address-id english-proficiency first-name last-name gender email-address date-of-birth phone-number place-of-birth-id race id))
      (lambda () (disconnect conn)))))

(define (person-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `person` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))