import requests
import re
import cv2
import numpy as np
#website = requests.get('http://stackoverflow.com//')
website = requests.get('http://192.168.0.100:5000')
html = website.text
pat = re.compile(r'<\s*img [^>]*src="([^"]+)')
img = pat.findall(html)
img_array = np.array(bytearray(img[0], dtype=np.uint8)
frame = cv2.imdecode(img_array, -1)
cv2.imshow('URL Image', frame)
cv2.waitKey()
print( img )
