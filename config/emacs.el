;; don't write stupid ~ files
(setq make-backup-files nil)

;; don't show the startup message
(setq inhibit-startup-message t)

;; don't show useless toolbar
(tool-bar-mode -1)

;; setup melpa package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; LSP configuration
(require 'lsp-mode)
(add-hook 'c++-mode-hook #'lsp-deferred)
(add-hook 'c-mode-hook #'lsp-deferred)
(add-hook 'python-mode-hook #'lsp-deferred)
(add-hook 'rust-mode-hook #'lsp-deferred)

