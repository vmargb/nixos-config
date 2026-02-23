;; -*- lexical-binding: t; -*-

;; ============================
;;      ** Dependencies **
;;  install with package-manager
;; ============================
;; - Emacs 29 minimum (treesitter, LSP)
;; - rg (ripgrep)
;; - fd (faster find)
;; - fzf (fuzzy finder)
;; - zoxide (optional)
;; - coreutils ('gls' mac-only)
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
(setq scroll-conservatively 100)
;(global-hl-line-mode t)
(save-place-mode 1)
(column-number-mode)
;; automatic bracket pairing
(electric-pair-mode 1)

(defun close-unused-buffers () ;; close buffers not visible
  (interactive)
  (let* ((buffers (buffer-list))
         (count 0))
    (dolist (buf buffers) ;; go through all buffers
      (when (and (not (buffer-modified-p buf)) ;; if not modified
                 (not (get-buffer-window buf 'visible))) ;; if not visible
        (kill-buffer buf)
        (setq count (1+ count)))) ;; increment buffer count
    (message "Closed %d unused buffers" count)))

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
;;(set-face-attribute 'default nil :font "Iosevka NF Medium-16")
(set-frame-font "Iosevka Nerd Font 16" nil t)
(setq imenu-auto-rescan t) ;; automatically rescan imenu for updates

;; fixes "ls" problem in dired for macos
;; brew install coreutils for this to work
(when (eq system-type 'darwin)
  (setq insert-directory-program "/opt/homebrew/bin/gls"))

;; --------------------------------
;;          ** LANGS **
;; --------------------------------

;; global indent settings
(setq-default indent-tabs-mode nil) ; Use spaces as tabs
(setq-default tab-width 4) ; global 4 spaces for tabs
(setq-default tab-stop-list (number-sequence 4 120 4))  ; Consistent columns

(use-package dtrt-indent
  :config
  ;; automatic indentation detection
  (dtrt-indent-global-mode 1))

;; -----------------
;; Treesitter
;; -----------------
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package nix-ts-mode ;; explicit nix mode
 :mode "\\.nix\\'")

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
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
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
  (load-theme 'doom-lantern t))

;; need to run M-x nerd-icons-install-fonts
(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

;; run M-x nerd-icons-install-fonts
(use-package doom-modeline
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

;; distraction-free mode
(use-package olivetti
  :init
  (setq olivetti-body-width 0.55
        olivetti-style 'fancy)  ;; use fringes as side margins

  :config
  ;; optionally enable olivetti-mode automatically in text and org modes
  ;;(add-hook 'text-mode-hook #'olivetti-mode)
  (add-hook 'org-mode-hook #'olivetti-mode))

;; toggle line number, text scale automatically
(require 'color)
(defun my/olivetti-setup ()
  "Disable line numbers and set darker fringes in Olivetti mode."
  (if olivetti-mode
      (let ((dark-bg (color-darken-name 
                      (face-attribute 'default :background) 8)))
        (set-face-attribute 'fringe nil :background dark-bg)
        (set-face-attribute 'olivetti-fringe nil :background dark-bg)
        (display-line-numbers-mode -1))
    ;; Restore theme defaults when leaving
    (set-face-attribute 'fringe nil :background 
                        (face-attribute 'default :background))
    (set-face-attribute 'olivetti-fringe nil :background 
                        (face-attribute 'default :background))
    (display-line-numbers-mode 1)))

(add-hook 'olivetti-mode-hook #'my/olivetti-setup)

(use-package focus)

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

;; alternatively jump around with zoxide + dired
(defun emacs-zoxide (q)
  "Query zoxide  and launch dired."
  (interactive "sZoxide: ")
  (if-let
      ((zoxide (executable-find "zoxide")) ;; if zoxide installed
       (target                             ;; if target is found
        (with-temp-buffer
          (if (= 0 (call-process zoxide nil t nil "query" q))
              (string-trim (buffer-string))))))
      (funcall-interactively #'dired  target) ;; open dired at target
    (unless zoxide (error "Install zoxide"))
    (unless target (error "No Match"))))

;; Harpoon, quick-switch between most common files
(use-package harpoon)

;; ---------------------------------------------
;; the difference between projects and sessions:
;; 'projects' are simply your git repos
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
(setq tab-bar-show nil) ;; use tab-bar but don't show


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
  :hook ((prog-mode . breadcrumb-mode)
         (breadcrumb-mode . (lambda () (when (> (buffer-size) 500000) (breadcrumb-mode -1)))))
  :custom ((breadcrumb-symbol-minimum-length 0)))

;; pulls from any icon provider
;; in this case nerd-icons
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

;; -----------------------------
;; Project & file-specific notes
;; similar to quicknote.nvim which
;; dynamically maps each file or
;; project to a 1:1 org file
;; -----------------------------
;; Project Org-Mode
;; -----------------------------
(defvar my-notes-dir "~/org/project-notes/"
  "directory for project notes, outside any repo.")

;; org notes for project
(defun my-project-notes-file ()
  "path to notes file for current project."
  (when-let ((root (project-root (project-current))))
    (expand-file-name (concat (file-name-nondirectory (directory-file-name root)) ".org")
                      my-notes-dir)))

(defun my-open-project-notes ()
  "toggle between project notes and previous buffer."
  (interactive)
  (if (and (eq major-mode 'org-mode)
           (string-prefix-p (expand-file-name my-notes-dir) (or buffer-file-name "")))
      (switch-to-prev-buffer)
    (let ((notes-file (my-project-notes-file)))
      (unless (file-exists-p notes-file)
        (make-directory (file-name-directory notes-file) t))
      (find-file notes-file))))

;; org notes for file
(defun my-file-notes-file ()
  "path to notes file for current file."
  (when-let* ((root (project-root (project-current)))
              (relpath (file-relative-name buffer-file-name root)))
    (expand-file-name (concat relpath ".notes.org") my-notes-dir)))

(defun my-open-file-notes ()
  "toggle between file notes and previous buffer."
  (interactive)
  (if (and (eq major-mode 'org-mode)
           (string-prefix-p (expand-file-name my-notes-dir) (or buffer-file-name "")))
      (switch-to-prev-buffer)
    (find-file (my-file-notes-file))))

;; ------------------
;; Terminal and help
;; ------------------
;; persists buffer after exit
;; use spc b d once done
(use-package eat
  :ensure (eat :host nongnu))

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

    ;; buffer
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")            ;; find file in opened buffers
    "bd" '(kill-current-buffer :which-key "kill buffer")
    "bi" '(ibuffer :which-key "ibuffer")
    "bc" '(clean-buffer-list :which-key "clean unused buffers")
    "bC" '(close-unused-buffers :which-key "clean buffers not visible")
    "bn" '(next-buffer :which-key "next buffer")
    "bp" '(previous-buffer :which-key "previous buffer")
    "bf" '(format-all-region :which-key "format region") ;; format region
    "bF" '(format-all-buffer :which-key "format file") ;; format entire file

    ;; compile
    "c"  '(:ignore t :which-key "custom")
    "cc" '(compile :which-key "compile")
    "cr" '(compile-reset :which-key "reset")

    ;; dired
    "d"  '(:ignore t :which-key "dired")
    "dd" '(dired :which-key "open dired")                        ;; specify directory
    "dc" '(dired-jump :which-key "dired in current buffer")      ;; current buffer directory
    "dn" '(dired-create-directory :which-key "new directory")    ;; create in current directory or '+'
    "df" '(find-name-dired :which-key "get files by name")       ;; find file, in specific directory
    "dg" '(find-grep-dired :which-key "get files by grep")       ;; grep file, in specific directory
    "do" '(dired-other-frame :which-key "dired other frame")     ;; open dired in another frame

    ;; eat terminal
    "e"  '(:ignore t :which-key "terminal")
    "ee" '(eat :which-key "open eat at file")
    "ep" '(eat-project :which-key "open eat at project")

    ;; files
    "f"  '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")                     ;; find file only in CURRENT dir
    "fd" '(consult-fd :which-key "find file")                    ;; find in ALL dirs from current
    "fg" '(consult-ripgrep :which-key "ripgrep")                 ;; grep in ALL dirs from current
    "fl" '(consult-line :which-key "consult line")               ;; see all '/' results
    "fj" '(breadcrumb-jump :which-key "breadcrumb")              ;; jump to contexts in file

    ;; magit
    "g"  '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")

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

    ;; lsp
    "l"  '(:ignore t :which-key "LSP")
    "ll" '(eglot :which-key "eglot")              ;; jump to contexts in file

    ;; bookmarks
    "m"  '(:ignore t :which-key "bookmarks")
    "mm" '(bookmark-jump :which-key "jump to bookmark")
    "ms" '(bookmark-set :which-key "set bookmark")
    "md" '(bookmark-delete :which-key "delete bookmark")
    "mz" '(emacs-zoxide :which-key "zoxide")

    ;; org
    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")
    "ol" '(org-store-link :which-key "current file link")
    "op" '(my-open-project-notes :which-key "org for this project")
    "of" '(my-open-file-notes :which-key "org for this file")
    "or" '(:ignore t :which-key "remark")
    "orr" '(org-remark-mode :which-key "enable highlights")
    "orh" '(org-remark-mark :which-key "highlight")
    "ord" '(org-remark-delete :which-key "delete highlight")
    "orl" '(org-remark-mark-line :which-key "mark line")
    "orc" '(org-remark-change :which-key "change highlight")

    ;; project
    "p"  '(:ignore t :which-key "projects")
    "pp" '(project-switch-project :which-key "switch project")
    "pa" '(my/add-project-root-marker :which-key "add project")
    "pf" '(project-find-file :which-key "find file in project")  ;; find file in project
    "pd" '(project-dired :which-key "project dired")             ;; open dired at project root
    "pk" '(project-kill-buffers :which-key "kill project buffers") ;; open dired at project root
    "pe" '(project-eshell :which-key "project eshell")

    ;; registers
    "r"  '(:ignore t :which-key "registers")
    "rs" '(copy-to-register :which-key "save region to register")
    "rp" '(point-to-register :which-key "save point position")
    "rn" '(number-to-register :which-key "save number")
    "r+" '(increment-register :which-key "increment register")
    "ri" '(insert-register :which-key "insert register")
    "rj" '(jump-to-register :which-key "jump to register")
    "rl" '(list-registers :which-key "list registers")
    "rr" '(view-register :which-key "view register")

    ;; tree
    "t"  '(:ignore t :which-key "tree")
    "tt" '(treemacs :which-key "toggle")
    "tp" '(my/treemacs-project-toggle :which-key "toggle project")

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


(provide 'init)
;;; init.el ends here
