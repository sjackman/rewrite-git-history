all: linuxbrew-brew/.git/config linuxbrew-core/.git/config

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

legacy-homebrew/.git/config:
	git clone https://github.com/Homebrew/legacy-homebrew.git

brew/.git/config:
	git clone https://github.com/Homebrew/brew.git

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

brew-env-filter.sh: legacy-homebrew.tsv brew.tsv

core-env-filter.sh: legacy-homebrew.tsv homebrew-core.tsv

# Lift over commits that differ between Homebrew/legacy-homebrew and Homebrew/brew.
linuxbrew-brew/.git/config: linuxbrew/.git/config brew-env-filter.sh
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
		--env-filter ". $(PWD)/brew-env-filter.sh" \
		-- --all
	# Remove empty merge commits after 001b8de Merge branch 'qt5'.
	cd linuxbrew-brew && git filter-branch -f --prune-empty --parent-filter $(PWD)/independent-parents -- 001b8de679e776516ae266699e40d403945137d2..

# Lift over commits that differ between legacy-homebrew and homebrew-core.
# a9bfaf1 add formula_renames.json and tap_migrations.json
# 0f293a9 add LICENSE.txt
# 5199b51 mlton 20130715 (new formula)
# 26e0c51 update tap_migrations
# 1413b79 libodbc++: boneyard
# 71e2276 Merge remote-tracking branch 'origin/master'
# ef98654 imapsync: update 1.678 bottle.
# 2323ae2 update tap_migrations
linuxbrew-core/.git/config: linuxbrew/.git/config core-env-filter.sh
	cp -a linuxbrew linuxbrew-core
	cd linuxbrew-core && git remote add legacy-homebrew https://github.com/Homebrew/legacy-homebrew.git
	cd linuxbrew-core && git fetch legacy-homebrew
	cd linuxbrew-core && git remote add homebrew-core https://github.com/Homebrew/homebrew-core.git
	cd linuxbrew-core && git fetch homebrew-core
	# Change #123 to Linuxbrew/linuxbrew#123.
	cd linuxbrew-core && git filter-branch -f --msg-filter 'sed -Ee "s~ (#[0-9]+)~ Linuxbrew/linuxbrew\1~g"' -- legacy-homebrew/master..master
	# Change #123 to Homebrew/homebrew#123.
	# Remove all files except Library/Formula and Library/Aliases.
	# Correct committer author and date.
	cd linuxbrew-core && git filter-branch -f --prune-empty \
		--msg-filter 'sed -Ee "s~ (#[0-9]+)~ Homebrew/homebrew\1~g"' \
		--index-filter 'git rm --cached --ignore-unmatch -r -q -- . ; git reset -q $$GIT_COMMIT -- Library/Formula Library/Aliases;' \
		--env-filter ". $(PWD)/core-env-filter.sh" \
		-- --all
	# Reroot on Library.
	cd linuxbrew-core && git filter-branch -f --prune-empty --subdirectory-filter Library -- --all
	# Graft a9bfaf1 add formula_renames.json and tap_migrations.json
	# and 0f293a9 add LICENSE.txt
	# onto 47e3f93 libxslt: update 1.1.28_1 bottle.
	cd linuxbrew-core && git filter-branch -f --parent-filter 's/47e3f93a2d465ee46c281b5150b7f975633089ac/0f293a9b3d8904f50bc53fbc8154e224b8493bec/' -- --ancestry-path 47e3f93a2d465ee46c281b5150b7f975633089ac..
	# Add formula_renames.json from a9bfaf1 add formula_renames.json and tap_migrations.json
	# Add LICENSE.txt from 0f293a9 add LICENSE.txt
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 0f293a9 LICENSE.txt formula_renames.json" --ancestry-path 0f293a9b3d8904f50bc53fbc8154e224b8493bec..
	# Add formula_renames.json from a9bfaf1 add formula_renames.json and tap_migrations.json
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout a9bfaf1 tap_migrations.json" -- --ancestry-path a9bfaf1504d66c6788daa3600befeb06f56289d4..
	# Update formula_renames.json from 5199b51 mlton 20130715 (new formula)
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 5199b51 tap_migrations.json" -- --ancestry-path 5199b5138fd0e1c23127be51f540221f67978831~1..
	# Graft 26e0c51 update tap_migrations
	# onto 0b7525c lbdb: add 0.41 bottle.
	cd linuxbrew-core && git filter-branch -f --parent-filter 's/0b7525c43259b4c36f61741f8c94001d12825e6b/26e0c5121720940aabd693ce911eb1a34bc7ff5b/' -- --ancestry-path 0b7525c43259b4c36f61741f8c94001d12825e6b..
	# Update tap_migrations.json from 26e0c51 update tap_migrations
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 26e0c51 tap_migrations.json" -- --ancestry-path 26e0c5121720940aabd693ce911eb1a34bc7ff5b..
	# Update formula_renames.json from 1413b79 libodbc++: boneyard
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 1413b79 tap_migrations.json" -- --ancestry-path 1413b793cd536f12ce387c65e17c54d86f77855b~1..
	# Remove 71e2276 Merge remote-tracking branch 'origin/master'
	cd linuxbrew-core && git filter-branch -f --parent-filter 'sed s/71e2276787d1254932271d807ff5de4cb6b64d77/ea76f6c57874182ebfe63103c2c7e5b23e038669/' -- --ancestry-path 71e2276787d1254932271d807ff5de4cb6b64d77~1..
	# Graft 2323ae2 update tap_migrations
	# onto ef98654 imapsync: update 1.678 bottle.
	cd linuxbrew-core && git filter-branch -f --parent-filter 'sed s/ef986543c2b5067a599a031edd432500ee6d23e2/2323ae27a16c511dc2d0b06d69602569a51f465e/' -- --ancestry-path ef986543c2b5067a599a031edd432500ee6d23e2..
	# Update tap_migrations.json from 2323ae2 update tap_migrations
	cd linuxbrew-core && git filter-branch -f --tree-filter "git checkout 2323ae2 tap_migrations.json" -- --ancestry-path 2323ae27a16c511dc2d0b06d69602569a51f465e..
	# Add mising new-line at end of message to cd7b96e ponyc: Update ponyc upstream URLs
	cd linuxbrew-core && git filter-branch -f --msg-filter 'sed \$$a\\' -- --ancestry-path cd7b96e3896cab5ac9f74aaa577b80b77a7fbd41~1..
