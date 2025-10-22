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
            (setq gc-cons-threshold (* 8 1024 1024))
            (message "GC threshold restored to %S" gc-cons-threshold)))
