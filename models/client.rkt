#lang racket

(provide make-client
         client?
         client-id
         client-version
         client-client-id ; This corresponds to the person.id
         client-first-visit
         client-first-visit-string
         client-household-income-level
         client-number-in-household
         client-file-location
         client-ami-id
         client->jsexpr)

(require gregor)

(define-struct client
  (id
   version
   client-id
   first-visit
   first-visit-string
   household-income-level
   number-in-household
   file-location
   ami-id))

(define (client->jsexpr c)
  (hasheq 'id (client-id c)
          'version (client-version c)
          'client-id (client-client-id c)
          'first-visit (and (client-first-visit c) (datetime->iso8601 (client-first-visit c)))
          'first-visit-string (client-first-visit-string c)
          'household-income-level (client-household-income-level c)
          'number-in-household (client-number-in-household c)
          'file-location (client-file-location c)
          'ami-id (client-ami-id c)))