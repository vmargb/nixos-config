;; =========================================================
;; Performance tweaks to run first
;; =========================================================

(setq package-native-compile t)

(setq gc-cons-threshold 100000000) ;; 100mb

;; reset it to a more reasonable value after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000))) ;; 800kb

;; =========================================================
;; Essentials Doom-like setup
;; =========================================================

(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------
;; Basic UI and UX improvements
;; -----------------------------
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(setq ring-bell-function 'ignore)
(setq scroll-margin 5)
(setq make-backup-files nil)
(setq auto-save-default nil)

;; fonts and mixed-pitch fonts
(set-face-attribute 'default nil :font "JetBrains Mono-12")
(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode)
  :custom
  (mixed-pitch-set-height t))


;; -------------------
;; Theme and modeline
;; -------------------
(use-package doom-themes
  :ensure t
  :config
  (doom-themes-org-config)
  (load-theme 'doom-gruvbox t))

;; need to run M-x all-the-icons-install-fonts
(use-package all-the-icons
  :if (display-graphic-p))

;; run M-x nerd-icons-install-fonts
(use-package doom-modeline
  :ensure t
  :after all-the-icons
  :init
  (doom-modeline-mode 1)
  :custom
  ;; Core appearance
  (doom-modeline-height 30)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)

  ;; Useful indicators
  (doom-modeline-lsp t)          ; show LSP status
  (doom-modeline-vcs-max-length 20) ; shorter git branch
  (doom-modeline-checker-simple-format t) ; compact check status
  (doom-modeline-hud t)          ; progress bar
  (doom-modeline-indent-info t)) ; show indentation settings


;; -----------------------------
;; More UI/UX improvements
;; -----------------------------

;; colour coded delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; intelligent indent-guides
(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'column)
  (setq highlight-indent-guides-responsive 'stack)
  (set-face-foreground 'highlight-indent-guides-odd-face "#303030") ;; dark gray
  (set-face-foreground 'highlight-indent-guides-even-face "#505050") ;; light gray
  (setq highlight-indent-guides-delay 0))



;; buffer and non buffer highlighting
(use-package solaire-mode
  :ensure t
  :hook (after-init . solaire-global-mode)
  :config
  (push '(treemacs-window-background-face . solaire-default-face) solaire-mode-remap-alist)
  (push '(treemacs-hl-line-face . solaire-hl-line-face) solaire-mode-remap-alist))

;; auto resize panes
(use-package golden-ratio
  :ensure t
  :hook (after-init . golden-ratio-mode)
  :custom
  (golden-ratio-exclude-modes '(occur-mode)))

;; floating command window with posframe and multiform commands(built-in)
(use-package vertico-posframe
  :ensure t
  :after vertico
  :custom
  (vertico-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8)))
  (vertico-multiform-commands
   '((consult-line
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-top-center)
      (vertico-posframe-border-width . 10)
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (t posframe)))
  :config
  (vertico-posframe-mode 1))

;; padding around windows
(use-package spacious-padding
  :ensure t
  :hook (after-init . spacious-padding-mode))

;; distraction-free mode
(use-package olivetti
  :ensure t
  :init
  (setq olivetti-body-width 120)  ;; makes the writing area around 100 columns wide

  :config
  ;; optionally enable olivetti-mode automatically in text and org modes
  (add-hook 'text-mode-hook #'olivetti-mode)
  (add-hook 'org-mode-hook #'olivetti-mode)

  ;; You may want to enable visual-line-mode for soft line wrapping with Olivetti
  (add-hook 'olivetti-mode-hook #'visual-line-mode))

;; toggle line number, text scale automatically
(defun my/olivetti-setup ()
  "Disable line numbers and increase font size in Olivetti mode."
  (if olivetti-mode
      (progn
        (display-line-numbers-mode -1)  ;; disable line numbers
        (text-scale-set 2)) ;; increase font size by 2 steps
    ;; Restore defaults when disabling
    (display-line-numbers-mode 1)
    (text-scale-set 0)))

(add-hook 'olivetti-mode-hook #'my/olivetti-setup)


;; -----------------
;; Evil setup
;; -----------------
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-snipe
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode +1))


;; -----------------
;; Treesitter setup
;; -----------------
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt) ; prompt to install missing grammars
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)  ; map all major modes to their tree-sitter versions
  (global-treesit-auto-mode)) ; enable treesit-auto globally


;; ---------------------------------------------
;; Project management (using built-in project.el)
;; ---------------------------------------------
(use-package project
  :ensure nil  ;; built-in
  :custom
  (project-projects-directory "~/projects")
  (project-switch-commands
   '((project-find-file "Find file")
     (project-dired "Dired")
     (magit-project-status "Magit")
     (consult-ripgrep "Search")
     (project-eshell "Eshell")))
  :config
  ;; helper to manually add projects
  (defun my/add-project (dir) ;; M-x my/add-project
    "Manually add DIR to known projects."
    (interactive "DDirectory: ")
    (add-to-list 'project--list (list dir))
    (project--write-project-list)))


;; -------------------
;; Dashboard (welcome)
;; -------------------
(use-package dashboard
  :after all-the-icons
  :config
  ;; --- Aesthetics ---
  (setq dashboard-startup-banner 'official) ; or point this to image
  (setq dashboard-center-content t)      ; center the dashboard content
  (setq dashboard-show-shortcuts t)    ; hide or show shortcuts
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-footer-messages '("Hello World!"))

  ;; --- Content ---
  (setq dashboard-projects-backend 'project-el)
  (setq dashboard-items '((recents   . 5)
                          (agenda    . 7)
                          (projects  . 5)
                          (bookmarks . 3)))
  (dashboard-setup-startup-hook))

;; -------------
;; Mini Buffer Completion UX
;; -------------
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("C-c h" . consult-history)))

;; embark integration with consult
(use-package embark
  :bind
  (("C-." . embark-act)         ;; act on thing at point
   ("C-;" . embark-dwim))       ;; smarter default action
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))


