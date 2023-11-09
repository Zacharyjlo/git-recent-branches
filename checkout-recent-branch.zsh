#!/bin/zsh

function get_recent_branches() {
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
  echo "${recent_branches[@]}"
}

branches=($(get_recent_branches))
branch_limit=${1:-10}
length=${#branches[@]}
display_count=$(( length < branch_limit ? length : branch_limit ))

local branches=($(get_recent_branches "$1"))
echo "\n\e[1;34mSelect a branch by number:\e[0m"
echo "\e[1;32m─────────────────────────────\e[0m"
for ((i=1; i<=$display_count; i++)); do
  echo "\e[1;36m$((i)).\e[0m ${branches[$i]}"
done
echo "\e[1;32m─────────────────────────────\e[0m"
print -n "\e[1;33mEnter the branch number:\e[0m "
read branch_num
if ((branch_num >= 1 && branch_num <= length)); then
  git checkout "${branches[$((branch_num))]}"
else
  echo "\e[1;31mInvalid selection.\e[0m"
fi
echo "\e[0m"
