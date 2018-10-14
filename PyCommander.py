#William Chapin, 12/27/17, using MIT license from Jon Cooper

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software
#and associated documentation files (the "Software"), to deal in the Software without restriction,
#including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
#and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
#PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
#FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import pygame
import socket
import xbox360_controller
import binascii
import sys,os
from time import sleep
import time
from struct import *

pygame.init()

#This code detects if a button state is changed and prints it to the terminal
#screen = pygame.display.set_mode(size)

#Variable Declarations ===============================================================
controller = xbox360_controller.Controller(0)

baud = 38400
ii=0
yn = ''
done = False
elapsed = 0
outpac = 0
inarray = 0
duo = 0
debug = 0
verbose = 0
frame = .033
UDP_IP = "10.0.1.4"
UDP_PORT = 5015

#Initialize =========================================================================
yn = input("Autoselect Xbee? Y/N")

sock = socket.socket(socket.AF_INET, # Internet
                             socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))



print("Press Dpad Up to return help")
print("Press Dpad left/right to turn off/on debug output")

t0 = time.clock()

#Main Loop ===========================================================================
while not done:
    new = time.clock()
    if debug == 1:
        print(inarray, outpac, elapsed)
    # event handling
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            done=True

    pressed = controller.get_buttons() #You need this to register any buttons
    a = pressed[xbox360_controller.A] #Change Gaits
    b = pressed[xbox360_controller.B] #Toggle Walk Method
    x = pressed[xbox360_controller.X] #Does Nothing
    y = pressed[xbox360_controller.Y] #Balance Mode
    back = pressed[xbox360_controller.BACK]
    start = pressed[xbox360_controller.START] #Toggle Preset Heights
    lt = pressed[xbox360_controller.LEFT_BUMP] #Change Modes
    rt = pressed[xbox360_controller.RIGHT_BUMP] #Change Walk Parameters
    lb = pressed[xbox360_controller.LEFT_STICK_BTN]
    rb = pressed[xbox360_controller.RIGHT_STICK_BTN]
    lt_x, lt_y = controller.get_left_stick()
    rt_x, rt_y = controller.get_right_stick()
    du, dr, dd, dl = controller.get_pad()


    if du == 1 and duo == 0:
        print('Button assignments')
        print('A ----- Change Gait')
        print('B ----- Toggle Walk Method')
        print('X ----- No Current Use')
        print('Y ----- Toggle Balance Mode')
        print('Back -- Height/Speed modifier')
        print('Start - Toggle Preset Heights')
        print('L2 ---- Change Modes')
        print('R2 ---- Change Walk Parameters')
        print('DL ---- Turn Off Debug output')
        print('DR ---- Turn On Debug Output')
        print('DU ---- Display Help')
        print('DD ---- Quit Program')
    if dr == 1:
        debug = 1
    elif dl == 1:
        debug = 0
    if dd == 1:
        done = 1
    duo = du
    leftx = round(lt_x * 125)+128
    lefty = round(lt_y * -125)+128
    ''' right stick '''
    rightx =round(rt_x * 125)+128
    righty =round(rt_y * 125)+128

    buttons = a*1+b*2+x*4+y*8+start*16+back*32+rt*64+lt*128
    initialize = 255
    notneeded = 0
    if leftx > 125 and leftx < 131:
        leftx = 128
    if lefty > 124 and lefty < 131:
        lefty = 128
    if rightx > 125 and rightx < 131:
        rightx = 128
    if righty > 125 and righty < 131:
        righty = 128


    checksum = (255-(righty+rightx+leftx+lefty+buttons)%256)
    inarray = (initialize,righty,rightx,lefty,leftx,buttons,notneeded,checksum)

    outpac = pack('BBBBBBBB',initialize,righty,rightx,lefty,leftx,buttons,notneeded,checksum)
    sock.sendto(outpac, ("10.0.1.4", 25001))
    elapsed = 0
    while elapsed < frame:
        new2 = time.clock()
        elapsed = new2-new

# close window on quit
pygame.quit ()
