ckms(8)

# NAME

CKMS - Chimera Kernel Module System

# SYNOPSIS

*ckms* [_options_...] _command_ [_arguments_...]

# DESCRIPTION

CKMS is a kernel module build system originally created for Chimera Linux.

It is designed to be a replacement for DKMS (Dynamic Kernel Module Support)
which is considered unwieldy and bloated, while missing certain functionality.

While it can be used on its own, usually it is to be invoked from package
management scripts.

The system is designed to have a similar file system layout and other aspects
to DKMS, in order to make porting DKMS configuration files easy. However, it
is written entirely from scratch, and not directly compatible.

A CKMS invocation consists of zero or more optional arguments, a command
and positional command arguments. The command is the action to perform,
influenced by the optional arguments. The extra positional arguments are
command-specific.

The system operates on packages. A package is a collection of one or more
modules, described by a configuration file (_ckms.ini_) plus a source tree.
The _ckms.ini_ describes some metadata about the package, plus a simple
recipe for building modules from source, and a list of kernel modules it
provides. It has its own manpage, *ckms.ini*(5).

CKMS can only build modules from source and manage their installation and
uninstallation/cleanup. Unlike DKMS, it cannot do things like create binary
or source tarballs for distribution, a feature which is in practice almost
never used for various reasons.

All state is tracked in the database directory, typically _/var/lib/ckms_.
This directory is to be owned by a special designated user. CKMS will then
drop privileges for all actions that involve manipulating the database (which
is anything that is not installation) to this user. That means builds and
so on are typically unprivileged, even if invoked as the root user.

# OPTIONS

The following are global optional arguments which affect the behavior of
the commands.

*-C, --config* _CONFIG_
	Path to the CKMS global configuration file (_/etc/ckms/config.ini_ by
	default). This configuration file has its own manual page
	*ckms-config.ini*(5).

*-c, --pkgconf* _PKGCONFIG_
	Override the module package config file when adding. This is rarely
	necessary, except when you are adding a kernel module source tree that
	does not supply a _ckms.ini_, and you are supplying it externally. By
	default, the package's own config file is used, which is _ckms.ini_ in
	the source tree.

*-D, --no-depmod*
	Depmod will not be performed after module installation.

*-d, --destdir* _DESTDIR_
	The kernel module destination directory. By default this is _/lib/modules_.

*-j, --jobs*
	The number of build jobs to use. By default, the number of CPUs is used.

*-k, --kernver* _KERNVER_
	The kernel version to use. By default, this is the current kernel.

*-L, --no-color*
	Force plain output without any ANSI colors. This is the default when
	the _NO\_COLOR_ environment variable is set or when the standard output
	is not a terminal.

*-q, --quiet*
	The build output will not be logged to standard output.

*-s, --statedir* _STATEDIR_
	The CKMS state directory (_/var/lib/ckms_ by default).

*-x, --compression* _METHOD_
	The compression method to use for modules. By default, no compression
	is used. The valid methods are _gz_, _xz_ and _zst_.

# COMMANDS

These commands are permitted, along with their options.

When the argument is a _PATH_, it's an absolute or relative path to a specific
directory. When it's a _PACKAGE_, it can be either _name=version_ (for example
_zfs=2.0.5_) or its path in CKMS database (e.g. _/var/lib/ckms/zfs/2.0.5_).

*add* _PATH_
	Add the given path, which refers to a CKMS package, to the database.
	Unless _--modconf_ is passed, this path has to contain a _ckms.ini_.
	This is the first thing you have to do before you manipulate a module.

	This results in the _ckms.ini_ or user-supplied config being copied to
	the database. All other commands will then read the copied file.

*remove* _PACKAGE_
	Remove a previously added package from the CKMS database. This will
	succeed only if there are no built kernel modules, so you will have
	to _uninstall_ and _clean_ them beforehand.

*build* _PACKAGE_
	Build a previously added package. If already built, this will not build
	again.

*clean* _PACKAGE_
	Clean a previously built package. That means restoring it back to the
	state when it was simply added.

