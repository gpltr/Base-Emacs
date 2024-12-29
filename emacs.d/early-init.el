;; The whole configuration is in a single org file "config.org"
;; Tangle the config file if needed.
;; https://www.reddit.com/r/emacs/comments/wn94ne/comment/ik3z99k/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button 
(let* ((default-directory user-emacs-directory)
       (org-file "config.org")
       (el-file "config.el")
       (changed-at (file-attribute-modification-time (file-attributes org-file))))
  (require 'org-macs)
  (unless (org-file-newer-than-p el-file changed-at)
    (require 'ob-tangle)
    (org-babel-tangle-file org-file el-file "emacs-lisp"))
  (load-file el-file))
