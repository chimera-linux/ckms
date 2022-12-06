ckms-config.ini(5)

# NAME

*config.ini* - global configuration file of CKMS

# DESCRIPTION

CKMS reads two kinds of configuration files. This is the global configuration
file, which affects the whole system. Package configuration files affect
specific packages.

Its default location is _/etc/ckms/config.ini_ unless overridden on invocation.

Both types of configuration use ini files, with syntax as defined by Python's
_ConfigParser_, with the default configuration.

In general, all options have hardcoded defaults that are used when not present
in the configuration file, so technically this does not even have to exist.

# CKMS OPTIONS

This is everything in the section _[ckms]_.

*statedir* _(path)_
	The state directory to use when not overridden by _ckms_ invocation.
	The default is _/var/lib/ckms_.

*destdir* _(path)_
	The module destination directory to use when not overridden by _ckms_
	invocation. The default is _/lib/modules_.

*quiet* _(bool)_
	Whether to not print build output to stdout. The default is to print it.

*strip* _(string)_
	The strip binary to use for modules. The default is just _strip_.

*initramfs_hook* _(path)_
	Path to the executable that is invoked to refresh initramfs for a kernel.
	This can be a shell script and must be supplied by the distribution, as
	it is specific to the initramfs generator and so on.

	If it does not exist, initramfs is never refreshed, but it is not an error.
	If it does exist, it is invoked with the kernel version as its argument,
	with the _destdir_ as its working directory, and the current environment
	of the _ckms_ invocation. It should exit with 0 on success, and a non-zero
	return code on failure. A failure will result in an error being printed
	out, but it is not a hard error for the _ckms_ invocation.

	The default is _/etc/ckms/refresh-initramfs.sh_.

*make_build_args*
	Additional arguments to be provided in _CKMS\_MAKE\_ARGS_ in the build
	environment of a package. They are always added to the very end, after
	any arguments implicitly set up by CKMS.

# BUILD ENVIRONMENT

It is additionally possible to globally influence the build environment of
a package. Packages do not inherit the environment of the CKMS invocation.

All environment variables specified here take priority over any environment
variables previously set up.

The section is _[build\_env]_ and the environment variables are simply options
within the section.

This is a coarse system for doing global customizations once there is no other
way to do what you want, and should be used with care.

# SEE ALSO

*ckms*(8), *ckms.ini*(5)
