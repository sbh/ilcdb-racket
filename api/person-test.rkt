#lang racket

(require rackunit
         rackunit/text-ui
         net/http-client
         racket/bytes
         json
         db/base
         "../main.rkt"
         "../utils.rkt"
         "../db/country.rkt"
         "../db/address.rkt"
         "../db/birth-place.rkt")

(define country-id #f)
(define birth-place-id #f)
(define address-id #f)
(define person-id #f)

(define person-api-tests
  (test-suite
   "Person API Tests"

   (with-handlers ([exn:fail? (lambda (ex) (stop-from-background) (raise ex))])
     (start-in-background)
     (sleep 2) ; Give the server a moment to start

     (test-case
      "Create dependencies"
      (set! country-id (country-create "USA"))
      (set! birth-place-id (birth-place-create "New York" "NY" country-id))
      (set! address-id (address-create "123 Main St" "Anytown" "Anycounty" "Anystate" "12345" country-id sql-null)))

     (test-case
      "POST /api/person"
      (define-values (status headers in)
        (http-sendrecv "localhost" "/api/person"
                       #:port 8080
                       #:method "POST"
                       #:data (jsexpr->string
                               (hasheq 'first-name "John"
                                       'last-name "Doe"
                                       'phone-number "555-1234"
                                       'date-of-birth "1990-01-01T00:00:00"
                                       'english-proficiency "native"
                                       'email-address "john.doe@example.com"
                                       'gender "male"
                                       'race "White"
                                       'address-id address-id
                                       'place-of-birth-id birth-place-id))))
      (check-equal? (bytes->string/utf-8 status) "200 OK")
      (define body (port->bytes in))
      (define json-response (bytes->jsexpr body))
      (set! person-id (hash-ref json-response 'id)))

     (test-case
      "GET /api/person/:id"
      (define-values (status headers in)
        (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id)) #:port 8080))
      (check-equal? (bytes->string/utf-8 status) "200 OK")
      (define body (port->bytes in))
      (define json-response (bytes->jsexpr body))
      (check-equal? (hash-ref json-response 'first-name) "John"))

     (test-case
      "PUT /api/person/:id"
      (define-values (status headers in)
        (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id))
                       #:port 8080
                       #:method "PUT"
                       #:data (jsexpr->string
                               (hasheq 'first-name "Jane"
                                       'last-name "Doe"
                                       'phone-number "555-5678"
                                       'date-of-birth "1990-01-01T00:00:00"
                                       'english-proficiency "high"
                                       'email-address "jane.doe@example.com"
                                       'gender "female"
                                       'race "White"
                                       'address-id address-id
                                       'place-of-birth-id birth-place-id))))
      (check-equal? (bytes->string/utf-8 status) "200 OK"))

     (test-case
      "GET /api/person/:id (verify update)"
      (define-values (status headers in)
        (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id)) #:port 8080))
      (check-equal? (bytes->string/utf-8 status) "200 OK")
      (define body (port->bytes in))
      (define json-response (bytes->jsexpr body))
      (check-equal? (hash-ref json-response 'first-name) "Jane"))

     (test-case
      "DELETE /api/person/:id"
      (define-values (status headers in)
        (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id))
                       #:port 8080
                       #:method "DELETE"))
      (check-equal? (bytes->string/utf-8 status) "200 OK"))

     (test-case
      "GET /api/person/:id (verify delete)"
      (define-values (status headers in)
        (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id)) #:port 8080))
      (check-pred (lambda (s) (bytes-prefix? s #"404")) status))

     (stop-from-background))))

(run-tests person-api-tests)