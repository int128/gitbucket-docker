#!/bin/bash -e

java_opts_array=()
while IFS= read -r -d '' item; do
  java_opts_array+=( "$item" )
done < <([[ $JAVA_OPTS ]] && xargs printf '%s\0' <<<"$JAVA_OPTS")

gitbucket_opts_array=()
while IFS= read -r -d '' item; do
  gitbucket_opts_array+=( "$item" )
done < <([[ $GITBUCKET_OPTS ]] && xargs printf '%s\0' <<<"$GITBUCKET_OPTS")

set -x
exec java "${java_opts_array[@]}" -jar /usr/share/gitbucket/gitbucket.war "${gitbucket_opts_array[@]}" "$@"
