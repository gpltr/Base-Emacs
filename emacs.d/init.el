;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold 100000000)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Terminal (eat) performance
(setq process-adaptive-read-buffering nil)
(setq read-process-output-max (* 4 1024 1024))

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)
  (setq mac-right-option-modifier 'super)
  (setq dired-use-ls-dired nil)
  (setq insert-directory-program "gls")
  (use-package exec-path-from-shell
    :ensure t
    :config
    (exec-path-from-shell-initialize))
  ;; Simulate CUA mode on Mac
  (keymap-global-set "M-c" 'kill-ring-save)
  (keymap-global-set "M-v" 'yank)
  (setq font_fix-pitch "JetBrains Mono")
  (setq font_var-pitch "Iosevka Aile"))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(when (eq system-type 'gnu/linux)
  (setq cua-auto-tabify-rectangles nil)
  (cua-mode t)
  (transient-mark-mode 1)
  (setq font_fix-pitch "JetBrains Mono Nerd Font")
  (setq font_var-pitch "Iosevka Aile"))

;; Load the package package
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Thanks, but no thanks
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell nil)

(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook latex-mode-hook LaTeX-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(add-to-list 'display-buffer-alist
           '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
             (display-buffer-no-window)
             (allow-no-window . t)))

;; Highlight the current line
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'text-mode-hook #'hl-line-mode)

;; Screenshots: https://github.com/doomemacs/themes/blob/screenshots/
(use-package doom-themes
  :vc (:url "https://github.com/doomemacs/themes" :rev :newest)
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

(defun gpltr/set-font-faces ()
  (message "Setting faces!")
    ;; Set the default pitch face
  (set-face-attribute 'default nil
                      :font font_fix-pitch
                      :weight 'normal
                      :height 120)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil
                      :font font_fix-pitch
                      :height 1.0
                      :weight 'normal)

  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil
                      :font font_var-pitch
                      :height 1.0
                      :weight 'normal))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                ;; (setq doom-modeline-icon t)
                (with-selected-frame frame
                  (gpltr/set-font-faces))))
  (gpltr/set-font-faces))

(defvar user-temporary-file-directory (concat user-emacs-directory "tmp/"))

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,user-temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))
(setq create-lockfiles nil)

(use-package vundo
  :ensure t
  :bind
  (("C-x u" . vundo))
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  :config
  (set-face-attribute 'vundo-default nil :family "Symbola"))

(use-package savehist
  :custom
  (history-length 100)
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
  (savehist-file "~/.cache/savehist")
  :init
  (savehist-mode 1))

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous)
              ("C-j" . vertico-exit))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism
     orderless-regexp))
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :custom
  (completion-in-region-function #'consult-completion-in-region))

(use-package marginalia
  :ensure t
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window))
  :custom
  (aw-scope 'frame)
  (aw-minibuffer-flag t)
  (aw-keys '(?q ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-char-2)))

(use-package magit
  :ensure t
  :bind (("C-x g" .  magit-status))
  :custom
  (magit-diff-refine-hunk (quote all)))

(use-package code-cells
  :ensure t)

(use-package vterm
  :vc (:url "https://github.com/akermu/emacs-libvterm" :branch "master")
  :ensure t)

(use-package popper
  :ensure t
  :bind (("C-ù" . popper-toggle)
         ("M-ù" .  popper-cycle)
         ("C-M-ù" . popper-toggle-type))
  :init
  (setq popper-window-height 12)
  (setq popper-reference-buffers
      '("\\*Messages\\*"
        "Output\\*$"
        "\\*Async Shell Command\\*"
        help-mode
        compilation-mode
        "^\\*eshell.*\\*$" eshell-mode
        "^\\*vterm.*\\*" vterm-mode
        "^\\*Python\\*"
        "^\\*julia\\*"))
  (popper-mode +1)
  (popper-echo-mode +1))

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . variable-pitch-mode)
  :custom
  (org-id-link-to-org-use-id t)
  (org-ellipsis " ▾")
  ;; (org-hide-emphasis-markers t)
  (org-startup-folded t)
  (org-fontify-quote-and-verse-blocks t)
  (org-startup-indented t)
  :config
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((shell . t)
      (gnuplot . t)
      (python . t)
      (emacs-lisp . t))))

;; Center org document
(use-package olivetti
  :ensure t
  :hook
  (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 150))

