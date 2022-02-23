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

TBD

## TODO

* Logging system
* Status support
* Configuration file reading
* Fallback build helpers
* Configurable make implementation
* More flexibility with the paths
* Configurable stripping
* Shell expression option for boolean metadata
* Compressed modules
* Module signing
* More hooks
* More validation/sanity checking
* Quiet mode (only output build progress to log, not to stdout)
* ...

