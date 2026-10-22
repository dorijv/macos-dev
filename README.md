# macos-dev

A small, pretty terminal setup for macOS: **iTerm2 + zsh + tmux + Neovim**, all in
[Catppuccin Mocha](https://catppuccin.com) with the JetBrains Mono Nerd Font, plus
[Claude Code](https://claude.com/claude-code).

One script sets up a fresh Mac. It's safe to run again, and it backs up anything it replaces.

## What you get

- **iTerm2**: a `dev-env` profile with Catppuccin Mocha colours and JetBrainsMono Nerd Font 13.
- **zsh**: [oh-my-zsh](https://ohmyz.sh) with a tweaked `robbyrussell` prompt that shows your
  active AWS profile:
  ```
  ➜ ☁️  my-profile project git:(main) ✗
  ```
- **tmux**: [Catppuccin](https://github.com/catppuccin/tmux) status bar at the top (app, session,
  user, host, clock), mouse support, vi copy mode, windows numbered from 1.
- **Neovim**: [NvChad](https://nvchad.com) v2.5 with the Catppuccin theme, LSP, Telescope
  (with ripgrep and fd) and Terraform support.
- **Claude Code**: installed with the official native installer, with a starter `settings.json`.
  It turns on AWS's [aws-core](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/plugins.html)
  plugin (AWS skills + MCP server), and asks before Claude runs `terraform`/`terragrunt` apply or
  destroy, `aws` delete/terminate/put commands, or any AWS MCP call.

## Install

```bash
git clone https://github.com/dorijv/macos-dev.git ~/macos-dev
~/macos-dev/install.sh
```

Add `--infra` to also install the Terraform and AWS tools in [`Brewfile.infra`](Brewfile.infra)
(tfenv, terragrunt, tflint, trivy, infracost, pre-commit, uv, awscli, direnv, aws-sso-util,
session-manager-plugin).

Then:

1. **iTerm2**: Settings → Profiles → select **dev-env** → *Other Actions…* → **Set as Default**.
2. **Neovim**: open `nvim` once and let the plugins install. For Terraform, run
   `:MasonInstall terraform-ls tflint`.
3. **tmux**: plugins install during setup. Inside tmux, `prefix + I` installs any you add later.
4. **Terraform repos**: copy [`aws/pre-commit-config.example.yaml`](aws/pre-commit-config.example.yaml)
   to `.pre-commit-config.yaml` and run `pre-commit install`. Each commit then runs fmt, tflint
   and trivy.

## AWS + direnv

With `--infra`, entering a project folder logs you in to AWS SSO and loads temporary
credentials. Leaving the folder unloads them, and the prompt shows the active profile (☁️).

**The pieces:**

- **AWS IAM Identity Center (SSO)**: you sign in once in the browser and get short-lived
  credentials for each account and role you have access to. There are no long-lived access keys on disk.
- **Profiles** in `~/.aws/config`: one per account, for example `myorg-dev` and `myorg-prod`.
  `AWS_PROFILE` picks which one the `aws` CLI and Terraform use.
- **[aws-sso-util](https://github.com/benkehoe/aws-sso-util)**: logs in and reuses the cached
  session, so the browser only opens when it has expired (after 8 hours by default).
- **[direnv](https://direnv.net)**: runs a folder's `.envrc` when you `cd` in and undoes it when you leave,
  so credentials only exist in the shell while you're in that project.

**Setup:**

1. Copy [`aws/config.example`](aws/config.example) to `~/.aws/config` and fill in your SSO URL,
   account IDs and role. Keep that file out of git.
2. In each project folder, add an `.envrc` that names the profile, then run `direnv allow`:
   ```bash
   use aws_sso myorg-dev
   ```
   With one subfolder per environment (`dev/`, `prod/`), put this in each one instead:
   ```bash
   use aws_sso "myorg-$(basename "$PWD")"
   ```

   Your SSO start URL and account IDs are on your AWS access portal page, or ask whoever manages
   your AWS organisation.

**Checking and fixing:**

| Want to | Run |
|---|---|
| See who you're logged in as | `aws sts get-caller-identity` |
| Log in again after the session expired | `direnv reload` (or `cd` out and back in) |
| See which profile is active | `echo $AWS_PROFILE`, or look for ☁️ in the prompt |

The helper lives in [`direnv/aws-sso.sh`](direnv/aws-sso.sh) and is linked into
`~/.config/direnv/lib/`. Be careful in folders that use production profiles: everything you run
there uses those credentials.

## How it works

Your config files become symlinks into this repo, so editing them shows up in `git diff`.
Anything already in the way is moved to `<file>.backup-<date>` first.

| In this repo | Linked to |
|---|---|
| `zsh/.zshrc`, `zsh/.zprofile` | `~/.zshrc`, `~/.zprofile` |
| `zsh/robbyrussell-aws.zsh-theme` | `~/.oh-my-zsh/custom/themes/` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim` |
| `direnv/aws-sso.sh` | `~/.config/direnv/lib/` |
| `iterm/dev-env.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/` |
| `claude/settings.json` | copied to `~/.claude/settings.json`, only if you don't have one |

Machine-specific setup (language toolchains, work config, secrets) belongs in `~/.zshrc.local`,
which `.zshrc` loads if it exists. Keep it out of the repo.

## Keys worth knowing

| Where | Key | Does |
|---|---|---|
| tmux | `prefix` (`Ctrl-b`) `+ %` / `"` | Split side by side / top and bottom |
| tmux | `prefix` `+` arrow keys | Move between panes |
| nvim | `Ctrl-h/j/k/l` | Move between splits |
| tmux | `prefix` (`Ctrl-b`) `+ I` | Install tmux plugins |
| nvim | `Space` | Leader key |
| nvim | `;` | Same as `:` |
| nvim | `jk` | Leave insert mode |
| nvim | `Space` `ff` / `fw` | Find files / find text (Telescope) |
| nvim | `Space` `th` | Pick another theme |
| shell | `vim`, `tg` | `nvim`, `terragrunt` |

## Make it yours

Fork it, then change the parts you care about:

- **Colours**: Catppuccin has four flavours. Change `@catppuccin_flavor` in `tmux/.tmux.conf`,
  `theme` in `nvim/lua/chadrc.lua`, and the colours in `iterm/dev-env.json`
  (from [catppuccin/iterm](https://github.com/catppuccin/iterm)).
- **Tools**: add them to `Brewfile`.
- **Neovim plugins**: `nvim/lua/plugins/init.lua`.

## Undo

Delete the symlinks and rename the `*.backup-<date>` files back to their original names.

## Credits

[NvChad](https://github.com/NvChad/NvChad) ·
[Catppuccin](https://github.com/catppuccin) ·
[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) ·
[tpm](https://github.com/tmux-plugins/tpm)
