# Inception

This project (developed as part of the 42 core curriculum) involves setting up a small infrastructure composed of several services under different rules using Docker. The services are a web server (Nginx), a database (MariaDB), and a content management system (WordPress). Each service runs in its own dedicated container.

## Features

-   **Dockerized Multi-Container Setup**: Each service (Nginx, WordPress, MariaDB) is isolated in its own Docker container.
-   **Orchestration with Docker Compose**: `docker-compose.yml` is used to build and manage the multi-container application.
-   **Nginx Web Server**: Serves the WordPress site and acts as a reverse proxy, with SSL/TLS encryption.
-   **WordPress CMS**: The application layer, providing the website's content management capabilities.
-   **MariaDB Database**: The persistence layer, storing all WordPress data.
-   **Data Persistence**: Docker volumes are used to persist MariaDB data and WordPress files, ensuring data is not lost when containers are stopped or removed.
-   **Secure Credential Management**: Docker secrets are used to handle sensitive data like database passwords and SSL certificates, avoiding hardcoding them in configuration files or images.
-   **Automated Setup**: Shell scripts automate the initial configuration of each service.

## Usage

### Prerequisites

-   Docker
-   Docker Compose

### Setup

1.  **Environment Variables**: This project uses an `.env` file to manage environment variables. You will need to create a `.env` file in the `srcs` directory. It should contain at least the following variables:
    -   `DOMAIN_NAME`: Any domain name such as `hello.world.com` that will be configured to point to the local IP address, so that typing it in the browser will connect to the WordPress application.
    -   `MARIADB_DATABASE`: A name for the database, e.g., `wordpress_db`.
    -   `MARIADB_USER`: A name for database user, e.g., `mdb_user`.
    -   `WORDPRESS_SHA1`: WordPress is installed from a `wordpress.tar.gz` file that is present in `srcs/requirements/wordpress/conf/wordpress.tar.gz`. The version used here is [6.8.3](https://wordpress.org/download/releases/) and its sha1 is `fd56bcdc15f1877e45dce67942ea75949ed650e8`.

2.  **Secrets**: Create a `secrets` directory at the root of the project and add the required secret files as defined in `docker-compose.yml`:
    -   `db_root_password.txt`: The root password for MariaDB.
    -   `db_password.txt`: The password for the WordPress database user.
    -   `anaqvi.42.fr.crt`: Your SSL certificate file.
    -   `anaqvi.42.fr.key`: Your SSL private key file.

3.  **Hosts File**: To access the site using the domain name you set, you may need to add an entry to your local `/etc/hosts` file:
    ```
    127.0.0.1 hello.world.com
    ```
    Replace `hello.world.com` with the value of `MARIADB_DATABASE` in your `.env` file, as this is used as the `server_name` in the Nginx configuration.

### Running the Application

1.  Navigate to the `srcs` directory.
2.  Build and start the services in detached mode:
    ```bash
    docker-compose up --build -d
    ```
3.  Access your WordPress site at `https://hello.world.com`.

### Stopping the Application

1.  To stop the services:
    ```bash
    docker-compose down
    ```
2.  To stop the services and remove the volumes (deleting all data):
    ```bash
    docker-compose down --volumes
    ```

## Key Concepts Learned & Applied

-   **Docker & Containerization**: Creating lightweight, isolated environments for services using Dockerfiles.
-   **Docker Compose**: Orchestrating a multi-container application, defining services, networks, and volumes.
-   **Networking**: Establishing communication between containers on a custom bridge network.
-   **Volumes**: Ensuring data persistence for the database and WordPress files across container lifecycles.
-   **Secrets**: Managing sensitive information securely without exposing it in the container image or source code.
-   **Nginx**: Configuration as a web server, reverse proxy, and enabling SSL/TLS for secure connections.
-   **MariaDB**: Database administration, including initialization, user creation, and securing access.
-   **WordPress**: Deploying a CMS application and connecting it to a backend database.
-   **Shell Scripting**: Automating service configuration inside containers for a seamless startup.

## Relevant resources and references

<p>
  Almost all resources mentioned here are official documentation, which is always the best resource to consult to get started as well as to troubleshoot. Third-party resources often have outdated information.
  <img src="https://page-views-counter-534232554413.europe-west1.run.app/view?src=github.com&src_uri=/alimnaqvi/inception" style="display: none;" />
</p>

- ["Get started" section](https://docs.docker.com/get-started/) of the official Docker docs
  - I recommend going through most of this section before starting the project. The [workshop](https://docs.docker.com/get-started/workshop/) is especially useful.
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Manual for Environment variables in Docker Compose](https://docs.docker.com/compose/how-tos/environment-variables/)
- [Manual for Secrets in Docker Compose](https://docs.docker.com/compose/how-tos/use-secrets/)
- [MariaDB Server Documentation](https://mariadb.com/docs/server)
- [WordPress Administration Handbook](https://developer.wordpress.org/advanced-administration/)
