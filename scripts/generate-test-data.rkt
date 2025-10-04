#lang racket

(require db
         db/base
         gregor
         racket/port)

;; --- Database Helper Functions (Self-Contained) ---

(define (get-connection)
  (mysql-connect #:user "ilcdb_user"
                 #:password "ilcdb_password"
                 #:database "ilcdb"
                 #:server "127.0.0.1"
                 #:port 3306))

(define (clear-database)
  (displayln "Clearing database...")
  (let ([conn (get-connection)])
    (query-exec conn "SET FOREIGN_KEY_CHECKS = 0;")
    (for ([table '("client_case" "client" "person" "address" "birth_place" "country" "case_type" "ami")])
      (displayln (format "  - Clearing ~a" table))
      (query-exec conn (string-append "DELETE FROM " table))
      (query-exec conn (string-append "ALTER TABLE " table " AUTO_INCREMENT = 1")))
    (query-exec conn "SET FOREIGN_KEY_CHECKS = 1;")
    (disconnect conn)))

(define (populate-initial-data)
  (displayln "Populating initial data...")
  (let ([conn (get-connection)])
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        ;; Populate countries from SQL file
        (let ([countries-sql (file->string "countries.sql" #:mode 'text)])
          (query-exec conn countries-sql))
        (displayln "  - Countries populated.")

        ;; Populate case types from SQL file
        (let ([case-types-sql (file->string "case_types.sql" #:mode 'text)])
          (query-exec conn case-types-sql))
        (displayln "  - Case types populated.")

        ;; Populate AMI levels
        (for ([i (in-range 1 6)])
          (query-exec conn "INSERT INTO `ami` (`version`, `label`, `level`) VALUES (0, ?, ?)"
                      (format "~a% AMI" (* i 20)) i))
        (displayln "  - AMI levels populated."))
      (lambda () (disconnect conn)))))

(define (generate-random-data)
  (displayln "Generating random client and case data...")
  (let* ([conn (get-connection)]
         [all-countries (query-rows conn "SELECT id FROM country")]
         [all-case-types (query-rows conn "SELECT id FROM case_type where deprecated != 1")]
         [all-amis (query-rows conn "SELECT id FROM ami")])
    
    (disconnect conn)

    (when (or (null? all-countries) (null? all-case-types) (null? all-amis))
      (error "Initial data (countries, case types, AMI) not found. Aborting."))

    (define first-names '("John" "Jane" "Peter" "Mary" "David" "Susan" "Michael" "Linda" "William" "Patricia"))
    (define last-names '("Smith" "Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Davis" "Rodriguez" "Martinez"))
    (define streets '("Main St" "High St" "Elm St" "Oak Ave" "Maple Dr" "Pine Ln" "Washington Blvd"))
    (define cities '("Springfield" "Fairview" "Salem" "Madison" "Georgetown" "Franklin"))
    (define states '("CA" "TX" "FL" "NY" "PA" "IL" "OH"))
    (define counties '("Los Angeles" "Cook" "Harris" "Maricopa" "San Diego" "Orange"))

    (for* ([country-row all-countries]
           [i (in-range 5)]) ; 5 clients per country
      (let ([conn (get-connection)])
        (dynamic-wind
          (lambda () #t)
          (lambda ()
            (define first-name (list-ref first-names (random (length first-names))))
            (define last-name (list-ref last-names (random (length last-names))))
            (define birth-country-id (vector-ref country-row 0))

            ;; Create birth place
            (query-exec conn "INSERT INTO `birth_place` (`version`, `city`, `state`, `country_id`) VALUES (0, ?, ?, ?)"
                        (list-ref cities (random (length cities)))
                        (list-ref states (random (length states)))
                        birth-country-id)
            (define birth-place-id (query-value conn "SELECT LAST_INSERT_ID()"))

            ;; Create address first, without person_id
            (query-exec conn "INSERT INTO `address` (`version`, `street`, `city`, `county`, `state`, `postal_code`, `country_id`, `person_id`) VALUES (0, ?, ?, ?, ?, ?, ?, ?)"
                        (format "~a ~a" (+ 1 (random 1000)) (list-ref streets (random (length streets))))
                        (list-ref cities (random (length cities)))
                        (list-ref counties (random (length counties)))
                        (list-ref states (random (length states)))
                        (number->string (+ 10000 (random 89999)))
                        birth-country-id
                        sql-null)
            (define address-id (query-value conn "SELECT LAST_INSERT_ID()"))

            ;; Create person, linking to the new address
            (query-exec conn "INSERT INTO `person` (`version`, `address_id`, `english_proficiency`, `first_name`, `last_name`, `gender`, `email_address`, `date_of_birth`, `phone_number`, `place_of_birth_id`, `race`) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                        address-id
                        (list-ref '("native" "high" "medium" "low" "none") (random 5))
                        first-name
                        last-name
                        (list-ref '("male" "female") (random 2))
                        (format "~a.~a@example.com" (string-downcase first-name) (string-downcase last-name))
                        (datetime->iso8601 (datetime 1950 (+ 1 (random 12)) (+ 1 (random 28))))
                        (format "555-~a" (+ 1000 (random 8999)))
                        birth-place-id
                        "Other")
            (define person-id (query-value conn "SELECT LAST_INSERT_ID()"))
            
            ;; Now, update the address with the new person_id
            (query-exec conn "UPDATE `address` SET `person_id` = ? WHERE `id` = ?" person-id address-id)

            ;; Create client
            (query-exec conn "INSERT INTO `client` (`version`, `client_id`, `first_visit`, `household_income_level`, `number_in_household`, `file_location`, `ami_id`) VALUES (0, ?, ?, ?, ?, ?, ?)"
                        person-id
                        (datetime->iso8601 (now))
                        (+ 30000 (random 50000))
                        (+ 1 (random 5))
                        (format "File-~a" person-id)
                        (vector-ref (list-ref all-amis (random (length all-amis))) 0))
            (define client-id (query-value conn "SELECT LAST_INSERT_ID()"))

            ;; Create cases for the client
            (for ([j (in-range (+ 1 (random 5)))]) ; 1 to 5 cases
              (query-exec conn "INSERT INTO `client_case` (`version`, `case_number`, `client_id`, `file_location`, `coltaf_number`, `completion_date`, `intake_type`, `start_date`, `attorney`, `case_type_id`, `case_result_id`, `intensity`) VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                          (format "CASE-~a-~a" client-id j)
                          client-id
                          (format "File-~a" person-id)
                          sql-null ; coltaf
                          sql-null ; completion date
                          "Representation"
                          (datetime->iso8601 (now))
                          "Jules"
                          (vector-ref (list-ref all-case-types (random (length all-case-types))) 0)
                          sql-null ; case result id
                          "Hi"))
            (displayln (format "  - Created client ~a ~a with cases." first-name last-name)))
          (lambda () (disconnect conn)))))))


;; --- Main Script Logic ---
(define (main)
  (displayln "Starting test data generation...")
  (let ([original-dir (current-directory)])
    (with-handlers ([exn:fail? (lambda (e) (current-directory original-dir) (raise e))])
      ;; Change to script's directory to make file paths relative
      (current-directory (path-only (find-system-path 'run-file)))
      (clear-database)
      (populate-initial-data)
      (generate-random-data)
      (current-directory original-dir)))
  (displayln "Test data generation complete."))

;; --- Entry Point ---
(main)