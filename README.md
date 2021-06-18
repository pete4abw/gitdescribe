# gitdesc.sh
A simple program to parse `git describe`

## Synopsis
`gitdesc.sh command [-r]`

Where command is one of:
* all - entire git describe in --long format with or without tags
* commit - commit, omitting leading v (if applicable)
* tagrev - tag revision count
* major - major release version
* ninor - minor release version
* micro - micro release version
* version - M.m.c

and option is
* -r -- get release tag only

## Description
`gitdesc.sh` is a small utility to return elements from `git describe`
and echo them to terminal. It can be used to assign variables in a
configure.ac file using m4 defines. It can be used by package managers
to enhance package versioning. Using simple bash commands,
`gitdesc.sh` can be easily modified and adapted through creative use
of `cut` and `${string/manipulation/commands}`

It eleminates the need to hard code versions into configure.ac or
other files. Rather, it relies on git itself to provide versioning
information - either from tags or release (annotated) tags.

## NEW
If there is no **.git** directory, then a **VERSION** file can be used
with the following lines. This may occur if your project is downloaded
as a tarball. In this case, no **.git** directory will exist.

```
# Version file
# in case tarball downloaded

Major: 0
Minor: 0
Micro: 0
```
Or Adjust as necessary

## Installation
Place `gitdesc.sh` in your path or call directly. If using in a git
repository, place where needed.

## Usage in configure.ac
Assigning m4 variables can be tricky. calling `gitdesc.sh` for the
`m4_esyscmd_s` command can make it easier.

## Examples
First task is to strip the `git describe` command of any extra values.
All activity is contained in the `init()` function. 
```
# git describe raw format
describe_tag=$(git describe $tagopt --long --abbrev=$commit_length)
# if tag has a leading `v' this will remove
describe_tag=${describe_tag/v/}
describe_tag=${describe_tag/g/}
```
The result will be  
`some.version-R-1234567`

where `R' is a revision count from last tag, 0 - n.

From there, further string manipulations can occur. Here is the major
version getting stipped out.
```
version=$(echo $describe_tag | cut -d- -f1)
# assign major version
major=$(echo $version | cut -d. -f1)
```

If a **VERSION** file is used, then it will assign Major, Minor, and
Micro as needed.

And so on. Configure to taste. It's possible different repos will have
different formats and requirements.

In these examples, `gitdesc.sh` is in the util directory of the git repo.

`m4_define([v_maj], [m4_esyscmd_s([./util/gitdesc.sh major])])`
This line will assign the major version from the latest tag to the m4
variable **v_maj**.

`m4_define([v_full], [m4_esyscmd_s([./util/gitdesc.sh all])])`
This line will assign the entire git describe output to the variable **v_full**.

### [From my lrzip repo](https://github.com/pete4abw/lrzip)
```
m4_define([v_maj], [m4_esyscmd_s([./util/gitdesc.sh major])])  
m4_define([v_min], [m4_esyscmd_s([./util/gitdesc.sh minor])])  
m4_define([v_mic], [m4_esyscmd_s([./util/gitdesc.sh micro])])  
m4_define([v_ver], [v_maj.v_min.v_mic])  
```

## References
[The Advanced Bash Scripting
Guide](https://tldp.org/LDP/abs/html/refcards.html#AEN22828), and in
particular table **B-5** (linked here) has every trick you may need to
tailor gitdesc.sh to your needs.

## Thanks
Inspiration for this program came from Thomas Adam,of the [fvwm3
window manager](https://github.com/fvwmorg/fvwm3) which used a
similarly applied script.

## License
Free to use for commercial or non-commercial use. Attribution is
appreciated.

Peter Hyman\
December 2020, April 2021\
pete@peterhyman.com  
