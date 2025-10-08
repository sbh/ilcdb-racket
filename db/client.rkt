#lang racket

(provide client-create
         client-read
         client-read-all
         client-update
         client-delete)

(require db
         db/base
         gregor
         "../models/client.rkt"
         "./person.rkt"
         "./ami.rkt"
         "connection.rkt")

(define select-cols "SELECT `id`, `version`, `client_id`, `first_visit`, `first_visit_string`, `household_income_level`, `number_in_household`, `file_location`, `ami_id` FROM `client`")

(define (row->client-struct row)
  (let ([person-id (vector-ref row 2)]
        [ami-id (vector-ref row 8)])
    (make-client (vector-ref row 0)    ; id
                 (vector-ref row 1)    ; version
                 (person-read person-id) ; person object
                 (vector-ref row 3)    ; first_visit
                 (vector-ref row 4)    ; first_visit_string
                 (vector-ref row 5)    ; household_income_level
                 (vector-ref row 6)    ; number_in_household
                 (vector-ref row 7)    ; file_location
                 (ami-read ami-id))))    ; ami object

(define (client-create person-id first-visit household-income-level number-in-household file-location ami-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "INSERT INTO `client` (`version`, `client_id`, `first_visit`, `household_income_level`, `number_in_household`, `file_location`, `ami_id`) VALUES (0, ?, ?, ?, ?, ?, ?)"
                    person-id (and first-visit (datetime->iso8601 first-visit)) household-income-level number-in-household file-location ami-id)
        (query-value conn "SELECT LAST_INSERT_ID()"))
      (lambda () (disconnect conn)))))

(define (client-read id)
  (let* ([conn (get-connection)]
         [result (query-row conn (string-append select-cols " WHERE `id` = ?") id)])
    (disconnect conn)
    (and result (row->client-struct result))))

(define (client-read-all)
  (let* ([conn (get-connection)]
         [result (query-rows conn select-cols)])
    (disconnect conn)
    (map row->client-struct result)))

(define (client-update id person-id first-visit household-income-level number-in-household file-location ami-id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "UPDATE `client` SET `client_id` = ?, `first_visit` = ?, `household_income_level` = ?, `number_in_household` = ?, `file_location` = ?, `ami_id` = ?, `version` = `version` + 1 WHERE `id` = ?"
                    person-id (and first-visit (datetime->iso8601 first-visit)) household-income-level number-in-household file-location ami-id id))
      (lambda () (disconnect conn)))))

(define (client-delete id)
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (query-exec conn "DELETE FROM `client` WHERE `id` = ?" id))
      (lambda () (disconnect conn)))))