all: env-filter.html linuxbrew-core.tsv

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

legacy-homebrew/.git/config:
	git clone https://github.com/Homebrew/legacy-homebrew.git

homebrew-core/.git/config:
	git clone https://github.com/Homebrew/homebrew-core.git

linuxbrew/.git/config:
	git clone https://github.com/Linuxbrew/linuxbrew.git

%.tsv: %/.git/config
	(cd $* &&  \
		printf 'SHA1\tSubject\tAuthor_name\tAuthor_email\tAuthor_date\tCommitter_name\tCommitter_email\tCommitter_date\n'; \
		git log --pretty='%H%x09%s%x09%an%x09%ae%x09%at%x09%cn%x09%ce%x09%ct') >$@

%.html %.sh %.tsv: %.rmd
	Rscript -e 'rmarkdown::render("$<")'
	chmod +x $*.sh

env-filter.html: legacy-homebrew.tsv homebrew-core.tsv

linuxbrew-core/.git/config: linuxbrew/.git/config env-filter.sh
	cp -a linuxbrew linuxbrew-core
	cd linuxbrew-core && ../git-filter-branch-core
