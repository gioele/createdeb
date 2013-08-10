MF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

REPO_DIR := repo

debs := $(addprefix $(REPO_DIR)/,$(patsubst %.debdesc,%.deb,$(wildcard *.debdesc)))
summary := $(REPO_DIR)/Packages.gz

all: $(debs) $(summary)

$(REPO_DIR):
	mkdir -p $@

.SECONDEXPANSION:
%.equivs: %.debdesc $$(call find, $(basename %), *)
	$(MF_DIR)/add_fields $< $@

%.deb: %.equivs
	equivs-build $<
	touch $@


find = $(foreach dir,$(1),$(foreach d,$(wildcard $(dir)/*),$(call find,$(d),$(2))) $(wildcard $(dir)/$(strip $(2))))

$(REPO_DIR)/%.deb: %.deb | $(REPO_DIR)
	mv *.deb $(REPO_DIR)

$(summary): $(debs) | $(REPO_DIR)
	cd $(REPO_DIR) && dpkg-scanpackages --multiversion --arch all . | gzip -9c > Packages.gz

clean:
	rm -f $(summary)
	rm -f $(debs)
	rm -Rf $(REPO_DIR)

.SECONDEXPANSION:

REMOTE_REPO_DIR ?= $(error Required variable REMOTE_REPO_DIR not set)
upload: all
	rsync -r --update --verbose --partial --progress $(REPO_DIR)/ $(REMOTE_REPO_DIR)

.PHONY: all clean upload
