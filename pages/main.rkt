#lang racket

(provide page-dispatcher)

(require web-server/dispatch
         web-server/servlet-env
         web-server/http
         "../db/person.rkt"
         "../models/person.rkt")

(define (base-template title . content)
  `(html
    (head
     (title ,title)
     (meta ([charset "utf-8"]))
     (meta ([name "viewport"]
            [content "width=device-width, initial-scale=1"]))
     (link ([rel "stylesheet"]
            [href "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"]))
     (script ([src "https://unpkg.com/htmx.org@1.9.10"]
              [integrity "sha384-D1Kt99CQMDuVetoL1lrYwg5t+9QdHe7NLX/SoJYkXDFfX37iInKRy5xLSi8nO7UC"]
              [crossorigin "anonymous"])))
    (body
     (div ([class "container mt-4"])
          ,@content))))

(define-values (page-dispatcher _)
  (dispatch-rules
   [("") (lambda (req) (index-page req))]
   [("clients") (lambda (req) (clients-page req))]
   [else (lambda (req) (not-found-page req))]))

(define (index-page request)
  (response/xexpr
   (base-template
    "ILCDB Home"
    `(h1 "Welcome to ILCDB")
    `(p "This is the Racket and HTMX version of the application.")
    `(p (a ([href "/clients"]) "View All Clients")))))

(define (clients-page request)
  (let ([clients (person-read-all)])
    (response/xexpr
     (base-template
      "Clients"
      `(h1 "All Clients")
      `(table ([class "table table-striped"])
              (thead
               (tr
                (th "ID")
                (th "First Name")
                (th "Last Name")
                (th "Email")
                (th "Phone")))
              (tbody
               ,@(for/list ([client clients])
                   `(tr
                     (td ,(number->string (person-id client)))
                     (td ,(person-first-name client))
                     (td ,(person-last-name client))
                     (td ,(or (person-email-address client) ""))
                     (td ,(or (person-phone-number client) ""))))))))))

(define (not-found-page request)
  (response/xexpr
   #:code 404
   (base-template
    "Not Found"
    `(h1 "404 - Page Not Found"))))