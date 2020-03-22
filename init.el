;;----------------------------------------- basic configurations -----------------------------------------------
(if (display-graphic-p)
    (progn
      (tool-bar-mode nil)                ;去掉工具栏
      (setq visible-bell t)              ;关闭出错时的提示声
      (setq frame-title-format "%f")     ;在标题栏显示完整的路径
      (setq x-select-enable-clipboard t) ;支持emacs和外部程序的粘贴
      (if (eq system-type 'gnu/linux)
	  (progn
	    ;; ubuntu窗口系统启动时最大化及字体设置
	    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(1 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
	    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(1 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
	    (set-frame-font "Ubuntu Mono-13"))
	(if (eq system-type 'windows-nt)
	    (progn
	      ;; windows窗口系统启动时最大化及字体设置
	      (run-with-idle-timer 0 nil 'w32-send-sys-command 61488)
	      (set-frame-font "Consolas-13")
	      (set-fontset-font "fontset-default" 'han '("Microsoft YaHei" . "unicode-bmp"))))))
  (menu-bar-mode 0))

(setq inhibit-startup-message t)     ;禁用启动画面
(global-font-lock-mode t)            ;语法高亮
(fset 'yes-or-no-p 'y-or-n-p)        ;以y/n代表yes/no
(show-paren-mode t)                  ;显示括号匹配
(blink-cursor-mode nil)              ;光标不闪
(setq mouse-yank-at-point t)         ;支持中键粘贴
(transient-mark-mode t)              ;transient:短暂的
(setq auto-save-default nil)         ;不生成名为#filename# 的临时文件
(setq backup-inhibited t)            ;不产生备份
(mouse-avoidance-mode 'animate)      ;光标靠近鼠标指针时,让鼠标指针自动让开
(setq user-full-name "zhujie")       ;设置用户名
(column-number-mode t)               ;显示列号
(size-indication-mode t)             ;显示文件大小
(setq eshell-buffer-maximum-lines 0) ;eshell中按"C-c C-t"清屏后保留的最大行数
(setq-default line-spacing 6)        ;设置行间距
(display-time-mode t)                ;显示时间
(global-auto-revert-mode t)          ;文件有修改时自动刷新
(prefer-coding-system 'utf-8)
(setq skeleton-pair t)               ;以下为设置括号自动补全
(global-set-key (kbd "(") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "[") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "{") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "\"") 'skeleton-pair-insert-maybe)


;;----------------------------------------- self-defined functions and their key-bindings -----------------------------------------------
(global-set-key (kbd "M-u") (lambda () (interactive) (upcase-word -1)))
(global-set-key (kbd "M-c") (lambda () (interactive) (capitalize-word -1)))
(global-set-key (kbd "C-M-l") (lambda () (interactive) (backward-up-list -1)))

;; 将"C-w"改成没有选择区域时剪切光标所在处单词，若选择了区域，则剪切区域内容
(global-set-key "\C-w"
                (lambda () (interactive)
                  (if mark-active (kill-region (region-beginning) (region-end))
                    (progn
		      (let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-word 1)) (point)))
			    (end (progn (forward-word 1) (point))))
			(kill-region beg end))
		      (message "kill word")))))

;; 将"M-w"改成没有选择区域时复制光标所在处单词，若选择了区域，则复制区域内容
(global-set-key "\M-w"
                (lambda () (interactive)
                  (if mark-active (kill-ring-save (region-beginning) (region-end))
                    (progn
		      (save-excursion
			(let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-word 1)) (point)))
			      (end (progn (forward-word 1) (point))))
			  (kill-ring-save beg end)))
		      (message "copy word")))))

;; 将"C-w"改成没有选择区域时剪切光标所在处单词(包括连接词组)，若选择了区域，则剪切区域内容
(global-set-key (kbd "C-M-w")
                (lambda () (interactive)
                  (if mark-active (kill-region (region-beginning) (region-end))
                    (progn
		      (let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-sexp)) (point)))
			    (end (progn (forward-sexp) (point))))
			(kill-region beg end))
		      (message "kill word")))))

