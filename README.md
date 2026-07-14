# git-recent-branches
An oh-my-zsh plugin to view and checkout branches that have been checked out recently

To use this, clone the repo into ~/.oh-my-zsh/custom/plugins/

```
cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/Zacharyjlo/git-recent-branches
```

And then edit your .zshrc file and add git-recent-branches to your oh my zsh plugins.

Use the alias `grbr` to print out your 10 most recently checked out branches (excluding your current branch and any branches already merged into your repo's default branch, auto-detected from `origin/HEAD` with a fallback to `main`/`master`) and check them out by simply typing the number associated with that branch! If you would like to view more than the last 10, easy! Just add a number to the end of your alias (Ex: `grbr 20`)
