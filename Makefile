PREFIX     ?= /usr
SYSCONFDIR ?= /etc
BINDIR     ?= $(PREFIX)/bin
DATADIR    ?= $(PREFIX)/share
MANDIR     ?= $(DATADIR)/man

all: ckms-config.ini.5 ckms.ini.5 ckms.8

ckms.8: ckms.8.scd
	scdoc < ckms.8.scd > ckms.8

ckms.ini.5: ckms.ini.5.scd
	scdoc < ckms.ini.5.scd > ckms.ini.5

ckms-config.ini.5: ckms-config.ini.5.scd
	scdoc < ckms-config.ini.5.scd > ckms-config.ini.5

install: ckms-config.ini.5 ckms.ini.5 ckms.8
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)/man5
	install -d $(DESTDIR)$(MANDIR)/man8
	install -d $(DESTDIR)$(SYSCONFDIR)/ckms
	install -m 755 ckms $(DESTDIR)$(BINDIR)
	install -m 644 ckms.8 $(DESTDIR)$(MANDIR)/man8
	install -m 644 ckms.ini.5 $(DESTDIR)$(MANDIR)/man5
	install -m 644 ckms-config.ini.5 $(DESTDIR)$(MANDIR)/man5
	install -m 644 config.ini $(DESTDIR)$(SYSCONFDIR)/ckms
