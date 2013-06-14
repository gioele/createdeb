createdeb: A simple way to create Debian packages
=================================================

`createdeb` generates Debian packages from simple package descriptors.

Internally `createdeb` acts as a frontend to `equivs-build`.


Usage
-----

**equivs-build (up to version 2.0.9 included) has a bug that prevents
`createdeb` from producing working packages. Please follow the
[workaround instructions](https://github.com/gioele/createdeb/issues/1)
to avoid problems.**

Put all your `debdesc` package descriptors in the `createdeb` directory
and launch the Makefile using GNU Make.

    $ ls *.debdesc
    demo.debdesc
    $ make
    $ ls repo/
    demo-1.0_all.deb Packages.gz

Once built, the packages can be copied to a remote or local repository
using the Makefile target `upload`.

    $ make upload REMOTE_REPO_DIR=mel@example.org:/var/repo


Author
------

* Gioele Barabucci <http://svario.it/gioele>


Licence
-------

This is free software released into the public domain (CC0 license).

See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
for more details.
