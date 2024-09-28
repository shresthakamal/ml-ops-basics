# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG PYTHON_VERSION=3.11.0
FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /mlops-app

# Copy the source code into the container.
COPY . .


# initialise dvc
#RUN pip install "dvc[gdrive]"
# RUN dvc init --no-scm
# # configuring remote server in dvc
# RUN dvc remote add -d storage gdrive://1Vq8Z76mZWJ8VGngHwhqS9J7GRAgtSATh
# RUN dvc remote modify storage gdrive_use_service_account true
# RUN dvc remote modify storage gdrive_service_account_json_file_path creds.json

# # Accept build argument for creds.json
# ARG GDRIVE_CREDS_JSON
# RUN echo "$GDRIVE_CREDS_JSON" > creds.json
# # (Optional) Set permissions if necessary
# RUN chmod 600 /mlops-app/creds.json
# RUN if [ ! -f /mlops-app/creds.json ]; then echo "creds.json not found!"; exit 1; fi


# initialize s3
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# aws credentials configuration
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

RUN pip install "dvc[s3]"   # since s3 is the remote storage

RUN dvc init --no-scm
RUN dvc remote add -d model-store s3://models-dvc/
RUN cat .dvc/config


# pulling the trained model
RUN dvc pull dvcfiles/model.onnx.dvc

RUN mv dvcfiles/model.onnx models/model.onnx

RUN pip install -r requirements.txt
# RUN ["python3", "-m", "src.convert_model_to_onnx"]


# Expose the port that the application listens on.
EXPOSE 8000

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Run the application.
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
