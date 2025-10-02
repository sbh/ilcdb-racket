#lang racket

(require db
         "../models/ami.rkt"
         "connection.rkt")

(provide ami-create
         ami-read-all)

(define (ami-create label level)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO `ami` (`version`, `label`, `level`) VALUES (0, ?, ?)"
     label level)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (ami-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM ami")])
      (disconnect conn)
      (map (lambda (row) (apply make-ami (vector->list row))) result))))