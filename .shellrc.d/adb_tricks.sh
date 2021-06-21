#!/bin/bash


# adb
# Initiate tcpip port and connect adb to device via tcp
deviceIp="adb shell ip -f inet addr show wlan0  | grep 'inet ' | cut -d ' ' -f 6 | cut -d / -f 1"

adbip() { eval "$deviceIp" }
adbd() { adb devices }              # list connected devices
adbk() { adb kill-server }          # kill adb server

# adbip=$(adb shell ip addr show wlan0  | grep 'inet ' | cut -d ' ' -f 6 | cut -d / -f 1)
function adbconnect {
  PORT="5555"

  ip=$(adbip)
  if [[ $1 == "-h" || $1 == "--help" ]]; then
      echo "WTF, enter a valid command..."
      echo "---------------------------------------"
      echo "USAGE:"
      echo "adbconnect <PORT> (OPTIONAL)"
  else
    if [ $1 ]; then
      PORT=$1
    fi
    adb tcpip ${PORT}
    # ip=$(eval $deviceIp)
    echo "Device ip: $ip"
    adb connect "${ip}:${PORT}"
  fi


}

# turn on android screen to take screenshot
#  adb exec-out screencap -p > file.png
function adbcapture {
    #dateStr="$(date +%x_time-%k:%M:%S)"
    dateStr="$(date +%m_%d_%Y_%T)"
    dir=~/Pictures/Screenshots/android_screenshots

    # Check if argument provided
    # if provided then create folder of that name &
    # save pic to that folder with that name
    if [ $# -eq 0 ]; then
      mkdir -p "${dir}"
      pic="screen_$dateStr.png"
    else
      dir="$dir/$1"
      mkdir -p "${dir}"
      pic="$1_$dateStr.png"
    fi

    filepath=$dir/$pic
    adb exec-out screencap -p > "${filepath}"
    echo "INFO: Saved at: ${dir}"
    echo "INFO: Filename: ${pic}"
}

# record android screen
function adbrecord {
    # dateStr="$(date +%x_%T)"
    dateStr="$(date +%F_%k:%M:%S)"
    format="mp4"
    dir=~/Pictures/Screenshots/android_screenshots

    if [[ $1 == "-h" || $1 == "--help" ]]; then
      echo """
--help 		Displays command syntax and options"""

    echo """
--size 		width x height 	Sets the video size: 1280x720.
    		The default value is the device's native display resolution (if supported), 1280x720 if not.
    		For best results, use a size supported by your device's Advanced Video Coding (AVC) encoder.
    		"""

      echo """
--bit-rate rate 	Sets the video bit rate for the video, in megabits per second. The default value is 4Mbps.
  			You can increase the bit rate to improve video quality, but doing so results in larger movie files.
			The following example sets the recording bit rate to 6Mbps:
  			adb shell screenrecord --bit-rate 6000000 /sdcard/demo.mp4"""

      echo """
--time-limit time 	Sets the maximum recording time, in seconds.
			The default and maximum value is 180 (3 minutes).
      """

      echo """
--rotate 	Rotates the output 90 degrees. This feature is experimental.
      """
      echo """
--verbose 	Displays log information on the command-line screen.
			If you do not set this option, the utility does not display any information while running.
      """
    # Check if argument provided
    # if provided then create folder of that name &
    # save pic to that folder with that name
    else
      if [ $# -eq 0 ]; then
        mkdir -p $dir
        name="screen_$dateStr.$format"
        name="demo.$format"
      else
        dir="$dir/$1"
        mkdir -p $dir
        name="$1_$dateStr.$format"
      fi

      filepath=$dir/$name
      # start record
      echo "INFO: Recording starting to $format file: $name"
      echo "INFO: Press Ctrl + C to stop recording"
      adb shell screenrecord --verbose /sdcard/"${name}"
      echo "INFO: Finishing recording..."
      adb shell pull /sdcard/"${name}" "${filepath}"
      adb shell rm /sdcard/${name}
      echo "INFO: Saved at: ${dir}"
      echo "INFO: Filename: ${name}"
    fi

}
