FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Pacific/Auckland

# Install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-distutils python3.10-dev wget ffmpeg libsm6 libxext6

# Set Python 3.10 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install pip for Python 3.10
RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm get-pip.py

# Install AWS CLI, Boto3, and OpenCV
RUN pip install boto3 opencv-python numpy ultralytics

# Set the working directory
WORKDIR /app

# Copy the Python script and yolo weights into container
COPY yolov8n.pt .
COPY processvideo.py .

# Run the Python script
CMD ["python3", "processvideo.py"]