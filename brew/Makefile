all: env-filter.html

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

legacy-homebrew/.git/config:
	git clone https://github.com/Homebrew/legacy-homebrew.git

brew/.git/config:
	git clone https://github.com/Homebrew/brew.git

%.tsv: %/.git/config
	(cd $* &&  \
		printf 'SHA1\tSubject\tAuthor_name\tAuthor_email\tAuthor_date\tCommitter_name\tCommitter_email\tCommitter_date\n'; \
		git log --pretty='%H%x09%s%x09%an%x09%ae%x09%at%x09%cn%x09%ce%x09%ct') >$@

%.html: %.rmd
	Rscript -e 'rmarkdown::render("$<")'

env-filter.html: legacy-homebrew.tsv brew.tsv
