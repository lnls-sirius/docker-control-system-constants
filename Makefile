FAC_IMG_CSCONSTS_TAG ?= $(shell cat ./images/.env | grep FAC_IMG_CSCONSTS_TAG= | sed s/FAC_IMG_CSCONSTS_TAG=//g)

# --- tags ---

tag-show-fac-csconsts:
	@cat /tmp/_DEPLOY_TAG_

tag-update-fac-csconsts:
	cd services; find ./ -name "docker-*.yml" -exec sed -i "s/fac-csconsts:.*/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)/g" {} \;

tag-template-fac-csconsts:
	cd services; find ./ -name "docker-*.yml" -exec sed -i "s/fac-csconsts:.*/fac-csconsts:__FAC_CSCONSTS_TAG_TEMPLATE__/g" {} \;

# --- images ---

image-build-fac-csconsts: image-cleanup
	cd images; docker-compose --file docker-compose.yml build --force-rm --no-cache fac-csconsts
	# docker push dockerregistry.lnls-sirius.com.br/fac/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)

image-pull-fac-cscnsts:
	docker pull dockerregistry.lnls-sirius.com.br/fac/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)

image-cleanup:
	docker system prune --filter "label=br.com.lnls-sirius.department=FAC" --all --force

