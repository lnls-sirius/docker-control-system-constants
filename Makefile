FAC_IMG_CSCONSTS_TAG ?= $(shell cat ./images/.env | grep FAC_IMG_CSCONSTS_TAG= | sed s/FAC_IMG_CSCONSTS_TAG=//g)
FAC_REP_CSCONSTS_VERSION ?= $(shell cat ./images/.env | grep FAC_REP_CSCONSTS_VERSION= | sed s/FAC_REP_CSCONSTS_VERSION=//g)

# --- deploy ---

deploy:
	# save deploy tag to file
	echo $(FAC_IMG_CSCONSTS_TAG) > /tmp/_DEPLOY_TAG_
	# update image tag in .env
	sed -i "s/FAC_IMG_CSCONSTS_TAG=.*/FAC_IMG_CSCONSTS_TAG=$(FAC_IMG_CSCONSTS_TAG)/g" ./images/.env
	# update csconsts version in .env
	sed -i "s/FAC_REP_CSCONSTS_VERSION=.*/FAC_REP_CSCONSTS_VERSION=$(FAC_REP_CSCONSTS_VERSION)/g" ./images/.env
	# create image and push to dockerregistry
	make image-build-fac-csconsts

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
	docker push dockerregistry.lnls-sirius.com.br/fac/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)

image-pull-fac-cscnsts:
	docker pull dockerregistry.lnls-sirius.com.br/fac/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)

image-cleanup:
	docker system prune --filter "label=br.com.lnls-sirius.department=FAC" --all --force

# --- services ---

service-start-csconsts:
	cd services; \
	sed -i "s/fac-csconsts:.*/fac-csconsts:$(FAC_IMG_CSCONSTS_TAG)/g" docker-stack-csconsts.yml; \
	docker stack deploy -c docker-stack-csconsts.yml facs-csconsts; \
	sed -i "s/fac-csconsts:.*/fac-csconsts:__FAC_CSCONSTS_TAG_TEMPLATE__/g" docker-stack-csconsts.yml

service-stop-csconsts:
	cd services; \
	docker stack rm facs-csconsts
