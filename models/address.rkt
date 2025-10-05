#lang racket

(provide make-address
         address?
         address-id
         address-version
         address-street
         address-city
         address-county
         address-state
         address-postal-code
         address-country-id
         address-person-id
         address->jsexpr)

(define-struct address
  (id
   version
   street
   city
   county
   state
   postal-code
   country-id
   person-id))

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