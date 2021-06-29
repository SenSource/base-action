#!/bin/sh -l

set -e
set -o pipefail

## GitHub token input from action
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN environment variable"
  exit 1
fi

## Base repo config file from action
if [[ -z "$BASE_REPO_CONFIG_FILE" ]]; then
  echo "Set the BASE_REPO_CONFIG_FILE environment variable"
  exit 1
fi

## PR labels from action
if [[ -z "$PR_LABELS" ]]; then
  echo "Set the PR_LABELS environment variable"
  exit 1
fi

## PR reviewer from action
if [[ -z "$PR_REVIEWER" ]]; then
  echo "Set the PR_REVIEWER environment variable"
  exit 1
fi

## Issue labels from action
if [[ -z "$ISSUE_LABELS" ]]; then
  echo "Set the ISSUE_LABELS environment variable"
  exit 1
fi

## Issue assignee from action
if [[ -z "$ISSUE_ASSIGNEE" ]]; then
  echo "Set the ISSUE_ASSIGNEE environment variable"
  exit 1
fi

sh -c "ls -al /github/home"
sh -c "ls -al /github/workspace"
sh -c "ls -al /github/workflow"

cd /github/workspace

## get base repo from ${BASE_REPO_CONFIG_FILE}
REPO=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.repo)")
## get branch name from ${BASE_REPO_CONFIG_FILE}
BRANCH=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.branch)")

## set base remote
git remote add base $REPO
git remote set-url --push base PUSH_DISABLED

## fetch branch from base repo locally
git fetch base $BRANCH

## check for changes
git log --oneline --exit-code master..base/$BRANCH > /dev/null || HAS_CHANGES=$?

if [[ ${HAS_CHANGES} -eq 0 ]]; then
  exit 0
fi

git checkout -b update-from-base

## if merge exits with zero, there were no conflicts
git merge --ff-only base/$BRANCH || FAILED_FAST_FORWARD=$?

if [[ ${FAILED_FAST_FORWARD} -eq 0 ]]; then
  gh pr create --title "🤖 Update from base" --body "Update from base repository" --reviewer "${PR_REVIEWER}" --label "${PR_LABELS}" || PR_FAILED=$?

  if [[ ${PR_FAILED} -ne 0 ]]; then
    echo "PR creation failed"
    exit 1
  else
    exit 0
  fi
fi

## create issue to manually update from base and fix merge conflicts
gh issue create --title "Update from base [manual]" --body "Needs manual update from base to resolve conflicts" --assignee "${ISSUE_ASSIGNEE}" --label "${ISSUE_LABEL}" || ISSUE_FAILED=$?

if [[ ${ISSUE_FAILED} -ne 0 ]]; then
  echo "Issue creation failed"
  exit 1
fi
