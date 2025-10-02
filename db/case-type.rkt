#lang racket

(require db
         "../models/case-type.rkt"
         "connection.rkt")

(provide case-type-create
         case-type-read-all)

(define (case-type-create deprecated type associated-status)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO `case_type` (`version`, `deprecated`, `type`, `associated_status`) VALUES (0, ?, ?, ?)"
     deprecated type associated-status)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (case-type-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM case_type")])
      (disconnect conn)
      (map (lambda (row) (apply make-case-type (vector->list row))) result))))