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
  :ensure t
  :bind (("C-q" . vterm-send-next-key)))

(defun buffer-mode (&optional buffer-or-name)
  "Returns the major mode associated with a buffer.
If buffer-or-name is nil return current buffer's mode."
  (buffer-local-value 'major-mode
                      (if buffer-or-name
                          (get-buffer buffer-or-name)
                        (current-buffer))))

(defvar gpltr/repl-names-list
  '("^\\*Python.*\\*$"
    "\\*julia.*\\*"
    "^\\*edebug.*\\*$"
    "^\\*vterm.*\\*$")
  "List of buffer names used in REPL buffers")

(defvar gpltr/help-modes-list
  '(helpful-mode
    help-mode
    pydoc-mode
    eldoc-mode
    TeX-special-mode)
  "List of major-modes used in documentation buffers")

(defvar gpltr/occur-grep-modes-list
  '(occur-mode
    grep-mode
    xref--xref-buffer-mode
    locate-mode
    flymake-diagnostics-buffer-mode)
  "List of major-modes used in occur-type buffers")

(defvar gpltr/message-names-list
  '("\\*\\(?:Warnings\\|Compile-Log\\|Messages\\)\\*"
    "[Oo]utput\\*"
    "\\*Async Shell Command\\*")
  "List of buffer names used in message buffers")

;; Occur type buffers on the top
(setq display-buffer-alist
      '(
	((lambda (buf act) (member (buffer-mode buf) gpltr/occur-grep-modes-list))
	 (display-buffer-reuse-mode-window
	  display-buffer-in-direction
	  display-buffer-in-side-window)
	 (side . top)
	 (slot . 5)
	 (window-height . (lambda (win) (fit-window-to-buffer win 20 10)))
	 (direction . above)
	 (body-function . select-window))

	;; Message buffers on the bottom
	((lambda (buf act) (seq-some (lambda (regex) (string-match-p regex buf)) gpltr/message-names-list))
	 (display-buffer-at-bottom display-buffer-in-side-window)
	 (window-height . 0.25)
	 (side . bottom)
	 (slot . -6))

	;; REPL type buffer at the right
	((lambda (buf act) (seq-some (lambda (regex) (string-match-p regex buf)) gpltr/repl-names-list))
	 (display-buffer-reuse-window
	  display-buffer-in-side-window)
	 (body-function . select-window)
	 ;; display-buffer-at-left
	 (window-width .  .40)
	 ;; (preserve-size . (nil . t))
	 (side . right)
	 (slot . 1))

	;; Help type buffer at the right
	((lambda (buf act) (member (buffer-mode buf) gpltr/help-modes-list))
	 (display-buffer-reuse-window
	  display-buffer-in-side-window)
	 (body-function . select-window)
	 ;; display-buffer-at-left
	 (window-width .  .40)
	 ;; (preserve-size . (nil . t))
	 (side . right)
	 (slot . 2))

      ;; julia-doc buffer (as it does not have a specific mode)
      ("\\*julia-doc\\*"
       (display-buffer-reuse-window
	display-buffer-in-side-window)
       (body-function . select-window)
       ;; display-buffer-at-left
       (window-width .  .40)
       ;; (preserve-size . (nil . t))
       (side . right)
       (slot . 2))))

(use-package popper
  :ensure t
  :bind (("C-ù" . popper-toggle)
         ("M-ù" .  popper-cycle)
         ("C-M-ù" . popper-toggle-type))

  :init
  (setq popper-reference-buffers
	'("\\*Messages\\*"
	  "Output\\*$"
	  "\\*Async Shell Command\\*"
	  help-mode
	  compilation-mode
	  "^\\*eshell.*\\*$" eshell-mode
	  "^\\*vterm.*\\*" vterm-mode
	  "^\\*Python.*\\*"
	  "\\*julia.*\\*"
	  "^\\*eldoc\\*"
	  "^\\*gud-run\\*"))
  (setq popper-display-control nil)
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
      (emacs-lisp . t)
      (julia-vterm . t)))
  (defalias 'org-babel-execute:julia 'org-babel-execute:julia-vterm)
  (defalias 'org-babel-variable-assignments:julia 'org-babel-variable-assignments:julia-vterm))

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
  (add-to-list 'org-structure-template-alist '("json" . "src json"))
  (add-to-list 'org-structure-template-alist '("julia" . "src julia")))

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

(use-package inline-diff
  :vc t
  :load-path "~/.emacs.d/local/inline-diff"
  :ensure t)

