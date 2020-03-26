#!/bin/bash
set -e
set -o pipefail
set -x

test "$CIRCLE_BRANCH"
test -f Dockerfile

git config user.email "int128@users.noreply.github.com"
git config user.name "CircleCI"
mkdir -p "$HOME/.ssh"
ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts"

# Make sure we are in the branch
git checkout "$CIRCLE_BRANCH"

# Check the latest version
latest_version="$(curl https://api.github.com/repos/gitbucket/gitbucket/releases/latest | jq -r '.tag_name')"
if [ "$latest_version" = "null" ]; then
  exit
fi

# Update version in Dockerfile
sed -i -e "s/^ENV GITBUCKET_VERSION .*$/ENV GITBUCKET_VERSION $latest_version/" Dockerfile
git diff | cat
git add Dockerfile

# Update version in charts
sed -i -e "s/^  tag: .*$/  tag: \"$latest_version\"/" charts/gitbucket/values.yaml
sed -i -e "s/^appVersion: .*$/appVersion: \"$latest_version\"/" charts/gitbucket/Chart.yaml
sed -i -e "s/^version: .*$/version: \"$latest_version\"/" charts/gitbucket/Chart.yaml
git diff | cat
git add charts

# Push the change if it exists
if [ "$(git status --porcelain)" ]; then
  git commit -m "GitBucket $latest_version"
  git tag "$latest_version"
  git push origin --tags
  git push origin "$CIRCLE_BRANCH"
fi
