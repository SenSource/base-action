# Base Check GitHub Action

Checks for changes in the base repository and opens a PR to merge those changes

## Inputs

### `github_token`

**Required** The GitHub API token

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

## Outputs

*none*

## Example usage

uses: SenSource/base-action@v1
with:
  github_token: ${{ secrets.GITHUB_API_KEY }}
  base_repo_config_file: base.json
