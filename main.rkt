#lang racket

(provide start-in-background
         stop-from-background)

(require web-server/web-server
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         "api/person.rkt"
         "api/country.rkt"
         "api/birth-place.rkt"
         "api/address.rkt"
         "api/ami.rkt"
         "api/client.rkt"
         "pages/main.rkt")

(define shutdown-server #f)

(define main-dispatcher
  (sequencer:make
   (lambda (conn req) (person-api-dispatcher req))
   (lambda (conn req) (country-api-dispatcher req))
   (lambda (conn req) (birth-place-api-dispatcher req))
   (lambda (conn req) (address-api-dispatcher req))
   (lambda (conn req) (ami-api-dispatcher req))
   (lambda (conn req) (client-api-dispatcher req))
   (lambda (conn req) (page-dispatcher req))))

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