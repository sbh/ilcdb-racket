#lang racket

(provide start-in-background
         stop-from-background)

(require web-server/web-server
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         "api/person.rkt"
         "api/address.rkt"
         "api/birth-place.rkt"
         "api/country.rkt")

(define shutdown-server #f)

;; (define main-dispatcher
;;   (sequencer:make person-api-dispatcher address-api-dispatcher birth-place-api-dispatcher country-api-dispatcher))

(define (start-in-background)
  (set! shutdown-server
        (serve #:dispatch (lambda (conn req) (person-api-dispatcher req))
               #:port 8080)))

(define (stop-from-background)
  (when (procedure? shutdown-server)
    (shutdown-server)
    (set! shutdown-server #f)))

(define (main)
  (define shutdown
    (serve #:dispatch (lambda (conn req) (person-api-dispatcher req))
           #:port 8080))
  (displayln "Server started. Press Ctrl+C to stop.")
  (sync/enable-break (make-semaphore 0))
  (shutdown))

#;(when (eq? (find-system-path 'run-file)
           (find-system-path 'main-file))
  (main))
