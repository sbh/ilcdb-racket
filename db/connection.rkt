#lang racket

(provide get-connection)

(require db/mysql)

(define (get-connection)
  (mysql-connect #:user "ilcdb_user"
                 #:password "ilcdb_password"
                 #:database "ilcdb"
                 #:server "127.0.0.1"
                 #:port 3306))