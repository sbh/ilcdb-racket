#lang racket

(require db)
(provide get-connection)

(define (get-connection)
  (mysql-connect #:server "localhost"
                 #:port 3306
                 #:user "ilcdb_user"
                 #:password "ilcdb_password"
                 #:database "ilcdb"))