;; ;; 将"ESC M-w"改成没有选择区域时复制光标所在处单词(包括连接词组)，若选择了区域，则复制区域内容
(global-set-key (kbd "ESC M-w")
                (lambda () (interactive)
                  (if mark-active (kill-ring-save (region-beginning) (region-end))
                    (progn
		      (save-excursion
			(let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-sexp)) (point)))
			      (end (progn (forward-sexp) (point))))
			  (kill-ring-save beg end)))
		      (message "copy word")))))

;; "M-l"设为复制光标所在位置一行
(global-set-key "\M-l"
                (lambda ()
                  (interactive)
                  (if mark-active
                      (kill-ring-save (region-beginning) (region-end))
                    (progn
                      (kill-ring-save (line-beginning-position) (line-end-position))
                      (message "copy line")))))

;; 将"M-p"设为复制一个段落
(global-set-key "\M-p"
                (lambda () (interactive)
                  (if mark-active (kill-ring-save (region-beginning) (region-end))
                    (progn
		      (save-excursion
			(let ((beg (progn (backward-paragraph 1) (point)))
			      (end (progn (forward-paragraph 1) (point))))
			  (copy-region-as-kill beg end)))
		      (message "copy paragraph")))))

;; 改变原本"\M-;"的注释方式:如果没有区域选中,当前行不为空且光标不在行末则注释该行
(global-set-key "\M-;"
		(lambda (&optional arg)
		  (interactive "*P")
		  (comment-normalize-vars)
		  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
		      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
		    (comment-dwim arg))))


;;----------------------------------------- built-in and third-party's packages -----------------------------------------------
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu" . "http://elpa.emacs-china.org/gnu/")))
(package-initialize)

(add-to-list 'load-path (concat user-emacs-directory "/not-in-elpa/use-package"))
(require 'use-package)

(use-package hydra
  :ensure t)

(use-package ivy
  :ensure t
  :bind (("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 ("M-y" . counsel-yank-pop)
	 ("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("M-y" . ivy-next-line))
  :diminish (ivy-mode . "")
  :config
  (ivy-mode 1)
  (setq ivy-use-virutal-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-height 10)
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-count-format "%d/%d"))

(use-package avy
  :ensure t
  :bind (("M-j" . avy-goto-char-2)
	 ("M-g f" . avy-goto-line)
	 ("M-g w" . avy-goto-word-1)
	 ("M-g e" . avy-goto-word-0))
  :config
  (avy-setup-default))

(use-package expand-region
  :ensure t
  :bind (("C-o" . er/expand-region)))

(add-to-list 'load-path (concat user-emacs-directory "/not-in-elpa/hungry-delete"))

(use-package iedit
  :load-path "not-in-elpa/iedit"
  :bind (("C-x ;" . iedit-mode)))

(use-package recentf
  :bind (("C-x C-r". recentf-open-files))
  :config
  (setq recentf-save-file "~/.emacs.d/.recentf")
  (setq recentf-max-saved-items 100)
  (recentf-mode 1))

(use-package company
  :ensure t
  :bind (:map company-active-map
	      ("M-n". nil)
	      ("M-p". nil)
	      ("C-n". 'company-select-next)
	      ("C-p". 'company-select-previous))
  :config
  (global-company-mode)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (setq company-backends '((company-dabbrev company-dabbrev-code company-capf company-files company-keywords company-gtags))))

(use-package ggtags
  :ensure t
  :config
  (add-hook 'asm-mode-hook 'ggtags-mode)
  (add-hook 'c-mode-hook 'ggtags-mode)
  (add-hook 'c++-mode-hook 'ggtags-mode)
  (add-hook 'java-mode-hook 'ggtags-mode))
