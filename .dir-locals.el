;;; Per-repo Emacs settings (read by Emacs for every file under this directory).
;;; K&R: each exercise 1-20.c pairs with its input file 1-20.in rather than a
;;; header, so SPC e flips between those two. Missing twin is created on save.
;;; Man pages: Linux syscalls first, then C library, then shell commands (2 before 3
;;; because man treats "3" as a prefix and would put open(3perl) ahead of open(2)).
((nil . ((my/source-header-twins . (("c" "in") ("in" "c")))
         (my/man-sections . "2,3,1"))))
