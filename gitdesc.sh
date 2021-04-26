#?bin/sh
# Peter Hyman, pete@peterhyman.com
# December 2020, April 2021
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
commit - commit, omitting g
tagrev - tag revision count
tagdate - date tag committed
major - major release version
minor - minor release version
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

# date tag committed
tagdate=

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
	local realtag
	if [ -d '.git' ] ; then
		# git describe raw format
		describe_tag=$(git describe $tagopt --long --abbrev=$commit_length)

		# grab real tag version in case we need it for git-show
		realtag=$(echo $describe_tag | cut -d- -f1)

		# if tag has a leading `v' this will remove
		# if some other tag format is used, change or omit
		describe_tag=${describe_tag/v/}

		# git describe prefixes commit with the letter `g'
		# this substitution removes the g. If the letter `g' is part of tag, this logic
		# will need revision, such as reversing $describe_tag and then reverting
		# echo $describe | rev, for example, and get variables right to left
		describe_tag=${describe_tag/g/}

		# assign commit, tag revision, and version to variables using `-' separator
		commit=$(echo $describe_tag | cut -d- -f3)
		tagrev=$(echo $describe_tag | cut -d- -f2)
		version=$(echo $describe_tag | cut -d- -f1)

		# if tag date is needed
		# alter date format per strftime formats
		# YYYY-mm-dd
		tagdate=$(git show -n1 -s --date=format:"%Y-%m-%d" --format="%cd" $realtag)

		# (Other examples)
		# dd mmm YYYY
		# tagdate=$(git show -n1 -s --date=format:"%d %b %Y" --format="%cd" $version)
		# dd MMMMMMM YYYY
		# tagdate=$(git show -n1 -s --date=format:"%d %B %Y" --format="%cd" $version)

		# set micro version or full micro version if tag revision > 0
		micro=$(echo $version | cut -d. -f3)
		[ $tagrev -gt 0 ] && micro=$micro-$tagrev-$commit

		# assign minor version
		minor=$(echo $version | cut -d. -f2)

		# assign major version
		major=$(echo $version | cut -d. -f1)
	elif [ -r VERSION ] ; then
		# if no .git directory, then look for a file named VERSION
		major=$(awk '/Major: / {printf "%s",$2; exit}' VERSION)
		minor=$(awk '/Minor: / {printf "%s",$2; exit}' VERSION)
		micro=$(awk '/Micro: / {printf "%s",$2; exit}' VERSION)
	else
		# if no .git directory and no file VERSION, then we can't go on
		echo "Cannot find .git or VERSION file. Aborting"
		exit 1
	fi
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
	"tagdate" )
		retval=$tagdate
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
