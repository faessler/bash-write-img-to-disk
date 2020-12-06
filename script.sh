#!/bin/bash

# READ FILE
echo -e "\n📄 Enter absolute path to img or iso file:"
read FILE_PATH
FILE=$(basename $FILE_PATH)
FILE_NAME="${FILE%.*}"
FILE_EXT="${FILE/*./}"


# CHECK DEPENDENCIES
# TODO


# CHECK IF FILE EXISTS
if [ ! -f "$FILE_PATH" ]; then
  echo -e "\n💥 Error: Could not find \"$FILE_PATH\""
  exit 1
fi


# CHECK FILE EXTENSION
if [ "$FILE_EXT" != "img" ] && [ "$FILE_EXT" != "iso" ]; then
  echo -e "\n💥 Error: Expected file to be img or iso but recived \"$FILE_EXT\" instead"
  exit 1
fi


# TRANSFORM ISO TO IMG
if [ "$FILE_EXT" == "iso" ]; then
  echo -e "\n💿 Creating img from iso"
  TEMPDIR=$(mktemp -d)
  hdiutil convert -format UDRW -o $TEMPDIR/$FILE_NAME.img $FILE_PATH
  mv $TEMPDIR/$FILE_NAME.img.dmg $TEMPDIR/$FILE_NAME.img
  FILE_PATH=$TEMPDIR/$FILE_NAME.img
fi


# WRITE IMG TO DISK
echo -e "\n💾 Insert USB or SD card now"
read -n 1 -s -r -p "   Press any key to continue..."
echo -e "\n"

diskutil list
echo -e "\n⚠️  Enter the name of the volume you want to write the img on (e.g. disk3s1).\n   The volume will be formatted and all data be lost, so select carefully!\n\n📝 Enter the name of your volume:"
read VOLUME

echo -e "\n📀 Writing img to $VOLUME. This may take a while."
diskutil unmountDisk /dev/$VOLUME
sudo dd if=$FILE_PATH of=/dev/$VOLUME bs=1m
afplay /System/Library/Sounds/Ping.aiff


# CLEANUP
echo -e "\n🧹 Cleaning up"
rm -r $TEMPDIR&>/dev/null


# DONE
echo -e "\n🏁 Done"
exit
