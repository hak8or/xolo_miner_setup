#!/usr/bin/env bash

# This sets up a miner on your address using the xolo miner.
echo "+-------------------------------------------------------------------+"
echo "|              Xolo Miner Automatic setup script                    |"
echo "|                                                                   |"	
echo "|    Sit back, grab a cup of tea, and relax as I take care of       |"
echo "|    everything for you! This will install all of the required      |"
echo "|    dependencies, compiler the miner, configure the miner,         |"
echo "|    have the miner autostart if the server has to restart,         |"
echo "|    have the miner restart if it freezes, and starts the miner     |"
echo "|    for you!                                                       |"
echo "|                                                                   |"

# Quick ugly to have this be empty so I can see if it changed later.
PrimeCoin_Address=""
Pool_IP=""
Pool_Port=""

#Get processor count
Processor_Count=`grep -c ^processor /proc/cpuinfo`

#Set some pool addresses
Beeeeer_US_Pool_IP="54.200.248.75"
Beeeeer_US_Pool_Port="1337"
XRam_Pool_IP="xpool.xram.co"
XRam_Pool_Port="1339"

while getopts ":a:tp:" opt; do
	case $opt in
	    a)
		  # It seems I can't do a comparison of string length within an if statement?
		  optarg_length=$(echo ${#OPTARG})
		  if [ $optarg_length -ne 34 ]; then
		  	echo "|      Address is not 34 characters, you probably made a typo.      |"
		  	PrimeCoin_Address=$OPTARG
		  	exit 1
		  fi
	      echo "|       PrimeCoin Address: $OPTARG       |"
	      PrimeCoin_Address=$OPTARG
	      ;;
	    t)
		  echo "|    Testing enabled! Mining to the primecoin developer address.    |"
		  echo "|    Can't find the development address, so it is my addr now!      |"
		  PrimeCoin_Address="AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT"
		  echo "|      PrimeCoin Address: $PrimeCoin_Address        |"
		  ;;
      p)
      Lowercase_OPTARG=`echo ${OPTARG,,}`
      if [ "$Lowercase_OPTARG" == "beeeeer" ]; then
        echo "|                    Using Beeeeer.org US pool.                     |"
        Pool_IP=$Beeeeer_US_Pool_IP
        Pool_Port=$Beeeeer_US_Pool_Port
      elif [ "$Lowercase_OPTARG" == "xram" ]; then
        echo "|                         Using XRam pool.                          |"         
        Pool_IP=$XRam_Pool_IP
        Pool_Port=$XRam_Pool_Port
      else
        echo "|         Pool unknown. Please specify Beeeeer or XRam.             |"
	      exit 1
      fi
      ;;
	    \?)
		  echo "|    Invalid option: -$OPTARG                                      |"
	      exit 1
	      ;;
	    :)
	      echo "|    You need to put in an address!                                |"
	      exit 1
	      ;;
	esac
done

