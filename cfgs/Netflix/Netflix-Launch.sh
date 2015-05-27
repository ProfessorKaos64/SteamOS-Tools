#!/bin/sh

main()
{

	WIN_RES=$(DISPLAY=:0 xdpyinfo | grep dimensions | awk '{print $2}')
	COMMA_WIN_RES=$(echo $WIN_RES | awk '{sub(/x/, ","); print}')

	/usr/bin/Xephyr :15 -ac -screen $WIN_RES -fullscreen -host-cursor -once & XEPHYR_PID=$!

	# start antimicro mouse control
        #antimicro_temp

	export DISPLAY=:15
	LD_PRELOAD= google-chrome --kiosk https://www.netflix.com/ --window-size=$COMMA_WIN_RES &&

	sleep 1
	killall chrome
	kill $XEPHYR_PID

}

# start main and log
main &> /home/steam/chrome-log.txt
