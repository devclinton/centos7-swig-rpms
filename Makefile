VERSION:=3.0.12
MAJOR_VERSION:=$(shell echo $(VERSION) | cut -b 1-3)
TARGET:=swig-$(VERSION)
OUTPUT:=$(TARGET)-1.el7.x86_64.rpm
centos7: $(OUTPUT)

$(OUTPUT): Dockerfile
	# generate buildout.cfg
	cp buildout.cfg.template buildout.$(MAJOR_VERSION).cfg
	perl -pi -e 's/#MAJOR_VERSION#/$(MAJOR_VERSION)/g' buildout.$(MAJOR_VERSION).cfg
	perl -pi -e 's/#VERSION#/$(VERSION)/g' buildout.$(MAJOR_VERSION).cfg
	docker build --build-arg VERSION=$(VERSION) \
		--build-arg BUILDOUT_CFG=buildout.$(MAJOR_VERSION).cfg \
		--build-arg MAJOR_VERSION=$(MAJOR_VERSION) \
		--build-arg HTTP_PROXY=http://172.17.0.8:3128 \
		--build-arg HTTPS_PROXY=http://172.17.0.8:3128 \
		--build-arg FTP_PROXY=http://172.17.0.8:3128 \
		--rm -t swig:$(VERSION)-centos -f Dockerfile .
	ID=$$(docker create swig:$(VERSION)-centos) \
	&& docker cp $$ID:/build/$(TARGET)-1.x86_64.rpm $(OUTPUT) \
	&& docker rm $$ID
	