#lang racket

(require db
         db/base
         "../models/address.rkt"
         "connection.rkt")

(provide address-create
         address-read
         address-read-all
         address-update
         address-delete)

(define (address-create street city county state postal-code country-id person-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO address (version, street, city, county, state, postal_code, country_id, person_id) VALUES (0, ?, ?, ?, ?, ?, ?, ?)"
     street city county state postal-code country-id person-id)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (address-read id)
  (let ([conn (get-connection)])
    (let ([result (query-row conn "SELECT * FROM address WHERE id = ?" id)])
      (disconnect conn)
      (apply make-address result))))

(define (address-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM address")])
      (disconnect conn)
      (map (lambda (row) (apply make-address row)) result))))

(define (address-update id street city county state postal-code country-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "UPDATE address SET street = ?, city = ?, county = ?, state = ?, postal_code = ?, country_id = ?, version = version + 1 WHERE id = ?"
     street city county state postal-code country-id id)
    (disconnect conn)))

(define (address-delete id)
  (let ([conn (get-connection)])
    (query-exec conn "DELETE FROM address WHERE id = ?" id)
    (disconnect conn)))