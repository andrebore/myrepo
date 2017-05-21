import sys
import time
import random
import datetime
import telepot
import RPi.GPIO as GPIO

#LED
def on(pin):
    GPIO.output(pin,GPIO.HIGH)
    return
def off(pin):
    GPIO.output(pin,GPIO.LOW)
    print 'Led off'
    return
# to use Raspberry Pi board pin numbers
GPIO.setmode(GPIO.BCM)
# set up GPIO output channel
GPIO.setup(27, GPIO.OUT)

def handle(msg):
    chat_id = msg['chat']['id']
    command = msg['text']
    print 'Got command: %s' % command

    if command == 'On':
        bot.sendMessage(chat_id, 'Led on')
        print 'Led on'
        bot.sendMessage(chat_id, on(27))
    elif command =='Off':
        bot.sendMessage(chat_id, 'Led off')
        print 'Led off'
        bot.sendMessage(chat_id, off(27))
    else:
        bot.sendMessage(chat_id, 'Command not found')

bot = telepot.Bot('350131512:AAFbqKgcn9i2cR597QfcxE_vrrA7GQL8F54')
bot.message_loop(handle)
GPIO.output(27,GPIO.LOW)
print 'I am listening...'

try:
    while 1:
        time.sleep(10)

except KeyboardInterrupt: # If CTRL+C is pressed, exit cleanly:
        GPIO.cleanup()
