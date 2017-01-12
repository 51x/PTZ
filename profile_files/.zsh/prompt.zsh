function git_prompt_info {
  local ref=$(=git symbolic-ref HEAD 2> /dev/null)
  local gitst="$(=git status 2> /dev/null)"

  if [[ -f .git/MERGE_HEAD ]]; then
    if [[ ${gitst} =~ "unmerged" ]]; then
      gitstatus=" %{$fg[red]%}unmerged%{$reset_color%}"
    else
      gitstatus=" %{$fg[green]%}merged%{$reset_color%}"
    fi
  elif [[ ${gitst} =~ "Changes to be committed" ]]; then
    gitstatus=" %{$fg[blue]%}!%{$reset_color%}"
  elif [[ ${gitst} =~ "use \"git add" ]]; then
    gitstatus=" %{$fg[red]%}!%{$reset_color%}"
  elif [[ -n `git checkout HEAD 2> /dev/null | grep ahead` ]]; then
    gitstatus=" %{$fg[yellow]%}*%{$reset_color%}"
  else
    gitstatus=''
  fi

  if [[ -n $ref ]]; then
    echo "%{$fg_bold[green]%}/${ref#refs/heads/}%{$reset_color%}$gitstatus"
  fi
}

function trso {
    trsochk=$(/usr/bin/torsocks show|grep libtorsocks.so)
    if [[ -z $(/usr/bin/torsocks show|grep libtorsocks.so) ]]
      then
        trchkres="%{$fg[yellow]%}tof"
      else
        trchkres="%{$fg[red]%}ton"
    fi
    echo $trchkres
}

PROMPT='%{$fg[red]%}$(whoami)%{$reset_color%}.ptz $(trso)%{$reset_color%} %~%<< $(git_prompt_info) ${PR_BOLD_WHITE}>%{${reset_color}%} '
