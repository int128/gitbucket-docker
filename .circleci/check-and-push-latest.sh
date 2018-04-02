#!/bin/bash
set -e
set -o pipefail
set -x

test "$CIRCLE_USERNAME"
test "$CIRCLE_BRANCH"
test -f Dockerfile

git config user.email "$CIRCLE_USERNAME@users.noreply.github.com"
git config user.name "CircleCI"
mkdir -p "$HOME/.ssh"
ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts"

# Make sure we are in the branch
git checkout "$CIRCLE_BRANCH"

# Update version in Dockerfile
latest_version="$(curl https://api.github.com/repos/gitbucket/gitbucket/releases/latest | jq -r '.tag_name')"
sed -i -e "s/^ENV GITBUCKET_VERSION .*$/ENV GITBUCKET_VERSION $latest_version/" Dockerfile
git diff
git add Dockerfile

# Push the change if it exists
if [ "$(git status --porcelain)" ]; then
  git commit -m "GitBucket $latest_version"
  git tag "$latest_version"
  git push origin --tags
  git push origin "$CIRCLE_BRANCH"
fi
