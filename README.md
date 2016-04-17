Rewrite the history of a git fork to match the history of its parent
================================================================================

+ Compare two git repositories and match up their commits by subject, author name, email and date.
+ Create a table of corresponding commits and their SHA1 and committer name, email and date.
+ Create a shell script to be used with `git filter-branch --env-filter` to set the committer date of a third repository to those of the second repository.

## Caveats

+ This script will not work if two commits in the same repository have identical subject, author name, email and date. I have seen this happen.

## Method

1. **tree-filter**: Remove the directories Library/Formula and Library/Aliases
2. **msg-filter**: Change issue references like #123 to Homebrew/homebrew#123
3. **env-filter**: Change the committer author and committer date of 103 revisions listed above.
4. **parent-filter**: Remove empty merge commits after and not including 001b8de Merge branch 'qt5' 2014-01-11 15:58:34 +0000. but do not remove empty merge commits before that commit

## Motivation

The repository `Homebrew/homebrew` was split into `Homebrew/brew` and `Homebrew/homebrew-core`. I maintain the long-term fork `Linuxbrew/linuxbrew` and need to effect this same split. To maintain commit history, that split needs to be done identically to Homebrew so that the resulting commits in Linuxbrew have identical SHA1 to the corresponding commits in Homebrew.

Mostly this split was automated using `git filter-branch`, but for a period of a month or so, commits were manually cherry-picked from `Homebrew/homebrew` to `Homebrew/brew` and `Homebrew/homebrew-core`, which changes the committer name and date of those commits. Additionally, empty merge commits were not cherry picked, which changes the topology of the git commit graph. This same manual changes need to be applied to the Linuxbrew split.

To accomplish this we compare `Homebrew/legacy-homebrew` to `Homebrew/brew` to create a table commits whose committer changed to apply those same changes to `Linuxbrew/linuxbrew`.

Finally, empty merge commits are removed after a particular commit, but importantly not before that commit.