(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.8))

(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  ((corfu-auto t)
   (corfu-auto-delay 0.1)
   (corfu-auto-prefix 2)
   (corfu-quit-no-match 'separator)))

;; cape integration with corfu
(use-package cape
  :init
  ;; add cape's completion functions to the global list
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; context indicator in code
(use-package breadcrumb
  :config (breadcrumb-mode))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init (all-the-icons-completion-mode))

;; ------
;; Magit
;; ------
(use-package magit
  :commands (magit-status))


;; ----------------
;; Treemacs (file tree)
;; ----------------
(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 30
        treemacs-collapse-dirs 3)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons)
  :config
  (treemacs-load-theme "all-the-icons"))

;; -------
;; Org mode
;; -------
(use-package org
  :config
  (setq org-startup-indented t
        org-hide-emphasis-markers t
        org-ellipsis " ▼"
        org-log-done 'time))

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autoemphasis t))


;; ------------------
;; Terminal and help
;; ------------------
(use-package vterm
  :commands vterm)

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-key]      . helpful-key))

;; ------------------
;; Dired enhancements
;; ------------------
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; beautiful dired
(use-package diredfl
  :hook (dired-mode . diredfl-mode))


;; ------------------
;; Power tools
;; ------------------
(use-package avy
  :bind (("C-:" . avy-goto-char-timer)
         ("C-'" . avy-goto-word-1)))

;; ------------------
;; LSP
;; ------------------
(use-package eglot
  :hook ((prog-mode . eglot-ensure))
  :config
  (setq eglot-events-buffer-size 0) ; optional: disables the bulky *eglot-events* buffer
  (setq eglot-autoshutdown t)) ; optional: shutdown server when last buffer is closed

;; ------------------
;; Keybindings (Doom-style)
;; ------------------
(use-package general
  :after evil
  :config
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "M-SPC")

  (my/leader-keys
    "f"  '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "fs" '(save-buffer :which-key "save file")

    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")
    "bd" '(kill-this-buffer :which-key "kill buffer")

    "s"  '(:ignore t :which-key "search")
    "ss" '(consult-ripgrep :which-key "search project (rg)")

    "p"  '(:ignore t :which-key "projects")
    "pp" '(project-switch-project :which-key "switch project")
    "pf" '(project-find-file :which-key "find file in project")
    "pd" '(project-dired :which-key "project dired")
    "pg" '(consult-ripgrep :which-key "search project (rg)")
    "pe" '(project-eshell :which-key "project eshell")

    "g"  '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")

    "t"  '(:ignore t :which-key "toggles")
    "tt" '(treemacs :which-key "toggle treemacs")

    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")

    "v"  '(:ignore t :which-key "vterm")
    "vv" '(vterm :which-key "open terminal")

    "SPC" '(consult-M-x :which-key "M-x")  ; A better M-x
    "w"   '(:ignore t :which-key "windows")
    "w/"  '(split-window-right :which-key "split vertical")
    "w-"  '(split-window-below :which-key "split horizontal")
    "wd"  '(delete-window :which-key "delete window")
    "ww"  '(other-window :which-key "other window")
    "z"   #'olivetti-mode)

  (general-define-key
    :states '(normal visual)
    :keymaps 'override
    ;; avy bindings
    "z" 'avy-goto-char-timer
    "Z" 'avy-goto-word-1

    ;; window navigation
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right

    ;; others
    "<f5>" 'treemacs))

;; window dividers
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode 1)


;; ------------------
;; General tweaks
;; ------------------
(setq scroll-conservatively 100)
(global-hl-line-mode t)
(save-place-mode 1)
(column-number-mode)
;; automatic bracket pairing
(electric-pair-mode 1)

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     default))
 '(doom-modeline-check-simple-format t nil nil "Customized with use-package doom-modeline")
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
