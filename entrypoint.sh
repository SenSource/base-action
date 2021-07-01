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

mkdir ~/.ssh

eval "$(ssh-agent -s)"

echo "${GITHUB_TOKEN}" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

echo "Adding identity"

ssh-add ~/.ssh/id_ed25519

echo "Added"

echo "Adding github to known hosts"

ssh -o StrictHostKeyChecking=no git@github.com || IGNORE=1

echo "Added"

cd $GITHUB_WORKSPACE

## get base repo from ${BASE_REPO_CONFIG_FILE}
REPO=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.repo)")

## get branch name from ${BASE_REPO_CONFIG_FILE}
BRANCH=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.branch)")

echo "Adding base repo $REPO"

## set base remote
git remote add base $REPO
git remote set-url --push base PUSH_DISABLED

echo "Fetching base $BRANCH"

## fetch branch from base repo locally
git fetch base $BRANCH

echo "Checking for changes"

## check for changes
git log --oneline --exit-code master..base/$BRANCH > /dev/null || HAS_CHANGES=$?

echo "HAS_CHANGES=$HAS_CHANGES"

if [[ ${HAS_CHANGES} -eq 0 ]]; then
  echo "No changes from base. Exiting..."

  exit 0
fi

echo "Has changes from base. Creating branch"

git checkout -b update-from-base

echo "Attempting to merge base/$BRANCH"

## if merge exits with zero, there were no conflicts
git merge --no-edit base/$BRANCH || FAILED_MERGE=$?

echo "FAILED_MERGE=$FAILED_MERGE"

exit 1

if [[ ${FAILED_MERGE} -eq 0 ]]; then
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
