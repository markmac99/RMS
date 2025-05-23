# RPi Meteor Station

Open source powered meteor station. We are currently using the Raspberry Pi 4 as the main development platform, and we use digital IP cameras. **The code also works on Linux PCs, and everything but the detection works under Windows.** We are slowly phasing out the support for analog cameras, but they should work well regardless.
The software is still in the development phase, but here are the current features:

1. Automated video capture - start at dusk, stop at dawn. **IP cameras with resolution of up to 720p supported on the Pi 3 and 4, and up to 1080p on Linux PCs.**
1. Compressing 256-frame blocks into the Four-frame Temporal Pixel (FTP) format (see [Jenniskens et al., 2011 CAMS](http://cams.seti.org/CAMSoverviewpaper.pdf) paper for more info).
1. Detecting bright fireballs in real time
1. Detecting meteors on FTP compressed files
1. Extracting stars from FTP compressed files
1. Astrometry and photometry calibration
1. Automatic recalibration of astrometry every night
1. Automatic upload of calibrated detections to central server
1. Manual reduction of fireballs/meteors

Please see our website for more info: https://globalmeteornetwork.org/
We are also selling Plug And Play meteor systems which run this code!

Finally, if you decide to build one system from scratch, we strongly encourage you to look at our [Wiki page](https://globalmeteornetwork.org/wiki/index.php?title=Main_Page).


# Table of Contents

1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [Software](#software)
1. [Setting Up](#setting-up)
1. [Running the Code](#running-the-code)
1. [Citations](#citations)


## Requirements
This guide will assume basic knowledge of electronics, the Unix environment, and some minor experience with the Raspberry Pi platform itself.

### Hardware

#### RPi control box

1. **Raspberry Pi 4 single-board computer.**

1. **Class 10 microSD card, 64GB or higher.** 
The recorded data takes up a lot of space, as much as several gigabytes per night. To be able to store at least one week of data on the system, a 64GB SD card is the minimum.

1. **5V power supply for the RPi with the maximum current of at least 2.5A.** 
The RPi will have to power the video digitizer, and sometimes run at almost 100% CPU utilization, which draws a lot of power. We recommend using the official RPi 5V/2.5A power supply. Remember, most of the issues people have with RPis are caused by a power supply that is not powerful enough.

1. **RPi case with a fan + heatsinks.** 
You **will** need to use a RPi case **with a fan**, as the software will likely utilize the CPU close to 100% at some time during the night. Be careful to buy a case with a fan which will not interfere with the Real Time Clock module. We recommend buying a case which allows the fan to be mounted on the outside of the case.

1. **Real Time Clock module**
The RPi itself does not have a battery, so every time you turn it off, it loses the current time. The time then needs to be fetched from the Internet. If for some reason you do not have access to the Internet, or you network connection is down, it is a good idea to have the correct time as it is **essential for meteor trajectory estimation**.
We recommend buying the DS3231 RTC module. See under [Guides/rpi3_rtc_setup.md](Guides/rpi3_rtc_setup.md) for information on installing this RTC module.

#### Camera

What cameras are supported? Basically any cameras that can be read as video devices in Linux and all network IP cameras. Read the sections below for ways how to configure RMS to use different devices.

1. **IP camera**
Preferably an IMX291 IP camera. Contact us for more details!

---------

1. **Security camera housing.**
The best place to mount a meteor camera is on the outside wall of your house. As this means that the camera will be exposed to the elements, you need a good camera housing. We recommend that you get a housing with a heater and a fan, which will keep it warm in the winter and cool in the summer. Also, be sure to buy a housing large enough to accommodate your camera. There is one **important thing to note** - security camera housings **are not** designed to look up at the sky. Most of them are designed to be under a roof and looking down. As your camera will be looking up, and most likely be without the protection of a roof, you will have to properly insulate it. Buy some silicone sealant and (after you fully assemble your camera and properly test everything), apply the sealant along all openings and joints, and most importantly, along the edges of the glass at the front. You want to keep the camera dry and prevent humidity from getting inside. If you have some humidity inside the camera, when the temperature hits the dew point, everything inside the housing will be wet. People have also found that putting aluminium foil on the glass, from the inside of the housing, prevents the humidity from forming (just be careful not to obstruct the view of your camera). A good idea is also to put some silica gels or desiccant inside the housing.

1. **Wiring**
You will probably need some cables and connectors to connect your camera to the digitizer, and to bring power to you camera. We recommend using a shielded coaxial cable for the video signal, and a simple copper pair wire for the power (although you might want to get a shielded cable for power if there's a lot of interference in the video signal).



### Software

**NOTE:** We have an SD card image for the Pi with everything installed on it. See our Wiki page.

---------

The code was designed to run on a RPi, but it will also run an some Linux distributions. Ubuntu and Linux Mint have been successfeuly tested, others will probably work too.

Meteor detection **does not** run on Windows, but most of other submodules do (astrometric calibration, viewing the data, manual reduction, etc.). The problem in Windows is that for some reason the logging module object cannot be pickled when parallelized by the multiprocessing library. **We weren't able to solve this issue, but we invite people to try to take a stab at it.**

If you are using Anaconda Python on your Windows or Linux PC, you can simply install all required libraries by running the following commands in the Anaconda Powershell:

```
conda create -y -n rms -c conda-forge python==3.11.6
conda activate rms
conda install -y -c conda-forge numpy'<2.0' scipy gitpython cython matplotlib paramiko
conda install -y -c conda-forge numba
conda install -y pyqt==5.15.10
conda install -y -c conda-forge Pillow pyqtgraph==0.12.3
conda install -y -c conda-forge ephem
conda install -y -c conda-forge imageio pandas
conda install -y -c conda-forge pygobject
conda install -y -c conda-forge opencv
conda install -y -c astropy astropy
pip install rawpy'<0.22'
pip install git+https://github.com/matejak/imreg_dft@master#egg=imreg_dft'>2.0.0'
pip install astrometry
```

If you want full gstreamer support (for better capture and raw video recording), you need to install the additional gstreamer libraries:

```
conda install -y -c conda-forge gstreamer==1.22.3
conda install -y -c conda-forge gobject-introspection
conda install -y -c conda-forge gst-libav
conda install -y -c conda-forge gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly
```

Next, clone this repository from GitHub in a directory of your choice:

```
git clone https://github.com/CroatianMeteorNetwork/RMS.git
```

And finally, install the RMS code as a package by running the following command in the terminal (make sure you are in the RMS directory):

```
pip install .
```


## Setting up

### Setting the timezone to UTC
It is always a good idea to set the timezone to UTC when recording any data. This provides a common time reference among observations, and more than once there have been issues when people were using different time zones. So, use your favorite search engine to find how to change the timezone on your RPi to UTC.


### Enabling the watchdog service
A watchdog service is a service that occasionally checks if the RPi is responsive and if it's working fine. If the RPi hangs of freezes, it will reboot it. See under [Guides/enabling_watchdog.md](Guides/enabling_watchdog.md) for more information.


### Checking video device and initializing proper settings - ANALOG CAMERAS ONLY!
Once you connect the EasyCap digitizer and the camera, you need to check if the video signal is being properly received.

If you have a NTSC camera (North American standard), run this in the terminal:

```
mplayer tv:// -tv driver=v4l2:device=/dev/video0:input=0:norm=NTSC -vo x11
```

If you have a PAL camera (Europe), enter the following:

```
mplayer tv:// -tv driver=v4l2:device=/dev/video0:input=0:norm=PAL -vo x11
```

### Editing the configuration file
This is a very important step as all settings are read from the configuration file. The file in question is the [.config](.config) file. Once you download this repository, start editing the file with your favorite editor.

#### [System]

##### Station ID
If you want to join our network of global cameras, please send me an e-mail and I will give you a station code. The codes are made up of the 2-letter ISO code of your country (e.g. DE for Germany), followed by a 4 character alphanumeric code starting at 0001 and ending with ZZZZ, giving a total number of 1.5 million unique combinations for every country. For testing purposes you might use XX0001.

##### GPS location
Edit the latitude, longitude and elevation of the location of your camera. This is used for automatically calculating the starting and ending time of the time of capture, as well as the astrometric plates. Try to be as precise as possible, **use at least 5 decimal places for latitude and longitude, and the elevation to a precision of 1 meter**. Measure the location of the camera with the GPS on your phone. This is extremely crucial and make sure to get a good location of the camera, otherwise the trajectories will be significantly off.


#### [Capture]

##### IP cameras
If you are using an IP camera, you need to give it the rtsp link so I can access the video stream. Here is an example of a string for the IMX291 camera with the Hikvision firmware:

```
device: rtsp://192.168.42.10:554/user=admin&password=&channel=1&stream=0.sdp
```

##### Capture cards, video devices
If you are using an analog camera or some other Linux video device, make sure you can see it as ```/dev/videoX```, where ```X``` is the number of the video device. This will usually be 0. So if you want RMS to use ```/dev/video0``` as the video source, specify the device in the config file as:

```
device: 0
```


##### Resolution and FPS
To be able to capture the video properly, you need to set up the right resolution and FPS (frames per second). For IP cameras, use the maximum resolution of 1280x720, as the Pi4 can't really handle 1080p, and such a high resolution produces enormous amounts of data.


## Running the code

### Capturing video and saving data
To start the video capture, navigate to the base folder (e.g. /home/pi/RMS) with the terminal and run:

```
python -m RMS.StartCapture
```

This command will automatically start capturing upon sunset, and stop capturing upon sunrise, do the detection automatically, do the astrometric recalibration (provided an initial astrometric plate was provided), and upload the detections to server.

If you want to start capture right away, for a specified duration, run this command with the argument -d HH.hh, where HH.hh is the number of hours you want to run the capture for. E.g. if you want to capture the video for 1 hour and 30 minutes, you would run:

```
python -m RMS.StartCapture -d 1.5
```

The data will be saved in /home/pi/RMS_data/CapturedFiles/YYYYMMDD_hhmmss_uuuuuu, where YYYYMMDD_hhmmss_uuuuuu is the timestamp of the time when the recording was started, which is used as a name for the directory where the data for the night will be stored. Once the automated detection and calibration is done, data will be extracted and archived to /home/pi/RMS_data/ArchivedFiles/YYYYMMDD_hhmmss_uuuuuu.

#### Live Stream
To test your camera with RMS configuration without a real capture - after certify it your camera is working properly - you can run the Live Stream module.
Navigate with terminal to base project directory and run:

```
python -m Utils.ShowLiveStream
```

Don't trust the FPS it's reporting too much, the Pi is too slow to display a video on screen in real time, but it works well when the capture is done in the background.


#### Viewing FF bin files (compressed video data)
You can view the recorded data using the [CMN_binViewer](https://github.com/CroatianMeteorNetwork/cmn_binviewer) software. You can either run it off the Pi, or you can install it on Windows (builds are provided).


#### Viewing FR bin files (fireball detections)
You may notice that there are some FR files in the night directory (as opposed to FF, which are storing the compressed video data). The FR files are created by the fireball detector, which detects brighter meteors as well. To see the detection, run:

```
python -m Utils.FRbinViewer ~/RMS_data/YYYMMDD_hhmmss_uuuuuu
```
where YYYMMDD_hhmmss_uuuuuu is the name of the night directory.

### Star extraction and meteor detection
This will be done automatically when StartCapture is run, but if for some reason you want to redo the detection, you can do it manually.

To extract the stars on recorded images, and detect meteors on them, run:

```
python -m RMS.DetectStarsAndMeteors ~/RMS_data/YYYMMDD_hhmmss_uuuuuu
```

where YYYMMDD_hhmmss_uuuuuu is the name of the night directory. This will take a while to run, and when it is done, it will generate a file called CALSTARS (which will hold information about detected stars on images), and FTPdetectinfo file which will hold information about detected meteors.


## Citations

For academic use, please cite the paper:
>[Vida, D., Šegon, D., Gural, P.S., Brown, P.G., McIntyre, M.J., Dijkema, T.J., Pavletić, L., Kukić, P., Mazur, M.J., Eschman, P. and Roggemans, P., 2021. The Global Meteor Network–Methodology and first results. Monthly Notices of the Royal Astronomical Society, 506(4), pp.5046-5074.](https://academic.oup.com/mnras/article/506/4/5046/6347233)
