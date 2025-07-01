#! /bin/bash

# Envs
## fastapi envs
RUN_MODE=${RUN_MODE:-prod}
OPTIONS='--host=0.0.0.0 --port=8080 --workers=1'
# OPTIONS="${OPTIONS} --log-config=./config/logging.json"

## git envs
tmp_git_work_tree=${GIT_WORK_TREE:-"/workspace/tmp/src"}
unset GIT_WORK_TREE
export GIT_DIR="${tmp_git_work_tree}/.git"
export GIT_BRANCH=${GIT_BRANCH:-'main'}

## Env validation
if [[ "$RUN_MODE" == "prod" ]]; then
    OPTIONS="$OPTIONS"
elif [[ "$RUN_MODE" == "dev" ]]; then
    OPTIONS="$OPTIONS --reload"
else
    >&2 echo "ERROR - 'RUN_MODE' is invalid! Expected 'dev' or 'prod', got '${RUN_MODE}'"
    exit 1
fi

for git_env in GIT_{REPO,BRANCH,USERNAME,EMAIL,ACCESSTOKEN}; do
    if [[ -z $(eval "echo \$$git_env") ]]; then
        >&2 echo "ERROR - Missing '$git_env' environment!"
        exit 1
    fi
done

# Clone Repo
if [[ "${GIT_REPO:0:8}" == "https://" ]]; then
    clone_url="https://${GIT_USERNAME}:${GIT_ACCESSTOKEN}@${GIT_REPO:8}"
    if [[ -d ${tmp_git_work_tree} ]]; then rm -rf ${tmp_git_work_tree}; fi
    git clone -b $GIT_BRANCH $clone_url ${tmp_git_work_tree}
    export GIT_WORK_TREE=$tmp_git_work_tree
    # git status
else
    >&2 echo "ERROR - GIT_REPO '$GIT_REPO' is not supported!"
    exit 1
fi
if ! ( exit $? ) ; then 
    >&2 echo ERROR - Cannot clone repo $GIT_REPO
    exit 1
fi

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config pull.rebase true

uvicorn main:app $OPTIONS
