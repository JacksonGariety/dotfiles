;;;; package --- Summary
;;; Commentary: Custom

;;;;;;;;;;;;
;; Custom ;;
;;;;;;;;;;;;

;;;; Code:
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-term-color-vector
   [unspecified "#2d2a2e" "#ff6188" "#a9dc76" "#ffd866" "#78dce8" "#ab9df2" "#ff6188" "#fcfcfa"] t)
 '(anzu-cons-mode-line-p nil)
 '(auto-compile-mode-line-counter t)
 '(auto-compile-use-mode-line 'mode-line-modified)
 '(package-selected-packages
   '(circe-notifications pass skewer-mode exec-path-from-shell rjsx-mode dap-node evil-string-inflection dap-mode lsp-treemacs lsp-ivy lsp-ui lsp-mode prettier-js gcmh highlight-numbers tide use-package bind-key rust-mode web-mode which-key smex smartparens purescript-mode paradox origami no-littering magit json-mode ivy-rich iedit hl-todo haskell-mode go-mode git-timemachine general exato evil-textobj-syntax evil-textobj-line evil-textobj-column evil-terminal-cursor-changer evil-matchit evil-indent-plus evil-exchange evil-embrace evil-easymotion evil-collection evil-args evil-anzu elfeed doom-themes doom-modeline diredfl dired-hacks-utils counsel-projectile circe auto-compile))
 '(paradox-github-token t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-candidate-face ((t (:inherit popup-face :background "black" :foreground "#073642"))))
 '(ac-completion-face ((t (:foreground "brightgreen" :underline nil))))
 '(ac-selection-face ((t (:inherit popup-menu-selection-face :background "black" :foreground "#2aa198"))))
 '(avy-lead-face ((t (:background "inherit" :foreground "red" :weight bold))))
 '(avy-lead-face-0 ((t (:inherit avy-lead-face :background "inherit" :foreground "#FF6666"))))
 '(avy-lead-face-1 ((t (:inherit avy-lead-face :background "brightblack" :foreground "brightgreen"))))
 '(avy-lead-face-2 ((t (:inherit avy-lead-face :background "inherit" :foreground "#FF9999"))))
 '(counsel-variable-documentation ((t (:inherit nil))))
 '(doom-modeline-bar-inactive ((t nil)))
 '(doom-modeline-battery-normal ((t (:inherit mode-line :background "black" :weight normal))))
 '(flycheck-error ((t (:background "red" :foreground "white" :underline (:color "#ff6655" :style wave)))))
 '(flycheck-warning ((t (:background "red" :foreground "white" :underline (:color "#ECBE7B" :style wave)))))
 '(font-lock-comment-face ((t (:foreground "#525252" :slant italic))))
 '(font-lock-doc-face ((t (:inherit font-lock-comment-face :foreground "color-239"))))
 '(highlight-indent-guides-character-face ((t (:foreground "black"))))
 '(highlight-indent-guides-even-face ((t (:foreground "black"))))
 '(highlight-indent-guides-odd-face ((t (:foreground "brightgreen"))))
 '(hl-line ((t (:background "black"))))
 '(indent-guide-face ((t (:inherit hl-line :background "brightblack" :foreground "black"))))
 '(ivy-separator ((t (:inherit nil))))
 '(ivy-virtual ((t (:inherit nil :foreground "#ddd"))))
 '(line-number ((t (:inherit default :foreground "#073642" :strike-through nil :underline nil :slant normal :weight normal))))
 '(line-number-current-line ((t (:inherit (hl-line defaultblack) :foreground "#657b83" :strike-through nil :underline nil :slant normal :weight normal))))
 '(linum ((t (:inherit default :foreground "#a9a1e1" :strike-through nil :underline nil :slant normal :weight normal))))
 '(mode-line ((t (:background "black" :foreground "#bfbfbf" :box nil))))
 '(mode-line-inactive ((t (:background "black" :foreground "#525252" :box nil))))
 '(popup-scroll-bar-background-face ((t (:background "brightcyan"))))
 '(popup-scroll-bar-foreground-face ((t (:background "brightgreen"))))
 '(show-paren-match ((t (:background "black" :foreground "#ff6655"))))
 '(window-divider ((t (:inherit nil :background "black" :foreground "black")))))
