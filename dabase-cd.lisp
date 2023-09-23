#!/usr/bin/clisp

(defvar *DATA_BASE* nil)
(defvar DATA_BASE_NAME "my-cds.db")

(defun make-cd (title artist rating)
  (list :title title :artist artist :rating rating))

(defun add-record (cd) (push cd *DATA_BASE*))

(defun dump-db ()
  (format t "~{~{~a:~10t~a~%~}~%~}" *DATA_BASE*))

(defun prompt-read (prompt)
  (format *QUERY-IO* "~a: " prompt)
  (finish-output *QUERY-IO*)
  (read-line *QUERY-IO*))

(defun prompt-for-cd ()
  (make-cd
   (prompt-read "Title")
   (prompt-read "Artist")
   (or (parse-integer (prompt-read "Rating") :junk-allowed t) 0)))

(defun add-cds ()
  (loop (add-record(prompt-for-cd))
    (if (not (y-or-n-p "Another? [y/n]: ")) (return))))

(defun select (selector-fn)
  (remove-if-not selector-fn *DATA_BASE*))

(defun where (&key title artist rating)
  #'(lambda (cd)
      (and
       (if title    (equal (getf cd :title)  title)  t)
       (if artist   (equal (getf cd :artist) artist) t)
       (if rating   (equal (getf cd :rating) rating) t))))

(defun save-db (filename)
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede)
    (with-standard-io-syntax
      (print *DATA_BASE* out))))

(defun load-db (filename)
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *DATA_BASE* (read in)))))

(load-db DATA_BASE_NAME)
(add-cds)
(dump-db)
(save-db DATA_BASE_NAME)
