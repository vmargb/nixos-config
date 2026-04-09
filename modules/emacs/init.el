; -*- lexical-binding: t; -*-

;; ====================================
;;         ** Dependencies **
;;    install with package-manager
;; ====================================
;; - Emacs 29 minimum (treesitter, LSP, Root markers etc...)
;; - rg     (ripgrep:     SPC f g)
;; - fd     (faster find: SPC f d)
;; - zoxide (better cd:   SPC d z)
;; - fzf    (optional)
;; - coreutils ('gls' mac-only)
;;
;; - Iosevka Nerd font (or change)
;; - M-x nerd-icons-install-fonts (symbols nerd font)
;; ====================================

;;=====================================
;;         Essentials (tldr)
;;-------------------------------------
;;               NOTE:
;; search works best in a git repo
;;   OR do: SPC p a (to add non-git project)
;;
;; to create sessions/workspaces
;;    do:  SPC a n (new activity)
;;    and: SPC a a (change activity)
;;
;;-------------------------------------
;;        ** Goto file/dir **
;; goto open buffers:       SPC b b
;; goto buffers in project: SPC p b
;; goto file in dir:        SPC f f
;; goto file in project:    SPC p f
;;
;;        ** Motions **
;; goto char:               gs    <search term>
;; goto line:               SPC s <search term>
;; ====================================

;; define package archives
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

;; faster archive initialization
(setq package-archive-priorities
      '(("gnu" . 90)
        ("nongnu" . 80)
        ("melpa" . 10)))

;; Initialize package system
(package-initialize)

