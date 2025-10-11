#lang racket

(provide make-birth-place
         birth-place?
         birth-place-id
         birth-place-version
         birth-place-city
         birth-place-state
         birth-place-country
         birth-place->jsexpr)

(require "./country.rkt")

(define-struct birth-place
  (id
   version
   city
   state
   country))

(define (birth-place->jsexpr bp)
  (hasheq 'id (birth-place-id bp)
          'version (birth-place-version bp)
          'city (birth-place-city bp)
          'state (birth-place-state bp)
          'country (country->jsexpr (birth-place-country bp))))