#lang racket

(provide birth-place-create
         birth-place-read
         birth-place-read-all
         birth-place-update
         birth-place-delete)

(require db
         "../models/birth-place.rkt"
         "./country.rkt"
         "connection.rkt")

(define (row->birth-place-struct row)
  (let ([country-id (vector-ref row 4)])
    (make-birth-place (vector-ref row 0)    ; id
                      (vector-ref row 1)    ; version
                      (vector-ref row 2)    ; city
                      (vector-ref row 3)    ; state
                      (country-read country-id)))) ; country struct

(define (birth-place-create city state country-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `birth_place` (`version`, `city`, `state`, `country_id`) VALUES (0, ?, ?, ?)"
                    city state country-id)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (birth-place-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn "SELECT * FROM `birth_place` WHERE `id` = ?" id)])
    (disconnect conn)
    (and result (row->birth-place-struct result))))

(define (birth-place-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn "SELECT * FROM `birth_place`")])
    (disconnect conn)
    (map row->birth-place-struct result)))

(define (birth-place-update id city state country-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `birth_place` SET `city` = ?, `state` = ?, `country_id` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    city state country-id id))
      (lambda () (disconnect conn)))))

(define (birth-place-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `birth_place` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))