# Use the official Racket base image
FROM racket/racket:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Racket application code into the container
COPY . /app/ilcdb-racket
COPY ./ilcdb.schema.sql /app/ilcdb.schema.sql

# Racket's package manager uses this directory
RUN mkdir -p /root/.local/share/racket

# The web server runs on port 8080
EXPOSE 8080

# The command to run when the container starts
CMD ["racket", "./main.rkt"]