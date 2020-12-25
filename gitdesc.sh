#?bin/sh
# Peter Hyman, pete@peterhyman.com
# December 2020
# Free to use
# No warranties
# Attribution appreciated as well as enhancements or fixes!

# gitdesc.sh
# This program will return commit references based on Tags and Annotated Tags from git describe
# customize init() function to extract variables to return
# ideal use to provide input for M4 defines in configure.ac
# or run standalone to get output for some other purpose like packaging

usage() {
cat >&2  <<EOF
$(basename $0) command [-r]
all - entire git describe
commit - commit, omitting v
tagrev - tag revision count
major - major release version
ninor - minor release version
micro - micro release version
version - M.m.c
-r -- get release tag only
EOF
exit 1
}

# showw message and usage
die() {
	echo "$1"
	usage
}

# return variables
# everything, with leading `v' and leading `g' for commits
describe_tag=

# abbreviated commit
commit=

# count of commits from last tag
tagrev=

# major version
major=

# minor version
minor=

# micro version
micro=

# get release or tag?
# if -r option is used, tagopt will be null
tagopt="--tags"

# how long shhow commit string be? 7 is default
commit_length=7

# get whole commit and parse
# if tagrev > 0 then add it and commit to micro version
# Expected tag format is:
##-##-##
# v#.#.# - adjust as required
##-##-##
# git describe will return
# vTAG-R-gC

# describe_tag variable will hold
# TAG-R-C
# with leading v and commit leadint g removed

init() {
	# git describe raw format
	describe_tag=$(git describe $tagopt --long --abbrev=$commit_length)

	# if tag has a leading `v' this will remove
	# if some other tag format is used, change or omit
	describe_tag=${describe_tag/v/}

	# git describe prefixes commit with the letter `g'
	# this substitution removes the g. If the letter `g' is part of tag, this logic
	# will need revision, such as reversing $describe_tag and then reverting
	# echo $describe | rev, for example
	describe_tag=${describe_tag/g/}

	# assign commit, tag revision, and version to variables using `-' separator
	commit=$(echo $describe_tag | cut -d- -f3)
	tagrev=$(echo $describe_tag | cut -d- -f2)
	version=$(echo $describe_tag | cut -d- -f1)

	# set micro version or full micro version if tag revision > 0
	micro=$(echo $version | cut -d. -f3)
	[ $tagrev -gt 0 ] && micro=$micro-$tagrev-$commit

	# assign minor version
	minor=$(echo $version | cut -d. -f2)

	# assign major version
	major=$(echo $version | cut -d. -f1)
}

[ ! $(which git) ] && die "Something very wrong: git not found."

[ $# -eq 0 ] && die "Must provide a command and optional argument."

# are we getting a release only?
if [ $# -eq 2 ]; then
	if [ $2 = "-r" ]; then
		tagopt=""
	else
		die "Invalid option. Must be -r or nothing."
	fi
fi

init

case "$1" in
	"all" )
		retval=$describe_tag
		;;
	"commit" )
		retval=$commit
		;;
	"tagrev" )
		retval=$tagrev
		;;
	"version" )
		retval=$version
		;;
	"major" )
		retval=$major
		;;
	"minor" )
		retval=$minor
		;;
	"micro" )
		retval=$micro
		;;
	* )
		die "Invalid command."
		;;
esac

echo $retval

exit 0
