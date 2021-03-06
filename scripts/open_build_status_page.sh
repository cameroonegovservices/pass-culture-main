#!/usr/bin/env bash

if [[ $# -gt 1 ]];
then
    environment=$1
    commit_to_deploy=$2
else
    echo "You need to specify (1) an environment and (2) a commit to deploy to query build status."
    exit 1
fi

build_url="https://circleci.com/api/v1.1/project/github/betagouv/pass-culture-main/tree/$environment"

counter=0
while [ "$counter" -le 10 ]
do
    last_build=$(curl -s "$build_url" | jq -r '.[0]')
    if [ "$last_build" = "null" ];
    then
        echo "Unknown problem querying last build."
        exit 1
    fi
    workflow_id=$(echo "$last_build" | jq -r '.workflows.workflow_id')
    commit=$(echo "$last_build" | jq -r '.vcs_revision')
    if [ "$commit" = "$commit_to_deploy" ];
    then
        xdg-open "https://circleci.com/workflow-run/$workflow_id"
        break
    fi
    sleep 5
    ((counter++))
done