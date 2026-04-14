# Use the official Python lightweight image.
# https://hub.docker.com/_/python
FROM python:3.11-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED=True

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the local code to the container image
COPY . .

# Run the web service on container startup.
# Cloud Run dynamically sets the PORT environment variable.
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
