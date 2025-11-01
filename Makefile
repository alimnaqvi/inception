SRCS_DIR = ./srcs
DOCKER_COMPOSE = docker compose --project-directory ${SRCS_DIR}

VOLUME_NAMES = wordpress-files wordpress-db
VOLUMES_LOCATION = ${HOME}/data/
VOLUMES = $(addprefix ${VOLUMES_LOCATION}, ${VOLUME_NAMES})

SECRET_FILES = db_root_password.txt db_password.txt cert.pem key.pem wp_admin_password.txt wp_user_password.txt
SECRETS_PATHS = $(addprefix ./secrets/, ${SECRET_FILES})

all: up

up: ${SECRETS_PATHS} ${VOLUMES} build
	${DOCKER_COMPOSE} up --detach 

down:
	${DOCKER_COMPOSE} down

clean:
	${DOCKER_COMPOSE} down --volumes

fclean:
	${DOCKER_COMPOSE} down --volumes --rmi local
	@echo "HINT: fclean requires sudo permission to delete the ${VOLUMES_LOCATION} directory. You might be asked to enter password in the next step"
	sudo rm -rf ${VOLUMES_LOCATION}
# 	docker system prune -a -f

re: fclean all

build:
	${DOCKER_COMPOSE} build

${SECRETS_PATHS}:
	@echo "Error: $@ does not exist. Make sure the secrets directory is present and contains all four required secrets." && exit 1

${VOLUMES}:
	mkdir -p $@

.PHONY: all up down clean fclean re build
