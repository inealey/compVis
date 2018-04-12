import urllib
import urllib.request
import cv2
import numpy as np
import time

url_response = urllib.request.urlopen('http://192.168.0.100:5000')
#url_response = urllib.request.urlopen('http://s0.geograph.org.uk/photos/40/57/405725_b17937da.jpg')

time.sleep(5)

img_array = np.array(bytearray(url_response.read()), dtype=np.uint8)

img = cv2.imdecode(img_array, -1)

cv2.imshow('URL Image', img)
cv2.waitKey()
