#lang racket

(provide make-case-type
         case-type?
         case-type-id
         case-type-version
         case-type-deprecated
         case-type-type
         case-type-associated-status
         case-type->jsexpr)

(define-struct case-type
  (id
   version
   deprecated
   type
   associated-status))

(define (case-type->jsexpr ct)
  (hasheq 'id (case-type-id ct)
          'version (case-type-version ct)
          'deprecated (case-type-deprecated ct)
          'type (case-type-type ct)
          'associated-status (case-type-associated-status ct)))