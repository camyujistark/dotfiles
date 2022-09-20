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


if [ `uname  -s` = "Linux" ]; then
  source $HOME/.zsh/wsl.sh
fi
