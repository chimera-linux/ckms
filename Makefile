PREFIX     ?= /usr
SYSCONFDIR ?= /etc
BINDIR     ?= $(PREFIX)/bin

all:
	@echo Nothing to be done.

install:
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(SYSCONFDIR)/ckms
	install -m 755 ckms $(DESTDIR)$(BINDIR)
	install -m 644 config.ini $(DESTDIR)$(SYSCONFDIR)/ckms
