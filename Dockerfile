FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Document that the container listens on port 8080
EXPOSE 8080

# Command to start the app when the container launches
CMD ["python", "app.py"]
