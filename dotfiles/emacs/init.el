;; -*- lexical-binding: t; -*-

;; ===========================
;; *** Dependencies ***
;; ===========================
;; - Emacs 29 minimum (treesitter, LSP)
;; - rg (ripgrep)
;; - ag (silver searcher)
;; - fd (faster find)
;; - fzf (fuzzy finder)

;; default package manager (will migrate to elpaca)
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

;; better GC management (optional)
;; run first before packages
(use-package gcmh
  :ensure t
  :init
  (gcmh-mode 1))

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

;; window dividers
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode 1)

;; or whatever nerd font you want
(set-face-attribute 'default nil :font "Lilex Nerd Font Mono-14")

;; -------------------
;; Theme and modeline
;; -------------------
(use-package doom-themes
  :ensure t
  :config
  (doom-themes-org-config)
  (load-theme 'doom-lantern t))

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
  (doom-modeline-hud t)          ; progress bar in file
  (doom-modeline-indent-info t)) ; show indentation settings


;; ===========================
;; Hydra
;; ===========================
(use-package hydra
  :defer t)

(defhydra hydra-theme-switcher (:hint nil)
  "
     Dark                ^Light^
----------------------------------------------
_1_ doom-lantern     _z_ one-light 
_2_ doom-rouge       _x_ doom-ayu-light
_3_ doom-gruvbox     _c_ doom-gruvbox-light
_4_ doom-sourcerer   _c_ doom-gruvbox-light
_5_ doom-tokyo-night _v_ flatwhite
_6_ old-hope         _b_ tomorrow-day
_7_ doom-homage-black    ^
_8_ peacock              ^
_9_ doom-feather-dark    ^
_q_ quit                 ^
^                        ^
"

  ;; Dark
  ("1" (load-theme 'doom-lantern)	     "one")
  ("2" (load-theme 'doom-rouge)		     "rouge")
  ("3" (load-theme 'doom-gruvbox)	     "gruvbox")
  ("4" (load-theme 'doom-sourcerer)	     "sourcerer")
  ("5" (load-theme 'doom-tokyo-night)	     "tokyo-night")
  ("6" (load-theme 'doom-old-hope)	     "old-hope")
  ("7" (load-theme 'doom-homage-black)	     "homage-black")
  ("8" (load-theme 'doom-peacock)	     "peacock")
  ("9" (load-theme 'doom-feather-dark)	     "feather-dark")

  ;; Light
  ("z" (load-theme 'doom-one-light)	     "one-light")
  ("x" (load-theme 'doom-ayu-light)	     "ayu-light")
  ("c" (load-theme 'doom-gruvbox-light)	     "gruvbox-light")
  ("v" (load-theme 'doom-flatwhite)	     "flatwhite")
  ("b" (load-theme 'doom-opera-light)	     "opera-light")
  ("q" nil))


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


;; clear buffer and non buffer highlighting
(use-package solaire-mode
  :ensure t
  :hook (after-init . solaire-global-mode))


;; auto resize panes on window switch
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
  (setq olivetti-body-width 100)  ;; makes the writing area around 100 columns wide

  :config
  ;; optionally enable olivetti-mode automatically in text and org modes
  ;;(add-hook 'text-mode-hook #'olivetti-mode)
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
  (setq evil-undo-system 'undo-redo) ;; use native undo-redo
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

;; more accurate f & t
(use-package evil-snipe
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode +1))

;; leap/flash.nvim functionality
(use-package avy)

;; mode colors
(setq evil-emacs-state-cursor    '("#649bce" box))
(setq evil-normal-state-cursor   '("#ebcb8b" box))
(setq evil-operator-state-cursor '("#649bce" hollow))
(setq evil-visual-state-cursor   '("#677691" box))
(setq evil-insert-state-cursor   '("#eb998b" (bar . 2)))
(setq evil-replace-state-cursor  '("#eb998b" hbar))
(setq evil-motion-state-cursor   '("#ad8beb" box))


;; -----------------
;; Treesitter setup
;; -----------------
;; treesitter grammars don't work on windows
;;(use-package treesit-auto
;;  :custom
;;  (treesit-auto-install 'prompt) ; prompt to install missing grammars
;;  :config
;;  (treesit-auto-add-to-auto-mode-alist 'all)  ; map all major modes to their tree-sitter versions
;;  (global-treesit-auto-mode)) ; enable treesit-auto globally


;; ---------------------------------------------
;; Project management (built-in project.el)
;; ---------------------------------------------
(use-package project
  :ensure nil ;; built-in
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

;; Harpoon, quick-switch most common files
(use-package harpoon
  :ensure t
  :defer t)

;; ---------------------------------------------
;; Session Persistence (easysession.el)
;; ---------------------------------------------
(use-package easysession
  :ensure t
  :custom
  (easysession-mode-line-misc-info t) ;; display in mode-line
  (easysession-save-interval (* 10 60)) ;; save the session every 10 minutes
  :init
  ;; load the session (including geometry) at startup
  (add-hook 'emacs-startup-hook #'easysession-load-including-geometry 102)
  ;; Start the autosave mode at startup
  (add-hook 'emacs-startup-hook #'easysession-save-mode 103)
  )



;; -------------------
;; Dashboard (Welcome)
;; -------------------
(use-package dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory))
  (setq dashboard-banner-logo-title "Welcome Back!")

  ;; Center it and keep it clean
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-set-file-icons nil)
  (setq dashboard-set-heading-icons nil)
  (setq dashboard-set-navigator nil)

  ;; --- custom face style for menu text ---
  (defface my/dashboard-menu-face
    '((t (:height 1.3 :weight bold :foreground "#87cefa")))
    "Face for dashboard menu options.")

  ;; --- custom Menu (text only, no icons) ---
  (setq dashboard-init-info
        (concat
         "\n"
         (propertize "  [p] Projects\n" 'face 'my/dashboard-menu-face)
         (propertize "  [r] Recent Files\n" 'face 'my/dashboard-menu-face)
         (propertize "  [m] Bookmarks\n" 'face 'my/dashboard-menu-face)
         (propertize "  [a] Agenda\n" 'face 'my/dashboard-menu-face)
         (propertize "  [q] Quit\n" 'face 'my/dashboard-menu-face)
         "\n"))

  (setq dashboard-items '()) ;; disable defaults
  (dashboard-setup-startup-hook)

  ;; --- keybindings ---
  (defun my/dashboard-open-projects ()
    (interactive)
    (call-interactively #'project-switch-project))

  (defun my/dashboard-open-recents ()
    (interactive)
    (call-interactively #'recentf))

  (defun my/dashboard-open-bookmarks ()
    (interactive)
    (call-interactively #'bookmark-jump))

  (defun my/dashboard-open-agenda ()
    (interactive)
    (org-agenda-list))

  ;; Quit Emacs completely
  (defun my/dashboard-quit ()
    (interactive)
    (save-buffers-kill-emacs))

  (defun my/dashboard-setup-keys ()
    (local-set-key (kbd "p") #'my/dashboard-open-projects)
    (local-set-key (kbd "r") #'my/dashboard-open-recents)
    (local-set-key (kbd "m") #'my/dashboard-open-bookmarks)
    (local-set-key (kbd "a") #'my/dashboard-open-agenda)
    (local-set-key (kbd "q") #'my/dashboard-quit))

  (add-hook 'dashboard-mode-hook #'my/dashboard-setup-keys))

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
  :defer t
  :commands (magit-status))

;; ----------------
;; file tree (neotree)
;; ----------------
;; q: close, R: change root to current
;; J: enter new path, y: copy to path
;; c: create, d: delete, r: rename
;; h: hidden files, 
(use-package neotree
  :ensure t
  :defer t
  :config
  (setq neo-window-fixed-size nil) ;; makes neotree window resize flexibly
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)) ;; use icons in GUI, arrows in terminal
  ;; fit neotree window to contents
  (defun neotree--fit-window (type path c)
    "Resize neotree window to fit contents based on TYPE, with PATH and C unused."
    (when (eq type 'directory)
      (neo-buffer--with-resizable-window
       (let ((fit-window-to-buffer-horizontally t))
         (fit-window-to-buffer)))))
  (add-hook 'neo-enter-hook #'neotree--fit-window))


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
;; will add eat when its on melpa

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-key]      . helpful-key))

;; ------------------
;; Dired enhancements
;; ------------------
;; Keybindings:
;; dired-do-rename: R, dired-create-directory: +
;; dired-do-copy: C(specify copy dir), dired-do-delete: D
;; move: R (specify new dir with file name)
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; beautiful dired
(use-package diredfl
  :hook (dired-mode . diredfl-mode))

;; wdired
;; C-x C-q: enter wdired
;; C-c C-c: apply changes
;; C-c C-k: discard
(setq wdired-allow-to-change-permissions t) ;; change permissions
(setq wdired-create-parent-directories t)   ;; create directories
(setq wdired-allow-to-redirect-links t)     ;; change symlinks

;; use built-in dired-x to launch external apps
(require 'dired-x)
(setq dired-guess-shell-alist-user
      '(("\\.mp3\\'" "mpv")
        ("\\.mkv\\'" "mpv")
        ("\\.mp4\\'" "mpv")
        ("\\.jpe?g\\'" "imv")
        ("\\.png\\'" "imv")
        ("\\.gif\\'" "imv")
        ("\\.pdf\\'" "zathura")
        ("\\.epub\\'" "zathura")
        ("\\.html\\'" "Zen")
        ("\\.zip\\'" "unzip")))


;; ------------------
;; LSP
;; ------------------
(use-package eglot
  :defer t
  :hook ((prog-mode . eglot-ensure))
  :config
  (setq eglot-events-buffer-size 0) ; optional: disables the bulky *eglot-events* buffer
  (setq eglot-autoshutdown t)) ; optional: shutdown server when last buffer is closed

;; temporary lang support without LSP
(unless (package-installed-p 'kotlin-mode)
  (package-refresh-contents)
  (package-install 'kotlin-mode))
(add-to-list 'auto-mode-alist '("\\.kt\\'" . kotlin-mode))
(add-to-list 'auto-mode-alist '("\\.kts\\'" . kotlin-mode))



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
    ;; files
    "f"  '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "fs" '(save-buffer :which-key "save file")

    ;; dired
    "d"  '(:ignore t :which-key "dired")
    "dd" '(dired :which-key "open dired")                        ;; have to specify directory
    "dj" '(dired-jump :which-key "dired in current buffer")      ;; dont have to specify directory
    "dn" '(dired-create-directory :which-key "new directory")    ;; create in current directory
    "df" '(find-name-dired :which-key "get files by name")       ;; returns all files with filename
    "dg" '(find-grep-dired :which-key "get files by grep")       ;; returns all files with grep
    "df" '(dired-other-frame :which-key "dired other frame")     ;; open dired in another frame
    "ds" '(dired-sidebar-toggle-sidebar :which-key "dired other frame") ;; open dired in another frame

    ;; buffer
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")
    "bd" '(kill-this-buffer :which-key "kill buffer")
    "bl" '(list-buffers :which-key "list buffers")
    "bi" '(ibuffer :which-key "ibuffer")
    "bj" '(breadcrumb-jump :which-key "breadcrumb")

    ;; bookmarks
    "m"  '(:ignore t :which-key "bookmarks")
    "mm" '(bookmark-jump :which-key "jump to bookmark")
    "ms" '(bookmark-set :which-key "set bookmark")
    "md" '(bookmark-delete :which-key "delete bookmark")

    ;; easysession
    "e"  '(:ignore t :which-key "session")
    "ee" '(easysession-switch-to :which-key "switch")
    "ed" '(easysession-delete :which-key "delete")
    "er" '(easysession-reset :which-key "reset")
    "el" '(easysession-load :which-key "load current")
    "es" '(easysession-save :which-key "save")
    "eS" '(easysession-save-as :which-key "save as")

    ;; harpoon
    "h"  '(:ignore t :which-key "harpoon")
    "ha" '(harpoon-add-file :which-key "add file")
    "hh" '(harpoon-toggle-quick-menu :which-key "menu")
    "hH" '(harpoon-quick-menu-hydra :which-key "menu")
    "hn" '(harpoon-go-to-next :which-key "next")
    "hp" '(harpoon-go-to-prev :which-key "previous")
    "h1" '(harpoon-go-to-1 :which-key "file 1")
    "h2" '(harpoon-go-to-2 :which-key "file 2")
    "h3" '(harpoon-go-to-3 :which-key "file 3")
    "h4" '(harpoon-go-to-4 :which-key "file 4")

    ;; project
    "p"  '(:ignore t :which-key "projects")
    "pp" '(project-switch-project :which-key "switch project")
    "pa" '(my/add-project :which-key "switch project")
    "pf" '(project-find-file :which-key "find file in project")  ;; open floating
    "pd" '(project-dired :which-key "project dired")             ;; open dired at project root
    "pg" '(consult-ripgrep :which-key "search project (rg)")     ;; grep from root
    "pe" '(project-eshell :which-key "project eshell")

    ;; magit
    "g"  '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")

    ;; tree
    "t"  '(:ignore t :which-key "tree")
    "tt" '(neotree-toggle :which-key "toggle")

    ;; org
    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")

    ;; custom commands
    "c"  '(:ignore t :which-key "custom")
    "ct" '(hydra-theme-switcher/body :which-key "load themes")

    ;;window navigation (with resizing)
    "w"  '(:ignore t :which-key "windows")
    "wL" '(split-window-right :which-key "split vertical")
    "wJ" '(split-window-below :which-key "split horizontal")
    "wd" '(delete-window :which-key "delete window")
    "ww" '(other-window :which-key "other window")
    "wh" '(windmove-left :which-key "move left")
    "wl" '(windmove-right :which-key "move right")
    "wj" '(windmove-down :which-key "move down")
    "wk" '(windmove-up :which-key "move up")

    "z"  '(:ignore t :which-key "zen mode")
    "zz" '(olivetti-mode :which-key "olivetti mode")
    "zl" '(display-line-numbers-mode :which-key "toggle line")

    "SPC" '(execute-extended-command :which-key "M-x") ; A better M-x
    )


  (general-define-key
    :states '(normal visual)
    :keymaps 'override
    ;; avy bindings
    "z" 'avy-goto-char-timer ;; flash.nvim style
    "Z" 'avy-goto-word-1     ;; goto single char

    ;; window navigation (without resizing)
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right))


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
   '("7771c8496c10162220af0ca7b7e61459cb42d18c35ce272a63461c0fc1336015"
     "5c8a1b64431e03387348270f50470f64e28dfae0084d33108c33a81c1e126ad6"
     "13096a9a6e75c7330c1bc500f30a8f4407bd618431c94aeab55c9855731a95e1"
     "4b88b7ca61eb48bb22e2a4b589be66ba31ba805860db9ed51b4c484f3ef612a7"
     "6963de2ec3f8313bb95505f96bf0cf2025e7b07cefdb93e3d2e348720d401425"
     "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
     "1f292969fc19ba45fbc6542ed54e58ab5ad3dbe41b70d8cb2d1f85c22d07e518"
     "c3c135e69890de6a85ebf791017d458d3deb3954f81dcb7ac8c430e1620bb0f1"
     "7de64ff2bb2f94d7679a7e9019e23c3bf1a6a04ba54341c36e7cf2d2e56e2bcc"
     "0d2c5679b6d087686dcfd4d7e57ed8e8aedcccc7f1a478cd69704c02e4ee36fe"
     "ff24d14f5f7d355f47d53fd016565ed128bf3af30eb7ce8cae307ee4fe7f3fd0"
     "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8"
     "b9761a2e568bee658e0ff723dd620d844172943eb5ec4053e2b199c59e0bcc22"
     "f053f92735d6d238461da8512b9c071a5ce3b9d972501f7a5e6682a90bf29725"
     "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd"
     "720838034f1dd3b3da66f6bd4d053ee67c93a747b219d1c546c41c4e425daf93"
     "56044c5a9cc45b6ec45c0eb28df100d3f0a576f18eef33ff8ff5d32bac2d9700"
     "4990532659bb6a285fee01ede3dfa1b1bdf302c5c3c8de9fad9b6bc63a9252f7"
     "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098"
     "3f24dd8f542f4aa8186a41d5770eb383f446d7228cd7a3413b9f5e0ec0d5f3c0"
     "df6dfd55673f40364b1970440f0b0cb8ba7149282cf415b81aaad2d98b0f0290"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "93011fe35859772a6766df8a4be817add8bfe105246173206478a0706f88b33d"
     "b99ff6bfa13f0273ff8d0d0fd17cc44fab71dfdc293c7a8528280e690f084ef0"
     "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9"
     "83550d0386203f010fa42ad1af064a766cfec06fc2f42eb4f2d89ab646f3ac01"
     "5244ba0273a952a536e07abaad1fdf7c90d7ebb3647f36269c23bfd1cf20b0b8"
     "9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9"
     "b7a09eb77a1e9b98cafba8ef1bd58871f91958538f6671b22976ea38c2580755"
     "2ab8cb6d21d3aa5b821fa638c118892049796d693d1e6cd88cb0d3d7c3ed07fc"
     "a9eeab09d61fef94084a95f82557e147d9630fbbb82a837f971f83e66e21e5ad"
     "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "72d9086e9e67a3e0e0e6ba26a1068b8b196e58a13ccaeff4bfe5ee6288175432"
     "e8ceeba381ba723b59a9abc4961f41583112fc7dc0e886d9fc36fa1dc37b4079"
     "dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176"
     "f64189544da6f16bab285747d04a92bd57c7e7813d8c24c30f382f087d460a33"
     "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
     "b754d3a03c34cfba9ad7991380d26984ebd0761925773530e24d8dd8b6894738"
     "f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     default))
 '(doom-modeline-check-simple-format t nil nil "Customized with use-package doom-modeline")
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
