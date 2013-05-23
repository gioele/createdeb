REPO_DIR := repo

debs := $(addprefix $(REPO_DIR)/,$(patsubst %.debdesc,%.deb,$(wildcard *.debdesc)))
summary := $(REPO_DIR)/Packages.gz

all: $(debs) $(summary)

$(REPO_DIR):
	mkdir -p $@

%.equivs: %.debdesc
	./add_fields $< $@

%.deb: %.equivs
	equivs-build $<
	touch $@

$(REPO_DIR)/%.deb: %.deb | $(REPO_DIR)
	mv *.deb $(REPO_DIR)

$(summary): $(debs) | $(REPO_DIR)
	cd $(REPO_DIR) && dpkg-scanpackages --multiversion --arch all . | gzip -9c > Packages.gz

clean:
	rm -f $(summary)
	rm -f $(debs)
	rm -Rf $(REPO_DIR)

upload: all
	echo rsync TODO

.PHONY: all clean upload
