#lang racket

(require db
         "../models/client-case.rkt"
         "connection.rkt")

(provide client-case-create)

(define (client-case-create case-number client-id file-location coltaf-number completion-date intake-type start-date attorney case-type-id case-result-id intensity)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO `client_case` (`version`, `case_number`, `client_id`, `file_location`, `coltaf_number`, `completion_date`, `intake_type`, `start_date`, `attorney`, `case_type_id`, `case_result_id`, `intensity`) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
     case-number client-id file-location coltaf-number completion-date intake-type start-date attorney case-type-id case-result-id intensity)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))