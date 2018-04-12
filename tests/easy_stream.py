import cv2
import numpy

cap = cv2.VideoCapture("http://@0.0.0.0:5000/video_feed")
cap.set(3, 640)
cap.set(4, 480)
while cap.isOpened():
  _,frame = cap.read()
  cv2.imshow("stream",frame)
  c = cv2.waitKey(10)
  if c == 27:
      break

cv2.destroyAllWindows()
cap.release()
