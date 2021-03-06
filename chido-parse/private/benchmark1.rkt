#lang racket/base

(module+ main
  (require
   "core-use.rkt"
   "readtable-parser.rkt"
   "parameters.rkt"
   racket/cmdline
   racket/port
   racket/file
   racket/stream
   rackunit
   )

  (define my-s-exp-readtable
    (extend-chido-readtable*
     (chido-readtable-add-list-parser
      "{" "}"
      (chido-readtable-add-list-parser
       "[" "]"
       (chido-readtable-add-list-parser "(" ")" empty-chido-readtable)))
     'nonterminating hash-t-parser
     'nonterminating hash-f-parser
     'terminating racket-style-string-parser
     'terminating-layout " "
     'terminating-layout "\n"
     'terminating-layout "\t"))
  (define my-parser (chido-readtable->read1 my-s-exp-readtable))

  (define f (command-line #:args (filename) filename))

  (define s (file->string f))

  (eprintf "Time for chido-parse s-exp parser:\n")
  (define my-parse
    (time (parse-derivation-result
           (stream-first
            (parse* (open-input-string s) my-parser)))))
  (get-counts!)
  (collect-garbage 'major)
  (eprintf "Time for racket's read function:\n")
  (define r-parse
    (time (read-syntax "my-input-name" (open-input-string s))))

  (check-equal? (syntax->datum my-parse) (syntax->datum r-parse))

  )
