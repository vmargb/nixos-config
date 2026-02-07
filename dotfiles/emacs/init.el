;; -*- lexical-binding: t; -*-

;; ============================
;;    ** Dependencies **
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
;; search works best in a git repo
;;   OR do: SPC p a (to add non-git project)
;;
;; to create sessions/workspaces
;;    do: SPC a n (new activity)
;;
;;-------------------------------------
;;        ** Goto file/dir **
;; goto open buffers:       spc b b
;; goto file in dir:        spc f f
;; goto file in project:    spc f d
;; grep file in project:    spc f g
;; goto match in file:      spc f l
;;
;;        ** Motions **
;; goto anything:           S (search)
;; goto char(current line): s
;; goto char(anywhere):     K
;; goto line number:        gl (goto line)
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

;; --------------------------------
;;          ** Misc **
;; --------------------------------

(defun close-unused-buffers () ;; close buffers not visible
  (interactive)
  (let ((buffers (buffer-list)))
    (dolist (buf buffers) ;; go through all buffers
      (when (and (not (buffer-modified-p buf)) ;; if not modified
                 (not (get-buffer-window buf 'visible))) ;; if not visible
        (Kill-buffer buf))))) ;; close

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
(set-face-attribute 'default nil :font "Iosevka NF Medium-14")
(setq imenu-auto-rescan t) ;; automatically rescan imenu for updates


;; --------------------------------
;;          ** LANGS **
;; --------------------------------
;; temporary lang support without LSP
(use-package kotlin-mode
  :mode ("\\.kt\\'" "\\.kts\\'"))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package go-mode
  :mode "\\.go\\'")

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook ((rust-mode . (lambda ()
                        (setq-local tab-width 4)
                        (setq-local indent-tabs-mode nil)))))


;; global indent settings
(setq-default indent-tabs-mode nil) ; Use spaces as tabs
(setq-default tab-width 4) ; global 4 spaces for tabs
(setq-default tab-stop-list (number-sequence 4 120 4))  ; Consistent columns
;; specific language overrides
(add-hook 'js-mode-hook
          (lambda ()
            (setq-local tab-width 2)
            (setq-local js-indent-level 2)))
(add-hook 'yaml-mode-hook
          (lambda ()
            (setq-local tab-width 2)
            (setq-local yaml-indent-offset 2)))
(add-hook 'css-mode-hook
          (lambda ()
            (setq-local tab-width 2)
            (setq-local css-indent-offset 2)))

;; compile code quickly (quickrun.el)
(use-package quickrun
  :bind (("<f5>" . quickrun)))


;; function to reset M-x compile
(defun compile-reset ()
  "prompt for new compile command every time"
  (interactive)
  (setq compile-command nil) ;; set compile-command to nil to force prompt
  (call-interactively 'compile))

;; file formatter
;; don't auto-format on save
;; format using spc b f (need to install deno & prettier)
(use-package format-all
  :commands format-all-mode
  :config
  (setq-default format-all-formatters
                '(("C"     (astyle "--mode=c"))
                  ("Shell" (shfmt "-i" "4" "-ci")))))

;; snippets (yasnippet.el)
;; M-x yas-new-snippet
;; enter snippet fields and code
;; use $1, $2 for tabstops
;; C-c C-c to save and use snippet
;; yas-describe-tables to see all snippets
;; yas-visit-snippet-file to edit snippet
(use-package yasnippet
  :hook ((prog-mode . yas-minor-mode)
         (text-mode . yas-minor-mode)
         (conf-mode . yas-minor-mode))
  :init
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)


;; -------------------------
;; Theme and modeline (doom)
;; -------------------------
(use-package doom-themes
  :config
  (doom-themes-org-config)
  (load-theme 'doom-old-hope t))

;; need to run M-x all-the-icons-install-fonts
(use-package all-the-icons
  :if (display-graphic-p))

;; run M-x nerd-icons-install-fonts
(use-package doom-modeline
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
  :config
  (defhydra hydra-theme-switcher (:hint nil)
    "
      Dark                ^Light^
  ----------------------------------------------
  _1_ doom-lantern     _z_ one-light
  _2_ doom-rouge       _x_ doom-ayu-light
  _3_ doom-gruvbox     _c_ doom-gruvbox-light
  _4_ doom-sourcerer   _v_ flatwhite
  _5_ doom-tokyo-night _b_ tomorrow-day
  _6_ old-hope         _n_ modus-operandi-tinted
  _7_ doom-pine            ^
  _8_ peacock              ^
  _9_ doom-moonlight       ^
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
    ("7" (load-theme 'doom-pine)	     "pine")
    ("8" (load-theme 'doom-peacock)	     "peacock")
    ("9" (load-theme 'doom-moonlight)	     "feather-dark")

    ;; Light
    ("z" (load-theme 'doom-one-light)	     "one-light")
    ("x" (load-theme 'doom-ayu-light)	     "ayu-light")
    ("c" (load-theme 'doom-gruvbox-light)	     "gruvbox-light")
    ("v" (load-theme 'doom-flatwhite)	     "flatwhite")
    ("b" (load-theme 'doom-opera-light)	     "opera-light")
    ("n" (load-theme 'modus-operandi-tinted) "modus-operandi")
    ("q" nil))
  )


;; -----------------------------
;; More UI/UX improvements
;; -----------------------------

;; colour coded delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; intelligent indent-guides
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'column)
  (setq highlight-indent-guides-responsive 'stack)
  (set-face-foreground 'highlight-indent-guides-odd-face "#303030") ;; dark gray
  (set-face-foreground 'highlight-indent-guides-even-face "#505050") ;; light gray
  (setq highlight-indent-guides-delay 0))


;; clear buffer and non buffer highlighting
(use-package solaire-mode
  :hook (elpaca-after-init . solaire-global-mode))


;; auto resize panes on window switch
(use-package golden-ratio
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
  :hook (elpaca-after-init . spacious-padding-mode))

;; distraction-free mode
(use-package olivetti
  :init
  (setq olivetti-body-width 90)  ;; makes the writing area 90 columns wide

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
        ;;(text-scale-set 2) ;; doube text ssize
		)
    ;; Restore defaults when disabling
    (display-line-numbers-mode 1)
    ;;(text-scale-set 0)
	))

(add-hook 'olivetti-mode-hook #'my/olivetti-setup)

;;(use-package focus) ;; twilight.nvim

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

(use-package evil-collection ;; better evil-support
  :after evil
  :config
  (evil-collection-init))

;; e.g. ysiw", ds", cs"'
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary ;; nerd-commenter
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


;; ------
;; Magit
;; ------
;; ?: see all commands
;;   0: F f, F u: fetch or pull from remote if you need to
;; 0.5: if this fails do "e" for ediff which shows the two variants
;;      do 'n' to go to variants, then 'a' or 'b' to pick variant
;;      repeat until you've picked each variant
;;      'q' to quit and save variant

;; 1. goto unstaged changes, tab to open each change
;; 2. s -> to stage an unstaged change
;; 3. c -> commit staged change
;; 4. enter commit message in commit window
;; 5. C-c C-c to commit the message
;; 6. P p, P u: push to remote
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
  "create a .project.el marker file in dir or the current project root.
when called, prompt for dir or default to current directory"
  (interactive "DDirectory for project root (Enter: current folder): ")
  (let* ((dir (or dir default-directory))
         (marker-file (expand-file-name ".project.el" dir)))
    (if (file-exists-p marker-file)
        (message "Marker already exists in %s" dir)
      (with-temp-buffer (write-file marker-file))
      (message "Added .project.el marker to %s" dir))))

;; let project.el identify root markers (emacs 29)
(setq project-vc-extra-root-markers '(".project.el" ".projectile" ".dumbjump"))
(setq xref-search-program 'ripgrep) ;; use ripgrep over grep

;; Harpoon, quick-switch between most common files
(use-package harpoon)

;; ---------------------------------------------
;; the difference between projects and sessions:
;; 'projects' are simply all your git repos
;; whereas 'sessions' are workspaces that persist
;; your window and buffer configurations for a project
;; ---------------------------------------------
;; Session Persistence (activities.el)
;; ---------------------------------------------
(use-package activities
  :init
  (activities-mode)
  (activities-tabs-mode)
  ;; Prevent `edebug' default bindings from interfering.
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  :bind
  (("C-x C-a C-n" . activities-new)
   ("C-x C-a C-d" . activities-define)
   ("C-x C-a C-a" . activities-resume)
   ("C-x C-a C-s" . activities-suspend)
   ("C-x C-a C-k" . activities-kill)
   ("C-x C-a RET" . activities-switch)
   ("C-x C-a b" . activities-switch-buffer)
   ("C-x C-a g" . activities-revert)
   ("C-x C-a l" . activities-list)))


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
         "  [p] Project\n"
         "  [r] Recent Files\n"
         "  [m] Bookmarks\n"
         "  [a] Agenda\n"
         "  [q] Quit\n"
         "\n"))

  ;; disable default sections
  (setq dashboard-items '())
  (dashboard-setup-startup-hook)

  ;; --- keybindings ---
  (defun my/dashboard-open-sessions () (interactive) (call-interactively #'activities-resume))
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
		;; fuzzy-first matching: flex over literal/regexp
		orderless-matching-styles '(orderless-literal orderless-flex orderless-regexp)))

;; icons for orderless matches
(use-package marginalia
  :init (marginalia-mode))

;; fd, ripgrep search for large projects
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

(use-package org-remark
  :defer t
  :config
  (org-remark-global-tracking-mode +1) ;; work globally on all buffers
  (org-remark-create "dark-pastel-green" '(:background "#3a6b35"))
  (org-remark-create "dark-pastel-blue" '(:background "#34547a"))
  (org-remark-create "dark-pastel-red" '(:background "#7a453a"))
  (org-remark-create "dark-pastel-purple" '(:background "#6a4b7b"))
  (org-remark-create "dark-pastel-orange" '(:background "#b56c49"))
  (org-remark-create "dark-pastel-teal" '(:background "#3b7165"))
  (org-remark-create "dark-pastel-brown" '(:background "#7b6046"))
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

;; -----------------
;; Treemacs
;; -----------------
;; Sidebar with Project integration
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'project
    (defun my/treemacs-project-toggle ()
      "toggle Treemacs at current project root"
      (interactive)
      (if-let ((pr (project-current))) ;; only continue if we're in a project
          (let ((proj-dir (project-root pr))) ;; get dir of current project
            (treemacs-add-project-to-workspace ;; add dir as treemacs workspace
             proj-dir (file-name-nondirectory (directory-file-name proj-dir)))
            (treemacs-select-window))
        (treemacs)))
    (global-set-key (kbd "C-x t t") #'treemacs) ; simple toggle
    (global-set-key (kbd "C-x t p") #'my/treemacs-project-toggle)) ; project root
  :config
  ;; follow current file, refresh on focus etc
  (treemacs-follow-mode t)      ; highlight current buffer's file
  (treemacs-filewatch-mode t)   ; auto-refresh on file changes
  (treemacs-fringe-indicator-mode 'always))

(use-package treemacs-all-the-icons
  :after treemacs
  :config
  (treemacs-load-theme "all-the-icons"))

;; integrate with project.el
(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "t") #'my/treemacs-project-toggle))

;; ------------------
;; Dired enhancements
;; ------------------
;; Keybindings:
;; dired-do-rename: R, dired-create-directory: +
;; dired-do-copy: C(specify copy dir), dired-do-delete: D
;; move: R (specify new dir with file name)

(setq dired-create-destination-dirs t) ;; create new directories during move/copy
;;(setq dired-create-destination-dirs-on-trailing-dirsep t) ;; trailling slash = directory (optional)
;; sort by folders first, also sort by filetype "-X"
(setq dired-listing-switches "-alh --group-directories-first")

;; treemacs icons > all-the-icons
(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-mode))
;; extra colorful faces in dired
(use-package diredfl
  :hook (dired-mode . diredfl-mode))
(add-hook 'dired-mode-hook #'hl-line-mode) ;; highlight current line

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
;; if there's no git repo, add a ".dumbjump" root marker
;; to allow for local project-wide search
(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate) ;; xref-backend
  ;; override evil bindings for dumb-jump
  (define-key evil-normal-state-map (kbd "M-.") #'xref-find-definitions)
  (define-key evil-normal-state-map (kbd "M-,") #'xref-go-back)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read) ;; use completing-read
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
    "bn" '(next-buffer :which-key "next buffer")
    "bp" '(previous-buffer :which-key "previous buffer")
    "bf" '(format-all-region :which-key "format region") ;; format region
    "bF" '(format-all-buffer :which-key "format file") ;; format entire file

    ;; bookmarks
    "m"  '(:ignore t :which-key "bookmarks")
    "mm" '(bookmark-jump :which-key "jump to bookmark")
    "ms" '(bookmark-set :which-key "set bookmark")
    "md" '(bookmark-delete :which-key "delete bookmark")

    ;; activities
    "a"  '(:ignore t :which-key "activities")
    "aa" '(activities-switch :which-key "switch")
    "ab" '(activities-switch-buffer :which-key "switch buffer")
    "ad" '(activities-define :which-key "define")               ;; define activity name
    "ak" '(activities-kill :which-key "kill")
    "an" '(activities-new :which-key "new")
    "ag" '(activities-revert :which-key "revert")               ;; revert to original
    "ar" '(activities-resume :which-key "resume")               ;; resume from suspended
    "as" '(activities-suspend :which-key "suspend")             ;; save and exit activity (close tab)

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
    "tt" '(treemacs :which-key "toggle")
    "tp" '(my/treemacs-project-toggle :which-key "toggle project")

    ;; org
    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")
    "ol" '(org-store-link :which-key "current file link")

    ;; remark
    "r"  '(:ignore t :which-key "remark")
    "rr" '(org-remark-mode :which-key "enable highlights")
    "rh" '(org-remark-mark :which-key "highlight")
    "ry" '(org-remark-mark-yellow :which-key "highlight yellow")
    "rl" '(org-remark-mark-line :which-key "mark line")
    "rd" '(org-remark-delete :which-key "delete highlight")
    "rc" '(org-remark-change :which-key "change highlight")

    ;; compile
    "c"  '(:ignore t :which-key "custom")
    "cc" '(compile :which-key "compile")
    "cr" '(compile-reset :which-key "compile")

    ;;window navigation (with resizing)
    "w"  '(:ignore t :which-key "windows")
    "wL" '(split-right-follow :which-key "split vertical")
    "wJ" '(split-below-follow :which-key "split horizontal")
    "wd" '(delete-window :which-key "delete window")
    "wD" '(delete-other-windows :which-key "delete other window")
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
    "zf" '(focus-mode :which-key "focus mode")
    "zl" '(display-line-numbers-mode :which-key "toggle line")

    "SPC" '(execute-extended-command :which-key "M-x") ; A better M-x
    )


  (general-define-key
   :states '(normal visual)
   :keymaps 'override
   ;; avy bindings
   "S" 'avy-goto-char-timer ;; flash.nvim style
   "s" 'evil-avy-goto-char-in-line ;; goto char in line
   "K" 'avy-goto-word-1     ;; goto single char
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
   '("2672cbaed4e6a6c61df4cbf665ff7ceb49cabf2f534f857f3927bab59e87ac61"
     "b33f1f59690615cef8ea9043659735289c54b0cfaf8b42e5c16651c0529a82fc"
     "1107071694e48770dfaeb2042b5d2b300efa0a01bfdfe8a9526347fe6f2cc698"
     "b184ec8abf5da1fe5cec54a366b71a02a5e54b592298dd5ebfb3e322848b58d8"
     "dbe27ea6d8ce383a84d19cfce97c3b10ed47a127e660ed588afe5d72d0674503"
     "c866d25d993c46bd6fbc7ecbfe4cf431e84b583a04a097efe36661250b239a16"
     "fda50dd4cf50b9be702b5a238c392c4e27574d2036ec0cb4526464794b35ce79"
     "1e3835c8bdec987c0d8a5866dc2f2a4c6e12c2dbfc0bc7e6cca5d934fe6273ec"
     "02d04a8dc702196134e2f7e33fbbccf11a6aebc14ad9fe7297d5d6bdb9db0c0d"
     "b389e8f19f205aa1ac63671b08440a413e14356bf155577409e4777bf52167a9"
     "b49a5e8b42d3f85ce2d4064d1c57a1adcb7a8bd53ff85aa1086748c79273992d"
     "6f5a202ec8a161e09a73c02836340d63291567c06520b34b8418bc70e0d59d79"
     "54eb38df6f95a3d49fd23a6aa301cbb262f011e4f3cda2a0b096518b53ff4132"
     "80326a0e1f4019c283bf58655b1ae9a9ac3f3e2fba88289c4743a90a4758a847"
     "23624d984235091c2ff287adee35e5ce61e10a3d5631b1d9d7f254ecba0b27ff"
     "f9609142fe3b8a4a13e4636378735425aee1c1a9960ba225c135609d234ae4a6"
     "fa6182c18c611476bf37f315e360e400ee019538a3f35d7255e6465f5314e91e"
     "324a496baf3e60648183fa1e126d80b402195be2492607990570e4afe96e7463"
     "7ef46af7fa7a09cf2b095dfae37eaa4e7656e8b62326737789ef947975383623"
     "d0afcc8f7ee60f78a7b125407db60b240db2bd16d7654ca7242bd1f31fbb9f9b"
     "64a09553dc753aa3a2d43a5445954c0f54fea434a5b94df60953c674f8f1af0d"
     "5a424cf0f4291edd391907a0de79fa75caedbe23a1c30b94c6869a6b1bbfbb83"
     "f2d71f01992bd48d21a3190c95a52de250b20f1de594d185ca3ab7de428a56c8"
     "4d12469f94f29f44958a3173a74985f1b6aa383f933a49735d07c3304d77c810"
     "cc8beb55d871fb8a0436905556c64a63689d65d7d3bc8376c9f04367d0e89d91"
     "8e03d6225a1bb55487a643ee359b0c3b620fbc48ea02c2369b07eaaf14dacf3d"
     "d2f96f82a08e5ce6a8cebcca90dcc08762a0c68ba836f3f6a38fc9b67a8e2530"
     "19df357062d81949f6b2e7f70cd87eb9c112c7a23d2128826468e536b038a085"
     "545a268abdb70a28a299242bb79daf7cf1f088ddcbe9518c9d754a6f6159feb6"
     "3e371167a709445163dcbd06850eadd54709f45eae0c546e94760724516c6006"
     "ac4ab3921322aaa6aec49d1268337ec28f88c9ee49fa9cb284d145388fb928a8"
     "d978a2d7c42875682d1d3260b2766f81ded2e3b908148d77283b6a972b768c89"
     "7ef4bf16bb25e0bcbf1dd198165e608d81c98f0453dded7d32aee9f165cf72d1"
     "4d0dde5a6b07849e72f93b05b370612ea8b84afb72cc8120217cc9f5aed0fd53"
     "e5248f88e64f3e06f0d9a8266f777f7e247c268765a649b7d07ef13ea62a51e2"
     "cbd687e0a602f873321dcf3cf24351c1334ee3d3f222529594397663ca2ce173"
     "42493c75393a0fedee66afc08e6de2c0e95b5764c5b9c39c9544e24212ad1e97"
     "18b73ae04a60c4a829f9ad06f17bf82300b27d3ceea497f236cec00b31866cde"
     "655bcb760f8113d91bcd2622527e081a2c1a05dceae8a9d23619caea9711ee30"
     "a22bd438c40a16bf2b0beac82d7fc60815c898646733e8d86d0068d2753ddd98"
     "30e605d418d00c070d4d8d0db14b2510f98c0ac955e68c20322bcb5eb624f18e"
     "b38cdb86997b75583bfa1ab60996a21b018e93c5f55a329bb6d1e110efca09bc"
     "cbeb83ea9d4e67a8fadf34ffb5603d20dc1554791751e8fdf69250e02c564fc2"
     "6410beae3c7fcd6b983f71fd09d75299015c2e1a93f4b6ccbc63ee79f1cba5a6"
     "7b52b206b53a9d95b45cdd1baad939dbf54609543e0f88ddb394e822cb129e81"
     "9393ed69ec24d2e1e41f60d7f3c1dc6eb3ae071da3e5991a05a0f77d8d236f30"
     "59473a9ba1a0f27e61e304e3a08be0c8ebb56a36c0840bfa2e8e614a61c0b369"
     "0af624df9b720a0085a55785338977d5fe85627a4a5adab44feff97d1eb60829"
     "6dfbfe942d5c75d2387cbd5946ff3fe76fa6d247c95b1c5b72e5dcddc61ed539"
     "9a4cb3e932a631c4b29129a865c6aa6c6877faa5e9188c7aa13e82e7f2241906"
     "5eb797a41e8619dc1d8a2fe45ed4abc99d31bd836079acc4869763a5e055a693"
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
 '(package-selected-packages nil)
 '(warning-suppress-types '((frameset))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
