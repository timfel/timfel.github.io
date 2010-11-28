date: 2010-11-28
title: Linux PM on Macbook Pro

I have recently switched back to Linux as my main OS on my Macbook Pro (7,1
series). After half a year of using Mac OS X, I found I couldn't force it to
yield to my workflow and preferences in too many ways. I still think it is a
great system, and a great user experience, it's just that I have grown
accustomed to so many little kinks (like sloppy-focus) that I find I cannot use
Mac OS X as effectively as my customized Linux desktop.

After customizing my environment (which can be done easily using GUI tools on
modern desktop linux distributions), I realized I had to tweak a little to get
battery life up to par with what it was under Mac OS X.

Much of these steps are drawn from the [Ubuntu
Wiki](https://help.ubuntu.com/community/MacBookPro7-1/Maverick).

First, there's a PPA with Macbook specific daemons, drivers, tools, so I added
that and installed a few things from there:  

`  $ sudo add-apt-repository ppa:mactel-support && sudo apt-get update`  

`  $ sudo apt-get install pommed macfanctld nvidia-bl-dkms xcalib bcm5974-dkms`
`    xserver-xorg-input-synaptics btusb-dkms`  

This will install:

* keyboard backlight support
* fan control
* screen backlight support
* screen color calibration
* better touchpad support
* bluetooth drivers

After that, a few module tweaks are in order:

* Activate coretemp on boot  
`  $ sudo su -c 'echo coretemp >> /etc/modules'`

* Activate proper sound driver variant, with powersaving  
`  $ sudo -s`  
`  # echo "options snd-hda-intel model=mbp55 power_save=1" >> /etc/modprobe.d/alsa-base.conf`

Then, to get reboot working and have usb devices automatically suspend, use this
to add a few kernel paramters to `/etc/default/grub`. Where it reads
`GRUB_CMDLINE_LINUX_DEFAULT`, add:  

`usbcore.autosuspend=1 reboot=pci hpet=force`  
To write those changes to the active grub configuration, run:  

`  $ sudo update-grub`

I found that this did not cause all usb devices be set to auto-suspend, even
though they could. So I added a one-liner to /etc/rc.local which I took from
`powertop`:  

`for i in /sys/bus/usb/devices/*/power/control; do echo "auto" > "$i"; done`  
Don't forget to make /etc/rc.local executable with `chmod +x /etc/rc.local`.  

Finally, after installing the proprietary NVidia drivers, you can add the
following options to the `Device` section in `/etc/X11/xorg.conf`:

`Option "Coolbits" "1"`  

`Option "OnDemandVBlankInterrupts" "True"`  

`Option "RegistryDwords" "PowerMizerEnable=0x1; PerfLevelSrc=0x2233; PowerMizerDefault=0x3"`

This will activate the frequency override capabilities, enable VBlank interrupts
to only fire on demand and set the performance on battery to the fixed-minimum,
so that Compiz doesn't trigger the NVidia performance scaling.

After a reboot with these tweaks, I'm getting between 7.5 and 9.5 Watts usage,
which is a little higher than on Mac OS X, but still good enough for around 6h
of battery under conservative use (on Wifi, twittering, emailing and surfing).