;; install use-package if missing (idempotent)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
;; load use-package
(require 'use-package)

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
(setopt use-short-answers t) ; "yes" bcomes "y"
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

(defun open-eat-vertical ()
  "Open a vertical split window and run eat in it."
  (interactive)
  (let ((new-win (split-window-right)))
    (select-window new-win)
    (eat)))

(defun open-eat-horizontal ()
  "Open a horizontal split window and run eat in it."
  (interactive)
  (let ((new-win (split-window-below)))
    (select-window new-win)
    (eat)))

;; FONT
;; windows handles font config through face-attributes (like :font)
;; while mac/linux uses set-frame-font
(cond
 ((eq system-type 'windows-nt)
  (set-face-attribute 'default nil :font "Iosevka NF Medium-17"))
 (t
  (set-frame-font "Iosevka Nerd Font 17" nil t)))

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
;; M-x treesit-install-language-grammar (if the below doesnt work)
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; explicity modes when above doesnt work
(use-package nix-ts-mode
 :mode "\\.nix\\'")


;; compile code quickly (quickrun.el)
(use-package quickrun
  :bind (("<f5>" . quickrun)))


;; function to reset M-x compile
(defun compile-reset ()
  "Prompt for new compile command every time."
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

(use-package tempel
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-_" . tempel-insert))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.  `tempel-expand'
    ;; only triggers on exact matches. We add `tempel-expand' *before* the main
    ;; programming mode Capf, such that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand completion-at-point-functions))
    ;; Alternatively use `tempel-complete' if you want to see all matches.  Use
    ;; a trigger prefix character in order to prevent Tempel from triggering
    ;; unexpectly.
    ;; (setq-local corfu-auto-trigger "/"
    ;;             completion-at-point-functions
    ;;             (cons (cape-capf-trigger #'tempel-complete ?/)
    ;;                   completion-at-point-functions))
  )
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  ;; (global-tempel-abbrev-mode)
)
(use-package tempel-collection)

;; -------------------------
;; Theme and modeline (doom)
;; -------------------------
(use-package doom-themes
  :config
  (doom-themes-org-config)
  (defvar my-random-themes
    '(doom-gruvbox doom-lantern doom-miramare))
  ;; randomly pick and load one
  (let* ((selected-theme (nth (random (length my-random-themes)) my-random-themes))
         (doom-theme selected-theme))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme selected-theme t)))

;; need to run M-x nerd-icons-install-fonts
(use-package nerd-icons
  ;; :custom
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
  (doom-modeline-bar-width 3)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-modal-modern-icon t)
  (doom-modeline-unicode-fallback t)
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


(use-package solaire-mode
  :hook (emacs-startup . solaire-global-mode))

;; auto resize panes on window switch
(use-package golden-ratio
  :hook (emacs-startup . golden-ratio-mode)
  :custom
  (golden-ratio-exclude-modes '(occur-mode)))

; vertical candidates
(use-package vertico
  :init (vertico-mode))

;; floating command window with posframe and multiform commands(built-in)
(use-package vertico-posframe
  :after vertico
  :custom
  (vertico-posframe-width 80)
  (vertico-posframe-min-width 40)
  (vertico-posframe-max-width 80)
  (vertico-posframe-parameters
   '((left-fringe . 4)
     (right-fringe . 4)))
  :config
  (vertico-posframe-mode 1))

;; padding around windows
(use-package spacious-padding
  :hook (after-init . spacious-padding-mode))

;; distraction-free mode
(use-package olivetti
  :init
  (setq olivetti-body-width 0.6
        olivetti-style 'fancy))  ;; use fringes as side margins

  ;; optionally enable olivetti-mode automatically in text and org modes
  ;;(add-hook 'text-mode-hook #'olivetti-mode)
  ;;(add-hook 'org-mode-hook #'olivetti-mode))

;; toggle line number, text scale automatically
(require 'color)
(defun my/olivetti-setup ()
  (if olivetti-mode
      (let ((dark-bg (color-darken-name
                      (face-attribute 'default :background) 8)))
        (set-face-attribute 'olivetti-fringe nil :background dark-bg)
        (display-line-numbers-mode -1))
    (set-face-attribute 'olivetti-fringe nil :background 'unspecified)
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
(use-package flash
  :commands (flash-jump flash-jump-continue
             flash-treesitter)
  :bind ("s-j" . flash-jump) ;; cmd-j, ctrl-j
  :custom
  (flash-multi-window t)
  :init
  ;; Evil integration (simple setup)
  (with-eval-after-load 'evil
    (require 'flash-evil)
    (flash-evil-setup t))  ; t = also set up f/t/F/T char motions
  :config
  ;; Search integration (labels during C-s, /, ?)
  (require 'flash-isearch)
  (flash-isearch-mode 1))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

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
(use-package transient)
(use-package magit
  :demand t)  ; ensures immediate loading like :wait t

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
  "Query zoxide Q and launch Dired."
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

;; ------------------------------
;; Bookmarks (arrow.el)
;; ------------------------------
(defun my-arrow-setup ()
  "Shared config for arrow.el."
  (arrow-auto-mode)
  (setq arrow-org-directory "~/arrow-notes/")
  (setq arrow-org-window-behavior 'same-window)
  (setq arrow-project-modeline t)
  (setq arrow-preview-context 0))

;; this is my package which is why i load it like this
(if (file-directory-p (expand-file-name "~/projects/arrow.el/"))
    (use-package arrow
      :load-path "~/projects/arrow.el/"
      :config (my-arrow-setup))
  (use-package arrow
    :vc (:url "https://github.com/vmargb/arrow.el")
    :config (my-arrow-setup)))

(with-eval-after-load 'doom-modeline
  (doom-modeline-def-segment arrow-project
    (arrow-project-modeline-string))
  (doom-modeline-add-segment 'arrow-project 'misc-info :after 'main))


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
  :custom
  (tab-bar-show . nil) ;; use tab-bar but don't show
  ;; Prevent `edebug' default bindings from interfering.
  (setq edebug-inhibit-emacs-lisp-mode-bindings t))


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
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file  (styles basic substring))       ; no orderless for files
          (buffer (styles basic substring)))))   ; and no orderless for buffers

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

;; === org-journalling =================================
;; org-agenda: t -> done, C-c C-s: schedule, C-c C-d: deadline
;; shift-up/down to toggle between active and inactive dates (org agenda)
;; TODO = do today
;; SCHEDULED = “do this on this day”
;; DEADLINE = “this must be done by this day”

(setq org-tag-alist
      '((:startgroup) ("mood") (:endgroup)
        ("happy" . ?h) ("sad" . ?s) ("productive" . ?p)
        ("tired" . ?t) ("idea" . ?i) ("code" . ?c) ("rant" . ?r)))

;; org-journalling with yearly files
(setq org-directory "~/org/")
(setq journal-dir (expand-file-name "journal/" org-directory))
(setq notes-dir (expand-file-name "notes/" org-directory))
(setq org-todo-file (expand-file-name "todo.org" org-directory))
(make-directory journal-dir t)

(defun get-journal-file-yearly ()
  "Return path to current year's journal file."
  (expand-file-name (format-time-string "%Y-journal.org" (current-time)) journal-dir))
(defun get-notes-file-yearly ()
  "Return path to current year's note file."
  (expand-file-name (format-time-string "%Y-notes.org" (current-time)) notes-dir))

(setq org-agenda-files
      (list org-todo-file)) ; add journal-dir only if you want journal TODOs in agenda

;; TODO states
(setq org-todo-keywords
      '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

(setq org-capture-templates
      `(("j" "Journal" entry
         (file+olp+datetree ,(get-journal-file-yearly))
         "* %<%H:%M>\n%?\n")
        ("n" "Note" entry
         (file+olp+datetree ,(get-notes-file-yearly))
         "* %<%H:%M>\n%?\n")
        ("t" "Todo" entry
         (file ,org-todo-file)
         "* TODO %?\n  %U\n")
        ))

;; Navigation functions
(defun journal-today ()
  "Open or create today's journal entry."
  (interactive)
  (org-capture nil "j"))

(defun journal-recent ()
  "Jump to most recent (current year) journal file."
  (interactive)
  (find-file (get-journal-file-yearly)))
(defun notes-recent ()
  "Jump to most recent (current year) journal file."
  (interactive)
  (find-file (get-notes-file-yearly)))
(defun journal-list ()
  "List all journal files for browsing."
  (interactive)
  (dired journal-dir))
(defun notes-list ()
  "List all notes files for browsing."
  (interactive)
  (dired notes-dir))

(use-package deft
  :commands (deft)
  :config
  (setq deft-directory "~/org"
        deft-extensions '("org" "md")  ;; No commas needed
        deft-recursive t              ;; Scans subfolders
        deft-use-filename-as-title t  ;; Title from filename
        deft-file-naming-rules '((noslash . "-") (nospace . "-") (case-fn . downcase))))

;; ====================================================

;; ------------------
;; Terminal and help
;; ------------------
;; persists buffer after exit
;; use spc b d once done
(use-package eat) ; auto-installs from nongnu.elpa

(use-package helpful
  :defer t
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
(setq dired-kill-when-opening-new-dired-buffer t) ;; auto-close old dired buffers
(setq dired-create-destination-dirs t) ;; create new directories during move/copy
;;(setq dired-create-destination-dirs-on-trailing-dirsep t) ;; trailling slash = directory (optional)
;; sort by folders first, also sort by filetype "-X"
(setq dired-listing-switches "-alh --group-directories-first") ;; need gls on macos

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
(use-package flymake
  :custom
  (flymake-diagnostic-functions-current-only t) ; only visible buffer
  (flymake-proc-compilation-prevents-syntax-check nil)
  (flymake-show-diagnostics-at-end-of-line 'fancy)
  :hook
  (prog-mode . flymake-mode))

(use-package eglot
  :ensure nil
  :hook ((python-ts-mode rust-ts-mode nix-ts-mode) . eglot-ensure)
  :custom (eglot-autoshutdown t)
  :config
  (add-hook 'eglot--managed-mode-hook
            (lambda () ;; use eglot over xref backend first
              (when eglot--managed-mode ; only when turning on (not shutting down)
                (remove-hook 'xref-backend-functions #'eglot-xref-backend t)
                ;; negative depth, higher priority
                (add-hook 'xref-backend-functions #'eglot-xref-backend -90 t)))))

(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "M-.") #'xref-find-definitions)
    (define-key evil-normal-state-map (kbd "M-,") #'xref-go-back)))

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

    ;; activity
    "a"  '(:ignore t :which-key "activities")
    "az" '(activities-switch :which-key "resume")               ;; resume from suspended
    "aa" '(activities-resume :which-key "switch")
    "ab" '(activities-switch-buffer :which-key "switch buffer")
    "ad" '(activities-define :which-key "define")               ;; define activity name
    "ak" '(activities-kill :which-key "kill")
    "an" '(activities-new :which-key "new")
    "ag" '(activities-revert :which-key "revert")               ;; revert to original
    "as" '(activities-suspend :which-key "suspend")             ;; save and exit activity (close tab)
    "ad" '(activities-discard :which-key "discard")             ;; save and exit activity (close tab)
    "ar" '(activities-rename :which-key "rename")             ;; save and exit activity (close tab)

    ;; buffer
    "b"  '(:ignore t :which-key "buffers")
    "ba" '(dired-create-empty-file :which-key "new file")            ;; find file in opened buffers
    "bb" '(consult-buffer :which-key "switch buffer")            ;; find file in opened buffers
    "bi" '(ibuffer :which-key "ibuffer menu")            ;; find file in opened buffers
    "bd" '(kill-current-buffer :which-key "kill buffer")
    "bD" '(delete-file :which-key "delete file")
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
    "dz" '(emacs-zoxide :which-key "zoxide")

    ;; eat terminal
    "e"  '(:ignore t :which-key "terminal")
    "ee" '(eat :which-key "open eat at file")
    "ep" '(eat-project :which-key "open eat at project")
    "el" '(open-eat-vertical :which-key "open eat vertically")
    "ej" '(open-eat-horizontal :which-key "open eat at project")

    ;; files
    "f"  '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")                     ;; find file only in CURRENT dir
    "fd" '(consult-fd :which-key "find file")                    ;; find in ALL dirs from current
    "fg" '(consult-ripgrep :which-key "ripgrep")                 ;; grep in ALL dirs from current
    "fi" '(consult-imenu :which-key "imenu")                ;; jump to contexts in file
    "fo" '(consult-outline :which-key "outline")                ;; jump to contexts in file
    "fy" '(consult-yank-pop :which-key "outline")                ;; jump to contexts in file

    ;; linting
    "l"  '(:ignore t :which-key "lint")
    "ll" '(consult-flymake :which-key "list all diagnostics")
    "ln" '(flymake-goto-next-error :which-key "next error")
    "lp" '(flymake-goto-prev-error :which-key "prev error")
    "ld" '(flymake-show-diagnostic :which-key "diagnostic at point")
    "lp" '(flymake-show-project-diagnostics :which‑key "show project diagnostics")

    ;; magit
    "g"  '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")

    ;; Buffer (arrow.el)
    ","  '(:ignore t :which-key "marks")
    ",," '(arrow-show :which-key "show")
    ",a" '(arrow-add          :which-key "add")
    ",j" '(arrow-jump-buffer  :which-key "add")
    ",d" '(arrow-delete       :which-key "delete")
    ",c" '(arrow-clear-all    :which-key "clear all")
    ",n" '(arrow-next-line    :which-key "next")
    ",p" '(arrow-prev-line    :which-key "prev")
    ;; Project layer
    "."  '(:ignore t :which-key "project marks")
    ".." '(arrow-project-show   :which-key "show")
    ".j" '(arrow-jump-project   :which-key "show")
    ".a" '(arrow-project-add    :which-key "add")
    ".d" '(arrow-project-delete :which-key "delete")
    ".n" '(arrow-project-next   :which-key "next")
    ".p" '(arrow-project-prev   :which-key "prev")
    ;; Global layer
    "/" '(:ignore t :which-key "global")
    "//" '(arrow-global-show    :which-key "sow")
    "/a" '(arrow-global-add    :which-key "add")
    "/j" '(arrow-jump-global    :which-key "add")
    "/d" '(arrow-global-delete :which-key "delete")
    "/c" '(arrow-global-clear-all :which-key "clear all")
    "/n" '(arrow-global-next   :which-key "next")
    "/p" '(arrow-global-prev   :which-key "prev")
    ;; arrow-Org
    "oo" '(arrow-org-list-project-notes :which-key "org list notes")
    "of" '(arrow-org-open-file          :which-key "org for this file")
    "oF" '(arrow-org-open-function      :which-key "org function for this file")
    "op" '(arrow-org-open-project       :which-key "org for this project")
    ;; Unified
    ";" '(arrow-jump :which-key "arrow global")

    ;; journal
    "j"  '(:ignore t :which-key "journal")
    "jt" '(journal-today :which-key "most recent")
    "jr" '(journal-recent :which-key "most recent")
    "jn" '(notes-recent :which-key "most recent")
    "jl" '(journal-list :which-key "journal list")

    ;; org
    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "oc" '(org-capture :which-key "capture")
    "od" '(deft :which-key "deft")
    "oD" '(deft-find-file :which-key "find-file")
    "ot" '(org-tags-view :which-key "org by tags")
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
    "pb" '(consult-project-buffer :which-key "find buffer in project")  ;; find buffer in project
    "pi" '(consult-imenu-multi :which-key "find buffer in project")  ;; find buffer in project
    "pf" '(project-find-file :which-key "find file in project")  ;; find file in project
    "pd" '(project-dired :which-key "project dired")             ;; open dired at project root
    "pk" '(project-kill-buffers :which-key "kill project buffers") ;; open dired at project root

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

    ;; single chars
    "SPC" '(execute-extended-command :which-key "M-x") ; A better M-x
    "s" '(consult-line :which-key "line")                ;; jump to contexts in file
    )


  (general-define-key
   :states '(normal visual)
   :keymaps 'override
   "gc" 'evil-commentary ;; comment region
   ;; window navigation (without resizing)
   "C-h"   'evil-window-left
   "C-j"   'evil-window-down
   "C-k"   'evil-window-up
   "C-l"   'evil-window-right))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
