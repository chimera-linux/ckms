# Chimera Kernel Module System

*Version 0.1.1*

This is a lightweight alternative to DKMS (https://github.com/dell/dkms).
As DKMS is full of cruft and is essentially a massive bash script, I felt
a change was needed. In general CKMS works more or less the same, and has
the same filesystem layout, in order to make rewriting DKMS config files
and scripts easy. It is, however, written entirely from scratch.

It is currently an incomplete work in progress.

See the `examples/` directory for some module definitions.

## Requirements

* Python 3.9 or newer

## Usage

CKMS modules are collections of kernel modules, with `ckms.ini` defining
their metadata. They can have three states:

* added (registered with CKMS)
* built (done building but not installed yet)
* installed
* disabled

Each state is for a specific kernel version, except `added`, which is global.

To register a CKMS module, you can do something like this:

```
$ ckms add /usr/src/foo-1.0
```

This assumes `ckms.ini` exists in the directory. If it does not, you will
need to specify it manually via `-c` or `--modconf`.

Once done, the module will be `added` and you will no longer refer to it
by the full path. You can build it:

```
$ ckms build foo=1.0
```

It is still possible to refer to it by path too, this time in the database, e.g.

```
$ ckms build /var/lib/ckms/foo/1.0
```

That will build the module for the current kernel. If you want to build it
for another kernel, use the `-k` or `--kernver` parameter. The `ckms.ini`
is installed into the state directory with `add`, so you no longer have to
worry about it. You can still specify `-c` or `--modconf` manually if you
wish to override it for some reason.

It is possible to disable a module for a specific kernel version. A module is
disabled if the `ckms-disable` directory exists in the kernel module directory,
containing `packagename`, it itself containing `packageversion`. If this is done,
`ckms` will not allow you to build the module, and it will show as `disabled` in
`status`.

If disabled after it is built, it will show as `built+disabled` in `status`
and it will not be installable. If disabled after it is installed, it will
still show as `installed` in `status` and you will be able to uninstall it.
You will be able to `clean` it if built, regardless of installed status.

This functionality can be used e.g. by package managers to prevent CKMS from
building modules that are managed through packaged binaries for specific kernels.

Once built, you can install it similarly, with

```
$ ckms install foo=1.0
```

Keep in mind that in order for the system to work, the CKMS state directory,
which is `/var/lib/ckms` by default, needs to exist. You can run most commands
as the user who owns `/var/lib/ckms`, which should in general not be `root`.
The only exception is `install`, which by default touches system locations
and therefore should be run as `root` unless you are installing into a special
`destdir` (which will also prevent `depmod` from running). Same goes for the
inverse of `install`, i.e. `uninstall`.

If you run non-`install` (or `uninstall`) steps as `root`, CKMS will drop
privileges to the owner of `/var/lib/ckms`.

Once installed, the modules are ready to be used. CKMS will run `depmod` if
the modules are installed in a real kernel, and will refresh your `initramfs`
if the module requires it and if there is an appropriate hook in place.

Unlike DKMS, CKMS is primarily designed to be integrated into package managers
of distributions and avoids including any features that would overlap with
that. Therefore, there is no support for e.g. distributing and managing
tarballs, or binary modules, or so on.

Also, CKMS does not manage multiple kernels during one run. You have to run
the build/install process for every kernel separately.

The `install` step will not run unless `build` has been run, and likewise
`build` will not run without `add`. The `remove` command (which unregisters
a CKMS module) will not run if a module is still built for some kernels. You
have to `uninstall` them before doing so.

## TODO

* Fallback build helpers
* Shell expression option for boolean metadata
* Module signing
* More hooks
* More validation/sanity checking
* ...

