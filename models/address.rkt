#lang racket

(provide make-address
         address?
         address-id
         address-version
         address-city
         address-county
         address-person-id
         address-postal-code
         address-state
         address-street
         address-country-id
         address->jsexpr)

(define-struct address
  (id
   version
   city
   county
   person-id
   postal-code
   state
   street
   country-id))

(define (address->jsexpr a)
  (hasheq 'id (address-id a)
          'version (address-version a)
          'street (address-street a)
          'city (address-city a)
          'county (address-county a)
          'state (address-state a)
          'postal-code (address-postal-code a)
          'country-id (address-country-id a)
          'person-id (address-person-id a)))