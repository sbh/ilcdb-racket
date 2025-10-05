#lang racket

(provide ami-create
         ami-read
         ami-read-all
         ami-update
         ami-delete)

(require db
         "../models/ami.rkt"
         "connection.rkt")

(define (row->ami-struct row)
  (make-ami (vector-ref row 0)
            (vector-ref row 1)
            (vector-ref row 2)
            (vector-ref row 3)))

(define (ami-create label level)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `ami` (`version`, `label`, `level`) VALUES (0, ?, ?)"
                    label level)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (ami-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn "SELECT * FROM `ami` WHERE `id` = ?" id)])
    (disconnect conn)
    (and result (row->ami-struct result))))

(define (ami-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn "SELECT * FROM `ami`")])
    (disconnect conn)
    (map row->ami-struct result)))

(define (ami-update id label level)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `ami` SET `label` = ?, `level` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    label level id))
      (lambda () (disconnect conn)))))

(define (ami-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `ami` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))