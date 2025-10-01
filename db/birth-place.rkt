#lang racket

(require db
         "../models/birth-place.rkt"
         "connection.rkt")

(provide birth-place-create
         birth-place-read
         birth-place-read-all
         birth-place-update
         birth-place-delete)

(define (birth-place-create city state country-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO birth_place (version, city, state, country_id) VALUES (0, ?, ?, ?)"
     city state country-id)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (birth-place-read id)
  (let ([conn (get-connection)])
    (let ([result (query-row conn "SELECT * FROM birth_place WHERE id = ?" id)])
      (disconnect conn)
      (apply make-birth-place result))))

(define (birth-place-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM birth_place")])
      (disconnect conn)
      (map (lambda (row) (apply make-birth-place row)) result))))

(define (birth-place-update id city state country-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "UPDATE birth_place SET city = ?, state = ?, country_id = ?, version = version + 1 WHERE id = ?"
     city state country-id id)
    (disconnect conn)))

(define (birth-place-delete id)
  (let ([conn (get-connection)])
    (query-exec conn "DELETE FROM birth_place WHERE id = ?" id)
    (disconnect conn)))