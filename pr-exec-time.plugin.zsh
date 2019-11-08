#!/usr/bin/env zsh

DEPENDENCES_ZSH+=( sindresorhus/pretty-time-zsh zpm-zsh/colors )

PR_EXEC_TIME_PREFIX="${PR_EXEC_TIME_PREFIX:-" "}"
PR_EXEC_TIME_SUFFIX="${PR_EXEC_TIME_SUFFIX:-""}"
PR_EXEC_TIME_ELAPSED="${PR_EXEC_TIME_ELAPSED:-5}"
PR_EXEC_TIME_ELAPSED_NOTIFY="${PR_EXEC_TIME_ELAPSED_NOTIFY:-10}"
PR_EXEC_TIME_IGNORE=(
  "vim" "nvim" "less" "more" "man"
  "tig""watch" "git commit" 
  "top" "htop" "ssh" "nano"
)

if (( $+functions[zpm] )); then
  zpm sindresorhus/pretty-time-zsh,apply:path,path:/ zpm-zsh/colors,inline
fi

function _pr_exec_time_ignored(){
  for ignore in $PR_EXEC_TIME_IGNORE; do
    if [[ "$1" == "$ignore "* || "$1" == "$ignore" ]]; then
      echo 1

      return 0
    fi
  done
  
  echo 0

  return 1
}

function _pr_exec_time_preexec() {
  _pr_exec_time_timer=${_pr_exec_time_timer:-$SECONDS}
  _pr_exec_time_timer_ignore=$(_pr_exec_time_ignored "${1:-$2}")
  _pr_exec_time_command="${1:-$2}"
}

_pr_exec_time() {
  if [ $_pr_exec_time_timer ]; then
    local pr_time_spend=$(($SECONDS - $_pr_exec_time_timer))

    if [[ $pr_time_spend -ge $PR_EXEC_TIME_ELAPSED && "$_pr_exec_time_timer_ignore" == "0" ]]; then
      pr_exec_time="$PR_EXEC_TIME_PREFIX%{$c[yellow]$c_bold%}$(pretty-time $pr_time_spend)%{$c_reset%}$PR_EXEC_TIME_SUFFIX"
    else
      pr_exec_time=''
    fi
    
    if [[ $pr_time_spend -ge $PR_EXEC_TIME_ELAPSED_NOTIFY && "$_pr_exec_time_timer_ignore" == "0" ]]; then
      local title="Completed: $_pr_exec_time_command"
      local body="Total time: $(pretty-time $pr_time_spend)"
      
      if (( $+commands[notify-send] )); then
        notify-send "$title" "$body" -t 5000
      elif (( $+commands[osascript] )); then
        osascript \
        -e 'on run argv' \
        -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
        -e 'end run' \
        "$body" "$title"
      fi
    fi
    
    unset _pr_exec_time_timer
  fi
}

preexec_functions+=(_pr_exec_time_preexec)
precmd_functions+=(_pr_exec_time)
