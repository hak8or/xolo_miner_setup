#!/usr/bin/env bash

# This sets up a miner on your address using the xolo miner.
echo "+-------------------------------------------------------------------+"
echo "|              Xolo Miner Automatic setup script                    |"
echo "|                                                                   |"	
echo "|    Sit back, grab a cup of tea, and relax as I take care of       |"
echo "|    everything for you! This will install all of the required      |"
echo "|    dependencies, compiler the miner, configure the miner,         |"
echo "|    have the miner autostart if the server has to restart, and     |"
echo "|    and starts the miner for you!                                  |"
echo "|                                                                   |"

# Quick ugly to have this be empty so I can see if it changed later.
PrimeCoin_Address=""

while getopts ":a:t" opt; do
	case $opt in
	    a)
		  # It seems I can't do a comparison of string length within an if statement?
		  optarg_length=$(echo ${#OPTARG})
		  if [ $optarg_length -ne 34 ]; then
		  	echo "|      Address is not 34 characters, you probably made a typo.      |"
		  	PrimeCoin_Address= $OPTARG
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
read -p "|           Press [ENTER] to continue?                              |"
echo "+-------------------------------------------------------------------+"
echo ""

echo "  [0/5] Installing required packages."
apt-get update &>/dev/null
apt-get install yasm -y git make g++ build-essential libminiupnpc-dev libboost-all-dev libdb++-dev libgmp-dev libssl-dev dos2unix htop supervisor &>/dev/null

echo "  [1/5] Downloading miner source from git"
git clone https://github.com/thbaumbach/primecoin.git &>/dev/null

# Make this run only if less than 512MB of ram is found
echo "  [2/5] Changing swapfile size so miner can compile with less than 512MB of ram"
dd if=/dev/zero of=/swapfile bs=64M count=16 &>/dev/null
mkswap /swapfile &>/dev/null
swapon /swapfile &>/dev/null

echo "  [3/5] Compilimg miner, this may take a while."
cd ~/primecoin/src &>/dev/null
make -f makefile.unix &>/dev/null

echo "  [4/5] Setting up autostart for miner if server restarts or whatever"
mkdir -p /var/log/supervisor >/dev/null
touch /etc/supervisor/conf.d/primecoin.conf >/dev/null
cat <<- _EOF_ >/etc/supervisor/conf.d/primecoin.conf
		[program:primecoin]

		command=$HOME/primecoin/src/primeminer -pooluser=$PrimeCoin_Address -poolip=54.200.248.75 -poolport=1337 -genproclimit=1 -poolpassword=PASSWORD

		stdout_logfile=/var/log/supervisor/%(program_name)s.log

		stderr_logfile=/var/log/supervisor/%(program_name)s.log

		autorestart=true
	_EOF_

echo "  [5/5] Restarting supervisor"
/etc/init.d/supervisor stop >/dev/null
/etc/init.d/supervisor start >/dev/null

echo

echo "+-------------------------------------------------------------------+"
echo "|         All done!                                                 |"
echo "|                                                                   |"
echo "| Command for the state of your miner:                              |"
echo "|    tail -f /var/log/supervisor/primecoin.log                      |"
echo "| Manually starting or stopping: /etc/init.d/supervisor start/stop  |"
echo "|                                                                   |"
echo "| URL for your status on the mining pool:                           |"
echo "|    http://www.beeeeer.org/user/$PrimeCoin_Address |"
echo "|                                                                   |"
echo "| Official thread for the beeeeer pool.                             |"
echo "|    http://www.peercointalk.org/index.php?topic=485.0              |"
echo "|                                                                   |"
echo "| Hardware comparison for primecoin mining:                         |"
echo "|    http://xpmwiki.com/index.php?title=Hardware_comparison         |"
echo "|                                                                   |"
echo "| Data on PrimeCoin:                                                |"
echo "|    http://cryptometer.org/primecoin_90_day_charts.html            |"
echo "|                                                                   |"
echo "| Original source for most of this:                                 |"
echo "|    http://www.davidedicillo.com                                   |"
echo "|                                                                   |"
echo "|                                                  By Hak8or        |"
echo "+-------------------------------------------------------------------+"