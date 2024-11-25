

# Use a lightweight Python base image for better performance and smaller image size
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Install essential system libraries required for the application
# - libgl1: Provides OpenGL support
# - libglib2.0-0: Required by image processing libraries like OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 && \
    apt-get clean

# Copy the requirements.txt file to the container
# This ensures dependencies are installed correctly
COPY requirements.txt /app/requirements.txt

# Copy the YOLO model file into the container
# The model file will be used by the application for predictions
COPY yolo11n.pt /app/yolo11n.pt

# Install Python dependencies specified in the requirements.txt file
# --no-cache-dir: Prevents caching to reduce image size
RUN pip install --no-cache-dir -r requirements.txt

# Copy the remaining project files into the container
# This includes the application code and other resources
COPY . /app

# Expose port 8000 to allow access to the application
EXPOSE 8000

# Run the application using Gunicorn with Uvicorn workers for production
# - `app:app`: Refers to the `app` instance in `app.py`
# - `-w 4`: Specifies 4 worker processes for handling requests
# - `-k uvicorn.workers.UvicornWorker`: Uses Uvicorn workers for ASGI support
# - `--bind 0.0.0.0:8000`: Binds the server to all network interfaces on port 8000
CMD ["gunicorn", "app:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]




# # Use a lightweight Python base image
# FROM python:3.10-slim

# # Set the working directory inside the container
# WORKDIR /app

# # Install essential system libraries
# RUN apt-get update && apt-get install -y \
#     libgl1 libglib2.0-0 && \
#     apt-get clean

# # Copy the requirement.txt file to the container
# COPY requirements.txt /app/requirements.txt

# COPY yolo11n.pt /app/yolo11n.pt

# # Install required Python dependencies
# RUN pip install --no-cache-dir -r requirements.txt

# # Copy the rest of the project files to the container
# COPY . /app

# # Expose the port for the application
# EXPOSE 8000

# # Run the FastAPI app using Gunicorn and Uvicorn worker
# CMD ["gunicorn", "app:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]















