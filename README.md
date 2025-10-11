# ILCDB Racket/HTMX Rewrite

This project is a rewrite of the ILCDB web application using Racket for the backend and HTMX for the frontend. The application is containerized using Podman for easy deployment and development.

## Prerequisites

- [Podman](https://podman.io/getting-started/installation)
- [podman-compose](https://github.com/containers/podman-compose)

## Building and Running the Application

1.  **Start the services:**

    ```bash
    podman-compose up --build
    ```

    This command will:
    - Build the Docker image for the Racket application.
    - Start the `app` and `db` services.
    - On the first run, the `db` service will be initialized with the schema from `ilcdb.schema.sql`.

2.  **Access the application:**
    - Web interface: [http://localhost:8080](http://localhost:8080)
    - API endpoint example: `curl http://localhost:8080/api/person`

## Populating the Database with Test Data

A script is provided to populate the database with a large set of realistic test data.

1.  **Ensure the application is running:**

    ```bash
    podman-compose up
    ```

2.  **Run the data generation script inside the container:**

    ```bash
    podman exec -it ilcdb-app racket generate-test-data.rkt
    ```
    This command executes the data generation script within the running `app` container, connecting to the `db` container to populate the database.

## Stopping the Application

To stop the services and remove the containers, run:

```bash
podman-compose down
```

This will stop the application and database containers. The database data will be preserved in a Podman volume. To remove the volume, run `podman volume rm ilcdb-data`.