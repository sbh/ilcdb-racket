#lang racket

(require db
         db/base
         gregor
         racket/string
         "../db/connection.rkt"
         "../db/country.rkt"
         "../db/address.rkt"
         "../db/birth-place.rkt"
         "../db/person.rkt"
         "../db/ami.rkt"
         "../db/case-type.rkt"
         "../db/client.rkt"
         "../db/client-case.rkt"
         "../models/country.rkt"
         "../models/case-type.rkt"
         "../models/ami.rkt")

;; --- Data from User ---

(define countries-sql
  "INSERT INTO `country` VALUES (1,0,'Afghanistan'),(2,0,'Albania'),(3,0,'Algeria'),(4,0,'American Samoa'),(5,0,'Andorra'),(6,0,'Angola'),(7,0,'Anguilla'),(8,0,'Antarctica'),(9,0,'Antigua and Barbuda'),(10,0,'Argentina'),(11,0,'Armenia'),(12,0,'Aruba'),(13,0,'Australia'),(14,0,'Austria'),(15,0,'Azerbaijan'),(16,0,'Bahamas'),(17,0,'Bahrain'),(18,0,'Bangladesh'),(19,0,'Barbados'),(20,0,'Belarus'),(21,0,'Belgium'),(22,0,'Belize'),(23,0,'Benin'),(24,0,'Bermuda'),(25,0,'Bhutan'),(26,0,'Bolivia'),(27,0,'Bosnia and Herzegovina'),(28,0,'Botswana'),(29,0,'Bouvet Island'),(30,0,'Brazil'),(31,0,'British Indian Ocean Territory'),(32,0,'Brunei Darussalam'),(33,0,'Bulgaria'),(34,0,'Burkina Faso'),(35,0,'Burundi'),(36,0,'Cambodia'),(37,0,'Cameroon'),(38,0,'Canada'),(39,0,'Cape Verde'),(40,0,'Cayman Islands'),(41,0,'Central African Republic'),(42,0,'Chad'),(43,0,'Chile'),(44,0,'China'),(45,0,'Christmas Island'),(46,0,'Cocos (Keeling) Islands'),(47,0,'Colombia'),(48,0,'Comoros'),(49,0,'Congo'),(50,0,'Cook Islands'),(51,0,'Costa Rica'),(52,0,'Croatia'),(53,0,'Cuba'),(54,0,'Cyprus'),(55,0,'Czech Republic'),(56,0,'Denmark'),(57,0,'Djibouti'),(58,0,'Dominica'),(59,0,'Dominican Republic'),(60,0,'East Timor'),(61,0,'Ecuador'),(62,0,'Egypt'),(63,0,'El Salvador'),(64,0,'Equatorial Guinea'),(65,0,'Eritrea'),(66,0,'Estonia'),(67,0,'Ethiopia'),(68,0,'Falkland Islands'),(69,0,'Faroe Islands'),(70,0,'Fiji'),(71,0,'Finland'),(72,0,'France'),(73,0,'French Guiana'),(74,0,'French Polynesia'),(75,0,'French Southern Territories'),(76,0,'Gabon'),(77,0,'Gambia'),(78,0,'Georgia'),(79,0,'Germany'),(80,0,'Ghana'),(81,0,'Gibraltar'),(82,0,'Greece'),(83,0,'Greenland'),(84,0,'Grenada'),(85,0,'Guadeloupe'),(86,0,'Guam'),(87,0,'Guatemala'),(88,0,'Guinea'),(89,0,'Guinea-Bissau'),(90,0,'Guyana'),(91,0,'Haiti'),(92,0,'Heard and McDonald Islands'),(93,0,'Honduras'),(94,0,'Hong Kong'),(95,0,'Hungary'),(96,0,'Iceland'),(97,0,'India'),(98,0,'Indonesia'),(99,0,'Iran'),(100,0,'Iraq'),(101,0,'Ireland'),(102,0,'Israel'),(103,0,'Italy'),(104,0,'Ivory Coast'),(105,0,'Jamaica'),(106,0,'Japan'),(107,0,'Jordan'),(108,0,'Kazakhstan'),(109,0,'Kenya'),(110,0,'Kiribati'),(111,0,'Kuwait'),(112,0,'Kyrgyzstan'),(113,0,'Laos'),(114,0,'Latvia'),(115,0,'Lebanon'),(116,0,'Lesotho'),(117,0,'Liberia'),(118,0,'Libya'),(119,0,'Liechtenstein'),(120,0,'Lithuania'),(121,0,'Luxembourg'),(122,0,'Macau'),(123,0,'Macedonia'),(124,0,'Madagascar'),(125,0,'Malawi'),(126,0,'Malaysia'),(127,0,'Maldives'),(128,0,'Mali'),(129,0,'Malta'),(130,0,'Marshall Islands'),(131,0,'Martinique'),(132,0,'Mauritania'),(133,0,'Mauritius'),(134,0,'Mayotte'),(135,0,'Mexico'),(136,0,'Micronesia'),(137,0,'Moldova'),(138,0,'Monaco'),(139,0,'Mongolia'),(140,0,'Montserrat'),(141,0,'Morocco'),(142,0,'Mozambique'),(143,0,'Myanmar'),(144,0,'Namibia'),(145,0,'Nauru'),(146,0,'Nepal'),(147,0,'Netherlands'),(148,0,'Netherlands Antilles'),(149,0,'New Caledonia'),(150,0,'New Zealand'),(151,0,'Nicaragua'),(152,0,'Niger'),(153,0,'Nigeria'),(154,0,'Niue'),(155,0,'Norfolk Island'),(156,0,'North Korea'),(157,0,'Northern Mariana Islands'),(158,0,'Norway'),(159,0,'Oman'),(160,0,'Pakistan'),(161,0,'Palau'),(162,0,'Panama'),(163,0,'Papua New Guinea'),(164,0,'Paraguay'),(165,0,'Peru'),(166,0,'Philippines'),(167,0,'Pitcairn'),(168,0,'Poland'),(169,0,'Portugal'),(170,0,'Puerto Rico'),(171,0,'Qatar'),(172,0,'Reunion'),(173,0,'Romania'),(174,0,'Russian Federation'),(175,0,'Rwanda'),(176,0,'Saint Kitts and Nevis'),(177,0,'Saint Lucia'),(178,0,'Saint Vincent and the Grenadines'),(179,0,'Samoa'),(180,0,'San Marino'),(181,0,'Sao Tome and Principe'),(182,0,'Saudi Arabia'),(183,0,'Senegal'),(184,0,'Seychelles'),(185,0,'Sierra Leone'),(186,0,'Singapore'),(187,0,'Slovakia'),(188,0,'Slovenia'),(189,0,'Solomon Islands'),(190,0,'Somalia'),(191,0,'South Africa'),(192,0,'South Georgia and the South Sandwich Islands'),(193,0,'South Korea'),(194,0,'Spain'),(195,0,'Sri Lanka'),(196,0,'St. Helena'),(197,0,'St. Pierre and Miquelon'),(198,0,'Sudan'),(199,0,'Suriname'),(200,0,'Svalbard and Jan Mayen Islands'),(201,0,'Swaziland'),(202,0,'Sweden'),(203,0,'Switzerland'),(204,0,'Syria'),(205,0,'Taiwan'),(206,0,'Tajikistan'),(207,0,'Tanzania'),(208,0,'Thailand'),(209,0,'Togo'),(210,0,'Tokelau'),(211,0,'Tonga'),(212,0,'Trinidad and Tobago'),(213,0,'Tunisia'),(214,0,'Turkey'),(215,0,'Turkmenistan'),(216,0,'Turks and Caicos Islands'),(217,0,'Tuvalu'),(218,0,'Uganda'),(219,0,'Ukraine'),(220,0,'United Arab Emirates'),(221,0,'United Kingdom'),(222,0,'United States'),(223,0,'United States Minor Outlying Islands'),(224,0,'Uruguay'),(225,0,'Uzbekistan'),(226,0,'Vanuatu'),(227,0,'Vatican City'),(228,0,'Venezuela'),(229,0,'Vietnam'),(230,0,'Virgin Islands (British)'),(231,0,'Virgin Islands (U.S.)'),(232,0,'Wallis and Futuna Islands'),(233,0,'Western Sahara'),(234,0,'Yemen'),(235,0,'Yugoslavia'),(236,0,'Zaire'),(237,0,'Zambia'),(238,0,'Zimbabwe'),(239,0,'East Germany'),(240,0,'Eritrea and Ethiopia'),(241,0,'Serbia'),(242,0,'Montenegro'),(243,0,'Kosovo'),(244,0,'Micronesia, Federated States of'),(245,0,'Congo, Democratic Republic of'),(246,0,'Timor-Leste'),(247,0,'Cote d''Ivoire');")

