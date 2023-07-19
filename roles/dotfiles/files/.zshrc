# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"

  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"

  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
  print -P "%F{33} %F{34}Installation successful.%f%b" || \
  print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit light-mode depth=1 for \
  romkatv/powerlevel10k \
  OMZL::history.zsh \
  blockf OMZL::completion.zsh

zinit wait lucid light-mode depth=1 for \
  atinit"zicompinit; zicdreplay" \
  zdharma/fast-syntax-highlighting \
  atload"bindkey '^[[A' history-substring-search-up; \
  bindkey '^[[B' history-substring-search-down" \
  zsh-users/zsh-history-substring-search

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completionkkk

#
# Other
#

source $HOME/.zsh/aliases
source $HOME/.zsh/functions
source $HOME/.zsh/fzf
source $HOME/.zsh/path

# FZF

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Python

# need to enable for python multithreading
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES


if [[ "`uname -a`" == *"microsoft"* ]]; then
  source $HOME/.zsh/wsl.sh
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# 1pass
export SSH_AUTH_SOCK=~/.1password/agent.sock

EDITOR=vim
<<<<<<< HEAD

if [ -f "${HOME}/dotfiles/.env" ]
||||||| parent of 331955fc (fix: update path to .env)
if [ ! -f .env ]
=======

if [ -f ~/dotfiles/.env ]
>>>>>>> 331955fc (fix: update path to .env)
then
<<<<<<< HEAD
  export $(cat "${HOME}/dotfiles/.env" | xargs)
||||||| parent of 331955fc (fix: update path to .env)
  export $(cat .env | xargs)
=======
  export $(cat ~/dotfiles/.env | xargs)
>>>>>>> 331955fc (fix: update path to .env)
fi
