build
=====

Stage and deploy your projects with Perl regex filtering, preprocessing, and revision conrol (using git, of course).  All configuration is done in a single YAML file.

installation
=====

First, look at the first few lines of build and make sure your Perl path is correct (on line #1).  Also, you might want to create a "lib" directory for Perl somewhere, and point build at it (on the 'use lib' line).  Then, copy Filter.pm to that directory.  Afterwards you can write up a build.yaml to do all this for you =)

usage
=====

build
    -l (--list)             list all possible targets and exit
    -v (--verbose)          be more verbose (can be used multiple times eg: '-vvv')
    -f (--yaml --config)    specify a yaml file to use (instead of the default 'build.yaml')
    -b (--build-only)       build step only
    -d (--deploy-only)      deploy step only

YAML config example
=====

see test/build.yaml

Perl req's
=====
```perl
use Carp;
use Data::Dumper;

use Cwd;
use File::Basename qw(fileparse);
use YAML::XS qw(LoadFile);
use Getopt::Long;
use Sys::Hostname;
```

I believe the relevant macports package is 'p5-yaml-libyaml' for YAML::XS.  Let me know about other platforms/package systems and I'll post them here.
