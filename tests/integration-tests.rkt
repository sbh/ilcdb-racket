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

(define (create-test-country)
  (define-values (s h i) (http-sendrecv "localhost" "/api/country" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'name "Testland"))))
  (hash-ref (bytes->jsexpr (port->bytes i)) 'id))

(define (delete-test-country id)
  (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080 #:method "DELETE"))

(define (create-test-ami)
  (define-values (s h i) (http-sendrecv "localhost" "/api/ami" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'label "Test AMI" 'level 1))))
  (hash-ref (bytes->jsexpr (port->bytes i)) 'id))

(define (delete-test-ami id)
  (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080 #:method "DELETE"))

(test-suite
 "ILCDB Full API Integration Tests"

 (with-handlers ([exn:fail? (lambda (ex) (stop-from-background) (raise ex))])
   (start-in-background)
   (sleep 2)

   (test-suite
    "Country API Lifecycle"
    (let ([id #f])
      (test-case "POST"
                 (define-values (s h i) (http-sendrecv "localhost" "/api/country" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'name "Testlandia"))))
                 (check-equal? (bytes->string/utf-8 s) "200 OK")
                 (set! id (hash-ref (bytes->jsexpr (port->bytes i)) 'id)))
      (test-case "GET /:id"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080))
                 (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'name) "Testlandia"))
      (test-case "GET /"
                 (define-values (s h i) (http-sendrecv "localhost" "/api/country" #:port 8080))
                 (check-true (list? (bytes->jsexpr (port->bytes i)))))
      (test-case "PUT"
                 (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080 #:method "PUT" #:data (jsexpr->bytes (hasheq 'name "New Testlandia"))))
      (test-case "GET /:id (verify PUT)"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080))
                 (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'name) "New Testlandia"))
      (test-case "DELETE"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080 #:method "DELETE"))
                 (check-equal? (bytes->string/utf-8 s) "200 OK"))
      (test-case "GET /:id (verify DELETE)"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/country/" (number->string id)) #:port 8080))
                 (check-pred (lambda(b) (bytes-prefix? b #"404")) s))))

   (test-suite
    "AMI API Lifecycle"
    (let ([id #f])
      (test-case "POST"
                 (define-values (s h i) (http-sendrecv "localhost" "/api/ami" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'label "100% AMI" 'level 5))))
                 (check-equal? (bytes->string/utf-8 s) "200 OK")
                 (set! id (hash-ref (bytes->jsexpr (port->bytes i)) 'id)))
      (test-case "GET /:id"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080))
                 (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'level) 5))
       (test-case "GET /"
                 (define-values (s h i) (http-sendrecv "localhost" "/api/ami" #:port 8080))
                 (check-true (list? (bytes->jsexpr (port->bytes i)))))
      (test-case "PUT"
                 (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080 #:method "PUT" #:data (jsexpr->bytes (hasheq 'label "120% AMI" 'level 6))))
      (test-case "GET /:id (verify PUT)"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080))
                 (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'level) 6))
      (test-case "DELETE"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080 #:method "DELETE"))
                 (check-equal? (bytes->string/utf-8 s) "200 OK"))
      (test-case "GET /:id (verify DELETE)"
                 (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/ami/" (number->string id)) #:port 8080))
                 (check-pred (lambda(b) (bytes-prefix? b #"404")) s))))

   (test-suite
    "Full Dependent Lifecycle (Birth Place, Address, Person, Client)"
    (let ([country-id #f] [ami-id #f] [birth-place-id #f] [address-id #f] [person-id #f] [client-id #f])
      (dynamic-wind
        (lambda () (set! country-id (create-test-country)) (set! ami-id (create-test-ami)))
        (lambda ()
          (test-suite
           "Dependent Creation"
           (test-case "POST birth-place" (set! birth-place-id (hash-ref (bytes->jsexpr (port->bytes (caddr (http-sendrecv "localhost" "/api/birth-place" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'city "Testville" 'state "TS" 'country-id country-id)))))) 'id)))
           (test-case "POST address" (set! address-id (hash-ref (bytes->jsexpr (port->bytes (caddr (http-sendrecv "localhost" "/api/address" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'street "123 Test St" 'city "Testopolis" 'county "Testshire" 'state "TS" 'postal-code "12345" 'country-id country-id)))))) 'id)))
           (test-case "POST person" (set! person-id (hash-ref (bytes->jsexpr (port->bytes (caddr (http-sendrecv "localhost" "/api/person" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'first-name "John" 'last-name "Tester" 'address-id address-id 'place-of-birth-id birth-place-id)))))) 'id)))
           (test-case "POST client"
                      (define-values (s h i) (http-sendrecv "localhost" "/api/client" #:port 8080 #:method "POST" #:data (jsexpr->bytes (hasheq 'client-id person-id 'ami-id ami-id 'household-income-level 50000))))
                      (check-equal? (bytes->string/utf-8 s) "200 OK")
                      (set! client-id (hash-ref (bytes->jsexpr (port->bytes i)) 'id)))
           (test-case "GET client"
                      (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/client/" (number->string client-id)) #:port 8080))
                      (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'household-income-level) 50000))
           (test-case "PUT client"
                      (http-sendrecv "localhost" (string-append "/api/client/" (number->string client-id)) #:port 8080 #:method "PUT" #:data (jsexpr->bytes (hasheq 'client-id person-id 'ami-id ami-id 'household-income-level 60000))))
           (test-case "GET client (verify PUT)"
                      (define-values (s h i) (http-sendrecv "localhost" (string-append "/api/client/" (number->string client-id)) #:port 8080))
                      (check-equal? (hash-ref (bytes->jsexpr (port->bytes i)) 'household-income-level) 60000))))
        (lambda ()
          (http-sendrecv "localhost" (string-append "/api/client/" (number->string client-id)) #:port 8080 #:method "DELETE")
          (http-sendrecv "localhost" (string-append "/api/person/" (number->string person-id)) #:port 8080 #:method "DELETE")
          (http-sendrecv "localhost" (string-append "/api/address/" (number->string address-id)) #:port 8080 #:method "DELETE")
          (http-sendrecv "localhost" (string-append "/api/birth-place/" (number->string birth-place-id)) #:port 8080 #:method "DELETE")
          (delete-test-country country-id)
          (delete-test-ami ami-id)))))
   
   (test-suite
    "Page Rendering"
    (test-case
     "GET / (Home Page)"
     (define-values (s h i) (http-sendrecv "localhost" "/" #:port 8080))
     (check-equal? (bytes->string/utf-8 s) "200 OK")
     (define content-type (headers-assq* #"Content-Type" h))
     (check-true (bytes-prefix? (header-value content-type) #"text/html"))
     (define body (port->bytes i))
     (check-true (bytes-contains? body #"Welcome to ILCDB")))
    (test-case
     "GET /clients (Client List Page)"
     (define-values (s h i) (http-sendrecv "localhost" "/clients" #:port 8080))
     (check-equal? (bytes->string/utf-8 s) "200 OK")
     (define content-type (headers-assq* #"Content-Type" h))
     (check-true (bytes-prefix? (header-value content-type) #"text/html"))
     (define body (port->bytes i))
     (check-true (bytes-contains? body #"All Clients"))
     (check-true (bytes-contains? body #"John"))
     (check-true (bytes-contains? body #"Tester"))))

   (stop-from-background)))