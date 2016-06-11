Custom LEDE Patch For TL-WDR3500/3600/4300/4310/MW4350R
======================================================

Dependencies
------------

* LEDE BuildRoot
* LEDE BuildRoot Dependencies
* Java Runtime

How to use
----------

* Install all the development packages required for LEDE BuildRoot
* Install Java Runtime
* Clone the LEDE Repository

    git clone https://github.com/lede-project/source.git lede --depth 1

Clone this Repository and copy into the LEDE repository

    git clone https://github.com/gwlim/mips74k-lede-patch.git temp --depth 1; mv temp/* lede/; rm -rf temp

Change directory into the LEDE Repository

    cd lede

Run the script

./patch_LEDE.sh

Make Menuconfig and select the Target Profile TP-LINK TL-WDR3500/3600/4300/4310/MW4350R (all the packages and config is inside except build target

    make menuconfig

Save and make

    make V=s
