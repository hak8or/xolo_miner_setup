xolo miner setup
================

Sets up xolominer to mine primecoin on the beeeeer.org mining pool.

It first installs all dependencies required to compile and run the miner. Then downloads the source code of the miner from the official git page, and compiles it for you. Sets up the miner for you so that it mines on beeeer and so that if your server restarts the miner autostarts.

To get this going you do the following in the terminal:
```
wget https://raw.github.com/hak8or/xolo_miner_setup/master/xolo_miner_setup.sh

chmod 777 xolo_miner_setup.sh

sudo ./xolo_miner_setup.sh -a your-primecoin-wallet-address-goes-here -p pool-selection-goes-here (beeeeer or xram)
```

example: 
```
sudo ./xolo_miner_setup.sh -a AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT -p beeeeer
```

Script output:
```
root@hak8or2core:~# sudo xolo_miner_setup.sh -a AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT -p beeeeer
+-------------------------------------------------------------------+
|              Xolo Miner Automatic setup script                    |
|                                                                   |
|    Sit back, grab a cup of tea, and relax as I take care of       |
|    everything for you! This will install all of the required      |
|    dependencies, compiler the miner, configure the miner,         |
|    have the miner autostart if the server has to restart,         |
|    have the miner restart if it freezes, and starts the miner     |
|    for you!                                                       |
|                                                                   |
|       PrimeCoin Address: AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT       |
|                    Using Beeeeer.org US pool.                     |
|                   Press [ENTER] to continue?                      |
+-------------------------------------------------------------------+
  [0/6] Installing required packages.
  [1/6] Downloading miner source from git
  [2/6] Not increasing swapfile size
  [3/6] Compiling miner on 2 core(s), this may take a while.
  [4/6] Setting up autostart for miner if server is restarted
  [5/6] Restarting supervisor
  [6/6] Creating a script to force primeminer to restart in case it freezes
+-------------------------------------------------------------------------------+
|         All done!                                                             |
|                                                                               |
| Command for the state of your miner:                                          |
|    tail -f /var/log/supervisor/primecoin.log                                  |
|                                                                               |
| Manually starting or stopping:                                                |
|    /etc/init.d/supervisor start/stop                                          |
|                                                                               |
| URL for your status on the Beeeeer.org pool:                                  |
|    http://www.beeeeer.org/user/AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT             |
|                                                                               |
| URL for your status on the XRam pool:                                         |
|    http://xpool.xram.co/individual?address=AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT |
|                                                                               |
| Official thread for the beeeeer pool.                                         |
|    http://www.peercointalk.org/index.php?topic=485.0                          |
|                                                                               |
| Hardware comparison for primecoin mining:                                     |
|    http://xpmwiki.com/index.php?title=Hardware_comparison                     |
|                                                                               |
| Data on PrimeCoin:                                                            |
|    http://cryptometer.org/primecoin_90_day_charts.html                        |
|                                                                               |
| Original source for most of this:                                             |
|    http://www.davidedicillo.com                                               |
|                                                                               |
|                                                            By Hak8or          |
+-------------------------------------------------------------------------------+
```


This is the now used repo intended to replace the gist I was using earlier found [here](https://gist.github.com/hak8or/7798027)
