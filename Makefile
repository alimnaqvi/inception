SRCS_DIR = ./srcs
DOCKER_COMPOSE = docker compose --project-directory ${SRCS_DIR}

VOLUME_NAMES = wordpress-files wordpress-db
VOLUMES_LOCATION = ${HOME}/data/
VOLUMES = $(addprefix ${VOLUMES_LOCATION}, ${VOLUME_NAMES})

SECRET_FILES = db_root_password.txt db_password.txt cert.pem key.pem
SECRETS_PATHS = $(addprefix ./secrets/, ${SECRET_FILES})

all: up

up: ${SECRETS_PATHS} ${VOLUMES}
	${DOCKER_COMPOSE} up --detach 

down:
	${DOCKER_COMPOSE} down

clean:
	${DOCKER_COMPOSE} down --volumes

fclean:
	${DOCKER_COMPOSE} down --volumes --rmi local
# 	rm -rf ${VOLUMES_LOCATION}

re:

build:
	${DOCKER_COMPOSE} ${SRCS_DIR} up --build --detach

${SECRETS_PATHS}:
	@echo "Error: $@ does not exist. Make sure the secrets directory is present and contains all four required secrets." && exit 1

${VOLUMES}:
	mkdir -p $@

.PHONY: all up down clean fclean re build
