import cv2
import numpy


#cap = cv2.VideoCapture("http://@192.168.0.100:5000/video_feed")
#cap = cv2.VideoCapture("http://@192.168.0.100:5000/video_feed.mjpg")
cap = cv2.VideoCapture("http://@127.0.0.1:5000/video_feed.mjpg")
while cap.isOpened():
    _,frame = cap.read()
    cv2.imshow("stream",frame)
    c = cv2.waitKey(1)
    if c == 27:
      break
