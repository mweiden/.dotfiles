EDITOR=vim

PATH=${PATH}:~/.bin/
export PATH=~/Library/Python/3.7/bin:$PATH

alias lah='ls -lahG'
alias tf='terraform'

source ~/.bin/solarized --theme dark

eval $(ssh-agent > /dev/null)

function cleanup {
  echo "Killing SSH-Agent"
  kill -9 $SSH_AGENT_PID
}

trap cleanup EXIT

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE=C
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_151.jdk/Contents/Home

# gcp
source /Users/mweiden/.gcp/google-cloud-sdk/completion.bash.inc
source /Users/mweiden/.gcp/google-cloud-sdk/path.bash.inc

# prompt
#function get_ret() {
#  ret=$?
#  echo $ret
#  return $ret
#}
#function get_color() {
#  ret=$?
#  [[ $ret -ne 0 ]] && echo 31 || echo 32
#  return $ret
#}
#
#export -f get_ret
#export -f get_color
#
#export PS1="\[\033[\`get_color\`m\]\`get_ret\`\[\033[0m\] \[\033[34m\]\W\[\033[0m\]> "

get-aws-profile() {
    echo $AWS_PROFILE
}
set-aws-profile() {
    export AWS_PROFILE=$1
    export AWS_DEFAULT_REGION=us-east-1
    eval "$(aws ecr get-login --no-include-email)"
    echo 'ECR login complete'
    aws sts get-caller-identity
}
_complete_aws_profile() {
    local cword=${COMP_WORDS[COMP_CWORD]}
    local aws_profiles=$(python3 -c 'import botocore.session as s; print("\n".join(s.Session().full_config["profiles"]))')
    COMPREPLY=( $(compgen -W "$aws_profiles" -- $cword) )
}
complete -F _complete_aws_profile set-aws-profile

set-gcp-creds() {
    export GOOGLE_APPLICATION_CREDENTIALS=~/credentials/$1
}
_complete_gcp_credentials() {
    local cword=${COMP_WORDS[COMP_CWORD]}
    local gcp_credentials=$(ls ~/credentials/)
    COMPREPLY=( $(compgen -W "$gcp_credentials" -- $cword) )
}
complete -F _complete_gcp_credentials set-gcp-creds

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

GIT_DIR="$HOME/workspace"
# do something given a directory at git/<name> or git/parent/<name> by giving a substring of the repo name
function g() {
  if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Usage: ${FUNCNAME[0]} <operation> <repo-name>"
  else
    local operation=$1
    local repoName=$2
    #local path=($(find "${GIT_DIR}" -type d -maxdepth 3 -name ".git" | egrep -i "/[^/]*${repoName}[^/]*/.git" | xargs dirname))
    local path=($(find "${GIT_DIR}" -type d -maxdepth 3 -name ".git" | egrep -i "/[^/]*${repoName}/.git" | xargs dirname))

    local count=${#path[@]}

    if [[ "$count" == "1" ]]; then
      $operation $path
    elif (( $count > 1 )); then
      echo -e "Found $count directories matching [${WHITE}$repoName${RESTORE}]"
      local index=1
      for p in "${path[@]}"; do
        local head=$(dirname $p)
        local tail=$(basename $p)
        echo "  [${GREEN}$index${RESTORE}] ${head}/${GREEN}${tail}${RESTORE}"
        ((index=index+1))
      done

      echo -n "Enter an repo to use, or <enter> to stop: "
      read g
      if [[ "$g" != "" ]]; then
        ((gotoIndex=g-1))
        $operation ${path[gotoIndex]}
      fi
    else
      echo -e "Found no directories matching [${RED}$repoName${RESTORE}]"
    fi
  fi
}

# bash auto completion for g commands.
# This actually gives the list of repos on all arg positions of g, where really
# we'd only want it on the second arg. TODO improve? It's also useful for
# pre-canned commands like cdg and atomg
function _do_with_git_complete_options() {
  local curr_arg=${COMP_WORDS[COMP_CWORD]}
  # get the list of git repos in known positions
  # this comment syntax for a multiline command is a pretty horrific abuse of
  # substitution, inspired by this: http://stackoverflow.com/questions/9522631
  local repos=$(find ${GIT_DIR} -type d -mindepth 2 -maxdepth 3 -name ".git" | awk -F/ '{ print $(NF-1) }')
  COMPREPLY=( $(compgen -W '${repos[@]}' -- $curr_arg ) )
}

complete -F _do_with_git_complete_options g

# cd to a directory at git/<name> or git/parent/<name> by giving a substring of the repo name
function cdg() {
  g "cd" $1
}
complete -F _do_with_git_complete_options cdg

# make commands
function _do_with_make_complete_options() {
    local curr_arg=${COMP_WORDS[COMP_CWORD]}
    # get the list of commands from the makefile in pwd
    local commands=$(egrep '^[a-zA-Z-]+:[[:space:]a-zA-Z-]*$' Makefile | sed 's/:.*//')
    COMPREPLY=( $(compgen -W '${commands[@]}' -- $curr_arg ) )
}

complete -F _do_with_make_complete_options make
