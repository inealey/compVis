import cv2
import numpy

cap = cv2.VideoCapture("http://@192.168.0.100:5000/video_feed")
cap2 = cv2.VideoCapture(0)
#while cap.isOpened():
while( True ):
    _,frame = cap.read()
    _2,frame2 = cap2.read()
   # cv2.imshow("stream",frame)
    cv2.imshow("2nd Stream", frame2) 
    c = cv2.waitKey(1)
    if c == 27:
      break
