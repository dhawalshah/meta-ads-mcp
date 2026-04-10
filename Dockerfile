FROM python:3.10-alpine
WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . ./

EXPOSE 8000

# FB_ACCESS_TOKEN must be provided as an environment variable at runtime
CMD ["python", "server.py"]
