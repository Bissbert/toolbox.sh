SHELL := /bin/sh

# Name of the CLI (binary name). Avoid using NAME due to env collisions.
PROG ?= toolbox

# Install locations for a self-contained tree
SYSTEM_PREFIX ?= /opt/$(PROG)
USER_PREFIX ?= $(HOME)/.local/opt/$(PROG)

# Where to place a convenience shim/symlink for the CLI
SYSTEM_BINDIR ?= /usr/local/bin
USER_BINDIR ?= $(HOME)/.local/bin

# Honor DESTDIR for packaging
DESTDIR ?=

.PHONY: all test install install-user uninstall uninstall-user completions completion-bash completion-zsh print-prefix

all:
	@echo "Nothing to build. Try: 'make test' or 'make install'"

test:
	sh tests/run

print-prefix:
	@echo "System prefix: $(SYSTEM_PREFIX)"
	@echo " User  prefix: $(USER_PREFIX)"

# Internal helper: copy the project tree to a prefix
define _copy_tree
	@echo "Installing to $(1)"
	install -d "$(DESTDIR)$(1)"
	# Copy core directories/files (exclude VCS/test artifacts)
	cp -R bin lib tools templates "$(DESTDIR)$(1)/"
	cp -R README.md VERSION "$(DESTDIR)$(1)/"
endef

install:
	$(call _copy_tree,$(SYSTEM_PREFIX))
	@echo "Linking $(PROG) into $(SYSTEM_BINDIR)"
	install -d "$(DESTDIR)$(SYSTEM_BINDIR)"
	ln -sf "$(SYSTEM_PREFIX)/bin/$(PROG)" "$(DESTDIR)$(SYSTEM_BINDIR)/$(PROG)"
	@echo "Installed $(PROG) -> $(DESTDIR)$(SYSTEM_PREFIX)"

install-user:
	$(call _copy_tree,$(USER_PREFIX))
	@echo "Linking $(PROG) into $(USER_BINDIR)"
	install -d "$(DESTDIR)$(USER_BINDIR)"
	ln -sf "$(USER_PREFIX)/bin/$(PROG)" "$(DESTDIR)$(USER_BINDIR)/$(PROG)"
	@echo "Installed $(PROG) -> $(DESTDIR)$(USER_PREFIX)"

uninstall:
	@echo "Removing $(DESTDIR)$(SYSTEM_PREFIX)"
	rm -rf -- "$(DESTDIR)$(SYSTEM_PREFIX)"
	@echo "Removing link $(DESTDIR)$(SYSTEM_BINDIR)/$(PROG) if present"
	rm -f -- "$(DESTDIR)$(SYSTEM_BINDIR)/$(PROG)"

uninstall-user:
	@echo "Removing $(DESTDIR)$(USER_PREFIX)"
	rm -rf -- "$(DESTDIR)$(USER_PREFIX)"
	@echo "Removing link $(DESTDIR)$(USER_BINDIR)/$(PROG) if present"
	rm -f -- "$(DESTDIR)$(USER_BINDIR)/$(PROG)"

# Generate shell completion scripts into ./completions (ignored by .gitignore)
completions: completion-bash completion-zsh

completion-bash:
	@mkdir -p completions
	@TOOLBOX_NAME=$(PROG) ./bin/$(PROG) completion bash > completions/$(PROG).bash 2>/dev/null || \
	  (echo "Generating via sh" && TOOLBOX_NAME=$(PROG) sh ./bin/$(PROG) completion bash > completions/$(PROG).bash)
	@echo "Wrote completions/$(PROG).bash"

completion-zsh:
	@mkdir -p completions
	@TOOLBOX_NAME=$(PROG) ./bin/$(PROG) completion zsh > completions/_$(PROG) 2>/dev/null || \
	  (echo "Generating via sh" && TOOLBOX_NAME=$(PROG) sh ./bin/$(PROG) completion zsh > completions/_$(PROG))
	@echo "Wrote completions/_$(PROG)"
