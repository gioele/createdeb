createdeb: A simple way to create Debian packages
=================================================

`createdeb` generates Debian packages from simple package descriptors.


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

Create a package

    $ createdeb demo-config.debdesc

Once built, a package can be copied to a remote or local repository
using the option `--upload`.

    $ createdeb --upload mel@example.org:/var/repo demo-config.debdesc


Author
------

* Gioele Barabucci <http://svario.it/gioele>


Licence
-------

This is free software released into the public domain (CC0 license).

See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
for more details.
