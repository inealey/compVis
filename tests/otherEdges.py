import cv2
import numpy as np
from matplotlib import pyplot as plt

# init capture
camera = cv2.VideoCapture(0)
camera.set(3, 640)
camera.set(4, 480)

while(True):
	# grab frame
	_,frame = camera.read()
	# converting to gray scale
	gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	# remove noise
	img = cv2.GaussianBlur(gray,(3,3),0)

	# convolute with proper kernels
	#laplacian = cv2.Laplacian(frame,cv2.CV_64F)
	laplacian = cv2.Laplacian(gray,cv2.CV_64F)
	sobelx = cv2.Sobel(frame,cv2.CV_64F,1,0,ksize=15)  # x
	sobely = cv2.Sobel(frame,cv2.CV_64F,0,1,ksize=5)  # y
	scharr = cv2.Scharr(frame, cv2.CV_64F,1,0)
	#blend = cv2.add(laplacian, sobelx)
	#blend = cv2.add(sobely, sobelx)
	cv2.cvtColor(gray, gray, cv2.CV_64F)	
	blend = cv2.addWeighted(gray,0.5,laplacian,0.5,0)

#	cv2.imshow('scharr', scharr)	
	cv2.imshow('blendy', blend)
#	cv2.imshow('laplacian', laplacian)
#	cv2.imshow('sobel-x', sobelx)
#	cv2.imshow('sobel-y', sobely)
#	plt.subplot(2,2,1),plt.imshow(img,cmap = 'gray')
#	plt.title('Original'), plt.xticks([]), plt.yticks([])
#	plt.subplot(2,2,2),plt.imshow(laplacian,cmap = 'gray')
#	plt.title('Laplacian'), plt.xticks([]), plt.yticks([])
#	plt.subplot(2,2,3),plt.imshow(sobelx,cmap = 'gray')
#	plt.title('Sobel X'), plt.xticks([]), plt.yticks([])
#	plt.subplot(2,2,4),plt.imshow(sobely,cmap = 'gray')
#	plt.title('Sobel Y'), plt.xticks([]), plt.yticks([])

#	plt.show()

	if cv2.waitKey(1) & 0xFF == ord('q'):
		break

camera.release()
cv2.destroyAllWindows()
