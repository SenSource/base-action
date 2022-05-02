# Base Check GitHub Action

Checks for changes in the base repository and opens a PR to merge those changes

## Inputs

### `ssh_private_key`

**Required** SSH private key for GitHub access

### `github_pa_token`

**Required** GitHub personal access token (repo scope) for GH CLI access

### `npm_token`

**Optional** NPM token if you have private repositories that you need to install for the PR to run

### `base_repo_config_file`

**Required** The JSON file containing the base repo config

Example required config:

```json
{
  "base": {
    "repo": "git@github.com:user/repo.git",
    "branch": "microservice"
  }
}
```

### `pr_labels`

**Required** Comma-separated string of labels to assign to the PR (no space between, see https://cli.github.com/manual/gh_pr_create)

### `pr_reviewer`

**Required** User/group to assign the PR to (see https://cli.github.com/manual/gh_pr_create)

### `issue_labels`

**Required** Comma-separated string of labels to assign to the issue (no space between, see https://cli.github.com/manual/gh_issue_create)

### `issue_assignee`

**Required** User/group to assign to the issue (see https://cli.github.com/manual/gh_issue_create)

### `committer_email`

**Required** Email used for merge commits

### `update_branch`

**Required** Branch name for updates

## Outputs

*none*

## Example usage

uses: SenSource/base-action@v1
with:
  github_token: ${{ secrets.GITHUB_API_KEY }}
  base_repo_config_file: base.json
