# Bash utils collection

## Source from file

Simply source the utils.sh file in your script:

    source utils.sh

## Source from git

You can add the bash-utils repo as a submodule to your project to keep an up-to-date version of the utils script.

    git submodule add https://github.com/aallrd/bash-utils.git bash-utils
    git submodule update

Then, simply source the utils.sh file in your script:

    source utils.sh

You can add the below helper in your script to automatically pull the latest from the bash-utils repo:

    if [[ -d "bash-utils" && ! "$(ls -A bash-utils)" ]] ; then
        git submodule init && git submodule update
        source "bash-utils/utils.sh"
    fi