*install* _PACKAGE_
	Install a package for the given kernel. It has to be built. If already
	installed, it will not be installed again. Normally, _depmod_ will be
	run after the installation, but this can be overridden. Also, if _depmod_
	has run successfully, an initramfs refresh hook may be invoked, if declared
	by the package. This is useful for packages that install modules which
	are needed in the initramfs. Handling initramfs refresh requires a custom
	user-supplied hook script, whose path can be set in the global config file.

*uninstall* _PACKAGE_OR_NAME_
	Uninstall a package for the given kernel. Similarly to installation, the
	_depmod_ command may be invoked, and initramfs may be refreshed. You do
	not have to specify the version here, as CKMS can guess the installed
	version from just the name.

*status* [_NAME_]
	Display the current status for either the given package or all packages,
	for the given kernel. If specifying a package, either specify just the
	name (which will display the status for all available versions) or
	specify only the version you want (which will filter the results).

	The status has the format _name, version, kernver, arch: state_, where
	the name is the package name, the version is its version, the kernver
	is the kernel version, the arch is the CPU architecture (as in _uname -m_),
	and the state is one of the valid states.

*plain-status* [_PACKAGE_]
	Just like *status*, but unformatted, i.e. just a space-separated list of
	words. This is intended for simplified parsing by readers. The fields are
	otherwise identical.

# PACKAGE STATES

The following states are recognized and valid.

*added*
	The package is registered with CKMS, but not built for the kernel, or
	installed.

*built*
	The package is built for the kernel, but not installed in the system.

*installed*
	The package is installed in the system. This is also the state CKMS will
	report if the package has been disabled after installation. You will be
	able to uninstall the modules, and afterwards you will not be able to
	install them again.

*disabled*
	The package is disabled for the kernel. Disabling a package prevents it
	from being built. This is mostly useful when a kernel is managing specific
	modules on its own, and CKMS would only get in the way.

	A package can be disabled for a kernel by creating a file with the same
	name as the kernel version in the _ckms-disable_ directory located inside
	the package's source tree.

*built+disabled*
	This is the state the package will have when it has been built for the
	kernel, then disabled, but not yet installed. You will be able to clean
	the modules, but not build them again.

# BUILD PROCESS

When building modules, the whole source tree is first copied to a separate
location in the state directory. This is needed because we cannot make any
assumptions about whether the module tree supports out-of-tree builds, and
we cannot pollute the original system source tree.

Once this is successfully done, the _configure_ hook is run if it exists.
Every hook gets its own log file initially in the _logs_ directory within
the state directory's subdirectory for this package version.

Once configured, the _pre\_build_ hook is invoked if it exists.

Then, the mandatory _build_ hook is invoked, i.e. it must always exist.
At some point an implicit default hook may be implemented, but for now
it is not.

Once build, the _post\_build_ hook is optionally invoked.

Once all of this is done, the built modules are registered as built. That
involves copying the built modules to a designated location in the state
directory, for the given kernel version and architecture. During this pass,
the modules are also optionally stripped, and have their permissions sanitized
within the registered destination.

Once done, the temporary copy of the module source tree is removed, and the
logs are also moved where the final registered modules are.

If any hook fails, CKMS will exit and the files will remain as they are,
so that the reason of the failure can be investigated and fixed. The build
can then be run again (all hooks will be re-run).

# EXAMPLES

To register a new package:

	ckms add /usr/src/zfs-2.0.5

To register a package that is missing a _ckms.ini_:

	ckms -c zfs.ini add /usr/src/zfs-2.0.5

To build it for an explicit kernel:

	ckms -k 4.20.69\_1 build zfs=2.0.5

You can also do it like this, though:

	ckms -k 4.20.69\_1 build /var/lib/ckms/zfs/2.0.5

To install it after building:

	ckms -k 4.20.69\_1 install zfs=2.0.5

To get rid of it (version is optional here):

	ckms -k 4.20.69\_1 uninstall zfs

To clean built artifacts of it:

	ckms -k 4.20.69\_1 clean zfs=2.0.5

And to remove it from the database:

	ckms remove zfs=2.0.5

To print status of all packages for the current kernel:

	ckms status

# SEE ALSO

*ckms-config.ini*(5), *ckms.ini*(5)
