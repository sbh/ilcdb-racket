#lang racket

(require db
         "../models/person.rkt"
         "connection.rkt")

(provide person-create
         person-read
         person-read-all
         person-update
         person-delete)

(define (person-create first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "INSERT INTO person (version, first_name, last_name, phone_number, date_of_birth, english_proficiency, email_address, gender, race, address_id, place_of_birth_id) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
     first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id)
    (let ([result (query-value conn "SELECT LAST_INSERT_ID()")])
      (disconnect conn)
      result)))

(define (person-read id)
  (let ([conn (get-connection)])
    (let* ([result (query-row conn "SELECT * FROM person WHERE id = ?" id)])
      (disconnect conn)
      (if result
          (apply make-person result)
          #f))))

(define (person-read-all)
  (let ([conn (get-connection)])
    (let* ([result (query-rows conn "SELECT * FROM person")])
      (disconnect conn)
      (map (lambda (row) (apply make-person row)) result))))

(define (person-update id first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id)
  (let ([conn (get-connection)])
    (query-exec
     conn
     "UPDATE person SET first_name = ?, last_name = ?, phone_number = ?, date_of_birth = ?, english_proficiency = ?, email_address = ?, gender = ?, race = ?, address_id = ?, place_of_birth_id = ?, version = version + 1 WHERE id = ?"
     first-name last-name phone-number date-of-birth english-proficiency email-address gender race address-id place-of-birth-id id)
    (disconnect conn)))

(define (person-delete id)
  (let ([conn (get-connection)])
    (query-exec conn "DELETE FROM person WHERE id = ?" id)
    (disconnect conn)))