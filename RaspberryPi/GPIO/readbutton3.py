import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(15, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
GPIO.setup(23, GPIO.IN, pull_up_down = GPIO.PUD_UP)

def printFunction(channel):
	print("Button 1 pressed!")
	print("Note how the bouncetime affects the button press")

GPIO.add_event_detect(15, GPIO.RISING, callback=printFunction, bouncetime=300)
	
while True:
	GPIO.wait_for_edge(23, GPIO.FALLING)
	print("Button 2 Pressed")
	GPIO.wait_for_edge(23, GPIO.RISING)
	print("Button 2 Released")

GPIO.cleanup()
