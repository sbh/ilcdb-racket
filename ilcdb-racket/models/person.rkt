#lang racket

(provide make-person
         person?
         person-id
         person-version
         person-address
         person-english-proficiency
         person-first-name
         person-last-name
         person-gender
         person-email-address
         person-date-of-birth
         person-phone-number
         person-place-of-birth
         person-race
         person->jsexpr)

(require gregor
         "./address.rkt"
         "./birth-place.rkt")

(define-struct person
  (id
   version
   address
   english-proficiency
   first-name
   last-name
   gender
   email-address
   date-of-birth
   phone-number
   place-of-birth
   race))

(define (person->jsexpr p)
  (hasheq 'id (person-id p)
          'version (person-version p)
          'address (address->jsexpr (person-address p))
          'english-proficiency (person-english-proficiency p)
          'first-name (person-first-name p)
          'last-name (person-last-name p)
          'gender (person-gender p)
          'email-address (person-email-address p)
          'date-of-birth (and (person-date-of-birth p) (datetime->iso8601 (person-date-of-birth p)))
          'phone-number (person-phone-number p)
          'place-of-birth (and (person-place-of-birth p) (birth-place->jsexpr (person-place-of-birth p)))
          'race (person-race p)))