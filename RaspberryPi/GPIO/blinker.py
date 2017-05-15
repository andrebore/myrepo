# External module imports
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setup(22, GPIO.OUT)

print("Press CTRL-C to exit")

try:
	while 1:
		GPIO.output(22, GPIO.HIGH)
		time.sleep(3)
		GPIO.output(22, GPIO.LOW)
		time.sleep(3)
	
except KeyboardInterrupt: # If CTRL+C is pressed, exit cleanly:
	GPIO.cleanup() # cleanup all GPIO
