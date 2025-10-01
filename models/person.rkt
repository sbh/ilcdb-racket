#lang racket

(require gregor)

(provide make-person
         person?
         person-id
         person-version
         person-address-id
         person-english-proficiency
         person-first-name
         person-last-name
         person-gender
         person-email-address
         person-date-of-birth
         person-phone-number
         person-place-of-birth-id
         person-race
         person->jsexpr)

(define-struct person
  (id
   version
   address-id
   english-proficiency
   first-name
   last-name
   gender
   email-address
   date-of-birth
   phone-number
   place-of-birth-id
   race))

(define (person->jsexpr p)
  (hasheq 'id (person-id p)
          'version (person-version p)
          'address-id (person-address-id p)
          'english-proficiency (person-english-proficiency p)
          'first-name (person-first-name p)
          'last-name (person-last-name p)
          'gender (person-gender p)
          'email-address (person-email-address p)
          'date-of-birth (and (person-date-of-birth p) (~t (person-date-of-birth p) "yyyy-MM-dd'T'HH:mm:ss"))
          'phone-number (person-phone-number p)
          'place-of-birth-id (person-place-of-birth-id p)
          'race (person-race p)))