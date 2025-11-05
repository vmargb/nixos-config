;; -*- lexical-binding: t; -*-

;; ============================
;;    *** Dependencies ***
;; ============================
;; - Emacs 29 minimum (treesitter, LSP)
;; - rg (ripgrep)
;; - fd (faster find)
;; - fzf (fuzzy finder)
;; ============================

;;=====================================
;;         Essentials (tldr)
;;-------------------------------------
;;               NOTE:
;; search works best inside a project
;;       do: SPC p a (add project)
;;
;;    to create sessions/workspaces
;;       do: SPC e S
;;
;;-------------------------------------
;;        ** Goto file/dir **
;; goto open buffers:       spc b b
;; goto file in dir:        spc f f
;; goto file project:       spc f d
;; grep file project:       spc f g
;; goto line in file:       spc f l
;;
;; do ctrl-back to remove whole
;; directory names when searching
;;
;;        ** Motions **
;; goto anything:           z
;; goto char(current line): s
;; goto line number:        S
;; ====================================

;; -------------------------
;; Elpaca package manager
;; -------------------------
;; Bootstrap Elpaca
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(when (eq system-type 'windows-nt) ;; no symlink mode on windows only
  (elpaca-no-symlink-mode))

(elpaca elpaca-use-package ;; use-package support
  (elpaca-use-package-mode))

(setq use-package-always-ensure t) ; always ensure
(setq package-install-upgrade-built-in t) ; upgrade built-in packages

;; -------------------------
;; Better GC management (optional)
;; -------------------------
;; always load first
(use-package gcmh
  :init
  (gcmh-mode 1))

(setq clean-buffer-list-delay-general (* 60 60 24)) ; close buffers older than 1 day
(defun close-unused-buffers () ;; more extreme, close all not visible
  (interactive)
  (let ((buffers (buffer-list)))
    (dolist (buf buffers)
      (when (and (not (buffer-modified-p buf)) ;; not modified
                 (not (get-buffer-window buf 'visible))) ;; not visible
        (kill-buffer buf))))) ;; close


;; --------------------------------
;;          ** Misc **
;; --------------------------------

;; window dividers
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode 1)

(defun split-below-follow ()
  "Split the window horizontally and move focus to the new window."
  (interactive)
  (split-window-below)
  (other-window 1))

(defun split-right-follow ()
  "Split the window vertically and move focus to the new window."
  (interactive)
  (split-window-right)
  (other-window 1))
;; or whatever nerd font you want
(set-face-attribute 'default nil :font "Iosevka NF-14")

(setq imenu-auto-rescan t) ;; automatically rescan imenu for updates


;; --------------------------------
;;          ** LANGS **
;; --------------------------------
;; temporary lang support without LSP
(use-package kotlin-mode)
(add-to-list 'auto-mode-alist '("\\.kt\\'" . kotlin-mode))
(add-to-list 'auto-mode-alist '("\\.kts\\'" . kotlin-mode))

(use-package nix-mode
  :mode "\\.nix\\'")

(setq-default indent-tabs-mode t) ; Use tabs for indentation
(setq-default tab-width 4)        ; Tab is displayed as 4 spaces
(setq c-basic-offset 4)
(setq c-syntactic-indentation nil) ; disables advanced indent features that use spaces[web:1]

;; -------------------------
;; Theme and modeline (doom)
;; -------------------------
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
  :ensure t
  :config
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
)


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
  :hook (elpaca-after-init . solaire-global-mode))


;; auto resize panes on window switch
(use-package golden-ratio
  :ensure t
  :hook (elpaca-after-init . golden-ratio-mode)
  :custom
  (golden-ratio-exclude-modes '(occur-mode)))

; vertical candidates
(use-package vertico
  :init (vertico-mode))

;; floating command window with posframe and multiform commands(built-in)
(use-package vertico-posframe
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
  :hook (elpaca-after-init . spacious-padding-mode))

;; distraction-free mode
(use-package olivetti
  :ensure t
  :init
  (setq olivetti-body-width 80)  ;; makes the writing area 80 columns wide

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

;; e.g. ysiw", ds", cs"'
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :config
  (evil-commentary-mode))

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
;; Treesitter
;; -----------------
;; treesitter grammars don't work on windows
;;(use-package treesit-auto
;;  :custom
;;  (treesit-auto-install 'prompt) ; prompt to install missing grammars
;;  :config
;;  (treesit-auto-add-to-auto-mode-alist 'all)  ; map all major modes to their tree-sitter versions
;;  (global-treesit-auto-mode)) ; enable treesit-auto globally

;; -----------------
;; LSP
;; -----------------

;; non-lsp goto def
(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate) ;; xref-backend
  ;; override evil bindings for dumb-jump
  (define-key evil-normal-state-map (kbd "M-.") #'xref-find-definitions)
  (define-key evil-normal-state-map (kbd "M-,") #'xref-pop-marker-stack)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read) ;; use completing-read
)

;; ------
;; Magit
;; ------
(elpaca transient)
(elpaca (magit :wait t))

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
     (project-eshell "Eshell"))))

;; set a directory as a project by adding a marker in the root, only
;; adds the project to project list when you open a file in the project
(defun my/add-project-root-marker (&optional dir) ;; optional target directory
  "Create a .project.el marker file in dir or the current project root.
When called interactively, prompt for dir or default to current directory."
  (interactive "DDirectory for project root (Enter: current folder): ")
  (let* ((dir (or dir default-directory))
         (marker-file (expand-file-name ".project.el" dir)))
    (if (file-exists-p marker-file)
        (message "Marker already exists in %s" dir)
      (with-temp-buffer (write-file marker-file))
      (message "Added .project.el marker to %s" dir))))

;; let project.el identify root markers (emacs 29)
(setq project-vc-extra-root-markers '(".project.el" ".projectile"))
(setq xref-search-program 'ripgrep) ;; use ripgrep over grep

;; Harpoon, quick-switch between most common files
(use-package harpoon)

;; ---------------------------------------------
;; the difference between projects and sessions:
;; 'projects' are simply all your git repos
;; whereas 'sessions' are workspaces that persist
;; your window and buffer configurations for a project
;; ---------------------------------------------
;; Session Persistence (easysession.el)
;; ---------------------------------------------
(use-package easysession
  :custom
  (easysession-mode-line-misc-info t) ;; display in mode-line
  (easysession-save-interval (* 10 60)) ;; save the session every 10 minutes
  :init
  ;; load the session (including geometry) at startup
  (add-hook 'emacs-startup-hook #'easysession-load-including-geometry 102)
  ;; Start the autosave mode at startup
  (add-hook 'emacs-startup-hook #'easysession-save-mode 103))

;;return back to initial save point (optional)
;;(setq easysession-switch-to-save-session nil) ;; don't save current session when switching to another session

;; only automatically save the main session
;; other sessions require manual easysession-save
(defun my-easysession-only-main-saved ()
  "Only save the main session."
  (when (string= "main" (easysession-get-current-session-name))
    t))
(setq easysession-save-mode-predicate 'my-easysession-only-main-saved)

;; get a list of only the visible buffers
;; this is to modify the custom: easysession-buffer-list-function
(defun my-easysession-visible-buffer-list ()
  "return a list of all visible buffers in the current session, including buffers visible in windows or tab-bar tabs."
  (let ((visible-buffers '())) ;; set visible buffers to empty list
    (dolist (buffer (buffer-list)) ;; get open buffers
      (when (or
             (get-buffer-window buffer 'visible) ;; get visible buffers
             (and (bound-and-true-p tab-bar-mode) ;; check if tab bar is enabled
                  (fboundp 'tab-bar-get-buffer-tab) ;; check if get-buffer-tab is defined
                  (tab-bar-get-buffer-tab buffer t nil))) ;; adds visible tab buffers too
        (push buffer visible-buffers)))
    visible-buffers))

;; set easysession to only persist the visible buffers list
;; this saves space and lets us rely on harpoon for buffer switching instead
(setq easysession-buffer-list-function #'my-easysession-visible-buffer-list)


;; -------------------------
;; Welcome Screen (dashboard.el)
;; -------------------------
(use-package dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory))
  (setq dashboard-banner-logo-title "Welcome Back!")

  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-set-file-icons nil)
  (setq dashboard-set-heading-icons nil)
  (setq dashboard-set-navigator nil)

  ;; --- define custom face ---
  (defface my/dashboard-menu-face
    '((t (:height 1.3 :weight bold :foreground "#87cefa")))
    "Face for dashboard menu options.")

  ;; --- build custom menu ---
  (setq dashboard-init-info
        (concat
         "\n"
         "  [p] Projects\n"
         "  [r] Recent Files\n"
         "  [m] Bookmarks\n"
         "  [a] Agenda\n"
         "  [q] Quit\n"
         "\n"))

  ;; disable default sections
  (setq dashboard-items '())
  (dashboard-setup-startup-hook)

  ;; --- keybindings ---
  (defun my/dashboard-open-sessions () (interactive) (call-interactively #'easysession-switch-to))
  (defun my/dashboard-open-recents ()  (interactive) (call-interactively #'recentf))
  (defun my/dashboard-open-bookmarks () (interactive) (call-interactively #'bookmark-jump))
  (defun my/dashboard-open-agenda ()   (interactive) (org-agenda-list))
  (defun my/dashboard-quit ()          (interactive) (save-buffers-kill-emacs))

  (defun my/dashboard-setup-keys ()
    (local-set-key (kbd "p") #'my/dashboard-open-sessions)
    (local-set-key (kbd "r") #'my/dashboard-open-recents)
    (local-set-key (kbd "m") #'my/dashboard-open-bookmarks)
    (local-set-key (kbd "a") #'my/dashboard-open-agenda)
    (local-set-key (kbd "q") #'my/dashboard-quit))

  (add-hook 'dashboard-mode-hook #'my/dashboard-setup-keys))



;; -------------------------
;; Mini Buffer Completion UX
;; -------------------------

(use-package orderless
  :init
  (setq completion-styles '(orderless basic) ;; use orderless, then basic
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))
	;; show updates in a fuzzy style
	orderless-matching-styles '(orderless-flex orderless-literal orderless-regexp)))

;; icons for orderless matches
(use-package marginalia
  :init (marginalia-mode))

;; does the searching
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

;; -------
;; Org mode
;; -------
(use-package org
  :config
  (setq org-startup-indented t
        org-hide-emphasis-markers t
		org-pretty-entities t
		org-fontify-done-headline t
        org-ellipsis " ▼" ; ↴, ⬎, ⋱, …, ⤵, ➟, ➡
        org-log-done 'time)
  (require 'org-tempo))

;; org-temp: <s: src, <q: quote, <e: example

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

;; highlighting text in org-mode
(use-package org-remark
  :defer t
  :config
  (org-remark-global-tracking-mode +1) ;; makes it work globally on all buffers
  (org-remark-create "dark-pastel-green" '(:background "#3a6b35"))
  (org-remark-create "dark-pastel-blue" '(:background "#34547a"))
  (org-remark-create "dark-pastel-red" '(:background "#7a453a"))
  (org-remark-create "dark-pastel-purple" '(:background "#6a4b7b"))
  (org-remark-create "dark-pastel-orange" '(:background "#b56c49"))
  (org-remark-create "dark-pastel-teal" '(:background "#3b7165"))
  (org-remark-create "dark-pastel-brown" '(:background "#7b6046"))
  (org-remark-create "dark-pastel-yellow" '(:background "#a6954e"))
)


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

;; dired upgrade & file tree (dirvish.el)
(use-package dirvish
  :init
  (dirvish-override-dired-mode) ; activate dirvish globally instead of default dired
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ("m" "/mnt/"                       "Drives")))
)


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
    "ff" '(find-file :which-key "find file")                     ;; find file only in CURRENT dir
    "fd" '(consult-fd :which-key "find file")                    ;; find in ALL dirs from current
    "fg" '(consult-ripgrep :which-key "ripgrep")                 ;; grep in ALL dirs from current
    "fl" '(consult-line :which-key "consult line")               ;; see all '/' results
    "fj" '(breadcrumb-jump :which-key "breadcrumb")              ;; jump to contexts in file

    ;; dired
    "d"  '(:ignore t :which-key "dired")
    "dd" '(dired :which-key "open dired")                        ;; specify directory
    "dc" '(dired-jump :which-key "dired in current buffer")      ;; current buffer directory
    "dn" '(dired-create-directory :which-key "new directory")    ;; create in current directory or '+'
    "df" '(find-name-dired :which-key "get files by name")       ;; find file, in specific directory
    "dg" '(find-grep-dired :which-key "get files by grep")       ;; grep file, in specific directory
    "do" '(dired-other-frame :which-key "dired other frame")     ;; open dired in another frame

    ;; buffer
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")            ;; find file in opened buffers
    "bd" '(kill-this-buffer :which-key "kill buffer")
    "bi" '(ibuffer :which-key "ibuffer")
    "bc" '(clean-buffer-list :which-key "clean unused buffers")
    "bC" '(close-unused-buffers :which-key "clean buffers not visible")

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
    "pa" '(my/add-project-root-marker :which-key "add project")
    "pf" '(project-find-file :which-key "find file in project")  ;; find file in project
    "pd" '(project-dired :which-key "project dired")             ;; open dired at project root
    "pk" '(project-kill-buffers :which-key "kill project buffers") ;; open dired at project root
    "pe" '(project-eshell :which-key "project eshell")

    ;; magit
    "g"  '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")

    ;; tree
    "t"  '(:ignore t :which-key "tree")
    "tt" '(dirvish-side :which-key "toggle")

    ;; org
    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")
    "ol" '(org-store-link :which-key "current file link")

    ;; remark
    "r"  '(:ignore t :which-key "org")
    "rr" '(org-remark-mode :which-key "enable highlights")
    "rh" '(org-remark-mark :which-key "highlight")
    "ry" '(org-remark-mark-yellow :which-key "highlight yellow")
    "rl" '(org-remark-mark-line :which-key "mark line")
    "rd" '(org-remark-delete :which-key "delete highlight")
    "rc" '(org-remark-change :which-key "change highlight")

    ;; custom commands
    "c"  '(:ignore t :which-key "custom")
    "ct" '(hydra-theme-switcher/body :which-key "load themes")

    ;;window navigation (with resizing)
    "w"  '(:ignore t :which-key "windows")
    "wL" '(split-right-follow :which-key "split vertical")
    "wJ" '(split-below-follow :which-key "split horizontal")
    "wd" '(delete-window :which-key "delete window")
    "ww" '(other-window :which-key "other window")
    "wh" '(windmove-left :which-key "move left")
    "wl" '(windmove-right :which-key "move right")
    "wj" '(windmove-down :which-key "move down")
    "wk" '(windmove-up :which-key "move up")
    "w>" '(enlarge-window-horizontally :which-key "grow width")
    "w<" '(shrink-window-horizontally :which-key "shrink width")
    "w+" '(enlarge-window :which-key "grow height")
    "w-" '(shrink-window :which-key "shrink height")

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
    "s" 'evil-avy-goto-char-in-line ;; goto char in line
    "gl" 'avy-goto-line      ;; no more numbers
    "gc" 'evil-commentary ;; comment region

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
   '("5eb797a41e8619dc1d8a2fe45ed4abc99d31bd836079acc4869763a5e055a693"
	 "9624c1828474f6071d465b9ac5cc0b8d457803a466ddd861cdc142638a255154"
	 "6665938b79d90cebac92a85953420179704efdbaec7a0e1a14ff90eee6541495"
	 "dca64882039075757807f5cead3cee7a9704223fab1641a9f1b7982bdbb5a0e2"
	 "b21e3ec892646747d647b34162e9d9e72abfd02ba60dd6e8fc51b2cc65d379dd"
	 "bf9df728461be9e8358a393dc3872f9ac6a7421fb613717fdf5b9e6026452461"
	 "7771c8496c10162220af0ca7b7e61459cb42d18c35ce272a63461c0fc1336015"
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
