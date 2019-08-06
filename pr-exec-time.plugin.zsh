#!/usr/bin/env zsh

DEPENDENCES_ZSH+=( sindresorhus/pretty-time-zsh zpm-zsh/colors )

PR_EXEC_TIME_PREFIX="${PR_EXEC_TIME_PREFIX:-" "}"
PR_EXEC_TIME_SUFFIX="${PR_EXEC_TIME_SUFFIX:-""}"
PR_EXEC_TIME_ELAPSED="${PR_EXEC_TIME_ELAPSED:-5}"

if command -v zpm >/dev/null; then
  zpm sindresorhus/pretty-time-zsh zpm-zsh/colors
fi

_pr_exec_time() {
  
  if [ $_pr_exec_time_timer ]; then
    local pr_time_spend=$(($SECONDS - $_pr_exec_time_timer))
    if [[ $pr_time_spend -ge $PR_EXEC_TIME_ELAPSED ]]; then
      
      if [[ $CLICOLOR = 1 ]]; then
        pr_exec_time="$PR_EXEC_TIME_PREFIX%{$c[yellow]$c_bold%}$(pretty-time $pr_time_spend)%{$c_reset%}$PR_EXEC_TIME_SUFFIX"
      else
        pr_exec_time="$PR_EXEC_TIME_PREFIX$(pretty-time $pr_time_spend)$PR_EXEC_TIME_SUFFIX"
      fi
    else
      pr_exec_time=''
    fi
    unset _pr_exec_time_timer
  fi
  
}

function _pr_exec_time_preexec() {
  _pr_exec_time_timer=${_pr_exec_time_timer:-$SECONDS}
}

preexec_functions+=(_pr_exec_time_preexec)
precmd_functions+=(_pr_exec_time)
