#lang racket

(provide make-birth-place
         birth-place?
         birth-place-id
         birth-place-version
         birth-place-city
         birth-place-state
         birth-place-country-id
         birth-place->jsexpr)

(define-struct birth-place
  (id
   version
   city
   state
   country-id))

(define (birth-place->jsexpr bp)
  (hasheq 'id (birth-place-id bp)
          'version (birth-place-version bp)
          'city (birth-place-city bp)
          'state (birth-place-state bp)
          'country-id (birth-place-country-id bp)))