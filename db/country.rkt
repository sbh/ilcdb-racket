#lang racket

(provide country-create
         country-read
         country-read-all
         country-update
         country-delete)

(require db
         "../models/country.rkt"
         "connection.rkt")

(define (row->country-struct row)
  (make-country (vector-ref row 0)
                (vector-ref row 1)
                (vector-ref row 2)))

(define (country-create name)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `country` (`version`, `name`) VALUES (0, ?)" name)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (country-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn "SELECT * FROM `country` WHERE `id` = ?" id)])
    (disconnect conn)
    (and result (row->country-struct result))))

(define (country-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn "SELECT * FROM `country`")])
    (disconnect conn)
    (map row->country-struct result)))

(define (country-update id name)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `country` SET `name` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    name id))
      (lambda () (disconnect conn)))))

(define (country-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `country` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))