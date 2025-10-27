;; -*- lexical-binding: t; -*-

;; disable built-in package.el
;; (setq package-enable-at-startup nil)

;; =========================================================
;; Performance tweaks to run early in init
;; =========================================================

;; temporarily increase GC threshold to max possible to avoid GC during startup
(setq gc-cons-threshold most-positive-fixnum)

;; enable native compilation
(setq package-native-compile t)

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
