#lang racket

(provide make-ami
         ami?
         ami-id
         ami-version
         ami-label
         ami-level
         ami->jsexpr)

(define-struct ami
  (id
   version
   label
   level))

(define (ami->jsexpr a)
  (hasheq 'id (ami-id a)
          'version (ami-version a)
          'label (ami-label a)
          'level (ami-level a)))