# Editor
export ALTERNATE_EDITOR=""
alias evlserv='ITERM_24BIT=1 emacs --daemon'
alias evl='ITERM_24BIT=1 emacsclient -c'
alias mou='/Applications/Mou.app/Contents/MacOS/Mou'

export EDITOR='vim'

export NVIM_HOME=/Users/Matt/Documents/soundcloud/notes/

# Git
alias git='/usr/local/Cellar/git/2.2.1/bin/git'

# SBIN
export PATH=/usr/local/sbin:$PATH

# Home rolled
export PATH=~/.bin:$PATH

# Java
export JAVA_HOME="$(/usr/libexec/java_home)"

# Python
alias ipyserver="ipython notebook --pylab=inline --port 8888 --ip 0.0.0.0 --no-browser --BaseIPythonApplication.profile=report"

# golang
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# load sc env
source ~/.soundcloud_profile

alias scrubhtml='sed -e :a -e "s/<[^>]*>//g;/</N;//ba"'

# Config
export PATH=~/.config:$PATH

# Vim
alias vim='/usr/local/Cellar/vim/7.4.488/bin/vim'
export LANG=en_US.UTF-8
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

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

de() {
  wget -O- -q "http://de-en.dict.cc/?s=$1" |
    xmllint --html --format --nowarning - 2> /dev/null |
    grep "englisch-deutsch" |
    sed -e :a -e 's/<[^>]*>//g;/</N;//ba' |
    head -n 5
}

#xrdb -load ~/.Xresources
source ~/.bin/solarized --theme dark

eval $(ssh-agent)

function cleanup {
  echo "Killing SSH-Agent"
  kill -9 $SSH_AGENT_PID
}

trap cleanup EXIT

export GOPATH=$HOME/gopkg
export PATH=$PATH:$GOPATH/bin
export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH=/usr/local/bin:$PATH

#histogram() {
#  perl -lane 'print $F[0], "\t", "=" x ($F[1] / 5)' $1
#}

# git
GIT_DIR="$HOME/Documents/workspace"
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
  local repos=$(find                                                                       \
          ${GIT_DIR}                      `# assumed base of where all of your repos live` \
          -type d                         `# looking for directories`                      \
          -mindepth 2 -maxdepth 3         `# either at ~/git/*/.git or ~/git/*/*/.git`     \
          -name ".git" |                  `# called .git`                                  \
            awk -F/ '{ print $(NF-1) }'   `# and get the name of the dir containing .git`  \
        )
  COMPREPLY=( $(compgen -W '${repos[@]}' -- $curr_arg ) )
}

complete -F _do_with_git_complete_options g

# cd to a directory at git/<name> or git/parent/<name> by giving a substring of the repo name
function cdg() {
  g "cd" $1
}
# cd to a directory at git/<name> or git/parent/<name> by giving a substring of the repo name
function atomg() {
  g "atom" $1
}
complete -F _do_with_git_complete_options cdg
complete -F _do_with_git_complete_options atomg

gitHubClone() {
  if [[ $1 == '' ]]; then
    echo 'Usage: git hub [<org>] <repo>';
    exit 1;
  fi;
  if [[ $2 == '' ]]; then
    local repo=$1;
    local org=$(pwd | xargs basename);
    local url=git@github.com:$org/$repo.git;
    echo "Cloning from [${YELLOW}$url${RESTORE}] into [${GREEN}$(pwd)/$repo${RESTORE}]...";
    git clone $url;
  else
    local org=$1;
    local repo=$2;
    local url=git@github.com:$org/$repo.git;
    local target="${GIT_DIR}/$org/$repo"
    echo "Cloning from [${YELLOW}$url${RESTORE}] into [${GREEN}${target}${RESTORE}]..."
    git clone $url $target;
  fi
}

# make commands
function _do_with_make_complete_options() {
    local curr_arg=${COMP_WORDS[COMP_CWORD]}
    # get the list of commands from the makefile in pwd
    local commands=$(egrep '^[a-zA-Z-]+:[[:space:]a-zA-Z-]*$' Makefile | sed 's/:.*//')
    COMPREPLY=( $(compgen -W '${commands[@]}' -- $curr_arg ) )
}

complete -F _do_with_make_complete_options make
