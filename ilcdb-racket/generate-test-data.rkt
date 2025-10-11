#lang racket

(require db/mysql
         gregor
         racket/random
         racket/port
         racket/file
         "db/connection.rkt")

;; --- Configuration ---
(define num-clients-to-generate 1000)
(define first-names '("John" "Jane" "Peter" "Mary" "David" "Susan" "Michael" "Linda" "James" "Patricia"))
(define last-names '("Smith" "Jones" "Williams" "Brown" "Davis" "Miller" "Wilson" "Moore" "Taylor" "Anderson"))
(define cities '("Springfield" "Greenville" "Franklin" "Clinton" "Bristol" "Fairview" "Salem" "Madison"))
(define states '("CA" "TX" "FL" "NY" "PA" "IL" "OH" "GA" "NC" "MI"))
(define streets '("Main St" "Oak Ave" "Maple St" "Pine St" "Washington St" "Elm St" "Cedar St"))
(define genders '("Male" "Female" "Other"))
(define races '("White" "Black" "Asian" "Hispanic" "Other"))
(define english-proficiencies '("Fluent" "Good" "Basic" "None"))

;; --- Helper Functions ---
(define (random-element lst)
  (list-ref lst (random (length lst))))

(define (random-date start-year end-year)
  (let* ([year (+ start-year (random (- end-year start-year)))]
         [month (+ 1 (random 12))]
         [day (+ 1 (random 28))]) ; Keep it simple
    (datetime year month day)))

(define (random-phone)
  (string-append
   (number->string (+ 100 (random 900))) "-"
   (number->string (+ 100 (random 900))) "-"
   (number->string (+ 1000 (random 9000)))))

(define (execute-sql-file conn path)
  (with-input-from-file path
    (lambda ()
      (for ([line (in-lines)])
        (when (string-contains? line "INSERT")
          (query-exec conn line))))))

(define (main)
  (printf "Connecting to database...\n")
  (let ([conn (get-connection)])
    (dynamic-wind
     (lambda () #t)
     (lambda ()
       (printf "Clearing existing data (client, person, address, birth_place, ami, country, case_type)...\n")
       (for-each (lambda (table) (query-exec conn (string-append "DELETE FROM " table)))
                 '("`client_case`" "`client`" "`person`" "`address`" "`birth_place`" "`ami`" "`country`" "`case_type`"))
       
       (printf "Populating 'country' and 'case_type' tables from SQL files...\n")
       (execute-sql-file conn "ilcdb-racket/countries.sql")
       (execute-sql-file conn "ilcdb-racket/case_types.sql")

       (printf "Populating 'ami' table...\n")
       (query-exec conn "INSERT INTO `ami` (version, label, level) VALUES (0, '30% AMI', 1)")
       (query-exec conn "INSERT INTO `ami` (version, label, level) VALUES (0, '50% AMI', 2)")
       (query-exec conn "INSERT INTO `ami` (version, label, level) VALUES (0, '80% AMI', 3)")
       (query-exec conn "INSERT INTO `ami` (version, label, level) VALUES (0, '120% AMI', 4)")

       (let ([country-ids (query-list conn "SELECT id FROM `country`" #:column 0)]
             [ami-ids (query-list conn "SELECT id FROM `ami`" #:column 0)])

         (printf "Generating ~a clients...\n" num-clients-to-generate)
         (for ([i (in-range num-clients-to-generate)])
           (when (= (modulo i 100) 0) (printf "  Generated ~a clients...\n" i))

           ;; 1. Create Birth Place
           (let* ([bp-country-id (random-element country-ids)]
                  [bp-city (random-element cities)]
                  [bp-state (random-element states)]
                  [birth-place-id
                   (begin
                     (query-exec conn "INSERT INTO `birth_place` (version, city, state, country_id) VALUES (0, ?, ?, ?)" bp-city bp-state bp-country-id)
                     (query-value conn "SELECT LAST_INSERT_ID()"))])

             ;; 2. Create Address (initially without person_id)
             (let* ([addr-country-id (random-element country-ids)]
                    [addr-street (string-append (number->string (random 1000)) " " (random-element streets))]
                    [addr-city (random-element cities)]
                    [addr-state (random-element states)]
                    [addr-postal (number->string (+ 10000 (random 90000)))]
                    [address-id
                     (begin
                       (query-exec conn "INSERT INTO `address` (version, street, city, county, state, postal_code, country_id, person_id) VALUES (0, ?, ?, ?, ?, ?, ?, NULL)"
                                   addr-street addr-city "County" addr-state addr-postal addr-country-id)
                       (query-value conn "SELECT LAST_INSERT_ID()"))])

               ;; 3. Create Person
               (let* ([first-name (random-element first-names)]
                      [last-name (random-element last-names)]
                      [dob (datetime->sql-timestamp (random-date 1950 2005))]
                      [person-id
                       (begin
                         (query-exec conn "INSERT INTO `person` (version, address_id, english_proficiency, first_name, last_name, gender, email_address, date_of_birth, phone_number, place_of_birth_id, race) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                                     address-id
                                     (random-element english-proficiencies)
                                     first-name
                                     last-name
                                     (random-element genders)
                                     (string-append (string-downcase first-name) "." (string-downcase last-name) "@example.com")
                                     dob
                                     (random-phone)
                                     birth-place-id
                                     (random-element races))
                         (query-value conn "SELECT LAST_INSERT_ID()"))])

                 ;; 4. Update Address with the new person_id
                 (query-exec conn "UPDATE `address` SET person_id = ? WHERE id = ?" person-id address-id)

                 ;; 5. Create Client
                 (let ([ami-id (random-element ami-ids)]
                       [first-visit (datetime->sql-timestamp (random-date 2010 2023))])
                   (query-exec conn "INSERT INTO `client` (version, client_id, first_visit, household_income_level, number_in_household, file_location, ami_id) VALUES (0, ?, ?, ?, ?, ?, ?)"
                               person-id
                               first-visit
                               (+ 20000 (random 50000))
                               (+ 1 (random 5))
                               (format "File-~a" person-id)
                               ami-id))))))) 
         (printf "Finished generating ~a clients.\n" num-clients-to-generate)))
     (lambda ()
       (printf "Closing database connection.\n")
       (disconnect conn)))))

(main)