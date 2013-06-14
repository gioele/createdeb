createdeb: A simple way to create Debian packages
=================================================

`createdeb` generates Debian packages from simple package descriptors.

Internally `createdeb` acts as a frontend to `equivs-build`.


`debdesc` files
---------------

A `debdesc` file describes the content a `deb` package. It is used to
state the name and the version of the package, its dependencies, who is
its maintainer, under what licence it is licensed and, most important,
what files should be in the package and where they should be installed.

A simple `debdesc` file for a metapackage that only declares dependencies
looks like this:

    Section: metapackages
    Priority: important

    Package: demo-metapackage
    Maintainer: Mel Shmoe <mel@example.com>

    Description: A demo metapackage

    Depends:
     libdemo,
     demo-client

    Recommends:
     demo-config

A `createdeb` file for a more interesting package that installs new files
and modifies existing files would look like the following:

    Section: admin
    Priority: important

    Package: demo-config
    Maintainer: Mel Shmoe <mel@example.com>

    Description: A demo configuration package

    Depends:
     demo-metapackage


    Copy: maintenance.sh /usr/share/demo-config/
    Copy: check.sh /usr/share/demo-config/

    Diff: /etc/login.defs


The Copy and Diff directives
----------------------------

In addition to the normal `debian/control` directives, `createdeb`
recognizes also two additional directives: `Copy`, to copy files to
specific locations, and `Diff`, to automatically generate patches of
existing files.


### The Copy directive

The `Copy` directive requires a source file and a destination directory:

    Copy: <file> <directory>

The file to be copied must be placed in the directory
`<package-name>/files/`.


### The Diff directive

The `Diff` directive requires the absolute path of the file to be
patched:

    Diff: <full-path>

The `Diff` directive requires the presence of two files: the original
file, as will be found installed, and the modified file.

The path of the original file must be

    <package-name>/diff/<full-path>.orig

while the path of the modified file must be

    <package-name>/diff/<full-path>

`createdeb` will take care of creating the needed patches and adding the
patching instruction to the package control file.


Creating deb packages
---------------------

**equivs-build (up to version 2.0.9 included) has a bug that prevents
`createdeb` from producing working packages. Please follow the
[workaround instructions](https://github.com/gioele/createdeb/issues/1)
to avoid problems.**

Put all your `debdesc` package descriptors in a directoy, then use GNU
make to run the Makefile found in the directory where you downloaded
`createdeb`.

    $ ls .debdesc
    demo-config.debdesc
    demo-config/
    $ alias createdeb="make -f ~/apps/createdeb/Makefile"
    $ createdeb
    $ ls repo/
    demo-1.0_all.deb Packages.gz

Once built, the packages can be copied to a remote or local repository
using the target `upload`.

    $ createdeb upload REMOTE_REPO_DIR=mel@example.org:/var/repo


Author
------

* Gioele Barabucci <http://svario.it/gioele>


Licence
-------

This is free software released into the public domain (CC0 license).

See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
for more details.