(use-package gptel
  :vc (:url "https://github.com/karthink/gptel" :branch "main")
  :ensure t
  :bind (("C-c g" . gptel-menu)
	 ("C-c r" . gpltr/rewrite-with-inline-diff))
  :commands (gptel gptel-menu gptel--suffix-rewrite)
  :init
  (defun gpltr/gptel--rewrite-inline-diff (&optional ovs)
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
  (defun gpltr/rewrite-with-inline-diff ()
    "Launch gptel-rewrite on region with fixed directive and inline-diff."
    (interactive)
    (require 'gptel-rewrite)
    (unless (use-region-p)
      (mark-whole-buffer))
    (let ((gptel--rewrite-directive
                  (concat
                   "You are a grammatical and spelling expert in all languages. "
                   "Proofread the following text. Generate ONLY the corrected text, "
                   "without any explanation before or after. If no mistakes are found just copy the text: ")))
      (setq-local gptel-rewrite-default-action #'gpltr/gptel--rewrite-inline-diff)
      (gptel--suffix-rewrite "Proofread: ")))
  :config
  (setq
   gptel-default-mode 'org-mode
   gptel-model 'claude-haiku-4-5-20251001
   gptel-backend (gptel-make-anthropic "Claude" :stream t :key gptel-api-key))
  ;; https://github.com/karthink/gptel/issues/937
  (advice-add
   'gptel--request-data
   :around
   (lambda (orig-fn &rest args)
     (when (cl-typep (car args) 'gptel-anthropic)
       (let ((result (apply orig-fn args)))
         (cons :tools (cons '[(:type "web_search_20250305"
				     :name "web_search"
				     :max_uses 5)] result)))))))

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

(use-package detached
  :vc (:url "https://github.com/LemonBreezes/detached.el")
  :ensure t
  :init
  (detached-init)
  :bind (;; Replace `async-shell-command' with `detached-shell-command'
	 ([remap async-shell-command] . detached-shell-command)
	 ;; Replace `compile' with `detached-compile'
	 ([remap compile] . detached-compile)
	 ([remap recompile] . detached-compile-recompile)
	 ;; Replace built in completion of sessions with `consult'
	 ([remap detached-open-session] . detached-consult-session))
  :custom ((detached-show-output-on-attach t)
           (detached-terminal-data-command system-type))
  :config (setq detached-notification-function #'detached-state-transition-echo-message))

(defun my-gfm-src-block (src-block contents info)
  "Add colapse around code block if :attr_gfm :hide t"
  (if (not (org-export-read-attribute :attr_gfm src-block :hide))
      (org-export-with-backend 'gfm src-block contents info)
    (let* ((name (org-element-property :name src-block))
	   (prefix (concat "<details>\n<summary><code>" name "</code></summary>\n\n"))
	   (content (org-gfm-src-block src-block contents info))
  	(suffix "```\n\n</details>"))
      (concat prefix content suffix))))

(defun my-gfm-headline (headline contents info)
  "Transcode HEADLINE element into Markdown format.
  CONTENTS is the headline contents.  INFO is a plist used as
  a communication channel."
  (if (not (org-element-property :HIDE headline))
      (org-export-with-backend 'gfm headline contents info)
    (let ((level (number-to-string (+ (org-export-get-relative-level headline info)
				       (1- (plist-get info :md-toplevel-hlevel)))))
	  (title (org-export-data (org-element-property :title headline) info))
	  (style (plist-get info :md-headline-style)))
	(concat "<details>\n<summary><h"  level ">" title "</h" level "></summary>\n\n"
		contents "\n</details>\n\n"))))


(org-export-define-derived-backend 'my-gfm 'gfm
  :translate-alist '((src-block . my-gfm-src-block)
		     (headline . my-gfm-headline))
  :menu-entry
  '(?G "Mod of gfm"
       ((?G "To temporary buffer"
	    (lambda (a s v b) (org-export-to-buffer 'my-gfm "*Org GFM Export*" a s v nil nil (lambda () (text-mode))))))))

(use-package org-transclusion
  :ensure t
  :after org)

(use-package python
  :config
  (setq python-cmd "uv run python")
  (setq gud-pdb-command-name "uv run python -m pdb")
  (defun python-shell-calculate-command () (format "%s %s" python-cmd python-shell-interpreter-args)))

(use-package eglot
  :ensure t
  :hook ((python-mode . eglot-ensure)
	 (python-ts-mode . eglot-ensure))
  :config
  (setq eldoc-echo-area-use-multiline-p nil)
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
		 . ,(eglot-alternatives '(("uv" "run" "--with" "python-lsp-ruff" "pylsp"))))))

(use-package corfu
  :ensure t
  :after orderless
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-separator ?\s)          ;; Orderless field separator
  (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  (corfu-echo-documentation t) ;; Disable documentation in the echo area
  (corfu-scroll-margin 5)        ;; Use scroll margin
  :init
  (global-corfu-mode) ; This does not play well in eshell if you run a repl)
  (define-key corfu-map (kbd "M-p") #'corfu-popupinfo-scroll-down) ;; corfu-next
  (define-key corfu-map (kbd "M-n") #'corfu-popupinfo-scroll-up))  ;; corfu-previous

(use-package ediff
  :custom
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (ediff-diff-options "-w")
  (ediff-split-window-function 'split-window-horizontally))

(setenv "JULIA_NUM_THREADS" "4")

(use-package julia-mode
  :ensure t)

(use-package julia-vterm
  :ensure t
  :hook (julia-mode . julia-vterm-mode))

(use-package ob-julia-vterm
  :ensure t)

(use-package eglot-jl
  :ensure t
  :config
  (eglot-jl-init))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values '((org-confirm-babel-evaluate))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
