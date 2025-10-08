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
         address-country
         address-person-id
         address->jsexpr)

(require "./country.rkt")

(define-struct address
  (id
   version
   street
   city
   county
   state
   postal-code
   country
   person-id)) ; person-id is kept as an ID to break circular dependency

(define (address->jsexpr a)
  (hasheq 'id (address-id a)
          'version (address-version a)
          'street (address-street a)
          'city (address-city a)
          'county (address-county a)
          'state (address-state a)
          'postal-code (address-postal-code a)
          'country (country->jsexpr (address-country a))
          'person-id (address-person-id a)))