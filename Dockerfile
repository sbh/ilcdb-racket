# Use the official Racket image as a base
FROM racket/racket:latest

# Set the working directory
WORKDIR /app

# Install Racket packages
RUN raco pkg install mysql gregor

# Copy the application source code
COPY ./ilcdb-racket/ /app/

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["racket", "main.rkt"]