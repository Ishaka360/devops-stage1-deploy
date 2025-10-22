# Use a lightweight Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy all files into the container
COPY . .

# Install dependencies
RUN pip install flask

# Expose internal port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
