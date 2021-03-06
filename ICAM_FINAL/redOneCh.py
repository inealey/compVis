import numpy as np
import cv2
import time
import random

cap = cv2.VideoCapture(0)
cap.set(3, 854)
cap.set(4, 480)
#cap.set(3, 1280)
#cap.set(4, 720)


# params for ShiTomasi corner detection
feature_params = dict( maxCorners = 100,
                       qualityLevel = 0.3,
                       minDistance = 7,
                       blockSize = 7 )

# params for lucas kanade optical flow
lk_params = dict( winSize  = (15,15),
                  maxLevel = 2,
                  criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

# red values
color = (0, 0, 255)

colorList = [ color, (1, 0, 255), (0, 1, 255) ]

for j in range(1, 30):
    for k in range(1, 30):
        colorList.append( (j, k, 255) )

lower = np.array([17, 15, 100])
upper = np.array([50, 56, 255])

# Take first frame and find corners in it
ret, old_frame = cap.read()
old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params)

# Create a mask image for drawing purposes
mask = np.zeros_like(old_frame)

#timer
timer = time.time()


while(1):
    #new corners every xxx seconds
    if time.time() - timer > 30:
        mask = np.zeros_like(old_frame)
        timer = time.time()

    ret,frame = cap.read()
    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # calculate optical flow
    p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **lk_params)

    if p1 is not None:
        # Select good points
        good_new = p1[st==1]
        good_old = p0[st==1]
    else:
        #find some new features
        ret, old_frame = cap.read()
        old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
        p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params)
        p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **lk_params)
        good_new = p1[st==1]
        good_old = p0[st==1]

    # draw the tracks
    for i,(new,old) in enumerate(zip(good_new,good_old)):
        a,b = new.ravel()
        c,d = old.ravel()
        mask = cv2.line(mask, (a,b),(c,d), random.choice(colorList), 30)
 #       mask = cv2.line(mask, (a,b),(c,d), color, 30)

    # add optical mask
    img = cv2.add(frame,mask)

    # red mask
    redMask = cv2.inRange(img, lower, upper)

    img = cv2.bitwise_and(img, img, mask = redMask)
 #   img = cv2.bitwise_and(img, img, mask = 255 - redMask)
   
    cv2.namedWindow("flow", cv2.WND_PROP_FULLSCREEN)
    cv2.setWindowProperty("flow", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
    cv2.imshow("flow",img)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break

    # Now update the previous frame and previous points
    old_gray = frame_gray.copy()
    p0 = good_new.reshape(-1,1,2)

cap.release()
cv2.destroyAllWindows()
