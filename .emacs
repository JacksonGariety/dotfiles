;;;;;;;;;;;;;;;;;
;; Performance ;;
;;;;;;;;;;;;;;;;;

;; in spite of this:
;; https://bling.github.io/blog/2016/01/18/why-are-you-changing-gc-cons-threshold/
;; ...i've found that the only way to reliably prevent emacs from
;; skipping/jumping when scrolling is to set an ungodly high gc threshold.
;; yeah... high number
(setq gc-cons-threshold  most-positive-fixnum
      gc-cons-percentage 0.6)

;; not sure what this does but let's turn it off
(setq site-run-file nil)

;; This is consulted on every `require', `load' and various path/io functions.
;; You get a minor speed up by nooping this.
(unless noninteractive
  (setq file-name-handler-alist nil))

;; Emacs "updates" its ui more often than it needs to.
(setq idle-update-delay 1)

;; Disable bidirectional text rendering for a modest performance boost.
(setq-default bidi-display-reordering  'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; More performant rapid scrolling over unfontified regions.
(setq fast-but-imprecise-scrolling t)

;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font.
(setq frame-inhibit-implied-resize t)

;; HACK `tty-run-terminal-initialization' is *tremendously* slow for some
;;      reason. Disabling it completely could have many side-effects, so we
;;      defer it until later.
(unless (display-graphic-p)
  (advice-add #'tty-run-terminal-initialization :override #'ignore)
  (add-hook 'window-setup-hook
            (defun doom-init-tty-h ()
              (advice-remove #'tty-run-terminal-initialization #'ignore)
              (tty-run-terminal-initialization (selected-frame) nil t))))

;; byte compile func
(defun er-byte-compile-init-dir ()
  "Byte-compile all your dotfiles."
  (interactive)
  (byte-recompile-directory user-emacs-directory 0))

;;;;;;;;;;;;;;;;;;;
;; Inhibit stuff ;;
;;;;;;;;;;;;;;;;;;;

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode nil))
(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))
(setq inhibit-startup-screen            t
      menu-bar-mode                     nil
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init              t
      initial-major-mode                'fundamental-mode
      initial-scratch-message           nil)
(fset #'display-startup-echo-area-message #'ignore)
(add-hook 'emacs-startup-hook (lambda () (message "")))

;;;;;;;;;;;;;;;;;;;;;;;;
;; Package management ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(setq package-enable-at-startup nil)

(unless (and (file-exists-p (expand-file-name "elpa/archives/gnu" user-emacs-directory))
             (file-exists-p (expand-file-name "elpa/archives/melpa" user-emacs-directory)))
  (package-refresh-contents))

(defvar my-package-list '(no-littering use-package))

(dolist (package my-package-list)
  (unless (package-installed-p package)
    (message "Pre-installing %s" (symbol-name package))
    (package-install package)))

(dolist (package my-package-list)
  (message "Pre-loading %s" (symbol-name package))
  (require package))

(defvar use-package-verbose)
(defvar use-package-always-ensure)
(setq use-package-verbose t
      use-package-always-ensure t)

(use-package paradox
  :config
  (paradox-enable))

;;;;;;;;;;;;;;;;;;;
;; GC Magic Hack ;;
;;;;;;;;;;;;;;;;;;;

(use-package gcmh
  :config
  (when (not noninteractive)
    (gcmh-mode +1)
    (with-eval-after-load 'gcmh
      (setq gcmh-idle-delay 10
            gcmh-verbose nil
            gcmh-high-cons-threshold 100000000)
      (add-function :after after-focus-change-function #'gcmh-idle-garbage-collect))))

;;;;;;;;;;;;;
;; General ;;
;;;;;;;;;;;;;

;; ;; Used to show some useful evil stuff one startup.
;; ;; Now I just keep it here:
;; (setq initial-scratch-message ";; ^    first non-whitespace
;; 'x   go to mark
;; mx   set mark
;; '.   last changed line
;; zz   center cursor line
;; C-o  previous location
;; C-i  next location
;; #    previous token under cursor
;; *    next token under cursor
;; cc   replace line
;; C    change to end of line
;; D    delete to end of line
;; cib  change in block (or symbol)
;; cil change in line
;; cia change in argument
;; I    insert at first non-whitespace"
;; g d  jump to definition
;; C-x C-e  iedit
;; L    next argument
;; H    previous argument
;; C-x RET evil marks)
;; General

(global-font-lock-mode +1)   ;; for all buffers
(global-visual-line-mode +1) ;; word-wrap
(show-paren-mode +1)         ;; show matching parentheses
(display-time) ;; in mode-line
(size-indication-mode +1)
(column-number-mode +1) ;; Column numbers in modeline
(delete-selection-mode +1) ;; Replace selection
(fset 'yes-or-no-p 'y-or-n-p) ;; Changes all yes/no questions to y/n type
(save-place-mode +1)
(blink-cursor-mode 0)
(window-divider-mode +1)
(electric-pair-mode +1)
(set-locale-environment "en_US.UTF-8")
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
(set-face-inverse-video 'vertical-border nil)
(set-face-background 'vertical-border "black")
(set-face-foreground 'vertical-border (face-background 'vertical-border))
(setq-default fill-column 80)
(setq comment-auto-fill-only-comments t)
(add-hook 'prog-mode-hook 'auto-fill-mode)

;; UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; Sane defaults

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq frame-background-mode (quote dark))
(defvar apropos-do-all)
(defvar compilation-message-face)
(setq garbage-collection-messages     nil
      echo-keystrokes                 0.15
      text-quoting-style              'grave
      user-full-name                  "Coleman Gariety"
      load-prefer-newer               t
      line-number-display-limit-width 2000000
      ;; initial-buffer-choice           t
      sentence-end-double-space       nil
      scroll-conservatively           most-positive-fixnum
      vc-follow-symlinks              t
      vc-make-backup-files            t
      delete-by-moving-to-trash       t
      compilation-message-face        (quote default)
      visible-bell                    nil
      visible-cursor                  nil
      ring-bell-function              'ignore
      scroll-error-top-bottom         t ;; Pgdn & Pgup work properly
      large-file-warning-threshold    (* 1024 1024) ;; 1mb
      mode-require-final-newline      t ;; Newlines
      create-lockfiles                nil ;; no lockfiles in server mode
      apropos-do-all                  t
      auto-mode-case-fold             nil)

;; Indentation

(setq-default indent-tabs-mode nil
              c-basic-indent   2
              c-basic-offset   2
              tab-width        2)
(defvar tab-width)
(defvar js-indent-level)
(defvar css-indent-offset)
(defvar c-basic-offset)
(setq css-indent-offset 2
      tab-width         2
      js-indent-level   2
      c-basic-offset    2)

;; Inhibit annoying "when done with this frame..." message
(add-hook 'after-make-frame-functions
          (lambda (&optional frame)
            (with-selected-frame (or frame (selected-frame))
              (setq inhibit-message t)
              (run-with-idle-timer 0 nil (lambda () (setq inhibit-message nil))))))

;;;;;;;;;;;;;;;
;; Dashboard ;;
;;;;;;;;;;;;;;;

(use-package all-the-icons)
(use-package dashboard
  :init
  (setq initial-buffer-choice       (lambda ()
                                      (get-buffer "*dashboard*"))
        dashboard-center-content    t
        dashboard-set-file-icons    t
        dashboard-set-heading-icons t
        dashboard-startup-banner    3
        dashboard-page-separator    "\n\n"
        dashboard-set-init-info     nil
        dashboard-items             '((recents   . 5)
                                      (projects  . 5)))
  :config
  (dashboard-setup-startup-hook))

;;:;;;;;;;;;;;;:
;; Move lines ;;
;;;;;;;;;;;;;;;;

;; (defun move-line-or-region (arg)
;;   "ARG: See https://github.com/syl20bnr/spacemacs/issues/5365."
;;   (interactive "P")
;;   (if (or (not arg) (>= arg 0))
;;       (let ((reg-or-lin (if (region-active-p) "'>" "."))
;;             (reactivate-region (if (region-active-p) "gv=gv" ""))
;;             (num (if arg arg 1)))
;;         (execute-kbd-macro
;;          (concat ":m" reg-or-lin "+" (number-to-string num) (kbd "RET") reactivate-region)))
;;     (backward-move-line-or-region (- arg))))

;; (defun backward-move-line-or-region (arg)
;;   "ARG: See https://github.com/syl20bnr/spacemacs/issues/5365."
;;   (interactive "P")
;;   (if (or (not arg) (>= arg 0))
;;       (let ((reg-or-lin (if (region-active-p) "'<" "."))
;;             (reactivate-region (if (region-active-p) "gv=gv" ""))
;;             (num (if arg (+ arg 1) 2)))
;;         (execute-kbd-macro
;;          (concat ":m" reg-or-lin "-" (number-to-string num) (kbd "RET") reactivate-region)))
;;     (move-line-or-region (- arg))))

;;;;;;;;;;
;; Evil ;;
;;;;;;;;;;

(use-package evil
  :preface
  (setq evil-want-keybinding                 nil
        evil-cross-lines                     t
        evil-symbol-word-search              t
        evil-shift-width                     2
        evil-ex-interactive-search-highlight 'selected-window)
  (setq-default evil-kill-on-visual-paste nil) ;; doesn't work :(
  :config
  (general-define-key
   :keymaps '(normal motion)
   "<remap> <evil-next-line>" 'evil-next-visual-line
   "<remap> <evil-previous-line>" 'evil-previous-visual-line
   "<remap> <evil-next-line>" 'evil-next-visual-line
   "<remap> <evil-previous-line>" 'evil-previous-visual-line)
  (general-define-key
   :keymaps '(normal insert visual)
   ;; "C-k" 'backward-move-line-or-region ;; too easy
   ;; "C-j" 'move-line-or-region          ;; to mess up
   "C-n" 'evil-next-line
   "C-p" 'evil-previous-line
   "C-a" 'evil-beginning-of-line
   "C-e" 'evil-end-of-line)
  (general-define-key
   :keymaps 'global
   "M-k" 'evil-window-up
   "M-j" 'evil-window-down
   "M-h" 'evil-window-left
   "M-l" 'evil-window-right
   "M-K" 'evil-window-split
   "M-J" 'evil-window-split
   "M-H" 'evil-window-vsplit
   "M-L" 'evil-window-vsplit
   "C-q" 'delete-window)
  (evil-mode +1))

;; ;; old evil config
;; (define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)

;; (define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
;; (define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
;; (define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
;; (define-key evil-normal-state-map (kbd "C-n") 'evil-next-line)
;; (define-key evil-insert-state-map (kbd "C-n") 'evil-next-line)
;; (define-key evil-visual-state-map (kbd "C-n") 'evil-next-line)
;; (define-key evil-normal-state-map (kbd "C-p") 'evil-previous-line)
;; (define-key evil-insert-state-map (kbd "C-p") 'evil-previous-line)
;; (define-key evil-visual-state-map (kbd "C-p") 'evil-previous-line)
;; (define-key evil-normal-state-map (kbd "C-a") 'evil-beginning-of-line)
;; (define-key evil-visual-state-map (kbd "C-a") 'evil-beginning-of-line)
;; (define-key evil-normal-state-map (kbd "C-e") 'evil-end-of-line)
;; (define-key evil-visual-state-map (kbd "C-e") 'evil-end-of-line)
;; (define-key global-map (kbd "M-k") 'evil-window-up)
;; (define-key global-map (kbd "M-j") 'evil-window-down)
;; (define-key global-map (kbd "M-h") 'evil-window-left)
;; (define-key global-map (kbd "M-l") 'evil-window-right)
;; (define-key global-map (kbd "M-K") 'evil-window-split)
;; (define-key global-map (kbd "M-J") 'evil-window-split)
;; (define-key global-map (kbd "M-H") 'evil-window-vsplit)
;; (define-key global-map (kbd "M-L") 'evil-window-vsplit)
;; (define-key global-map (kbd "C-q") 'delete-window)

(unless (display-graphic-p)
  (use-package evil-terminal-cursor-changer
    :after evil
    :init
    (setq evil-normal-state-cursor 'box
          evil-motion-state-cursor 'box
          evil-visual-state-cursor 'hollow ;; does not work in kitty
          evil-insert-state-cursor 'bar
          evil-emacs-state-cursor  'hbar)
    :config
    (etcc-on)))

(use-package evil-string-inflection
  :config
  (define-key evil-normal-state-map "g~" 'evil-operator-string-inflection))

;; ;; couldn't get it to work I think
;; (use-package rotate-text
;;   :load-path "~/Git/rotate-text.el"
;;   :init
;;   (autoload 'rotate-text "rotate-text" nil t)
;;   (autoload 'rotate-text-backward "rotate-text" nil t)
;;   (push '("true" "false") rotate-text-words))

(use-package evil-textobj-column)
(use-package evil-textobj-line)
(use-package evil-textobj-syntax)
(use-package evil-indent-plus)
(use-package evil-embrace)
(use-package exato)

;; ;; just don't know how to work it
;; (use-package targets
;;   :load-path "~/Git/targets.el/targets.el"
;;   :init
;;   (setq targets-user-text-objects '((pipe "|" nil separator)
;;                                     (paren "(" ")" pair :more-keys "b")
;;                                     (bracket "[" "]" pair :more-keys "r")
;;                                     (curly "{" "}" pair :more-keys "c")))
;;   :config
;;   (targets-setup t
;;                  :inside-key nil
;;                  :around-key nil
;;                  :remote-key nil))

(use-package evil-exchange
  :config
  (evil-exchange-install))

(use-package evil-collection
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode +1))

;; (use-package evil-args
;;   :config
;;   (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
;;   (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)
;;   (define-key evil-normal-state-map "L" 'evil-forward-arg)
;;   (define-key evil-normal-state-map "H" 'evil-backward-arg)
;;   (define-key evil-motion-state-map "L" 'evil-forward-arg)
;;   (define-key evil-motion-state-map "H" 'evil-backward-arg)
;;   (define-key evil-normal-state-map "H" 'evil-backward-arg)
;;   (define-key evil-motion-state-map "L" 'evil-forward-arg))

;; this makes the dreaded
;; startup-screen-flash return :/
(use-package vim-empty-lines-mode
  :config
  (global-vim-empty-lines-mode))

;;;;;;;;;;;;;;;;;
;; Auto-compie ;;
;;;;;;;;;;;;;;;;;

(use-package auto-compile
  :init
  (setq auto-compile-display-buffer nil
        auto-compile-mode-line-counter t)
  :config
  (auto-compile-on-load-mode +1)
  (auto-compile-on-save-mode +1)
  (setq auto-compile-display-buffer               nil
        auto-compile-mode-line-counter            t
        auto-compile-source-recreate-deletes-dest t
        auto-compile-toggle-deletes-nonlib-dest   t
        auto-compile-update-autoloads             t))

;;;;;;;;;;;;;;;
;; which-key ;;
;;;;;;;;;;;;;;;

(use-package which-key
  :config
  (which-key-mode +1))

;;:;;;;;;;;;;;;;;;;;;
;; Misc. Languages ;;
;;;;;;;;;;;;;;;:;;;;;

(use-package json-mode
  :mode ("\\.json\\'" . json-mode)
  :init
  (setq json-reformat:indent-width 2))

(use-package yaml-mode
  :mode ("\\.yml\\'" . yaml-mode))

(use-package graphql-mode
  :mode ("\\.graphql\\'" . graphql-mode))

;; (use-package psc-ide)
(use-package purescript-mode
  :mode ("\\.psc\\'" . purescript-mode))

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package haskell-mode
  :mode "\\.hs\\'")

;; javsacript + typescript
(use-package web-mode
  :mode (("\\.tsx\\'"  . web-mode)
         ("\\.ts\\'"  . web-mode)
         ("\\.jsx\\'"  . web-mode)
         ("\\.js\\'"  . web-mode))
  :init
  (setq web-mode-code-indent-offset                 2
        web-mode-markup-indent-offset               2
        web-mode-css-indent-offset                  2
        web-mode-enable-html-entities-fontification t)
  :config
  (let ((types '("javascript" "jsx")))
    (setq web-mode-comment-formats
          (cl-remove-if (lambda (item) (member (car item) types))
                        web-mode-comment-formats))
    (dolist (type types)
      (push (cons type "//") web-mode-comment-formats))))

(use-package indium)

;;;;;;;;;;;;;;;;;;
;; Code Folding ;;
;;;;;;;;;;;;;;;;;;

(use-package origami
  :config
  (global-origami-mode +1)
  (global-set-key (kbd "M-o") 'origami-toggle-node))

;;;;;;;;;;;;;;;
;; Mode line ;;
;;;;;;;;;;;;;;;

(use-package doom-modeline
  :init
  (setq doom-modeline-buffer-encoding   nil
        doom-modeline-github            nil
        doom-modeline-icon              nil
        doom-modeline-project-detection 'project)
  (unless after-init-time
    ;; prevent flash of unstyles modeline at startup
    (setq-default mode-line-format nil))
  :config
  (doom-modeline-mode +1))

;;;;;;;;;;;;;;;;;;;
;; Expand region ;;
;;;;;;;;;;;;;;;;;;;

(use-package expand-region
  :config
  (global-set-key (kbd "C-u") 'er/expand-region))

;; ;; broken
(use-package highlight-indent-guides
  :config
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-auto-enabled nil)
  ;; (add-hook 'prog-mode-hook #'highlight-indent-guides-auto-set-faces)
  (add-hook 'prog-mode-hook #'highlight-indent-guides-mode))

;; ;; can't use glyphs O_o ??
;; (use-package highlight-indentation
;;   :config
;;   (set-face-attribute 'highlight-indentation-face nil
;;                       :stipple (list 7 4 (string 16 0 0 0))
;;                       :inherit nil)

;;   (set-face-attribute 'highlight-indentation-current-column-face nil
;;                       :stipple (list 7 4 (string 16 0 0 0))
;;                       :inherit nil
;;                       :foreground "yellow")
;;   (add-hook 'prog-mode-hook 'highlight-indentation-mode))

;; ;; moves with cursor ???
;; (use-package indent-guide
;;   :config
;;   (indent-guide-global-mode))

;;;;;;:;;;;;;;;;
;; Easymotion ;;
;;;;;;;;;;;;;;;;

(use-package avy
  :init
  ;; See:
  ;; https://github.com/PythonNut/quark-emacs/blob/dev/modules/config-avy-easymotion.el
  (setq avy-keys  (eval-when-compile (string-to-list "jfkdlsaurieowncpqmxzb"))
        avy-style 'de-bruijn))

(use-package evil-easymotion
  :after avy)

(use-package general
  :after evil-easymotion
  :init
  (defvar general-override-states)
  (setq general-override-states '(insert
                                  emacs
                                  hybrid
                                  normal
                                  visual
                                  motion
                                  operator
                                  replace))
  :config
  (general-define-key
   :states '(normal visual motion)
   :keymaps 'override
   ;; there can be no better config
   "f" 'evilem-motion-find-char
   "F" 'evilem-motion-find-char-backward
   "t" 'evilem-motion-find-char-to
   "T" 'evilem-motion-find-char-to-backward))

;;;;;;;;;;;
;; Dired ;;
;;;;;;;;;;;

(use-package diredfl
  :config
  (diredfl-global-mode +1))

;; (use-package dired-subtree)

;;;;;;;;;;;;;;;;;
;; Completion  ;;
;;;;;;;;;;;;;;;;;

(use-package company
  :init
  (defvar company-dabbrev-downcase)
  (defvar company-dabbrev-ignore-case)
  (defvar company-dabbrev-code-other-buffers)
  (setq-local completion-ignore-case t)
  (setq company-minimum-prefix-length      2 ;; responsive > cpu cycles
        company-idle-delay                 0.0 ;; same
        company-tooltip-limit              10
        company-tooltip-flip-when-above    t
        company-tooltip-align-annotations  t
        ;; ;; nonde of these work O_o
        ;; completion-ignore-case             t
        ;; company-dabbrev-code-ignore-case   t
        ;; company-dabbrev-downcase           t
        ;; company-dabbrev-ignore-case        t
        ;; company-dabbrev-code-other-buffers t
        company-require-match              'never
        company-backends                   '(company-capf)
        company-frontends                  '(company-pseudo-tooltip-frontend
                                             company-echo-metadata-frontend
                                             company-tng-frontend))
  :config
  ;; don't persist company when switching back to normal mode
  (add-hook 'evil-normal-state-entry-hook #'company-abort)
  (add-hook 'after-init-hook 'global-company-mode)
  (general-define-key
   :keymaps 'company-active-map
   "<backtab>" 'company-select-previous ;; no back-cycle?
   "TAB"       'company-complete-common-or-cycle))

;; (use-package company-flx
;;   :after company
;;   :config
;;   (company-flx-mode +1))

;;;;;;;;;
;; Ivy ;;
;;;;;;;;;

(use-package counsel
  :init
  (let ((base-command "rg -i -M 120 --no-heading --line-number --color never %s"))
    (setq counsel-rg-base-command   base-command
          counsel-grep-base-command base-command))
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x RET") 'counsel-evil-marks)
  (global-set-key (kbd "M-y") 'counsel-yank-pop)
  (global-set-key (kbd "M-p") 'counsel-evil-registers)
  (global-set-key (kbd "C-x C-b") 'counsel-ibuffer)
  (global-set-key (kbd "C-x C-r") 'counsel-buffer-or-recentf)
  (counsel-mode +1))

(use-package request)
(use-package counsel-web)

(use-package projectile
  :init
  (setq projectile-enable-caching t))

(use-package counsel-projectile
  :init
  (setq counsel-projectile-sort-files t)
  :config
  (counsel-projectile-mode +1)
  (general-define-key
   :keymaps 'projectile-mode-map
   "C-c p" 'projectile-command-map
   "C-x C-j" 'counsel-projectile
   "C-x C-g" 'counsel-projectile-rg))

(use-package ivy
  :init
  (setq ivy-wrap                         t
        enable-recursive-minibuffers     t
        projectile-completion-system     'ivy
        ivy-magic-slash-non-match-action nil
        ivy-on-del-error-function        #'ignore
        ivy-use-virtual-buffers          t
        ivy-use-selectable-prompt        t
        ivy-count-format                 "(%d/%d) ")
  (setf (alist-get 't ivy-format-functions-alist)
        #'ivy-format-function-line)
  :config
  (ivy-mode +1)
  (global-set-key (kbd "C-x b") 'ivy-switch-buffer)
  (global-set-key (kbd "C-c v") 'ivy-push-view)
  (global-set-key (kbd "C-c V") 'ivy-pop-view)
  (defun ivy-resize--minibuffer-setup-hook ()
    (add-hook 'post-command-hook #'ivy-resize--post-command-hook nil t))
  (defun ivy-resize--post-command-hook ()
    (when ivy-mode
      (shrink-window (1+ ivy-height))))
  (add-hook 'minibuffer-setup-hook 'ivy-resize--minibuffer-setup-hook)
  (general-define-key
   :keymaps 'ivy-minibuffer-map
   "<ESC>" 'minibuffer-keyboard-quit
   "TAB" 'ivy-alt-done
   "C-l" 'ivy-calle)
  (general-define-key
   :keymaps '(counsel-imenu-map counsel-ag-map)
   "C-n" 'ivy-next-line-and-call
   "C-p" 'ivy-previous-line-and-call)
  (general-define-key
   :keymaps '(normal insert visual)
   "M-r" 'counsel-imenu)
  (define-key counsel-find-file-map (kbd "C-l") 'counsel-up-directory))

(use-package ivy-hydra)

;; (use-package ivy-rich
;;   :after ivy
;;   :init
;;   (setq ivy-rich-path-style 'abbrev)
;;   (setq ivy-rich-parse-remote-buffer nil)
;;   (setq ivy-switch-buffer-faces-alist nil)
;;   :config
;;   ;; Highlight buffers differently based on whether they're in the same project
;;   ;; as the current project or not.
;;   (let* ((plist (plist-get ivy-rich-display-transformers-list 'ivy-switch-buffer))
;;          (switch-buffer-alist (assq 'ivy-rich-candidate (plist-get plist :columns))))
;;     (when switch-buffer-alist
;;       (setcar switch-buffer-alist '+ivy-rich-buffer-name)))
;;   (ivy-set-display-transformer 'internal-complete-buffer nil)
;;   (ivy-rich-mode +1))

;; ;; doesn't match spaces for dashes why ???
;; (use-package flx
;;   :init
;;   (setq ivy-flx-limit 1000)
;;   :config
;;   ;; fuzzy matching in ivy
;;   (setq ivy-initial-inputs-alist nil)
;;   (setq ivy-re-builders-alist
;;         '((counsel-find-file  . ivy--regex-fuzzy)
;;           (counsel-projectile . ivy--regex-fuzzy)
;;           (t                  . ivy--regex-plus))))

;; we add this for sort-by-frequency
(use-package smex)

;; ;; show # of candidates in isearch
(use-package evil-anzu
  :after evil)

(use-package swiper
  :init
  (setq swiper-action-recenter t)
  :config
  (global-set-key (kbd "C-s") 'swiper-isearch)
  (global-set-key (kbd "C-x C-a") 'swiper-all))

;;;;;;;;;;;;;;;;
;; Copy/paste ;;
;;;;;;;;;;;;;;;;

(case system-type
  ('darwin (unless window-system
             (setq interprogram-cut-function
                   (lambda (text &optional push)
                     (let* ((process-connection-type nil)
                            (pbproxy (start-process "pbcopy"
                                                    "pbcopy"
                                                    "/usr/bin/pbcopy")))
                       (process-send-string pbproxy text)
                       (process-send-eof pbproxy))))))
  ('gnu/linux (progn
                (setq select-enable-clipboard t)
                (defun xsel-cut-function (text &optional push)
                  (with-temp-buffer
                    (insert text)
                    (call-process-region (point-min)
                                         (point-max)
                                         "xsel"
                                         nil
                                         0
                                         nil
                                         "--clipboard"
                                         "--input")))
                (defun xsel-paste-function()
                  (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))

                    (unless (string= (car kill-ring) xsel-output)
                      xsel-output)))
                (setq interprogram-cut-function 'xsel-cut-function)
                (setq interprogram-paste-function 'xsel-paste-function))))

;;;;;;;;;;;
;; Color ;;
;;;;;;;;;;;

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;;;;;;;;;;;;;;
;; Flycheck ;;
;;;;;;;;;;;;;;

(use-package flycheck
  :delight " ✓"
  :init
  (setq flycheck-check-syntax-automatically '(save))
  (setq flycheck-temp-prefix ".flycheck")
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc
                                             javascript-jshint))
  :config
  ;; (global-flycheck-mode +1)
  ;; disable jshint since we prefer eslint checking
  ;; customize flycheck temp file prefix
  (setq-default flycheck-temp-prefix ".flycheck"))

;;;;;;;;:
;; LSP ;;
;;;;;;;;;

(use-package lsp-mode
  :commands lsp
  :hook ((rust-mode . lsp)
         (web-mode  . lsp)
         (lsp-mode  . lsp-enable-which-key-integration))
  :init
  (defvar read-process-output-max)
  (setq read-process-output-max            3145728 ;; 3mb max packet size
        lsp-auto-guess-root                t
        lsp-keep-workspace-alive           nil
        lsp-keymap-prefix                  "C-l"
        lsp-prefer-capf                    nil
        lsp-enable-completion-at-point     nil
        lsp-enable-folding                 nil
        lsp-enable-file-watchers           nil
        lsp-enable-text-document-color     nil
        lsp-enable-semantic-highlighting   nil
        lsp-enable-indentation             nil
        lsp-enable-on-type-formatting      nil
        lsp-flycheck-live-reporting        nil ;; was causing seizures
        lsp-signature-auto-activate        nil
        lsp-signature-render-documentation nil
        lsp-ui-doc-enable                  nil ;; too big
        lsp-ui-sideline-ignore-duplicate   t
        lsp-enable-symbol-highlighting     t
        lsp-idle-delay                     0.5)
  :config
  (setq-default company-lsp-cache-candidates 'auto))

(use-package lsp-ui
  :requires lsp-mode)

;; (use-package lsp-ivy
;;   :requires lsp-mode)

;; ;; So slow!
(use-package company-lsp
  :commands company-lsp
  :config
  (push 'company-lsp company-backends))

;; (use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package treemacs)
(use-package lsp-treemacs)
(use-package dap-mode)
(use-package dap-chrome
  :ensure nil
  :config
  (dap-register-debug-template
   "default"
   (list :type "chrome"
         :cwd nil
         :mode "url"
         :request "launch"
         :webRoot nil
         :url "http://localhost:3000"
         :name "Chrome Browse URL"
         :runtimeExecutable "/usr/bin/google-chrome-stable")))
;; (use-package dap-node
;;   :ensure nil
;;   :requires dap-mode)

;;;;;;;;;;;;;;;;;;;;;
;; Highlight stuff ;;
;;;;;;;;;;;;;;;;;;;;;

;; (use-package rainbow-delimiters
;;   :hook (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo
  :config
  (global-hl-todo-mode +1))

(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))

;;;;;;;;;
;; Git ;;
;;;;;;;;;

(use-package gitattributes-mode)
(use-package gitconfig-mode)
(use-package gitignore-mode)
;; (use-package magit)
(use-package git-timemachine)

;;;;;;;;;
;; IRC ;;
;;;;;;;;;

(setq my-credentials-file "~/.private.el")

(defun my-nickserv-password (server)
  (with-temp-buffer
    (insert-file-contents-literally my-credentials-file)
    (plist-get (read (buffer-string)) :nickserv-password)))

(use-package circe
  :init
  (setq circe-network-options
        '(("Freenode"
           :tls t
           :nick "clmg"
           :sasl-username "clmg"
           :sasl-password my-nickserv-password))))

(use-package circe-notifications
  :config
  ;; (eval-after-load "circe-notifications"
  ;;   '(setq circe-notifications-watch-strings
  ;;       '("people" "you" "like" "to" "hear" "from")))
  (autoload 'enable-circe-notifications "circe-notifications" nil t)
  (add-hook 'circe-server-connected-hook 'enable-circe-notifications))

;;;;;;;;;;;;;;
;; Hardcore ;;
;;;;;;;;;;;;;;

(use-package jammer
  :hook (prog-mode . jammer-mode)
  :init
  (setq jammer-repeat-type                'linear
        jammer-repeat-allowed-repetitions 7))

;;;;;;;;;;;;;;;;;;;
;; ido-yes-or-no ;;
;;;;;;;;;;;;;;;;;;;

(use-package ido-yes-or-no
  :config
  (ido-yes-or-no-mode))

;;;;;;;;;
;; Org ;;
;;;;;;;;;

(use-package org-brain)

;;;;;;;;;;;;;;;;;;
;; Smart Parens ;;
;;;;;;;;;;;;;;;;;;

;; (use-package smartparens
;;   :config
;;   (smartparens-global-mode))

;; (use-package smart-jump
;;   :config
;;   (smart-jump-setup-default-registers))

;;;;;;;;;
;; RSS ;;
;;;;;;;;;

;; (use-package elfeed
;;   :config
;;   (setq elfeed-feeds
;;         '("https://oremacs.com/atom.xml"
;;           "https://medium.com/feed/@gcanti")))
