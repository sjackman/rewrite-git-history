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

# 0f293a9 add LICENSE.txt
# a9a2262 gdm 1.3
# 39563d2 texlive: Fix style issues for Linuxbrew
linuxbrew-core/.git/config: linuxbrew/.git/config env-filter.sh
	cp -a linuxbrew linuxbrew-core
	cd linuxbrew-core && ../git-filter-branch-core
	cd linuxbrew-core && ../git-insert-commit 0f293a9b3d8904f50bc53fbc8154e224b8493bec a9a22623229bf494cc56a6ae1df3ad4e13d0ab39 --not 39563d2ccaea9cbe7fe3399884f736aacd845527
	cd linuxbrew-core && git filter-branch -f --tree-filter "cp -a $$PWD/../data/* ." 0f293a9b3d8904f50bc53fbc8154e224b8493bec.. --not 39563d2ccaea9cbe7fe3399884f736aacd845527
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 5199b5138fd0e1c23127be51f540221f67978831:tap_migrations.json" 5199b5138fd0e1c23127be51f540221f67978831.. --not 39563d2ccaea9cbe7fe3399884f736aacd845527
