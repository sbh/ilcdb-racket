#lang racket

(provide get-connection)

(require db/mysql)

(define (get-connection)
  (let ([db-host (getenv "DB_HOST")])
    (mysql-connect #:user "ilcdb_user"
                   #:password "ilcdb_password"
                   #:database "ilcdb"
                   #:server (if db-host db-host "127.0.0.1")
                   #:port 3306)))