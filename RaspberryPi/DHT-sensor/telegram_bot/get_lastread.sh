#!/bin/bash
until [ "$SUCCESS" = "y" ] ;do
  echo "Insert room name"
  read room
  room=$(echo "$room" | tr '[:upper:]' '[:lower:]')
  case $room in
    'living')
      roomid=1;
      python get_lastread.py $roomid;
      SUCCESS=y
      ;;
    'bedroom')
      roomid=2;
      python get_lastread.py $roomid
      SUCCESS=y
      ;;
    *)
      echo "Wrong room name";
      echo "Valid names are [living|bedroom]"
      SUCCESS=n
      ;;
    esac
done
