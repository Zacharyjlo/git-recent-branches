#!/bin/zsh

function get_default_branch() {
  local ref
  if ref=$(git symbolic-ref --quiet refs/remotes/origin/HEAD); then
    echo "${ref#refs/remotes/origin/}"
  elif git show-ref --verify --quiet refs/heads/main; then
    echo main
  else
    echo master
  fi
}

function get_recent_branches() {
  local default_branch current_branch branch
  local -a merged_branches all_branches recent_branches

  default_branch=$(get_default_branch)
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  merged_branches=(${(f)"$(git for-each-ref --merged "$default_branch" refs/heads/ --format '%(refname:short)' 2>/dev/null)"})
  all_branches=(${(f)"$(git for-each-ref refs/heads/ --format '%(refname:short)')"})

  recent_branches=()
  while IFS= read -r branch; do
    if (( ${all_branches[(Ie)$branch]} )) \
        && (( ! ${merged_branches[(Ie)$branch]} )) \
        && (( ! ${recent_branches[(Ie)$branch]} )) \
        && [[ $branch != $current_branch ]]; then
      recent_branches+=("$branch")
    fi
  done < <(git reflog show --oneline -n 500 | grep 'checkout: moving' | awk '{print $NF}')

  print -l -- "${recent_branches[@]}"
}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

branch_limit=${1:-10}
branches=(${(f)"$(get_recent_branches)"})
length=${#branches[@]}
display_count=$(( length < branch_limit ? length : branch_limit ))

if (( display_count == 0 )); then
  echo "No recently checked out branches found."
  exit 0
fi

echo "\n\e[1;34mSelect a branch by number:\e[0m"
echo "\e[1;32m─────────────────────────────\e[0m"
for ((i=1; i<=display_count; i++)); do
  echo "\e[1;36m$i.\e[0m ${branches[$i]}"
done
echo "\e[1;32m─────────────────────────────\e[0m"
print -n "\e[1;33mEnter the branch number:\e[0m "
read branch_num
if [[ $branch_num == <-> ]] && (( branch_num >= 1 && branch_num <= display_count )); then
  git checkout "${branches[$branch_num]}"
else
  echo "\e[1;31mInvalid selection.\e[0m"
fi
echo "\e[0m"
