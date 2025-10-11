#lang racket

(provide make-country
         country?
         country-id
         country-version
         country-name
         country->jsexpr)

(define-struct country
  (id
   version
   name))

(define (country->jsexpr c)
  (hasheq 'id (country-id c)
          'version (country-version c)
          'name (country-name c)))