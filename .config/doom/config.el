(map! :leader
      (:prefix ("b". "buffer")
       :desc "List bookmarks" "L" #'list-bookmarks
       :desc "Save current bookmarks to bookmark file" "w" #'bookmark-save))

;; https://stackoverflow.com/questions/9547912/emacs-calendar-show-more-than-3-months
(defun dt/year-calendar (&optional year)
  (interactive)
  (require 'calendar)
  (let* (
      (current-year (number-to-string (nth 5 (decode-time (current-time)))))
      (month 0)
      (year (if year year (string-to-number (format-time-string "%Y" (current-time))))))
    (switch-to-buffer (get-buffer-create calendar-buffer))
    (when (not (eq major-mode 'calendar-mode))
      (calendar-mode))
    (setq displayed-month month)
    (setq displayed-year year)
    (setq buffer-read-only nil)
    (erase-buffer)
    ;; horizontal rows
    (dotimes (j 4)
      ;; vertical columns
      (dotimes (i 3)
        (calendar-generate-month
          (setq month (+ month 1))
          year
          ;; indentation / spacing between months
          (+ 5 (* 25 i))))
      (goto-char (point-max))
      (insert (make-string (- 10 (count-lines (point-min) (point-max))) ?\n))
      (widen)
      (goto-char (point-max))
      (narrow-to-region (point-max) (point-max)))
    (widen)
    (goto-char (point-min))
    (setq buffer-read-only t)))

(defun dt/scroll-year-calendar-forward (&optional arg event)
  "Scroll the yearly calendar by year in a forward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (unless arg (setq arg 0))
  (save-selected-window
    (if (setq event (event-start event)) (select-window (posn-window event)))
    (unless (zerop arg)
      (let* (
              (year (+ displayed-year arg)))
        (dt/year-calendar year)))
    (goto-char (point-min))
    (run-hooks 'calendar-move-hook)))

(defun dt/scroll-year-calendar-backward (&optional arg event)
  "Scroll the yearly calendar by year in a backward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (dt/scroll-year-calendar-forward (- (or arg 1)) event))

(map! :leader
      :desc "Scroll year calendar backward" "<left>" #'dt/scroll-year-calendar-backward
      :desc "Scroll year calendar forward" "<right>" #'dt/scroll-year-calendar-forward)

(defalias 'year-calendar 'dt/year-calendar)

(setq centaur-tabs-set-bar 'over
      centaur-tabs-set-icons t
      centaur-tabs-gray-out-icons 'buffer
      centaur-tabs-height 24
      centaur-tabs-set-modified-marker t
      centaur-tabs-style "bar"
      centaur-tabs-modified-marker "•")
(map! :leader
      :desc "Toggle tabs globally" "t c" #'centaur-tabs-mode
      :desc "Toggle tabs local display" "t C" #'centaur-tabs-local-mode)
(evil-define-key 'normal centaur-tabs-mode-map (kbd "g <right>") 'centaur-tabs-forward        ; default Doom binding is 'g t'
                                               (kbd "g <left>")  'centaur-tabs-backward       ; default Doom binding is 'g T'
                                               (kbd "g <down>")  'centaur-tabs-forward-group
                                               (kbd "g <up>")    'centaur-tabs-backward-group)

(use-package dashboard
  :init      ;; tweak dashboard config before loading it
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.config/doom/doom-emacs-dash.png")  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 5)
                          (projects . 5)
                          (registers . 5)))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
			      (bookmarks . "book"))))

(setq doom-fallback-buffer "*dashboard*")

(map! :leader
      (:prefix ("d" . "dired")
       :desc "Open dired" "d" #'dired
       :desc "Dired jump to current" "j" #'dired-jump)
      (:after dired
       (:map dired-mode-map
        :desc "Peep-dired image previews" "d p" #'peep-dired
        :desc "Dired view file" "d v" #'dired-view-file)))
;; Make 'h' and 'l' go back and forward in dired. Much faster to navigate the directory structure!
(evil-define-key 'normal dired-mode-map
  (kbd "M-RET") 'dired-display-file
  (kbd "h") 'dired-up-directory
  (kbd "l") 'dired-open-file ; use dired-find-file instead of dired-open.
  (kbd "m") 'dired-mark
  (kbd "t") 'dired-toggle-marks
  (kbd "u") 'dired-unmark
  (kbd "C") 'dired-do-copy
  (kbd "D") 'dired-do-delete
  (kbd "J") 'dired-goto-file
  (kbd "M") 'dired-chmod
  (kbd "O") 'dired-chown
  (kbd "P") 'dired-do-print
  (kbd "R") 'dired-rename
  (kbd "T") 'dired-do-touch
  (kbd "Y") 'dired-copy-filenamecopy-filename-as-kill ; copies filename to kill ring.
  (kbd "+") 'dired-create-directory
  (kbd "-") 'dired-up-directory
  (kbd "% l") 'dired-downcase
  (kbd "% u") 'dired-upcase
  (kbd "; d") 'epa-dired-do-decrypt
  (kbd "; e") 'epa-dired-do-encrypt)
;; If peep-dired is enabled, you will get image previews as you go up/down with 'j' and 'k'
(evil-define-key 'normal peep-dired-mode-map
  (kbd "j") 'peep-dired-next-file
  (kbd "k") 'peep-dired-prev-file)
(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "sxiv")
                              ("jpg" . "sxiv")
                              ("png" . "sxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

(setq doom-theme 'doom-one)
(map! :leader
      :desc "Load new theme" "h t" #'counsel-load-theme)

(use-package emojify
  :hook (after-init . global-emojify-mode))

(use-package! elfeed-goodies)
(elfeed-goodies/setup)
(setq elfeed-goodies/entry-pane-size 0.5)
(add-hook 'elfeed-show-mode-hook 'visual-line-mode)
(evil-define-key 'normal elfeed-show-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(evil-define-key 'normal elfeed-search-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(setq elfeed-feeds (quote
                    (("https://www.reddit.com/r/linux.rss" reddit linux)
                     ("https://www.reddit.com/r/commandline.rss" reddit commandline)
                     ("https://www.reddit.com/r/distrotube.rss" reddit distrotube)
                     ("https://www.reddit.com/r/emacs.rss" reddit emacs)
                     ("https://www.gamingonlinux.com/article_rss.php" gaming linux)
                     ("https://hackaday.com/blog/feed/" hackaday linux)
                     ("https://opensource.com/feed" opensource linux)
                     ("https://linux.softpedia.com/backend.xml" softpedia linux)
                     ("https://itsfoss.com/feed/" itsfoss linux)
                     ("https://www.zdnet.com/topic/linux/rss.xml" zdnet linux)
                     ("https://www.phoronix.com/rss.php" phoronix linux)
                     ("http://feeds.feedburner.com/d0od" omgubuntu linux)
                     ("https://www.computerworld.com/index.rss" computerworld linux)
                     ("https://www.networkworld.com/category/linux/index.rss" networkworld linux)
                     ("https://www.techrepublic.com/rssfeeds/topic/open-source/" techrepublic linux)
                     ("https://betanews.com/feed" betanews linux)
                     ("http://lxer.com/module/newswire/headlines.rss" lxer linux)
                     ("https://distrowatch.com/news/dwd.xml" distrowatch linux))))

(emms-all)
(emms-default-players)
(emms-mode-line 1)
(emms-playing-time 1)
(setq emms-source-file-default-directory "~/Music/Non-Classical/70s-80s/"
      emms-playlist-buffer-name "*Music*"
      emms-info-asynchronously t
      emms-source-file-directory-tree-function 'emms-source-file-directory-tree-find)
(map! :leader
      (:prefix ("a" . "EMMS audio player")
       :desc "Go to emms playlist" "a" #'emms-playlist-mode-go
       :desc "Emms pause track" "x" #'emms-pause
       :desc "Emms stop track" "s" #'emms-stop
       :desc "Emms play previous track" "p" #'emms-previous
       :desc "Emms play next track" "n" #'emms-next))

(map! :leader
      (:prefix ("e". "evaluate/EWW")
       :desc "Evaluate elisp in buffer" "b" #'eval-buffer
       :desc "Evaluate defun" "d" #'eval-defun
       :desc "Evaluate elisp expression" "e" #'eval-expression
       :desc "Evaluate last sexpression" "l" #'eval-last-sexp
       :desc "Evaluate elisp in region" "r" #'eval-region))

(setq browse-url-browser-function 'eww-browse-url)
(map! :leader
      :desc "Search web for text between BEG/END"
      "s w" #'eww-search-words
      (:prefix ("e" . "evaluate/EWW")
       :desc "Eww web browser" "w" #'eww
       :desc "Eww reload page" "R" #'eww-reload))

(setq doom-font (font-spec :family "Source Code Pro" :size 15)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 15)
      doom-big-font (font-spec :family "Source Code Pro" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))
(setq global-prettify-symbols-mode t)

(setq ivy-posframe-display-functions-alist
      '((swiper                     . ivy-posframe-display-at-point)
        (complete-symbol            . ivy-posframe-display-at-point)
        (counsel-M-x                . ivy-display-function-fallback)
        (counsel-esh-history        . ivy-posframe-display-at-window-center)
        (counsel-describe-function  . ivy-display-function-fallback)
        (counsel-describe-variable  . ivy-display-function-fallback)
        (counsel-find-file          . ivy-display-function-fallback)
        (counsel-recentf            . ivy-display-function-fallback)
        (counsel-register           . ivy-posframe-display-at-frame-bottom-window-center)
        (dmenu                      . ivy-posframe-display-at-frame-top-center)
        (nil                        . ivy-posframe-display))
      ivy-posframe-height-alist
      '((swiper . 20)
        (dmenu . 20)
        (t . 10)))
(ivy-posframe-mode 1) ; 1 enables posframe-mode, 0 disables it.

(map! :leader
      (:prefix ("v" . "Ivy")
       :desc "Ivy push view" "v p" #'ivy-push-view
       :desc "Ivy switch view" "v s" #'ivy-switch-view))

(setq display-line-numbers-type t)
(map! :leader
      :desc "Comment or uncomment lines" "TAB TAB" #'comment-line
      (:prefix ("t" . "toggle")
       :desc "Toggle line numbers" "l" #'doom/toggle-line-numbers
       :desc "Toggle line highlight in frame" "h" #'hl-line-mode
       :desc "Toggle line highlight globally" "H" #'global-hl-line-mode
       :desc "Toggle truncate lines" "t" #'toggle-truncate-lines))

(after! mastodon
  (setq mastodon-instance-url "https://distrotoot.com"))

(xterm-mouse-mode 1)

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
;;(require 'smtpmail)
(setq user-mail-address "derek@distrotube.com"
      user-full-name  "Derek Taylor"
      ;; I have my mbsyncrc in a different folder on my system, to keep it separate from the
      ;; mbsyncrc available publicly in my dotfiles. You MUST edit the following line.
      ;; Be sure that the following command is: "mbsync -c ~/.config/mu4e/mbsyncrc -a"
      mu4e-get-mail-command "mbsync -c ~/.config/mu4e-dt/mbsyncrc -a"
      mu4e-update-interval  300
      mu4e-main-buffer-hide-personal-addresses t
      message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-starttls-credentials '(("smtp.1and1.com" 587 nil nil))
      mu4e-sent-folder "/account-1/Sent"
      mu4e-drafts-folder "/account-1/Drafts"
      mu4e-trash-folder "/account-1/Trash"
      mu4e-maildir-shortcuts
      '(("/account-1/Inbox"      . ?i)
        ("/account-1/Sent Items" . ?s)
        ("/account-1/Drafts"     . ?d)
        ("/account-1/Trash"      . ?t)))

;; (defvar my-mu4e-account-alist
;;   '(("acc1-domain"
;;      (mu4e-sent-folder "/acc1-domain/Sent")
;;      (mu4e-drafts-folder "/acc1-domain/Drafts")
;;      (mu4e-trash-folder "/acc1-domain/Trash")
;;      (mu4e-compose-signature
;;        (concat
;;          "Ricky Bobby\n"
;;          "acc1@domain.com\n"))
;;      (user-mail-address "acc1@domain.com")
;;      (smtpmail-default-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-user "acc1@domain.com")
;;      (smtpmail-stream-type starttls)
;;      (smtpmail-smtp-service 587))
;;     ("acc2-domain"
;;      (mu4e-sent-folder "/acc2-domain/Sent")
;;      (mu4e-drafts-folder "/acc2-domain/Drafts")
;;      (mu4e-trash-folder "/acc2-domain/Trash")
;;      (mu4e-compose-signature
;;        (concat
;;          "Suzy Q\n"
;;          "acc2@domain.com\n"))
;;      (user-mail-address "acc2@domain.com")
;;      (smtpmail-default-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-user "acc2@domain.com")
;;      (smtpmail-stream-type starttls)
;;      (smtpmail-smtp-service 587))
;;     ("acc3-domain"
;;      (mu4e-sent-folder "/acc3-domain/Sent")
;;      (mu4e-drafts-folder "/acc3-domain/Drafts")
;;      (mu4e-trash-folder "/acc3-domain/Trash")
;;      (mu4e-compose-signature
;;        (concat
;;          "John Boy\n"
;;          "acc3@domain.com\n"))
;;      (user-mail-address "acc3@domain.com")
;;      (smtpmail-default-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-server "smtp.domain.com")
;;      (smtpmail-smtp-user "acc3@domain.com")
;;      (smtpmail-stream-type starttls)
;;      (smtpmail-smtp-service 587))))

(load "~/.config/doom/email")

(defun my-mu4e-set-account ()
  "Set the account for composing a message."
  (let* ((account
          (if mu4e-compose-parent-message
              (let ((maildir (mu4e-message-field mu4e-compose-parent-message :maildir)))
                (string-match "/\\(.*?\\)/" maildir)
                (match-string 1 maildir))
            (completing-read (format "Compose with account: (%s) "
                                     (mapconcat #'(lambda (var) (car var))
                                                my-mu4e-account-alist "/"))
                             (mapcar #'(lambda (var) (car var)) my-mu4e-account-alist)
                             nil t nil nil (caar my-mu4e-account-alist))))
         (account-vars (cdr (assoc account my-mu4e-account-alist))))
    (if account-vars
        (mapc #'(lambda (var)
                  (set (car var) (cadr var)))
              account-vars)
      (error "No email account found"))))

(add-hook 'mu4e-compose-pre-hook 'my-mu4e-set-account)

(after! neotree
  (setq neo-smart-open t
        neo-window-fixed-size nil))
(after! doom-themes
  (setq doom-neotree-enable-variable-pitch t))
(map! :leader
      :desc "Toggle neotree file viewer" "t n" #'neotree-toggle
      :desc "Open directory in neotree" "d n" #'neotree-dir)

(map! :leader
      (:prefix ("-" . "open file")
       :desc "Edit agenda file" "a" #'(lambda () (interactive) (find-file "~/Org/agenda.org"))
       :desc "Edit doom config.org" "c" #'(lambda () (interactive) (find-file "~/.config/doom/config.org"))
       :desc "Edit eshell aliases" "e a" #'(lambda () (interactive) (find-file "~/.config/doom/eshell/aliases"))
       :desc "Edit eshell aliases" "e p" #'(lambda () (interactive) (find-file "~/.config/doom/eshell/profile"))
       :desc "Edit doom init.el" "i" #'(lambda () (interactive) (find-file "~/.config/doom/init.el"))
       :desc "Edit doom packages.el" "p" #'(lambda () (interactive) (find-file "~/.config/doom/packages.el"))))

(map! :leader
      :desc "Org babel tangle" "m B" #'org-babel-tangle)
(after! org
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-directory "~/Org/"
        org-agenda-files '("~/Org/agenda.org")
        org-default-notes-file (expand-file-name "notes.org" org-directory)
        org-ellipsis " ▼ "
        org-log-done 'time
        org-journal-dir "~/Org/journal/"
        org-journal-date-format "%B %d, %Y (%A) "
        org-journal-file-format "%Y-%m-%d.org"
        org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]
        org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
          '(("google" . "http://www.google.com/search?q=")
            ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
            ("ddg" . "https://duckduckgo.com/?q=")
            ("wiki" . "https://en.wikipedia.org/wiki/"))
        org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
          '((sequence
             "TODO(t)"           ; A task that is ready to be tackled
             "BLOG(b)"           ; Blog writing assignments
             "GYM(g)"            ; Things to accomplish at the gym
             "PROJ(p)"           ; A project that contains other tasks
             "VIDEO(v)"          ; Video assignments
             "WAIT(w)"           ; Something is holding up this task
             "|"                 ; The pipe necessary to separate "active" states and "inactive" states
             "DONE(d)"           ; Task has been completed
             "CANCELLED(c)" )))) ; Task has been cancelled

(use-package ox-man)
(use-package ox-gemini)

(map! :leader
      (:prefix ("r" . "registers")
       :desc "Copy to register" "c" #'copy-to-register
       :desc "Frameset to register" "f" #'frameset-to-register
       :desc "Insert contents of register" "i" #'insert-register
       :desc "Jump to register" "j" #'jump-to-register
       :desc "List registers" "l" #'list-registers
       :desc "Number to register" "n" #'number-to-register
       :desc "Interactively choose a register" "r" #'counsel-register
       :desc "View a register" "v" #'view-register
       :desc "Window configuration to register" "w" #'window-configuration-to-register
       :desc "Increment register" "+" #'increment-register
       :desc "Point to register" "SPC" #'point-to-register))

(map! :leader
      (:prefix ("\\" . "ssh")
       :desc "Ssh into distrotube.com" "\\ d" #'(lambda () (interactive) (find-file "/scp:derek@distrotube.com"))
       :desc "Ssh into my nextcloud" "\\ n" #'(lambda () (interactive) (find-file "/scp:derek@distrotube.net"))))

(setq shell-file-name "/bin/fish"
      vterm-max-scrollback 5000)
(setq eshell-rc-script "~/.config/doom/eshell/profile"
      eshell-aliases-file "~/.config/doom/eshell/aliases"
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))
(map! :leader
      :desc "Eshell" "e s" #'eshell
      :desc "Counsel eshell history" "e h" #'counsel-esh-history)

(defun prefer-horizontal-split ()
  (set-variable 'split-height-threshold nil t)
  (set-variable 'split-width-threshold 40 t)) ; make this as low as needed
(add-hook 'markdown-mode-hook 'prefer-horizontal-split)
(map! :leader
      :desc "Clone indirect buffer other window" "b c" #'clone-indirect-buffer-other-window)

(map! :leader
      (:prefix ("w" . "window")
       :desc "Winner redo" "<right>" #'winner-redo
       :desc "Winner undo" "<left>" #'winner-undo))
