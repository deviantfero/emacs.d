;;; package -- deviantfero's .init.el -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(require 'package)
(require 'mouse)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(setq evil-want-integration nil)
(setq-default org-agenda-file-regexp "~/org/.*.org$")

(package-initialize)

(eval-when-compile
  (require 'use-package))

;;; FUNCTION DEFINITIONS.
(defun my/use-eslint-from-node-modules ()
  "Use local eslint from node_modules before global."
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

(defun sudo-save ()
  "Use TRAMP to open a file with write access using sudo."
  (interactive)
  (if (not buffer-file-name)
      (write-file (concat "/sudo:root@localhost:" (ido-read-file-name)))
    (write-file (concat "/sudo:root@localhost:" (buffer-file-name)))))

(defun line-number-toggle ()
  "Toggle line numbers based on Emacs version."
  (interactive)
  (if (version<= "26.0.50" emacs-version)
      (display-line-numbers-mode)
    (nlinum-mode)))

(define-globalized-minor-mode global-outline-minor-mode
  outline-minor-mode outline-minor-mode)

(define-globalized-minor-mode global-xterm-mouse-mode
  xterm-mouse-mode xterm-mouse-mode)

(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*")) (abort-recursive-edit)))


;;; BASIC
(use-package helm
  :after (evil projectile)
  :ensure t
  :bind (:map evil-normal-state-map
	      ("K" . helm-do-ag)
	      ("C-g" . helm-projectile)
	      ("C-f" . helm-find-files)
	      ("C-o" . helm-buffers-list)
	      :map helm-map
	      ("TAB" . helm-execute-persistent-action)
              :map global-map
              ("M-x" . helm-M-x))
  :config (helm-mode 1))

(use-package smart-mode-line
  :ensure t
  :init
  (setq sml/no-confirm-load-theme t)
  :config
  (column-number-mode)
  (smart-mode-line-enable 1))

(use-package magit
  :bind (:map evil-normal-state-map
              ("<f9>" . magit))
  :ensure t)

(use-package nlinum
  :ensure t
  :config
  (setq nlinum-format "%3d  ")
  (add-hook 'prog-mode-hook (lambda () (nlinum-mode 1))))

(use-package dtrt-indent
  :ensure t
  :config (dtrt-indent-global-mode 1))

(use-package xclip
  :ensure t
  :config (xclip-mode 1))

(use-package projectile
  :ensure t)

(use-package multi-term
  :ensure t
  :config
  (setq multi-term-program "/bin/zsh"))

(use-package restclient
  :ensure t
  :mode (("\\.http\\'" . restclient-mode)
         ("\\.rest\\'" . restclient-mode))
  :config
  (setq outline-regexp "#[*\f]+"))

;;; COMPANY
(use-package company
  :ensure t
  :init
  (setq company-dabbrev-downcase nil)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq company-dabbrev-code-everywhere t)
  :config
  (global-company-mode 1))

(use-package company-anaconda
  :ensure t)

(use-package company-jedi
  :after company-anaconda
  :ensure t
  :config
  (add-to-list 'company-backends 'company-jedi))

(use-package company-tern
  :after (js2-mode rjsx-mode)
  :ensure t
  :config
  (add-to-list 'company-backends 'company-tern))

(use-package company-irony
  :ensure t)

(use-package flycheck
  :ensure t
  :init
  (setq flycheck-python-flake8-executable (executable-find "flake8"))
  (setq flycheck-python-pycompile-executable (executable-find "python3"))
  :config
  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  (global-flycheck-mode 1))

;;; EVIL
(use-package evil
  :ensure t
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "<f9>") 'magit-status)
  (define-key evil-insert-state-map (kbd "C-f") 'company-files)
  (define-key evil-normal-state-map (kbd "-") 'dired-jump)
  (define-key evil-normal-state-map (kbd "ga") 'align-regexp)
  (define-key evil-normal-state-map (kbd "gt") 'other-frame)
  (define-key evil-normal-state-map (kbd "C-w n") 'make-frame-command)
  (define-key evil-normal-state-map (kbd "C-w u") 'winner-undo)
  (define-key evil-normal-state-map (kbd "C-w C-r") 'winner-redo)
  (define-key evil-normal-state-map (kbd "TAB") 'org-cycle)
  (define-key evil-normal-state-map (kbd "<backtab>") 'org-global-cycle)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-insert-state-map (kbd "C-y") 'yas-insert-snippet))

(use-package evil-collection
  :after (evil helm)
  :ensure t
  :config
  (setq evil-collection-setup-minibuffer t)
  (evil-collection-init))

(use-package evil-org
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))


(use-package evil-magit
  :after (evil magit)
  :ensure t
  :config (evil-magit-init))


(use-package evil-surround
  :after evil
  :ensure t
  :config (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :ensure t
  :config (evil-commentary-mode 1))

;;; LANGUAGES.
(use-package elixir-mode
  :ensure t)

(use-package alchemist
  :after elixir-mode
  :ensure t
  :config
  (add-to-list 'company-backends 'alchemist-company))

(use-package js2-mode
  :ensure t
  :init
  (setq js2-mode-show-strict-warnings nil)
  (setq js2-mode-show-parse-errors 1)
  :config
  (add-hook 'js2-mode-hook 'my/use-eslint-from-node-modules)
  (add-hook 'js2-mode-hook 'tern-mode))

(use-package rjsx-mode
  :after js2-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode)))

(use-package vue-mode
  :after js-mode
  :ensure t)

(use-package irony
  :after company-irony
  :ensure t
  :config
  (add-to-list 'company-backends 'company-irony)
  (dolist (hook '(c++-mode-hook c-mode-hook objc-mode-hook))
    (add-hook hook 'irony-mode)))

(use-package conf-mode
  :ensure t
  :mode (("\\.env\\'" . conf-mode))
  :config
  (setq outline-regexp "[#\f]+")
  (define-key evil-normal-state-map (kbd "TAB") 'org-cycle))

;;;; NOTE-TAKING
(use-package pdf-tools
  :ensure t)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config (setq outline-regexp "[#\f]+"))

(use-package tex
  :ensure auctex
  :config
  (use-package latex
    :config
    (setq TeX-auto-save t)
    (setq TeX-parse-self t)
    (setq-default TeX-master nil)
    (setq-default TeX-engine "xetex")
    (setq-default TeX-save-query nil)
    (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
    (add-hook 'LaTeX-mode-hook 'flyspell-mode)
    (add-to-list 'TeX-view-program-list
                 '("my mupdf" ("mupdf" " %o" (mode-io-correlate " %(outpage)")))
                 (setcdr (assq 'output-pdf TeX-view-program-selection) '("my mupdf")))))

;;;; OTHER MODES
(electric-pair-mode 1)
(show-paren-mode 1)
(menu-bar-mode -1)
(toggle-tool-bar-mode-from-frame -1)
(yas-global-mode 1)
(xterm-mouse-mode 1)
(winner-mode 1)
(outline-minor-mode)

;;;; SETTING VARIABLES
(setq backup-directory-alist '(("." . "~/.emacs.d/saves")))
(setq backup-by-copying t)
(setq auto-save-default nil)
(setq create-lockfiles nil)
(setq inhibit-startup-message t)
(setq-default tab-width 4)
(dolist (basic-offset '(c-basic-offset sh-basic-offset))
  (defvaralias basic-offset 'tab-width))
(setq ispell-program-name (executable-find "hunspell")
      ispell-local-dictionary-alist
      '(("es_ES" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)
        ("en_EN" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8))
      ispell-dictionary "es_ES")

(toggle-scroll-bar nil)
(load-theme 'wpgtk t)



;;; AUTOMATICALLY GENERATED
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-engine (quote xetex))
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (wpgtk)))
 '(custom-safe-themes
   (quote
    ("d82be0f6d159afc8d3454341b61a85726f540acc1120173efcf13cb685a780e4" "b2d3cc213eb601663964102aa21f56d46ece7f15ef60a87fbd1c6212139cf5ac" "f91f0c73603d8007e81812342698f0e97eca5ef5ee17b9d240c35ea86cdd04a9" "b7d13664d4c1ab4f5043560012f47c48b3975a3b76cb7aa0513f4e9b44084ff4" "3c362bc8b8641f8674a25c0764918c43404343e8f0c507d842a0d39213ca004f" "31727b11df14e9c72e26e5fe54be088bc64a46bad4cc1c3c1668b21e401d8dbd" "01ac01d5685319b831ba8da231a5445e6731359c5d086eca8dbbf616475edbc4" "9851704f68d5dc28a6906c9b82bb624c9b02c0f56111d662cc5cc8549d61bdc9" "d77b456aeabc9d5686f3a0e55200f96a7dc1e44258f546e5e99d6ae9b3a8e69f" "1d45727504db1f6528410b9f8fbcea82b1e3ff0741000278311a8394c7876cf1" "cbf94cf658e1f858a39b63670c7c326cc838fa1bd1170d097f0fd335adc81df9" "201c7538c3196f8f5f1c949e72f033eabad77622e9bbee600d5e457d6dfdd570" "5f295bb1303e8ea912e7fab806008eb9dc584d772eff4f42959bc15ba766f5ce" "f3a15f89d7e0062256c5eff2cf72a854e5bec72cc6b203a6e785bf3a27f81cfe" "c499720368e09a56ec362ee23c7a44202419108844ef7c09c623bc10bbacde77" "28351cdec72c9628101e0d82a0616628ff7ffbe29160366d7d8189b24330c430" "9724a104d6a69ed0c2cc90842b6881e9f2985b3e205dd96b9be403c11c79a22a" "6e2c04db23101a0cce6645fc622ce90b933e41216f862b4267c2f175e755207b" "fa22f350fb34c44363a26e7c8742c528f72f235b08a1c59731617c1f59595427" "e53709dc67a9345e89967782b1f43670b5330e9778a24f0ec173da789a42227c" "70a9a887bd6f7153fbabe60b01bf7ca6688e1e34b41a731a18b87d6ec1d97fe5" "c3d103e1d95596aa17df3fe5adbe6b780b1f6dfd5e13f3d03cf359edcec4f36e" "08c3aa56c6d9211e6c942a8a4e21c88ae46cdc903c2539bb543ed3012fd06b44" "c15e8e951ff27e9ac6311a71d94e52a66f6465e37b3acda410774ad9f4731a5d" "0c85de10851cf504c53a79d7af40c901b321ceda695c7b2f09ac1d9c08a91ea7" "ea27b445edb93b38cf8c6f087e188eacb6b3a389ff78473987e69c82f29c9200" "8aa7251074b0f3304948e6bad6540c9cec964112677884cd39c32ac2e480c2ae" "f9376799d2ac86f104b58e9d4742677c66808cdd2b12cb0f3e2364d0e771279b" "a1d1c523e2b234464b19090cd27c70d22b85840dd40614cd287457210ed3620c" "6e562c29348052159de4e6b8e86df36e1eea300b98454e92ae03b0fd8e141271" "d140e64e4e1c29a564ead7104dd08d063e7432334144bc16280b3cba49fcfeb2" "8c62da104514ece86adc596d38d403b8c07d0107685b197adbcdf9ef226c18a6" "4c9363a2de6807560eb127a4e79e7cf2afff4505ca112e22ec187236ad4b8b51" "a9f5ae1da25e28d22850dd9542b078b2563de99530b898b23c2394e724f9d65c" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "6b66f49729b5dc928b8c793581064254a1788fddb1eaa0b7bfd807494f36c8a9" default)))
 '(evil-collection-setup-minibuffer t)
 '(magit-diff-section-arguments (quote ("--no-ext-diff")))
 '(package-selected-packages
   (quote
    (yasnippet async with-editor mmm-mode vue-html-mode ssass-mode edit-indirect vue-mode bind-key undo-tree tern tablist rich-minority s faceup quelpa dash f pythonic deferred python-environment epl pkg-info pos-tip popup markdown-mode magit-popup ghub git-commit json-snatcher json-reformat concurrent ctable epc jedi-core helm-core goto-chg evil-org dash-functional anaconda-mode auctex shell-mode pdf-tools company-anaconda multi-term yaml-mode latex restclient company-irony irony company-quickhelp quelpa-use-package helm-projectile company-tern xclip use-package nlinum evil-commentary evil-collection json-mode rjsx-mode projectile web-mode helm-ag evil-surround smart-mode-line dtrt-indent 0blayout flycheck auto-org-md evil-magit magit js2-mode company-jedi racket-mode yasnippet-classic-snippets alchemist elixir-mode helm-mode-manager company-go seoul256-theme python-mode react-snippets helm yasnippet-snippets company slime evil elpy)))
 '(scroll-bar-mode nil)
 '(setq ansi-term-color-vector)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Menlo" :foundry "PfEd" :slant normal :weight normal :height 82 :width normal)))))
(provide 'init)

;;; init.el ends here
