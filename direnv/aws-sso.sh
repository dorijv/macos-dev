# direnv helper, linked into ~/.config/direnv/lib/
# In a project's .envrc:   use aws_sso <profile>
# Logs in with AWS SSO (only opens the browser when the session has expired)
# and exports temporary credentials; direnv unloads them when you leave the folder.
use_aws_sso() {
  export AWS_PROFILE="$1"
  if ! aws-sso-util login --profile "$AWS_PROFILE"; then
    log_error "AWS SSO login failed for $AWS_PROFILE"
    unset AWS_PROFILE
    return 1
  fi
  eval "$(aws configure export-credentials --format env)"
}
