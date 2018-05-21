# import the necessary packages
import numpy as np
import argparse
import os
import cv2
import time
import serial
 
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-r", "--radius", type = int,
	help = "radius of Gaussian blur; must be odd")
args = vars(ap.parse_args())

# init serial
ser = serial.Serial('/dev/cu.usbmodem1451', 9600)

# set up capture
width = 640
height = 480

cam = cv2.VideoCapture(0)
cam.set(3, width)
cam.set(4, height)

time.sleep(1)

counter = 0
brightLabel = "one"

# a lil' string formatter
def msgFormat( msg, f ):
    tempStr = '<' + msg + ',' + str(f) + '>'
    return tempStr.encode(encoding='UTF-8',errors='strict')

while( cam.isOpened() ):

    # capture
    ret, frame = cam.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # apply a Gaussian blur to the image then find the brightest
    # region
    gray = cv2.GaussianBlur(gray, (args["radius"], args["radius"]), 0)
    (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(gray)
    cv2.circle(frame, maxLoc, args["radius"], (255, 0, 0), 2)

    counter += 1
    
    # send to arduino
    if counter > 5:
        ser.write( msgFormat(brightLabel, maxLoc[0] / width) )
        counter = 0
        #print(maxLoc[0] / width)
        
    # display the results
    cv2.imshow("Brightest", frame)

    # q to quit
    key = cv2.waitKey(25) & 0xFF
    if key == ord("q"):
        break

ser.close()
cam.release()
cv2.destroyAllWindows()
os._exit(0)
    
