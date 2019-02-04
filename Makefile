SUBDIRS = aws/private-subnet/default aws/private-subnet/no-nat aws/public-subnet
.PHONY: docs $(SUBDIRS)

docs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
