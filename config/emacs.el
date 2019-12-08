;; set backup directory
(setq backup-directory-alist '((".*" . "~/.emacs.d/backup")))

;; set autosave directory
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save/" t)))

;; don't show the startup message
(setq inhibit-startup-message t)

;; don't show useless toolbar
(tool-bar-mode -1)

;; setup melpa package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; set dark theme
(load-theme 'dracula t)

(require 'use-package)

;; LSP configuration
(use-package lsp-mode
  :hook (c++-mode . lsp)
  :hook (c-mode . lsp)
  :hook (python-mode . lsp)
  :hook (rust-mode . lsp)
  :commands lsp)


