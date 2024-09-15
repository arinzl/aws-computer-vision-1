import boto3
import json
import cv2
import numpy as np
import os
import logging
from ultralytics import YOLO
from datetime import datetime

def process_video(queue_url):
    try:
        response = sqs.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=10
        )
        # Check if 'Messages' key exists in the response
        if 'Messages' in response:
            for message in response['Messages']:
                # Parse SQS message body
                body = json.loads(message['Body'])

                sns_message_str = json.loads(body["Message"])
                print(type(sns_message_str))

                # S3 event notifications are in the 'Records' list
                if 'Records' in sns_message_str:
                    print(f"4-Records found of type {type(sns_message_str)}")
                    for record in sns_message_str['Records']:
                        print(record)
                        if record['eventSource'] == 'aws:s3':
                            bucket_name = record['s3']['bucket']['name']
                            object_key = record['s3']['object']['key']
                            logging.info(f"Bucket: {bucket_name}, Object Key: {object_key}")
                            print(f"6-Bucket: {bucket_name}, Object Key: {object_key}")

                            # Split object key into folder and file
                            folder, file_name = os.path.split(object_key)

                            # Download the object
                            download_path = f'/app/{file_name}'
                            s3.download_file(bucket_name, object_key, download_path)
                            logging.info(f"Downloaded {object_key} to {download_path}")
                            print(f"7-Downloaded {object_key} to {download_path}")

                            # process video file
                            cap = cv2.VideoCapture(download_path)
                            frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
                            frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
                            size = (frame_width,frame_height)
                            fps = cap.get(cv2.CAP_PROP_FPS)
                            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                            out = cv2.VideoWriter('output.mp4', fourcc, fps, size )
                            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                            s3_uploadkey = f'video-processed/{timestamp}_{file_name}'                                

                            while cap.isOpened():
                                ret, frame = cap.read()
                                if not ret:
                                    break

                                results = model.track(frame, persist=True)
                                mod_frame = results[0].plot()
                                out.write(mod_frame)

                            cap.release()
                            out.release()
                            cv2.destroyAllWindows()
                            print("9-Video processing completed, next upload")

                            # Upload the process video to the new folder 'video-processed'

                            s3.upload_file('output.mp4', bucket_name, s3_uploadkey) 
                            logging.info(f"Uploaded converted video to {s3_uploadkey}")
                            print(f"10-Uploaded converted video to {s3_uploadkey}")

                            # Clean up the downloaded file
                            os.remove(download_path)
                            os.remove('output.mp4')
                            logging.info(f"Removed downloaded file {download_path}")

                            

                # Delete the message from the queue to prevent reprocessing
                sqs.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
                
                logging.info("Deleted message from queue.")
                print("11-Deleted message from queue.")

        else:
            logging.info("12-No messages received.")
            
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        print(f"An error occurred: {e}")


# Enable logging
logging.basicConfig(
    filename='/app/vidoprocessing.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

queue_url = os.getenv('SQS_QUEUE_URL')


# Load YOLOv8 model
model = YOLO('yolov8n.pt')  # Ensure you have the yolov8s.pt file

sqs = boto3.client('sqs')
s3 = boto3.client('s3')
logging.info("Starting SQS listener...")


if not queue_url:
    print("1-SQS_QUEUE_URL environment variable not set")
    logging.error("SQS_QUEUE_URL environment variable not set")

    exit(1)
else:
    print(f"1-Polling SQS queue: {queue_url}")
    logging.info("Processing queue events")
    print("2-Processing queue events")

    process_video(queue_url)


