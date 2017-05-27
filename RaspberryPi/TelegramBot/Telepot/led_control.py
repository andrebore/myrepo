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
    return

# Use Raspberry PIN in BCM format
GPIO.setmode(GPIO.BCM)
# GPIO output channel
GPIO.setup(27, GPIO.OUT)

def handle(msg):
    chat_id = msg['chat']['id']
    command = msg['text']
    print 'Got command: %s' % command

    if command == 'On':
        bot.sendMessage(chat_id, 'Led on')
        bot.sendMessage(chat_id, 'Waiting for command...')
        print 'Led on'
        bot.sendMessage(chat_id, on(27))
    elif command =='Off':
        bot.sendMessage(chat_id, 'Led off')
        bot.sendMessage(chat_id, 'Waiting for command...')
        print 'Led off'
        bot.sendMessage(chat_id, off(27))
    else:
        bot.sendMessage(chat_id, 'Command not found')

bot = telepot.Bot('bot token')
bot.message_loop(handle)
GPIO.output(27,GPIO.LOW)
print 'Waiting for command...'

try:
    while 1:
        time.sleep(10)

except KeyboardInterrupt: # If CTRL+C is pressed, exit cleanly:
        GPIO.cleanup()