(define case-types-sql
  "INSERT INTO `case_type` VALUES (1,1,0,'Naturalization/Citizenship','Naturalization'),(2,1,0,'Petition for Alien Relative','Petition for Relative'),(3,1,0,'Adjustment of Status','Adjustment of Status'),(4,1,0,'Consular Processing','Consular Processing'),(5,1,0,'NACARA','NACARA'),(6,1,0,'VAWA','VAWA'),(7,1,0,'U-Visa','U-Visa'),(8,1,0,'T-Visa','T-Visa'),(9,1,0,'TPS','TPS'),(10,1,0,'Asylum','Asylum'),(11,1,0,'Withholding of Removal','Withholding'),(12,1,0,'Convention Against Torture','CAT'),(13,1,0,'Cancellation of Removal','Cancellation'),(14,1,0,'SIJS','SIJS'),(15,1,0,'DACA','DACA'),(16,1,0,'Other','Other'),(17,1,0,'Employment Authorization','EAD'),(18,1,0,'Travel Document','Travel Document'),(19,1,0,'Family-based Petitions (including K-visas)',''),(20,1,0,'Violence Against Women Act (VAWA) Petitions',''),(21,1,0,'Special Immigrant Juvenile Status (SIJS)',''),(22,1,0,'Victims of Trafficking and Violence (T and U visas)',''),(23,1,0,'Temporary Protected Status (TPS)',''),(24,1,0,'Deferred Action for Childhood Arrivals (DACA)',''),(25,1,0,'Asylum and other forms of humanitarian relief',''),(26,1,0,'Removal defense',''),(27,1,0,'Other immigration remedies',''),(28,0,1,'Naturalization/Citizenship','Naturalization'),(29,0,1,'Petition for Alien Relative','Petition for Relative'),(30,0,1,'Adjustment of Status','Adjustment of Status'),(31,0,1,'Consular Processing','Consular Processing'),(32,0,1,'NACARA','NACARA'),(33,0,1,'VAWA','VAWA'),(34,0,1,'U-Visa','U-Visa'),(35,0,1,'T-Visa','T-Visa'),(36,0,1,'TPS','TPS'),(37,0,1,'Asylum','Asylum'),(38,0,1,'Withholding of Removal','Withholding'),(39,0,1,'Convention Against Torture','CAT'),(40,0,1,'Cancellation of Removal','Cancellation'),(41,0,1,'SIJS','SIJS'),(42,0,1,'DACA','DACA'),(43,0,1,'Other','Other'),(44,0,1,'Employment Authorization','EAD'),(45,0,1,'Travel Document','Travel Document'),(46,0,1,'Family-based Petitions (including K-visas)',''),(47,0,1,'Violence Against Women Act (VAWA) Petitions',''),(48,0,1,'Special Immigrant Juvenile Status (SIJS)',''),(49,0,1,'Victims of Trafficking and Violence (T and U visas)',''),(50,0,1,'Temporary Protected Status (TPS)',''),(51,0,1,'Deferred Action for Childhood Arrivals (DACA)',''),(52,0,1,'Asylum and other forms of humanitarian relief',''),(53,0,1,'Removal defense',''),(54,0,1,'Other immigration remedies',''),(55,1,0,'Consultation','Consultation'),(56,1,0,'Referral','Referral'),(57,1,0,'Representation','Representation'),(58,1,0,'Brief Service','Brief Service'),(59,1,0,'Filing Assistance','Filing Assistance'),(60,1,0,'FOIA','FOIA'),(61,1,0,'Citizenship Outreach','Citizenship Outreach'),(62,1,0,'Workshops','Workshops'),(63,1,0,'Advocacy','Advocacy');")


