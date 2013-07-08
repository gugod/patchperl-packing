#!/bin/bash

perlenv=perl-5.8.8@patchperl-packing

cd $(dirname $0)

eval "$(perlbrew init-in-bash)"
perlbrew use ${perlenv}

if [[ $? -eq 0 ]]; then
    echo "-- Using to $perlenv"
else
    echo "Require a perl+lib installation named exactly $perlenv"
    exit 1
fi

git clean -d -f
git pull

cpanm Devel::PatchPerl App::FatPacker || exit 1

hash -r
hash -r

if [[ "$PERLBREW_ROOT/bin/patchperl" == $(which patchperl) ]]; then
    echo "The patch of patchperl does not look right, abort"
    exit 1
fi


fatpack trace `which patchperl`
fatpack packlists-for `cat fatpacker.trace` >packlists
fatpack tree `cat packlists`
(echo "#!/usr/bin/env perl"; fatpack file; cat `which patchperl`) > patchperl
chmod +x patchperl

versions=$(perl -MApp::FatPacker -MDevel::PatchPerl -e 'print "patchperl: " . Devel::PatchPerl->VERSION . ", fatpacker: " . App::FatPacker->VERSION . "\n"')

git add patchperl

git_changed=$(git status --porcelain patchperl | grep patchperl)

if [[ "$git_changed" == "" ]]; then
    echo "Nothing changed. Skip committing."
    exit 0
else
    git commit -m "rebuild with $versions"
    git push
    git clean -d -f
    git pull
fi

