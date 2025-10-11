#lang racket

(provide address-create
         address-read
         address-read-all
         address-update
         address-delete)

(require db
         db/base
         "../models/address.rkt"
         "./country.rkt"
         "connection.rkt")

(define select-cols "SELECT `id`, `version`, `street`, `city`, `county`, `state`, `postal_code`, `country_id`, `person_id` FROM `address`")

(define (row->address-struct row)
  (let ([country-id (vector-ref row 7)])
    (make-address (vector-ref row 0) ; id
                  (vector-ref row 1) ; version
                  (vector-ref row 2) ; street
                  (vector-ref row 3) ; city
                  (vector-ref row 4) ; county
                  (vector-ref row 5) ; state
                  (vector-ref row 6) ; postal_code
                  (country-read country-id) ; nested country struct
                  (vector-ref row 8)))) ; person_id (as ID)

(define (address-create street city county state postal-code country-id person-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `address` (`version`, `street`, `city`, `county`, `state`, `postal_code`, `country_id`, `person_id`) VALUES (0, ?, ?, ?, ?, ?, ?, ?)"
                    street city county state postal-code country-id person-id)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (address-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn (string-append select-cols " WHERE `id` = ?") id)])
    (disconnect conn)
    (and result (row->address-struct result))))

(define (address-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn select-cols)])
    (disconnect conn)
    (map row->address-struct result)))

(define (address-update id street city county state postal-code country-id person-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `address` SET `street` = ?, `city` = ?, `county` = ?, `state` = ?, `postal_code` = ?, `country_id` = ?, `person_id` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    street city county state postal-code country-id person-id id))
      (lambda () (disconnect conn)))))

(define (address-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `address` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))