#lang racket

(provide make-client
         client?
         client-id
         client-version
         client-person
         client-first-visit
         client-first-visit-string
         client-household-income-level
         client-number-in-household
         client-file-location
         client-ami
         client->jsexpr)

(require gregor
         "./person.rkt"
         "./ami.rkt")

(define-struct client
  (id
   version
   person
   first-visit
   first-visit-string
   household-income-level
   number-in-household
   file-location
   ami))

(define (client->jsexpr c)
  (hasheq 'id (client-id c)
          'version (client-version c)
          'person (person->jsexpr (client-person c))
          'first-visit (and (client-first-visit c) (datetime->iso8601 (client-first-visit c)))
          'first-visit-string (client-first-visit-string c)
          'household-income-level (client-household-income-level c)
          'number-in-household (client-number-in-household c)
          'file-location (client-file-location c)
          'ami (ami->jsexpr (client-ami c))))