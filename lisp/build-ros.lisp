(defpackage :roswell.build.ros
  (:use :cl))
(in-package :roswell.build.ros)

(defun parse-argv (argv)
  (let* ((header "exec ros")
         (hl (length header)))
    (and (equal header (subseq argv 0 (length header)))
         (loop for last = nil then c
               for i from 0
               for c across argv
               when (and (equal #\- last)
                         (equal #\- c))
                 do (return (subseq argv hl (1- i)))))))

(defun ros (&rest argv)
  (let (opts)
    (with-open-file (in (first argv))
      (loop repeat 4
            for line = (read-line in)
            when (ignore-errors (string= line "exec" :end1 4))
              do (setf opts (parse-argv line))))
    (roswell:roswell `(,@(when (roswell:verbose) '("-v"))
                         ,opts "-L" ,(or (ros:opt "*lisp")
                                         (ros:opt "default.lisp"))
                         "dump" ,@(rest argv) "executable" ,(first argv))
                     :interactive nil)))
