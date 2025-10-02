#lang racket

(provide make-client-case
         client-case?
         client-case-id
         client-case-version
         client-case-case-number
         client-case-client-id
         client-case-file-location
         client-case-coltaf-number
         client-case-completion-date
         client-case-intake-type
         client-case-start-date
         client-case-attorney
         client-case-case-type-id
         client-case-case-result-id
         client-case-intensity
         client-case->jsexpr)

(define-struct client-case
  (id
   version
   case-number
   client-id
   file-location
   coltaf-number
   completion-date
   intake-type
   start-date
   attorney
   case-type-id
   case-result-id
   intensity))

(define (client-case->jsexpr cc)
  (hasheq 'id (client-case-id cc)
          'version (client-case-version cc)
          'case-number (client-case-case-number cc)
          'client-id (client-case-client-id cc)
          'file-location (client-case-file-location cc)
          'coltaf-number (client-case-coltaf-number cc)
          'completion-date (client-case-completion-date cc)
          'intake-type (client-case-intake-type cc)
          'start-date (client-case-start-date cc)
          'attorney (client-case-attorney cc)
          'case-type-id (client-case-case-type-id cc)
          'case-result-id (client-case-case-result-id cc)
          'intensity (client-case-intensity cc)))