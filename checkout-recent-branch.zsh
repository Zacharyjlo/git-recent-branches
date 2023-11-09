#!/bin/zsh

function get_recent_branches() {
  local count=${1:-10}  # Use the first argument if provided, otherwise default to 10
  local merged_branches=$(git for-each-ref --merged main refs/heads/ --format '%(refname:short)')
  local all_branches=$(git branch --list | tr -d ' ')
  local recent_branches=()
  while IFS= read -r branch; do
    if ! echo "$merged_branches" | grep -qw "$branch" && echo "$all_branches" | grep -qw "$branch"; then
      if [[ ! " ${recent_branches[@]} " =~ " ${branch} " ]]; then
        recent_branches+=("$branch")
      fi
    fi
  done < <(git reflog show --oneline -n 500 | grep 'checkout: moving' | awk '{print $NF}' | tr -d ' ')
  echo "${recent_branches[@]:0:$count}"
}

# Usage: rbr [number]

# Get the number of recent branches to show from the first script argument
# If no argument is provided, it defaults to 10
local branches=($(get_recent_branches "$1"))
local length=${#branches[@]}
echo "\n\e[1;34mSelect a branch by number:\e[0m"
echo "\e[1;32m─────────────────────────────\e[0m"
for ((i=0; i<$length; i++)); do
  echo "\e[1;36m$((i+1)).\e[0m ${branches[$i]}"
done
echo "\e[1;32m─────────────────────────────\e[0m"
print -n "\e[1;33mEnter the branch number:\e[0m "
read branch_num
if ((branch_num >= 1 && branch_num <= length)); then
  git checkout "${branches[$((branch_num-1))]}"
else
  echo "\e[1;31mInvalid selection.\e[0m"
fi
echo "\e[0m"

