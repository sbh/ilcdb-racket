#lang racket

(require db
         "../models/client.rkt"
         "connection.rkt")

(provide client-create)

(define (client-create person-id first-visit household-income-level number-in-household file-location ami-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO `client` (`version`, `client_id`, `first_visit`, `household_income_level`, `number_in_household`, `file_location`, `ami_id`) VALUES (0, ?, ?, ?, ?, ?, ?)"
     person-id first-visit household-income-level number-in-household file-location ami-id)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))