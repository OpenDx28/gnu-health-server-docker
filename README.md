# GNU Health Docker

This project provides a Docker image for running a GNU Health server, configurable through environment variables to connect to a PostgreSQL database server. The project also includes a Docker Compose file to launch two containers of the image, connected to a single PostgreSQL server.

## Setup

1. Ensure you have Docker and Docker Compose installed on your machine. If not, you can download them from [Docker's official website](https://www.docker.com/products/docker-desktop).

2. Clone this repository:

git clone https://github.com/OpenDx28/gnu-health-server-docker.git

3. Navigate to the directory:

cd gnu-health-server-docker

## Usage

1. To build the Docker image, run:

docker build -t opendx/gnu_health .

2. To start the containers using Docker Compose, run:

docker-compose up -d

3. Open GNU Health Client and connect to the host server and port (changes from one instance to another).


## Configuration

The Docker image can be configured using the following environment variables:

- `DB_NAME`: The name of the database to connect to. Defaults to `ghs`.
- `DB_USER`: The username to connect to the database with. Defaults to `gnuhealth`.
- `DB_PASSWORD`: The password to connect to the database with. Defaults to `gnuhealth`.
- `DB_HOST`: The hostname of the database server. Defaults to `postgres`.
- `DEMO_DB`: Set this to 0 for an empty database or 1 for a demo database. Defaults to `1`.
- `ADMIN_PASSWORD`: Sets the default password for the `admin` user. Defaults to `opendx28`.

You can set these variables in the Docker Compose file.

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.


## People

* Rafael Nebot Medina. ITC-DCCT (Instituto Tecnológico de Canarias - Departamento de Computación)
* Paula Moreno Fajardo. ITC-DCCT
* Luis Falcón. GNU Solidario.
* Gerald Wiese. Leibniz Hannover University

## Acknowledgements

The development of this project has been supported by the Interreg-MAC programme 2014-2020, through the project [OpenDx28](https://opendx28.com/).
