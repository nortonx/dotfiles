### Git utils
git_list_authors(){
  git shortlog -sn
}

### Search git history for a string from a file
## param 1: desired string
## param 2: filename with desired string
git_search_string_in_history(){
	git rev-list --all $1 | (
		while read revision; do
			git grep -F '$2' $revision $1
		done
	)
}

# show git logs containing a string
# param 1: string to search
git_log() {
    git log --grep="$1"
}