# This checks if an address was given via command line argument. If not, ask user.
if [ -z "$PrimeCoin_Address" ]; then
	echo -n "|  PrimeCoin address?    :"
	read PrimeCoin_Address
	optarg_length=$(echo ${#PrimeCoin_Address})
	if [ $optarg_length -ne 34 ]; then
		echo "|           Address is not 34 characters, exiting.                  |"
		echo "+-------------------------------------------------------------------+"
		exit 1
	fi
fi
#This checks to see if a pool was given via command line argument. If not, set to a default.
if [ -z "$Pool_IP" ]; then
	#Set a default pool address
	Pool_IP=$Beeeeer_US_Pool_IP
	Pool_Port=$Beeeeer_US_Pool_Port
	echo "|                    Using Beeeeer.org US pool.                     |"
fi
read -p "|                   Press [ENTER] to continue?                      |"
echo "+-------------------------------------------------------------------+"
echo ""

echo "  [0/6] Installing required packages."
apt-get update &>/dev/null
apt-get install yasm -y git make g++ build-essential libminiupnpc-dev libboost-all-dev libdb++-dev libgmp-dev libssl-dev dos2unix htop supervisor &>/dev/null
# It seems that primeminer does not handle lboost_chrono and similar from newer libboost on lower distributions, so libboost 1.48 has to be installed for them. 
# More info can be found here: http://www.peercointalk.org/index.php?topic=501.165
# Do a check in the future here to see if this needs to be done.
apt-get install -y libboost-chrono1.48-dev libboost-filesystem1.48-dev libboost-system1.48-dev libboost-program-options1.48-dev libboost-thread1.48-dev &>/dev/null

echo "  [1/6] Downloading miner source from git"
git clone https://github.com/thbaumbach/primecoin.git &>/dev/null

echo "  [2/6] Changing swapfile size so miner can compile with less than 512MB of ram"
dd if=/dev/zero of=/swapfile bs=64M count=16 &>/dev/null
mkswap /swapfile &>/dev/null
swapon /swapfile &>/dev/null

echo "  [3/6] Compiling miner on $Processor_Count core(s), this may take a while."
cd ~/primecoin/src &>/dev/null
#Change the compilier optimization flag from 2 to 3 (Small increase in PPS/Chains per day).
sed -i 's/-O2/-O3/g' makefile.unix&>/dev/null 
make -j $Processor_Count -f makefile.unix &>/dev/null

echo "  [4/6] Setting up autostart for miner if server restarts or whatever"
mkdir -p /var/log/supervisor >/dev/null
touch /etc/supervisor/conf.d/primecoin.conf >/dev/null
cat <<- _EOF_ >/etc/supervisor/conf.d/primecoin.conf
[program:primecoin]
	command=$HOME/primecoin/src/primeminer -pooluser=$PrimeCoin_Address -poolip=$Pool_IP -poolport=$Pool_Port -genproclimit=$Processor_Count -poolpassword=PASSWORD -poolshare=6
	stdout_logfile=/var/log/supervisor/%(program_name)s.log
	stderr_logfile=/var/log/supervisor/%(program_name)s.log
	autorestart=true
_EOF_

echo "  [5/6] Restarting supervisor"
/etc/init.d/supervisor stop >/dev/null
/etc/init.d/supervisor start >/dev/null

echo "  [6/6] Creating a script to force primeminer to restart in case it freezes"
touch ~/mine_watcher.sh
cat <<- _EOF_ >~/mine_watcher.sh
while true; do
  if [[ \`tail -n 1 /var/log/supervisor/primecoin.log | cut -c1-27\` == "force reconnect if possible" ]]; then
    killall primeminer
  fi
  sleep 15
done
_EOF_
chmod 755 ~/mine_watcher.sh
~/mine_watcher.sh &

echo

echo "+-------------------------------------------------------------------------------+"
echo "|         All done!                                                             |"
echo "|                                                                               |"
echo "| Command for the state of your miner:                                          |"
echo "|    tail -f /var/log/supervisor/primecoin.log                                  |"
echo "| Manually starting or stopping: /etc/init.d/supervisor start/stop              |"
echo "|                                                                               |"
echo "| URL for your status on the Beeeeer.org pool:                                  |"
echo "|    http://www.beeeeer.org/user/$PrimeCoin_Address             |"
echo "|                                                                               |"
echo "| URL for your status on the XRam pool:                                         |"
echo "|    http://xpool.xram.co/individual?address=$PrimeCoin_Address |"
echo "|                                                                               |"
echo "| Official thread for the beeeeer pool.                                         |"
echo "|    http://www.peercointalk.org/index.php?topic=485.0                          |"
echo "|                                                                               |"
echo "| Hardware comparison for primecoin mining:                                     |"
echo "|    http://xpmwiki.com/index.php?title=Hardware_comparison                     |"
echo "|                                                                               |"
echo "| Data on PrimeCoin:                                                            |"
echo "|    http://cryptometer.org/primecoin_90_day_charts.html                        |"
echo "|                                                                               |"
echo "| Original source for most of this:                                             |"
echo "|    http://www.davidedicillo.com                                               |"
echo "|                                                                               |"
echo "|                                                            By Hak8or          |"
echo "+-------------------------------------------------------------------------------+"
