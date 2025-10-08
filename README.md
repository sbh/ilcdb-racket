# ILCDB Racket Rewrite

This repository contains the source code for a rewrite of the ILCDB web application, using Racket for the backend and HTMX for the frontend.

## Containerizing the Application with Podman

This project is set up to run in containers using Podman and `podman-compose`.

### Prerequisites

*   [Podman](https://podman.io/getting-started/installation)
*   `podman-compose`

### 1. Database Setup

The `compose.yaml` file automates the entire database setup process. When you run `podman-compose up` for the first time, it will:

1.  Start a MySQL 8.0 container.
2.  Create a database named `ilcdb`.
3.  Create a user named `ilcdb_user` with the password `ilcdb_password`.
4.  Grant all necessary permissions on the `ilcdb` database to the `ilcdb_user`.
5.  Execute the `ilcdb.schema.sql` file to create all the necessary tables.

The database credentials used by the Racket application are configured in `ilcdb-racket/db/connection.rkt` and match the environment variables set in the `compose.yaml` file.

### 2. Building the Application Image

To build the container image for the Racket application, navigate to the root directory of this repository and run the following command:

```bash
podman build -t ilcdb-app .
```

This will read the `Dockerfile`, install the necessary dependencies, and package the Racket application into a container image named `ilcdb-app`.

### 3. Running the Application Stack

To start the entire web application, including both the Racket app and the MySQL database, run the following command from the root of the repository:

```bash
podman-compose up -d
```

This command will:
- Start the `db` service (MySQL).
- Start the `app` service (Racket), waiting for the database to be ready first.
- The `-d` flag runs the containers in detached mode, so they will run in the background.

Your application should now be running and accessible at `http://localhost:8080`.

To stop the application, run:
```bash
podman-compose down
```

### 4. Populating the Database with Test Data

After the application is running, you can populate the database with a large set of test data using the provided script.

To do this, execute the following command from the root of the repository. This command runs the `generate-test-data.rkt` script *inside* the already running `ilcdb-app` container:

```bash
podman exec -it ilcdb-app racket ilcdb-racket/scripts/generate-test-data.rkt
```

The script will print its progress to the console as it clears the tables and generates new data. Once it's complete, you can navigate to `http://localhost:8080/clients` to see the newly populated client list.