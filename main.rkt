#lang racket

(provide start-in-background
         stop-from-background)

(require web-server/web-server
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         "api/person.rkt"
         "api/country.rkt"
         "api/birth-place.rkt"
         "api/address.rkt")

(define shutdown-server #f)

;; The sequencer:make function expects dispatchers that take two arguments
;; (connection and request), but our API dispatchers only take one (request).
;; We wrap each in a lambda to adapt the signature.
(define main-dispatcher
  (sequencer:make
   (lambda (conn req) (person-api-dispatcher req))
   (lambda (conn req) (country-api-dispatcher req))
   (lambda (conn req) (birth-place-api-dispatcher req))
   (lambda (conn req) (address-api-dispatcher req))))

(define (start-in-background)
  (set! shutdown-server
        (serve #:dispatch main-dispatcher
               #:port 8080)))

(define (stop-from-background)
  (when (procedure? shutdown-server)
    (shutdown-server)
    (set! shutdown-server #f)))

(define (main)
  (define shutdown
    (serve #:dispatch main-dispatcher
           #:port 8080))
  (displayln "Server started. Press Ctrl+C to stop.")
  (sync/enable-break (make-semaphore 0))
  (shutdown))

#;(when (eq? (find-system-path 'run-file)
           (find-system-path 'main-file))
  (main))