export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell-aws"   # robbyrussell with the AWS profile (☁️) before the folder
SHOW_AWS_PROMPT=false          # the theme shows it, so keep the aws plugin out of RPROMPT
plugins=(git aws)
source $ZSH/oh-my-zsh.sh

export EDITOR=nvim

alias vim="nvim"
alias tg="terragrunt"
export TG_TF_FORWARD_STDOUT=true   # plain terraform output, no "time STDOUT terraform:" prefix per line

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# Machine-specific setup (toolchains, work config) that is not in this repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
