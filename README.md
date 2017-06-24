Custom LEDE Patch For TL-WDR3500/3600/4300/4310/MW4350R (With Working Fast Path)
================================================================================

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

    git clone -b lede-17.01 https://github.com/lede-project/source.git lede

Clone this Repository and copy into the LEDE repository

    git clone -b lede-17.01 https://github.com/gwlim/mips74k-lede-patch.git temp; mv temp/* lede/; rm -rf temp

Change directory into the LEDE Repository

    cd lede

Run the script

./patch_LEDE.sh

Make Menuconfig Default Target is TL-WDR4300 (all the packages and config is inside)
If you want to enable Fast Path select all the fast path modules in 
Go to 
Kernel Modules > Network Support > 
Select all the 3 modules
kmod-fast-classifier, kmod-shortcut-fe, kmod-shortcut-fe-cm

    make menuconfig

Save and make

    make V=s
