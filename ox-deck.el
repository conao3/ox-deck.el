;;; ox-deck.el --- Export markdown for deck from org-mode document  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>
;; Version: 0.0.1
;; Keywords: convenience
;; Package-Requires: ((emacs "30.1") (org "9.0") (ox-gfm "0.1"))
;; URL: https://github.com/conao3/ox-deck.el

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Export markdown for deck from org-mode document.


;;; Code:

(require 'ox-gfm)

(defgroup org-export-deckmd nil
  "Export markdown for deck from `org-mode' document.
deck: https://github.com/k1LoW/deck"
  :group 'convenience
  :link '(url-link :tag "Github" "https://github.com/conao3/ox-deck.el"))

(org-export-define-derived-backend 'deckmd 'gfm
  :menu-entry
  '(?d "Export to Deck Flavored Markdown"
       ((?G "To temporary buffer"
            (lambda (a s v b) (org-deck-export-as-markdown a s v)))
        (?g "To file" (lambda (a s v b) (org-deck-export-to-markdown a s v)))
        (?o "To file and open"
            (lambda (a s v b)
              (if a (org-deck-export-to-markdown t s v)
                (org-open-file (org-deck-export-to-markdown nil s v)))))))
  :translate-alist
  '((headline . org-deck-headline)))


;;; Transform functions

(defun org-deck-headline (headline contents info)
  "Make HEADLINE string.
CONTENTS is the headline contents.
INFO is a plist used as a communication channel."
  (let ((level (org-export-get-relative-level headline info))
        (title (org-export-data (org-element-property :title headline) info)))
    (if (= level 1)
        (mapconcat #'identity
                   (list "---"
                         ""
                         (format "# %s" title)
                         ""
                         contents)
                   "\n")
      (org-gfm-headline headline contents info))))


;;; Frontend

;;;###autoload
(defun org-deck-export-as-markdown (&optional async subtreep visible-only)
  "Export current buffer to a Deck Flavored Markdown buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Export is done in a buffer named \"*Org DeckMd Export*\", which will
be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (org-export-to-buffer 'deckmd "*Org DeckMD Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-deck-convert-region-to-md ()
  "Assume `org-mode' syntax, and convert it to Deck Flavored Markdown.
This can be used in any buffer.  For example, you can write an
itemized list in `org-mode' syntax in a Markdown buffer and use
this command to convert it."
  (interactive)
  (org-export-replace-region-by 'deckmd))

;;;###autoload
(defun org-deck-export-to-markdown (&optional async subtreep visible-only)
  "Export current buffer to a Deck Flavored Markdown file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'deckmd outfile async subtreep visible-only)))

;;;###autoload
(defun org-deck-publish-to-markdown (plist filename pub-dir)
  "Publish an org file to Markdown.
FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.
Return output file name."
  (org-publish-org-to 'deckmd filename ".md" plist pub-dir))

(provide 'ox-deck)

;;; ox-deck.el ends here
