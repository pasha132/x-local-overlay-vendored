# Vendored distfiles for packages in the x-local-overlay overlay

This repository provides pipelines for automatically vendoring distfiles required for some packages in the [x-local-overlay](1).

## Go vendor tarballs

To create vendor tarballs,
simply edit the CI configuration and add a new item to the ``build-vendor`` job matrix.
The variables ``PN``, ``PV``, ``SRC_URI`` and ``S`` must be specified in the same way as in the ebuild.

[1]: https://github.com/pasha132/x-local-overlay
