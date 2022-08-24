# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gruvbox"

SPACESHIP_PROMPT_ORDER=(
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  package       # Package version
  node          # Node.js section
  dotnet        # .NET section
  ruby          # Ruby section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

# oh-my-zsh plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completionkkk

#
# Other
#

source $HOME/.zsh/aliases
source $HOME/.zsh/functions
source $HOME/.zsh/path

# FZF

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Python

# need to enable for python multithreading
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES


# WSL SSH Forwarding

# Configure ssh forwarding
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
# need `ps -ww` to get non-truncated command for matching
# use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)

if [[ $ALREADY_RUNNING != "0" ]]; then
    if [[ -S $SSH_AUTH_SOCK ]]; then
        # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
        echo "removing previous socket..."
        rm $SSH_AUTH_SOCK
    fi
    echo "Starting SSH-Agent relay..."
    # setsid to force new session to keep running
    # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
    (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export DISPLAY=:0


## GPG Setup

if [ -f $HOME/.gpg-agent-info ]; then
    . $HOME/.gpg-agent-info
    export GPG_AGENT_INFO
fi

if [ ! -f $HOME/.gpg-agent.conf ]; then
  cat <<EOM >$HOME/.gpg-agent.conf
default-cache-ttl 604800
max-cache-ttl 604800
default-cache-ttl-ssh 604800
max-cache-ttl-ssh 604800
EOM
fi

if [ -n "${GPG_AGENT_INFO}" ]; then
    nc  -U "${GPG_AGENT_INFO%%:*}" >/dev/null </dev/null
    if [ ! -S "${GPG_AGENT_INFO%%:*}" -o $? != 0 ]; then
        # set passphrase cache so I only have to type my passphrase once a day
        eval $(gpg-agent --options $HOME/.gpg-agent.conf --daemon --write-env-file $HOME/.gpg-agent-info --use-standard-socket --log-file $HOME/tmp/gpg-agent.log --verbose)
    fi
fi
export GPG_TTY=$(tty)
