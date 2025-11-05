;; -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil) ;; disable built-in package.el

;; =========================================================
;; Performance tweaks to run early in init
;; =========================================================

(setq gc-cons-threshold most-positive-fixnum) ;; temporarily increase GC threshold to max possible to avoid GC during startup
(setq package-native-compile t) ;; enable native compilation

;; restore GC threshold after init to a high but reasonable value (8MB here)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 8 1024 1024))))


;; -----------------------------
;; Default UI/UX behaviour
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
;;(add-to-list 'initial-frame-alist '(fullscreen . maximized))
