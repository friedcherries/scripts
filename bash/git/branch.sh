#/usr/bin/env bash

bname=$1

if [ "" = "${bname}" ]; then
    echo "You must provide a new branch name."
    echo "Dummy"
    exit;
fi

git branch $bname
git checkout $bname
git push origin $bname
git branch --set-upstream-to=origin/$bname $bname

