# Chimera Kernel Module System

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

That will build the module for the current kernel. If you want to build it
for another kernel, use the `-k` or `--kernver` parameter. This assumes that
`ckms.ini` for the module exists within the source directory too; if it does
not, you still need to pass the path via `-c` or `--modconf`.

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
privileges to the owner of `/var/lib/ckms`. This does not apply to `status`,
which can be run as any user (as long as it can read `/var/lib/ckms`).

Once installed, the modules are ready to be used. CKMS will never regenerate
your `initramfs` or perform anything other than `depmod` (which can still be
overridden). It is up to you to do so.

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

* Status support
* Configuration file reading
* Fallback build helpers
* Configurable make implementation
* More flexibility with the paths
* Configurable stripping
* Shell expression option for boolean metadata
* Module signing
* More hooks
* More validation/sanity checking
* ...

