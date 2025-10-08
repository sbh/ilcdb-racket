#lang racket

(require rackunit
         rackunit/text-ui
         net/http-client
         web-server/http
         racket/bytes
         json
         gregor
         "../main.rkt"
         "../utils.rkt")

;; --- Helper Functions for Test Dependencies ---

(define (get-id res)
  (let ([body (port->bytes (caddr res))])
    (hash-ref (bytes->jsexpr body) 'id)))

(define (create-country)
  (get-id (http-sendrecv "localhost" "/api/country" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'name "Testland")))))
(define (delete-country id)
  (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080 #:method "DELETE"))

(define (create-ami)
  (get-id (http-sendrecv "localhost" "/api/ami" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'label "Test AMI" 'level 1)))))
(define (delete-ami id)
  (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080 #:method "DELETE"))

(define (create-birth-place country-id)
  (get-id (http-sendrecv "localhost" "/api/birth-place" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'city "Testville" 'state "TS" 'country-id country-id)))))
(define (delete-birth-place id)
  (http-sendrecv "localhost" (string-append "/api/birth-place/" (number->string id)) #:port 8080 #:method "DELETE"))

(define (create-address country-id)
  (get-id (http-sendrecv "localhost" "/api/address" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'street "123 Test St" 'city "Testopolis" 'county "Testshire" 'state "TS" 'postal-code "12345" 'country-id country-id)))))
(define (delete-address id)
  (http-sendrecv "localhost" (string-append "/api/address/" (number->string id)) #:port 8080 #:method "DELETE"))

(define (create-person address-id birth-place-id)
  (get-id (http-sendrecv "localhost" "/api/person" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'first-name "John" 'last-name "Tester" 'address-id address-id 'place-of-birth-id birth-place-id)))))
(define (delete-person id)
  (http-sendrecv "localhost" (string-append "/api/person/" (number->string id)) #:port 8080 #:method "DELETE"))

(test-suite
 "ILCDB Full API Integration Tests"

 (with-handlers ([exn:fail? (lambda (ex) (stop-from-background) (raise ex))])
   (start-in-background)
   (sleep 2)

   (test-suite
    "Country API Lifecycle"
    (let ([id #f])
      (dynamic-wind
        (lambda () #t)
        (lambda ()
          (test-case "POST" (set! id (create-country)))
          (test-case "GET /:id"
                     (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080))
                     (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'name) "Testland"))
          (test-case "GET /"
                     (define-values (s h i) (http-sendrecv "localhost" "/api/country" #:port 8080))
                     (check-true (list? (bytes->jsexpr (port->bytes i)))))
          (test-case "PUT" (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080 #:method "PUT" #:data (jsexpr->bytes (hasheq 'name "New Testland"))))
          (test-case "GET /:id (verify PUT)"
                     (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080))
                     (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'name) "New Testland")))
        (lambda () (and id (delete-country id))))))

   (test-suite
    "Person and Dependencies Lifecycle"
    (let ([country-id #f] [birth-place-id #f] [address-id #f] [person-id #f])
      (dynamic-wind
        (lambda ()
          (set! country-id (create-country))
          (set! birth-place-id (create-birth-place country-id))
          (set! address-id (create-address country-id)))
        (lambda ()
          (test-case "POST Person" (set! person-id (create-person address-id birth-place-id)))
          (test-case "GET Person"
                     (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id)) #:port 8080))
                     (let ([json-resp (bytes->jsexpr (port->bytes i))])
                       (check-equal? (hash-ref json-resp 'first-name) "John")
                       (check-equal? (hash-ref (hash-ref json-resp 'address) 'street) "123 Test St")
                       (check-equal? (hash-ref (hash-ref json-resp 'place-of-birth) 'city) "Testville"))))
        (lambda ()
          (and person-id (delete-person person-id))
          (and address-id (delete-address address-id))
          (and birth-place-id (delete-birth-place birth-place-id))
          (and country-id (delete-country country-id))))))

   (test-suite
    "Client API Lifecycle"
    (let ([country-id #f] [ami-id #f] [birth-place-id #f] [address-id #f] [person-id #f] [id #f])
      (dynamic-wind
        (lambda ()
          (set! country-id (create-country))
          (set! ami-id (create-ami))
          (set! birth-place-id (create-birth-place country-id))
          (set! address-id (create-address country-id))
          (set! person-id (create-person address-id birth-place-id)))
        (lambda ()
          (test-case "POST"
                     (define-values (s h i) (http-sendrecv "localhost" "/api/client" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'person-id person-id 'ami-id ami-id 'household-income-level 50000))))
                     (check-equal? (bytes->string/utf-8 s) "200 OK")
                     (set! id (hash-ref (bytes->jsexpr (port->bytes i)) 'id)))
          (test-case "GET /:id"
                     (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/client/" (number->string id)) #:port 8080))
                     (let ([json-resp (bytes->jsexpr (port->bytes i))])
                       (check-equal? (hash-ref json-resp 'household-income-level) 50000)
                       (check-equal? (hash-ref (hash-ref json-resp 'person) 'first-name) "John")
                       (check-equal? (hash-ref (hash-ref json-resp 'ami) 'label) "Test AMI"))))
        (lambda ()
          (and id (http-sendrecv "localhost" (string-append "/api/client/" (number->string id)) #:port 8080 #:method "DELETE"))
          (and person-id (delete-person person-id))
          (and address-id (delete-address address-id))
          (and birth-place-id (delete-birth-place birth-place-id))
          (and country-id (delete-country country-id))
          (and ami-id (delete-ami ami-id))))))

   (test-suite
    "Page Rendering"
    (test-case
     "GET / (Home Page)"
     (define-values (s h i) (http-sendrecv "localhost" "/" #:port 8080))
     (check-equal? (bytes->string/utf-8 s) "200 OK")
     (define content-type (headers-assq* #"Content-Type" h))
     (check-true (bytes-prefix? (header-value content-type) #"text/html"))
     (define body (port->bytes i))
     (check-true (bytes-contains? body #"Welcome to ILCDB"))))

   (test-suite
    "Client Pages"
    (let ([country-id #f] [birth-place-id #f] [address-id #f] [person-id #f])
      (dynamic-wind
        (lambda ()
          (set! country-id (create-country))
          (set! birth-place-id (create-birth-place country-id))
          (set! address-id (create-address country-id))
          (set! person-id (create-person address-id birth-place-id)))
        (lambda ()
          (test-case
           "GET /clients (Client List Page)"
           (define-values (s h i) (http-sendrecv "localhost" "/clients" #:port 8080))
           (check-equal? (bytes->string/utf-8 s) "200 OK")
           (define body (port->bytes i))
           (check-true (bytes-contains? body #"All Clients"))
           (check-true (bytes-contains? body #"John")))
          (test-case
           "GET /clients/:id (Client Detail Page)"
           (define-values (s h i) (http-sendrecv "localhost" (string-append "/clients/" (number->string person-id)) #:port 8080))
           (check-equal? (bytes->string/utf-8 s) "200 OK")
           (define body (port->bytes i))
           (check-true (bytes-contains? body #"John Tester"))
           (check-true (bytes-contains? body #"Email:"))))
        (lambda ()
          (and person-id (delete-person person-id))
          (and address-id (delete-address address-id))
          (and birth-place-id (delete-birth-place birth-place-id))
          (and country-id (delete-country country-id))))))

   (stop-from-background)))