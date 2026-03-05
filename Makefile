TEXT_PAGINATION := true
LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif

sourcecode: draft-ietf-asdf-sdf-mapping.xml
	kramdown-rfc-extract-sourcecode -tfiles $^

sdfcheck: sourcecode
	for file in sourcecode/sdf/*.sdf; do echo $$file; cddl sdf-feature.cddl vp $$file; done

lists.md: draft-ietf-asdf-sdf-mapping.xml
	kramdown-rfc-extract-figures-tables -trfc $< >$@.new
	if cmp $@.new $@; then rm -v $@.new; else mv -v $@.new $@; fi
