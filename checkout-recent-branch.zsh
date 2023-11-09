#!/bin/zsh

function get_recent_branches() {
  local count=$1  # This will take the first argument passed to the function
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

# Now you can specify the number of branches when you call the function
# If no number is provided, default to showing 10 branches
if [ -z "$1" ]; then
  branches=($(get_recent_branches 10))
else
  branches=($(get_recent_branches "$1"))
fi

length=${#branches[@]}
echo "\n\e[1;34mSelect a branch by number:\e[0m"
echo "\e[1;32m─────────────────────────────\e[0m"
for ((i=1; i<=$length; i++)); do
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
