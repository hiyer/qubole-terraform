SUBDIRS = aws/private-subnet/default aws/private-subnet/with-ec2-endpoint aws/public-subnet aws/iam-role aws/iam-user
.PHONY: docs $(SUBDIRS)

docs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
