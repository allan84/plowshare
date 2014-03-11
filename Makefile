##
# Plowshare4 Makefile (requires GNU sed)
# Usage:
# - make PREFIX=/usr install
# - make PREFIX=/usr DESTDIR=/tmp/packaging install
#
# Important note for OpenBSD, NetBSD and Mac OS X users:
# Be sure to properly define GNU_SED variable (gsed or gnu-sed).
##

# Tools

INSTALL  = install
LN_S     = ln -sf
RM       = rm -f
GNU_SED ?= sed

# Files

MODULE_FILES = $(wildcard src/modules/*.sh) src/modules/config
SRCS      = download.sh upload.sh delete.sh list.sh probe.sh core.sh
MANPAGES1 = plowdown.1 plowup.1 plowdel.1 plowlist.1 plowprobe.1
MANPAGES5 = plowshare.conf.5
DOCS      = README

BASH_COMPL  = scripts/plowshare.completion
GIT_VERSION = scripts/version

# Target path
# DESTDIR is for package creation only

PREFIX ?= /usr/local
ETCDIR  = /etc
BINDIR  = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/plowshare4
DOCDIR  = $(PREFIX)/share/doc/plowshare4
MANDIR  = $(PREFIX)/share/man/man

# Rules

install: $(DESTDIR)$(BINDIR) patch_git_version patch_bash_completion

$(DESTDIR)$(BINDIR):
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(DATADIR)
	$(INSTALL) -d $(DESTDIR)$(DATADIR)/modules
	$(INSTALL) -d $(DESTDIR)$(DOCDIR)
	$(INSTALL) -d $(DESTDIR)$(MANDIR)1
	$(INSTALL) -d $(DESTDIR)$(MANDIR)5
	$(INSTALL) -m 644 $(MODULE_FILES) $(DESTDIR)$(DATADIR)/modules
	$(INSTALL) -m 755 $(addprefix src/,$(SRCS)) $(DESTDIR)$(DATADIR)
	$(INSTALL) -m 644 $(addprefix docs/,$(MANPAGES1)) $(DESTDIR)$(MANDIR)1
	$(INSTALL) -m 644 $(addprefix docs/,$(MANPAGES5)) $(DESTDIR)$(MANDIR)5
	$(INSTALL) -m 644 $(DOCS) $(DESTDIR)$(DOCDIR)
	$(LN_S) $(DATADIR)/download.sh $(DESTDIR)$(BINDIR)/plowdown
	$(LN_S) $(DATADIR)/upload.sh   $(DESTDIR)$(BINDIR)/plowup
	$(LN_S) $(DATADIR)/delete.sh   $(DESTDIR)$(BINDIR)/plowdel
	$(LN_S) $(DATADIR)/list.sh     $(DESTDIR)$(BINDIR)/plowlist
	$(LN_S) $(DATADIR)/probe.sh    $(DESTDIR)$(BINDIR)/plowprobe

uninstall:
	@$(RM) $(DESTDIR)$(BINDIR)/plowdown
	@$(RM) $(DESTDIR)$(BINDIR)/plowup
	@$(RM) $(DESTDIR)$(BINDIR)/plowdel
	@$(RM) $(DESTDIR)$(BINDIR)/plowlist
	@rm -rf $(DESTDIR)$(DATADIR) $(DESTDIR)$(DOCDIR)
	@$(RM) $(addprefix $(DESTDIR)$(MANDIR)1/, $(MANPAGES1))
	@$(RM) $(addprefix $(DESTDIR)$(MANDIR)5/, $(MANPAGES5))

patch_git_version: $(DESTDIR)$(BINDIR)
	@v=`$(GIT_VERSION)` && v2=`$(GIT_VERSION) x` && \
	for file in $(SRCS); do \
		$(GNU_SED) -i -e 's/^\(declare -r VERSION=\).*/\1'"'$$v'"'/' $(DESTDIR)$(DATADIR)/$$file; \
	done; \
	for file in $(DOCS); do \
		$(GNU_SED) -i -e '/[Pp]lowshare/s/\(.*\)GIT-snapshot\(.*\)/\1'"$$v"'\2/' $(DESTDIR)$(DOCDIR)/$$file; \
	done; \
	for file in $(MANPAGES1); do \
		$(GNU_SED) -i -e '/[Pp]lowshare/s/\(.*\)GIT-snapshot\(.*\)/\1'"$$v2"'\2/' $(DESTDIR)$(MANDIR)1/$$file; \
	done; \
	for file in $(MANPAGES5); do \
		$(GNU_SED) -i -e '/[Pp]lowshare/s/\(.*\)GIT-snapshot\(.*\)/\1'"$$v2"'\2/' $(DESTDIR)$(MANDIR)5/$$file; \
	done

patch_bash_completion: $(DESTDIR)$(BINDIR)
	@$(INSTALL) -d $(DESTDIR)$(ETCDIR)/bash_completion.d
	@$(GNU_SED) -e "/cut/s,/usr/local/share/plowshare4,$(DATADIR)," $(BASH_COMPL) > $(DESTDIR)$(ETCDIR)/bash_completion.d/plowshare4

# Note: sed append syntax is not BSD friendly!
patch_gnused: $(DESTDIR)$(BINDIR)
	@for file in $(SRCS); do \
		$(GNU_SED) -i -e '/\/licenses\/>/ashopt -s expand_aliases; alias sed='\''$(GNU_SED)'\' "$(DESTDIR)$(DATADIR)/$$file"; \
	done

.PHONY: install uninstall
