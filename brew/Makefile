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

# Lift over commits that differ between Homebrew/legacy-homebrew and Homebrew/brew.
linuxbrew-brew/.git/config: linuxbrew/.git/config env-filter.sh
	cp -a linuxbrew linuxbrew-brew
	cd linuxbrew-brew && git remote add legacy-homebrew https://github.com/Homebrew/legacy-homebrew.git
	cd linuxbrew-brew && git fetch legacy-homebrew
	cd linuxbrew-brew && git remote add brew https://github.com/Homebrew/brew.git
	cd linuxbrew-brew && git fetch brew
	# Change #123 to Linuxbrew/linuxbrew#123.
	cd linuxbrew-brew && git filter-branch --msg-filter 'sed -Ee "s~ (#[0-9]+)~ Linuxbrew/linuxbrew\1~g"' -- legacy-homebrew/master..
	# Change #123 to Homebrew/homebrew#123.
	# Remove Library/Formula and Library/Aliases.
	# Correct committer author and date.
	cd linuxbrew-brew && git filter-branch -f --prune-empty \
		--msg-filter 'sed -Ee "s~ (#[0-9]+)~ Homebrew/homebrew\1~g"' \
		--index-filter 'git rm --cached --ignore-unmatch -r -q -- Library/Formula Library/Aliases' \
		--env-filter ". $(PWD)/env-filter.sh" \
		-- --all
	# Remove empty merge commits after 001b8de Merge branch 'qt5'.
	cd linuxbrew-brew && git filter-branch -f --prune-empty --parent-filter $(PWD)/independent-parents -- 001b8de679e776516ae266699e40d403945137d2..
