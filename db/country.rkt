#lang racket

(require db
         db/base
         "../models/country.rkt"
         "connection.rkt")

(provide country-create
         country-read
         country-read-all
         country-update
         country-delete)

(define (country-create name)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO country (version, name) VALUES (0, ?)"
     name)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (country-read id)
  (let ([conn (get-connection)])
    (let ([result (query-row conn "SELECT * FROM country WHERE id = ?" id)])
      (disconnect conn)
      (apply make-country result))))

(define (country-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM country")])
      (disconnect conn)
      (map (lambda (row) (apply make-country row)) result))))

(define (country-update id name)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "UPDATE country SET name = ?, version = version + 1 WHERE id = ?"
     name
     id)
    (disconnect conn)))

(define (country-delete id)
  (let ([conn (get-connection)])
    (query-exec conn "DELETE FROM country WHERE id = ?" id)
    (disconnect conn)))