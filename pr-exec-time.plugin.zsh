#!/usr/bin/env zsh

: ${PR_EXEC_TIME_PREFIX:=" "}
: ${PR_EXEC_TIME_SUFFIX:=""}
: ${PR_EXEC_TIME_ELAPSED:=5}

typeset -g pr_exec_time
typeset -g _pr_exec_time_timer

if (( $+functions[zpm] )); then #DO_NOT_INCLUDE_LINE_IN_ZPM_CACHE
  zpm sindresorhus/pretty-time-zsh,fpath:/,async #DO_NOT_INCLUDE_LINE_IN_ZPM_CACHE
fi #DO_NOT_INCLUDE_LINE_IN_ZPM_CACHE

function _pr_exec_time_preexec() {
  _pr_exec_time_timer=${_pr_exec_time_timer:-$SECONDS}
}

function _pr_exec_time() {
  if [[ -n $_pr_exec_time_timer ]]; then
    local pr_time_spend=$(($SECONDS - $_pr_exec_time_timer))

    if [[ $pr_time_spend -ge $PR_EXEC_TIME_ELAPSED ]]; then
      pr_exec_time="$PR_EXEC_TIME_PREFIX%{$c[yellow]$c_bold%}$(pretty-time $pr_time_spend)%{$c_reset%}$PR_EXEC_TIME_SUFFIX"
    else
      pr_exec_time=''
    fi

    _pr_exec_time_timer=''
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _pr_exec_time_preexec
add-zsh-hook precmd _pr_exec_time
