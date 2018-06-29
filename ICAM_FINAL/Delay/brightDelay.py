from CirFrameBuf import CirFrameBuf
import argparse
import numpy as np
import cv2
import serial

# usage: brightDelay.py -r [radius]
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-r", "--radius", type = int,
	help = "radius of Gaussian blur; must be odd")
ap.add_argument("-s", "--serial", type = int,
	help = "serial out? 1 for yes.")
args = vars(ap.parse_args())

if( args["serial"] == 1 ):
        # init serial
        ser = serial.Serial('/dev/cu.usbmodem1451', 9600)

width = 640
height = 480
#width = 1280
#height = 720
size = 40       # number of frames
pixdepth = 3

cfbuf = CirFrameBuf(size+1, height, width, pixdepth)
cap = cv2.VideoCapture(0)

iWIDTH = 3
iHEIGHT = 4
iFPS = 5
cap.set(iWIDTH, width)
cap.set(iHEIGHT, height)
cap.set(iFPS, 30)
print(width)
print(height)
print(cap.get(iFPS))

count = 0

dframe = None

nfback = 1
inc = 1
counter = 0
brightLabel = "one"
# a lil' string formatter
def msgFormat( msg, f ):
    tempStr = '<' + msg + ',' + str(f) + '>'
    return tempStr.encode(encoding='UTF-8',errors='strict')

while ( cap. isOpened() ):

        ret, frame = cap.read()
        # find brightest point
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (args["radius"], args["radius"]), 0.5)
        (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(gray)
	
        # Write out to the circular buffer
        #cfbuf.write(gray)
        cfbuf.write(frame)

        # modulate the delay
        if nfback >= size: 
            inc = -1
        elif nfback <= 1:
            inc = 2
        nfback += inc

        dframe = cfbuf.readback(nfback)

        # Blend the two images: real time and delay time. Must be the same pix depth
        #blend = cv2.addWeighted(gray, 0.5, dframe, 0.5, 0)
        blend = cv2.addWeighted(frame, 0.5, dframe, 0.5, 0)

        # send to arduino
        if( args["serial"] == 1 ):
                counter += 1
                if counter > 5:
                        ser.write( msgFormat(brightLabel, maxLoc[0] / width) )
                        counter = 0
                        #print(maxLoc[0] / width)
        
        # draw circle
        cv2.circle(blend, maxLoc, args["radius"], (5, 255, 255), 1)
        
        #retVal, thresh = cv2.threshold(blend, 80, 205, cv2.THRESH_BINARY) 
        
#        cv2.namedWindow("bDelay", cv2.WND_PROP_FULLSCREEN)
#        cv2.setWindowProperty("bDelay", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN) 
        cv2.imshow("bDelay", blend)
        #cv2.imshow("bDelay", thresh)

        key = cv2.waitKey(25) & 0xFF
        if key == ord("q"):
            break

cap.release()
cv2.destroyAllWindows()
