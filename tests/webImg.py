import cv2
import urllib
import urllib.request
import numpy as np

#req = urllib.request.urlopen('http://answers.opencv.org/upfiles/logo_2.png')
req = urllib.request.urlopen('http://192.168.0.100:5000/image.jpg')
arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
img = cv2.imdecode(arr,-1) # 'load it as it is'

cv2.imshow('lalala',img)
if cv2.waitKey() & 0xff == 27: quit()