;; --- Helper Functions ---

(define (parse-sql-inserts sql-string)
  (define values-str (cadr (string-split sql-string "VALUES ")))
  (for/list ([val-group (string-split (string-trim values-str ";") "),(")])
    (define cleaned-group (string-trim val-group "()"))
    (for/list ([val (string-split cleaned-group ",")])
      (define trimmed-val (string-trim val))
      (cond
        [(string-prefix? trimmed-val "'")
         (string-replace (string-trim trimmed-val "'") "''" "'")]
        [else
         (with-handlers ([exn:fail? (lambda (e) trimmed-val)])
           (string->number trimmed-val))]))))

(define (clear-database)
  (displayln "Clearing database...")
  (let ([conn (get-connection)])
    (for ([table '("client_case" "client" "person" "address" "birth_place" "country" "case_type" "ami")])
      (displayln (format "  - Clearing ~a" table))
      (query-exec conn (string-append "DELETE FROM " table))
      (query-exec conn (string-append "ALTER TABLE " table " AUTO_INCREMENT = 1")))
    (disconnect conn)))

(define (populate-initial-data)
  (displayln "Populating initial data...")
  ;; Populate countries
  (let ([countries (parse-sql-inserts countries-sql)])
    (for ([country-data countries])
      (country-create (list-ref country-data 2))))
  (displayln "  - Countries populated.")

  ;; Populate case types
  (let ([case-types (parse-sql-inserts case-types-sql)])
    (for ([case-type-data case-types])
      (case-type-create (list-ref case-type-data 2)
                        (list-ref case-type-data 3)
                        (list-ref case-type-data 4))))
  (displayln "  - Case types populated.")

  ;; Populate AMI levels
  (for ([i (in-range 1 6)])
    (ami-create (format "~a% AMI" (* i 20)) i))
  (displayln "  - AMI levels populated."))


(define (generate-random-data)
  (displayln "Generating random client and case data...")
  (let ([all-countries (country-read-all)]
        [all-case-types (case-type-read-all)]
        [all-amis (ami-read-all)])
    (when (or (null? all-countries) (null? all-case-types) (null? all-amis))
      (error "Initial data (countries, case types, AMI) not found. Aborting."))

    (define first-names '("John" "Jane" "Peter" "Mary" "David" "Susan" "Michael" "Linda" "William" "Patricia"))
    (define last-names '("Smith" "Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Davis" "Rodriguez" "Martinez"))
    (define streets '("Main St" "High St" "Elm St" "Oak Ave" "Maple Dr" "Pine Ln" "Washington Blvd"))
    (define cities '("Springfield" "Fairview" "Salem" "Madison" "Georgetown" "Franklin"))
    (define states '("CA" "TX" "FL" "NY" "PA" "IL" "OH"))
    (define counties '("Los Angeles" "Cook" "Harris" "Maricopa" "San Diego" "Orange"))

    (for* ([country all-countries]
           [i (in-range 5)]) ; 5 clients per country
      (define first-name (list-ref first-names (random (length first-names))))
      (define last-name (list-ref last-names (random (length last-names))))
      (define birth-country-id (country-id country))

      ;; Create birth place
      (define birth-place-id
        (birth-place-create (list-ref cities (random (length cities)))
                            (list-ref states (random (length states)))
                            birth-country-id))

      ;; Create address (person_id will be updated later)
      (define address-id
        (address-create (format "~a ~a" (+ 1 (random 1000)) (list-ref streets (random (length streets))))
                        (list-ref cities (random (length cities)))
                        (list-ref counties (random (length counties)))
                        (list-ref states (random (length states)))
                        (number->string (+ 10000 (random 89999)))
                        birth-country-id
                        sql-null)) ; person_id is null for now

      ;; Create person
      (define person-id
        (person-create first-name
                       last-name
                       (format "555-~a" (+ 1000 (random 8999)))
                       (datetime->iso8601 (datetime 1950 (+ 1 (random 12)) (+ 1 (random 28))))
                       (list-ref '("native" "high" "medium" "low" "none") (random 5))
                       (format "~a.~a@example.com" (string-downcase first-name) (string-downcase last-name))
                       (list-ref '("male" "female") (random 2))
                       "Other"
                       address-id
                       birth-place-id))
      
      ;; Update address with person_id
      (let ([conn (get-connection)])
          (query-exec conn "UPDATE address SET person_id = ? WHERE id = ?" person-id address-id)
          (disconnect conn))

      ;; Create client
      (define client-id
        (client-create person-id
                       (datetime->iso8601 (now))
                       (+ 30000 (random 50000))
                       (+ 1 (random 5))
                       (format "File-~a" person-id)
                       (ami-id (list-ref all-amis (random (length all-amis))))))

      ;; Create cases for the client
      (for ([j (in-range (+ 1 (random 5)))]) ; 1 to 5 cases
        (client-case-create (format "CASE-~a-~a" client-id j)
                            client-id
                            (format "File-~a" person-id)
                            sql-null ; coltaf
                            sql-null ; completion date
                            "Representation"
                            (datetime->iso8601 (now))
                            "Jules"
                            (case-type-id (list-ref all-case-types (random (length all-case-types))))
                            sql-null ; case result id
                            "Hi"))
      (displayln (format "  - Created client ~a ~a with cases." first-name last-name)))))


;; --- Main Script Logic ---
(define (main)
  (displayln "Starting test data generation...")
  (clear-database)
  (populate-initial-data)
  (generate-random-data)
  (displayln "Test data generation complete."))

;; --- Entry Point ---
(main)