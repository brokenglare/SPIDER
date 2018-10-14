from imutils.object_detection import non_max_suppression
from imutils.video import VideoStream
import numpy as np
import imutils
import thread
import threading
import datetime
import cv2
import string
import os
import socket
import serial
import array
import binascii
from struct import *
import serial.tools.list_ports

# Wait for some signal from the server
def waitForServer():
	udpPort = 5005;
	
	serverSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	serverSock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	serverSock.bind(('', udpPort))
	(data, address) = serverSock.recvfrom(1024)
	
	# Check data received back
	d = array.array('c', data)
	if ord(d[0]) != 10:  # Waiting and ACK bits are set
		thread.start_new_thread(waitForServer, ())
		return
	
	# Notify other threads that communication has begun
	commEvent.clear()
	# Start communications
	thread.start_new_thread(commServer, ())
	return

# Communicate with the server
def commServer():
	while 1:
		# Connect to server
		udpPort = 5006;
		s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		s.connect(("10.0.1.4", udpPort))
		
		# Tell the server that we're waiting for instructions
		header = 10  # Waiting and ACK bits are set
		outPack = pack('B', header)
		sent = s.send(outPack)
		
		# Wait for response
		udpPort = 5005;
		serverSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		serverSock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
		serverSock.bind(('', udpPort))
		(data, address) = serverSock.recvfrom(1024)
		
		# Check data received back
		d = array.array('c', data)
		if ord(d[0]) == 64:  # Ending bit is set
			# Connect to server
			udpPort = 5006;
			s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
			s.connect(("10.0.1.4", udpPort))
			
			# Tell the server that we acknowledge the message
			header = 2  # ACK bit is set
			outPack = pack('B', header)
			sent = s.send(outPack)
			break
		else:
			# Process machine commands ***ROBOT STUFF***
			ser.write(d[1:])
			continue
	
	# Notify other threads that communication is over
	commEvent.set()
	waitForServer()

# The automatic mode for the robot
def fullAuto():
	# Showcase auto mode is just spinning in place
	outpac = pack('BBBBBBBB', 255, 128, 160, 128, 128, 0, 0, 223)
	
	while 1:
		# Make sure not communicating with the server
		commEvent.wait()
		ser.write(outpac)

# Remove annoying characters from strings
def makeSafeFileName(inputFileName):
	try:
		safeChars = string.letters + string.digits
		return filter(lambda c: c in safeChars, inputFileName)
	except:
		return ""
	pass

# Process the contents of a frame for matches
def process(frame):
	print "Processing"
	# Make sure not communicating with the server
	commEvent.wait()
	
	found = False
	gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	faces = faceCascade.detectMultiScale(gray, 1.3, 5)
		
	for (x, y, w, h) in faces:
		found = True
		cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
		roiGray = gray[y:y+h, x:x+w]
		roiColor = frame[y:y+h, x:x+w]
		eyes = eyeCascade.detectMultiScale(roiGray)
		for (ex, ey, ew, eh) in eyes:
			cv2.rectangle(roiColor, (ex, ey), (ex + ew, ey + eh), (0, 255, 0), 2)
	
	if found:
		timestamp = datetime.datetime.now()
		name = "{}.png".format(timestamp)
		cv2.imwrite(name, frame)
		
		# Connect to server
		udpPort = 5006;
		s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		s.connect(("10.0.1.4", udpPort))
		
		# Tell the server that someone was found
		header = 16  # Just the found bit
		outPack = pack('B', header)
		sent = s.send(outPack)

# Event for whether or not in communication with server
commEvent = threading.Event()
# Initially set to mean not in communication
commEvent.set()

# Set up all path constants
os.chdir(os.getcwd() + "/matches")
faceCascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_frontalface_default.xml')
eyeCascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_eye.xml')
# Initialize the video stream
vs = VideoStream(src=0).start()

# Set up serial
ports = list(serial.tools.list_ports.comports())
xbee = ports[0][0]  # Change once we find out ***
baud = 38400
ser = serial.Serial(xbee, baud)

# Set up waiting thread
thread.start_new_thread(waitForServer, ())

# Set up manual thread
thread.start_new_thread(fullAuto, ())

# Check only every n frames
n = 30
i = 0
while(True):
	# Make sure not communicating with the server
	commEvent.wait()
	
	frame = vs.read()
	frame = imutils.resize(frame, width=min(400, frame.shape[1]))
	orig = frame.copy()
	
	if i == n:
		i = 0
		print "Off to process"
		thread.start_new_thread(process, (orig,))
	
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break
	i = i + 1

vs.stop()
cv2.destroyAllWindows()
