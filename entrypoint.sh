#!/bin/sh -l

set -e
set -o pipefail

##
## Set up SSH access to GitHub for fetching base repository and merging
##

mkdir ~/.ssh
eval "$(ssh-agent -s)" > /dev/null
echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

echo "Adding identity"
ssh-add ~/.ssh/id_ed25519 > /dev/null
echo "Added"

echo "Adding GitHub to known_hosts"
## we know this will fail because you can't log in to a shell at github.com
## but it adds the host key to known_hosts; adding manually failed to work
ssh -o StrictHostKeyChecking=no git@github.com > /dev/null || IGNORE=1
echo "Added"

##
## Setting up base repository as a remote
##

cd $GITHUB_WORKSPACE

## get base repo from ${BASE_REPO_CONFIG_FILE}
REPO=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.repo)")

## get branch name from ${BASE_REPO_CONFIG_FILE}
BRANCH=$(node -e "console.log(require('./${BASE_REPO_CONFIG_FILE}').base.branch)")

echo "Adding base repo $REPO"

## set base remote
git remote add base $REPO
git remote set-url --push base PUSH_DISABLED

##
## Fetching the base branch and checking for changes
##

echo "Fetching base $BRANCH"
git fetch base $BRANCH

echo "Checking for changes"
git log --oneline --exit-code master..base/$BRANCH > /dev/null || HAS_CHANGES=$?

if [ -z ${HAS_CHANGES} ]; then
  echo "No changes from base. Exiting..."

  exit 0
fi

##
## Attempt to merge changes and create a PR
##

echo "Has changes from base. Creating $UPDATE_BRANCH branch"
git checkout -b $UPDATE_BRANCH

echo "Attempting to merge base/$BRANCH"
## if merge exits with zero, there were no conflicts
git merge --no-edit base/$BRANCH || FAILED_MERGE=$?

if [ -z ${FAILED_MERGE} ]; then
  echo "Merge succeeded without conflicts. Creating PR"
  git push -u origin $UPDATE_BRANCH
  GITHUB_TOKEN=$GITHUB_PA_TOKEN gh pr create --head $UPDATE_BRANCH --title "🤖 Update from base" --body "Update from base repository" --reviewer "${PR_REVIEWER}" --label "${PR_LABELS}" || PR_FAILED=$?

  if [ -z ${PR_FAILED} ]; then
    echo "PR created successfully"
    exit 0
  else
    echo "PR creation failed"
    exit 1
  fi
fi

##
## Fall back to creating an issue to manually update, if the merge failed
##

echo "Merge failed, likely due to merge conflicts. Creating issue to manually update"
GITHUB_TOKEN=$GITHUB_PA_TOKEN gh issue create --title "Update from base [manual]" --body "Needs manual update from base to resolve conflicts" --assignee "${ISSUE_ASSIGNEE}" --label "${ISSUE_LABEL}" || ISSUE_FAILED=$?

if [ -z ${ISSUE_FAILED} ]; then
  echo "Issue created successfully"
  exit 0
else
  echo "Issue creation failed"
  exit 1
fi

