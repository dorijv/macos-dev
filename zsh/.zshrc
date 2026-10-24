export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell-aws"   # robbyrussell with the AWS profile (☁️) before the folder
SHOW_AWS_PROMPT=false          # the theme shows it, so keep the aws plugin out of RPROMPT
plugins=(git aws)
source $ZSH/oh-my-zsh.sh

export EDITOR=nvim

alias vim="nvim"
alias tg="terragrunt"
export TG_TF_FORWARD_STDOUT=true   # plain terraform output, no "time STDOUT terraform:" prefix per line
# terragrunt's default pretty format, with HH:MM:SS instead of milliseconds
export TG_LOG_CUSTOM_FORMAT="%time(format='H:i:s',color=light-black) %level(case=upper,width=6,color=preset) %prefix(path=short-relative,color=gradient,suffix=' ')%tf-path(color=cyan,suffix=': ')%msg(path=relative)"

# deploy: plan, price that plan, apply exactly it once you confirm; args go to terragrunt plan.
# Prices the plan JSON because infracost's source scan drops terragrunt units at random.
tgd() {
  local json=$(mktemp -d)/plan.json reply
  terragrunt plan -out=tgd.tfplan "$@" || return
  terragrunt show -json tgd.tfplan > $json || return
  infracost scan $json || return
  read "reply?Apply? [y/N] "
  [[ $reply == [yY]* ]] || return 1
  terragrunt apply tgd.tfplan
}

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# Machine-specific setup (toolchains, work config) that is not in this repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
