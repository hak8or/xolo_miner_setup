xolo_miner_setup
================

Sets up xolominer to mine primecoin on the beeeeer.org mining pool.

It first installs all dependencies required to compile and run the miner. Then downloads the source code of the miner from the official git page, and compiles it for you. Sets up the miner for you so that it mines on beeeer and so that if your server restarts the miner autostarts.

To get this going you do the following in the terminal:
```
wget https://raw.github.com/hak8or/xolo_miner_setup/master/xolo_miner_setup.sh

chmod 777 xolo_miner_setup.sh

sudo ./xolo_miner_setup.sh -a your-primecoin-wallet-address-goes-here
```

example: 
```
sudo ./xolo_miner_setup.sh -a AbFituYrzGLdsziL4g6Y2a2i5x19N1BZtT
```