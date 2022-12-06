ckms.ini(5)

# NAME

*ckms.ini* - package configuration files of CKMS

# DESCRIPTION

CKMS reads two kinds of configuration files. This is the configuration file
for the package, which describes its metadata and a build recipe. There is
also the global configuration file, which may additionally influence builds.

Typically this is _ckms.ini_ located in the package's kernel module source
tree. It can also be supplied externally, however, during the _add_ step.

Both types of configuration use ini files, with syntax as defined by Python's
_ConfigParser_, with the default configuration. Value interpolation can be
used as specified by Python, with _%(foo)_ referring to either another field
in the same section, or a field of the general section.

Package config files have multiple sections.

# SECTIONS

*general*
	This describes the metadata of the package. This is the default section,
	which means interpolation of fields from this section will work in every
	other section, alongside the own values of the section.

*hooks*
	Hooks are simple shell snippets that are invoked during different
	phases of the module build.

*module.NAME*
	Module sections describe individual kernel modules that are the result
	of the build.

# GENERAL SECTION

There are several metadata fields that can be set in the general section.

*name* _(string)_
	This is the mandatory package name. An example would be _zfs_.

*version* _(string)_
	This is the mandatory package version. An example would be _2.0.5_.

*strip* _(bool)_
	Whether to have CKMS strip the modules. Optional and _yes_ by default.

*make* _(string)_
	The make command to use when building the module. Exposed into the
	build environment as the _MAKE_ variable. Optional, with the default
	being _gmake_. This value is special, because if _gmake_ does not
	exist in the system and _make_ is determined to be GNU make, it will
	be used instead. This means you can use _gmake_ and have it portably
	default to GNU make, regardless of whether it's called _gmake_ or just
	_make_ in the system.

*initramfs* _(bool)_
	Whether this module is to be a part of initramfs. Optional and defaults
	to _no_. If set to _yes_, it will result in the initramfs hook being
	called upon (un)installation.

# HOOKS SECTION

There are multiple hooks which describe a build recipe. They are just simple
shell snippets (executed with the system _/bin/sh_). Return codes other than
0 in any hook will result in an error. Most hooks are optional, but _build_
must always be present.

Hook output is logged to a log file, and may be printed to standard output
as well unless the invocation is quiet.

*configure*
	This hook is used to configure the package for build. For example in
	packages with an Autotools-based build system, this would typically run
	the _configure_ script.

*pre\_build*
	Run before the actual build.

*build*
	This is the mandatory hook that will build the module.

*post\_build*
	Run after the build.

# MODULE SECTIONS

Each resulting kernel module will have its own section. There are some
mandatory fields as well as some optional ones. The section name must be
the string _module.MODNAME_ where _MODNAME_ is the module name without any
extension.

*path* _(string)_
	This is the path in the build directory which contains the built module.
	That means the built module is in _BUILD\_DIR/path/MODNAME.ko_. Mandatory.

*dest* _(string)_
	This is the path in the kernel's modules directory where the module will
	be installed. To make an example, the final module may end up in
	_/lib/modules/dest/MODNAME.ko_.

*strip* _(bool)_
	This can be used to control stripping in a fine-grained way. All modules
	that do not explicitly say will follow the global package setting. Modules
	that do set it will have their own behavior.

# IMPLICIT FIELDS

The general section has some implicit fields that are set by CKMS, and those
can be referenced from other fields using the standard interpolation.

*ckms\_rootdir*
	The state directory of CKMS (i.e. _/var/lib/ckms_).

*ckms\_destdir*
	The destination directory of CKMS (i.e. _/lib/modules_).

*kernel\_hdrdir*
	The path to kernel headers for the given kernel.

*kernel\_arch*
	The kernel architecture, i.e. _uname -m_.

*kernel\_version*
	The kernel version.

# HOOK ENVIRONMENT

Hooks are executed with a specific shell environment. The environment may
be additionally overridden by the global configuration file of CKMS, which
needs to be used with care.

*PATH*
	The system *PATH*, passed through from the CKMS invocation.

*MAKE*
	The make implementation, typically _gmake_ or _make_, as decided by CKMS.

*SHELL*
	This is always _/bin/sh_.

*CKMS\_MODNAME*
	The package name from the metadata.

*CKMS\_MODVERSION*
	The package version from the metadata.

*CKMS\_JOBS*
	The number of build jobs to use.

*CKMS\_ROOTDIR*
	The state directory of CKMS (i.e. _/var/lib/ckms_).

*CKMS\_DESTDIR*
	The destination directory of CKMS (i.e. _/lib/modules_).

*CKMS\_DEPMOD*
	If running _depmod_ is enabled, this is set to 1.

*CKMS\_KERNEL\_HDRDIR*
	The path to kernel headers for the given kernel.

*CKMS\_KERNEL*
	The kernel version.

*CKMS\_ARCH*
	The kernel architecture, i.e. _uname -m_.

*CKMS\_MAKE\_ARGS*
	The arguments to pass to _MAKE_. This is a mixture of implicit make
	arguments constructed by CKMS, followed by global arguments that are
	specified in the CKMS global configuration file.

*LLVM*
	This is set to 1 if a kernel config file is located and the system
	infers that it was built with Clang.

*LLVM\_IAS*
	If a kernel config file is located and the system infers that GNU assembler
	was used to link, this is set to 0. Otherwise, if Clang was used (i.e.
	_LLVM_ is set to 1), this will also be set to 1. In any other case, this
	will be unset.

*LD*
	If a config file for the kernel is located, this is set to the linker
	used for the kernel, with _ld.lld_ and _ld.bfd_ being currently supported.
	Not set if an unknown linker was used.

# MAKE ARGUMENTS

CKMS will usually try to construct some implicit make arguments. This will
be done particularly when a kernel configuration file for the given kernel
can be found.

These arguments are currently constructed.

*LLVM=1*
	Added if Clang was used to build the kernel.

*LLVM\_IAS=0*
	Set if GNU assembler was used for the kernel.

*LLVM\_IAS=1*
	Set if Clang's integrated assembler was used for the kernel.

*LD=ld.bfd*
	Added if the BFD linker was used for the kernel.

*LD=ld.lld*
	Added if the LLD linker was used for the kernel.

# SEE ALSO

*ckms-config.ini*(5), *ckms*(8)