;; Sleek look
(use-package org-modern-indent
  :vc (:url "https://github.com/jdtsmith/org-modern-indent" :rev :newest)
  :ensure t
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

;; This is needed as of Org 9.2
(use-package org-tempo
  :after (org)
  :config
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
  (add-to-list 'org-structure-template-alist '("json" . "src json")))

(use-package org-superstar
  :ensure t
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-faces
  :after (color)
  :custom-face
  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (org-block ((t (:inherit 'fixed-pitch))))
  (org-table ((t (:inherit 'fixed-pitch))))
  (org-formula ((t (:inherit 'fixed-pitch))))
  (org-code ((t (:inherit 'fixed-pitch))))
  (org-verbatim ((t (:inherit 'fixed-pitch))))
  (org-tag ((t (:inherit 'fixed-pitch)))))

(use-package gnuplot :ensure t)

(use-package ox-gfm
  :ensure t
  :init
  (with-eval-after-load 'org
    '(require 'ox-gfm nil t)))

(use-package gptel
  :ensure t
  :bind (("C-c g" . gptel-menu))
  :config
  (setq
   gptel-default-mode 'org-mode
   gptel-model 'claude-3-5-sonnet-20240620
   gptel-backend (gptel-make-anthropic "Claude" :stream t :key gptel-api-key)))

(use-package inline-diff
  :vc t
  :load-path "~/.emacs.d/local/inline-diff"
  :ensure t
  :after gptel-rewrite)

(use-package gptel-rewrite
  :vc (:url "https://github.com/karthink/gptel" :branch "main")
  :ensure t
  :after gptel
  :bind (:map gptel-rewrite-actions-map
     ("C-c C-i" . gptel--rewrite-inline-diff))
  :config
  (defun gptel--rewrite-inline-diff (&optional ovs)
    "Start an inline-diff session on OVS."
    (interactive (list (gptel--rewrite-overlay-at)))
    (unless (require 'inline-diff nil t)
      (user-error "Inline diffs require the inline-diff package."))
    (when-let* ((ov-buf (overlay-buffer (or (car-safe ovs) ovs)))
                ((buffer-live-p ov-buf)))
      (with-current-buffer ov-buf
        (cl-loop for ov in (ensure-list ovs)
                 for ov-beg = (overlay-start ov)
                 for ov-end = (overlay-end ov)
                 for response = (overlay-get ov 'gptel-rewrite)
                 do (delete-overlay ov)
                 (inline-diff-words
                  ov-beg ov-end response)))))
  (when (boundp 'gptel--rewrite-dispatch-actions)
    (add-to-list
     'gptel--rewrite-dispatch-actions '(?i "inline-diff")
     'append))

  (defun gpltr/gptel--rewrite-directive-default ()
    "Generic directive for rewriting or refactoring.

    These are instructions not specific to any particular required
    change.

    The returned string is interpreted as the system message for the
    rewrite request.  To use your own, add a different directive to
    `gptel-directives', or add to `gptel-rewrite-directives-hook',
    which see."
    (let* ((lang (downcase (gptel--strip-mode-suffix major-mode)))
           (article (if (and lang (not (string-empty-p lang))
                                 (memq (aref lang 0) '(?a ?e ?i ?o ?u)))
                        "an" "a")))
      (if (derived-mode-p 'prog-mode)
          (format (concat "You are %s %s programmer.  "
                          "Follow my instructions and refactor %s code I provide.\n"
                          "- Generate ONLY %s code as output, without "
                          "any explanation or markdown code fences.\n"
                          "- Generate code in full, do not abbreviate or omit code.\n"
                          "- Do not ask for further clarification, and make "
                          "any assumptions you need to follow instructions.")
                  article lang lang lang)
        (concat
         "You are an a grammatical and spelling expert in all language."
         (if (string-empty-p lang)
             ""
           (format "You are in a %s %s editor." article lang))
         "  Follow my instructions and only fix mistakes in the text I provide."
         "  Generate ONLY the replacement text,"
         " without any explanation."))))
  (add-hook 'gptel-rewrite-directives-hook 'gpltr/gptel--rewrite-directive-default))

(defun gpltr/gptel-from-anywhere ()
  (interactive)
  (let* ((display-width (display-pixel-width))
         (display-height (display-pixel-height))
         (frame-width (/ display-width 3))
         (frame-height display-height))
    (make-frame `((window-system . ns)
                  (left . 0)
                  (top . 0)
                  (width . 80)
                  (height . 999))))
  (gptel "My:AI Chat" gptel-api-key nil)
  (switch-to-buffer "My:AI Chat")
  (delete-other-windows))

(use-package emacs-everywhere
  :vc (:url "https://github.com/tecosaur/emacs-everywhere" :branch "master" :rev :newest)
  :ensure t)
