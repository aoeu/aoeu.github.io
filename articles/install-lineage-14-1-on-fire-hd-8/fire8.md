# Install Lineage OS 14.1 (Unofficial) onto a Amazon Fire HD 8 (2018)

## About
This guide is paraphrasing the instructions on an XDA Developers' [forum post](https://forum.xda-developers.com/hd8-hd10/general/tut-root-hd82018-via-magisk-t3906554), but with a bit more brevity and with direct-download links in-line with the instructions.  
This guide assumes the use of Ubuntu Linux, although it was successfully performed on Arch Linux with equivalent instructions (for installing python packages and Android tools).

## Prepare your Computer
* If you're not running Linux, you'll need to run from a Live image or use a Virtual machine.
* Install Python tools: `sudo pip install pyserial` xor `sudo apt install python3 python3-serial`
* Install Android tools: `sudo apt install android-tools-adb android-tools-fastboot`
* Downolad [amonet-lite.zip](https://forum.xda-developers.com/attachment.php?attachmentid=4716727&d=1551731231)
```
unzip amonet-lite.zip
chmod 755 amonet-lite/bootrom-step.sh
```
* Disable ModemManager:
```
python -m platform | grep --quiet Ubuntu && sudo apt remove modemmanager
```

## Prepare the Tablet

### Do not connect tablet to the Internet

If your Fire 8 HD 2018 has already been connected to the internet after 9/11/2019, then Amazon may have already pushed an over-the-air update that prevents `mtk-su` from working [as noted by the author](https://forum.xda-developers.com/showpost.php?p=80102590&postcount=786). It appears that `mtk-su` is such an effective tool that Amazon deliberatley patched Fire OS to make `mtk-su` not work.

The best way to avoid this is to not connect the Fire 8 HD 2018 *at all* after getting it from Amazon.

If you already have the update that prevents `mtk-su` from working, you will have to go through a [slight hassle of downgrading](https://forum.xda-developers.com/hd8-hd10/orig-development/fire-hd-8-2018-downgrade-unlock-root-t3894256) the tablet via shorting a pin and flashing relevant software onto it.

### Put Tablet into Developer Mode
* Open Settings App
* Click on "Device Options"
* Click on "About Fire Tablet"
* Click on "Serial Number" many times until a toast appears saying developer mode has been enabled.
* Press the back button to go back to "Device Options" screen
* Click on "Developer Options" (below "About Fire Tablet")
* Click the "On" switch to enable it
* Scroll down to "Debugging" section
* Click the "USB debugging" switch to enable it

### Install G-Apps

* Download the 4 APKs (version matters) described [here](https://www.xda-developers.com/amazon-fire-hd-8-google-play-store/), which requires clicking-through ~3 pages per APK, or just use directly links here: 
    * [Google Services Framework 7.1.2](https://www.apkmirror.com/apk/google-inc/google-services-framework/google-services-framework-7-1-2-release/google-services-framework-7-1-2-android-apk-download/download/)
    * [Google Account Manager 7.1.2](https://www.apkmirror.com/apk/google-inc/google-account-manager/google-account-manager-7-1-2-release/google-account-manager-7-1-2-android-apk-download/download/)
    * [Google Play Services 14.3.66 64bit nodpi](https://www.apkmirror.com/apk/google-inc/google-play-services/google-play-services-14-3-66-release/google-play-services-14-3-66-020400-213742215-android-apk-download/download/)
    * [Google Play Store 11.9.14](https://www.apkmirror.com/apk/google-inc/google-play-store/google-play-store-11-9-14-release/google-play-store-11-9-14-all-0-pr-214884739-android-apk-download/download/)
* Connect the device to your computer with a USB cable and accept the prompt to enable communication with your computer.
* Install the APK files to the android device:
```
adb kill-server && sudo adb start-server
adb install -r 'com.android.vending_11.9.14-all_0_PR_214884739-81191400_minAPI16(armeabi,armeabi-v7a,mips,mips64,x86,x86_64)(240,320,480dpi)_apkmirror.com.apk'
adb install -r 'com.google.android.gms_14.3.66_(020400-213742215)-14366010_minAPI21(arm64-v8a,armeabi-v7a)(nodpi)_apkmirror.com.apk'
adb install -r 'com.google.android.gsf_7.1.2-25_minAPI25(nodpi)_apkmirror.com.apk'
adb install -r 'com.google.android.gsf.login_7.1.2-25_minAPI23(nodpi)_apkmirror.com.apk'
```

### Drain the Battery
* Download "Fast Discharge" from Google Play Store
* Start draining the battery to 3%
* FAQ:
    * Why? Because if the rooting scripts freeze, you'll have to wait for battery to drain before trying again.
    * Why not 4% battery life?  Because it'll be 1 hour per 1% battery drain when in Bootloader.
    * Why not 2% battery life?  Because you'll need just enough battery to reboot into TWRP after rooting, and 2% isn't.

### Prepare for Rooting
* Download zip files that are attached to bottom of [this forum post](https://forum.xda-developers.com/hd8-hd10/general/tut-root-hd82018-via-magisk-t3906554):
    * [unlock_images.zip](https://forum.xda-developers.com/attachment.php?attachmentid=4715583&d=1551558490)
    * [finalize_no_ota.zip](https://forum.xda-developers.com/attachment.php?attachmentid=4715583&d=1551558490)
* Downlad [Magisk-v18.0.zip](https://github.com/topjohnwu/Magisk/releases/download/v18.0/Magisk-v18.0.zip) (referenced in article step 4)
* Download the MediaTek superuser binary (arm, not arm64), [mtk-su_r17.zip](https://forum.xda-developers.com/attachment.php?attachmentid=4791658) (referenced in article step 6, referring to this [other forum poust](https://forum.xda-developers.com/hd8-hd10/orig-development/experimental-software-root-hd-8-hd-10-t3904595))
* Copy the files over to the device:
```
adb kill-server && sudo adb start-server
adb shell mkdir /sdcard/00
adb push unlock_images.zip /sdcard/00
adb push finalize_no_ota.zip /sdcard/00
adb push Magisk-v18.0.zip /sdcard/00
adb push mtk-su_r17/arm/mtk-su /data/local/tmp
adb shell chmod 755 /data/local/tmp/mtk-su
```

## Root the device
* DRAIN THE BATTERY via Fast Discharge to 3%, this is critical to do. Don't go *lower* than 3%.
* Keep the tablet screen ON and do NOT let it go to sleep.
* Shell into device and then start the MediaTek superuser binary:
```
adb shell
cd /data/local/tmp/
./mtk-su
```
* If the program gets stuck after a few seconds, press `ctrl+c` and try again.
* You should get a root shell, with the prompt: `karnak:/data/local/tmp #`
* If the prompt does not say *karnak* then STOP and do NOT continue, you don't have a Fire HD 8 2018.
* Do the following commands from the root shell, make sure there are no errors other than exepceted errors that say "no disk space on device" for the commands using `/dev/zero` :
```
dd if=/dev/block/platform/soc/11230000.mmc/by-name/boot of=/sdcard/00/boot_orig.img
dd if=/dev/block/platform/soc/11230000.mmc/by-name/lk of=/sdcard/00/orig_lk.bin
dd if=/dev/block/platform/soc/11230000.mmc/by-name/tee1 of=/sdcard/00/orig_tz.bin
dd if=/dev/block/mmcblk0boot0 of=/sdcard/00/orig_boot0.bin
dd if=/dev/zero of=/dev/block/platform/soc/11230000.mmc/by-name/recovery
dd if=/sdcard/00/unlock_recovery-inj.img of=/dev/block/platform/soc/11230000.mmc/by-name/recovery
```
* Double check the MD5 sums:
```
md5sum /sdcard/00/unlock_lk.bin
md5sum /sdcard/00/unlock_tz.bin
md5sum /dev/block/platform/soc/11230000.mmc/by-name/recovery
```
```
90ee125c08abc999f78325d30e26a388  /sdcard/00/unlock_lk.bin
982513e70d6de114ed4a9058a86de848  /sdcard/00/unlock_tz.bin
faae811e229f0a7780fd130a286d3c47  /dev/block/platform/soc/11230000.mmc/by-name/recovery
```
* Proceed wiping the preloader, which will enable the BootRom with these commands:
```
dd if=/sdcard/00/unlock_lk.bin of=/dev/block/platform/soc/11230000.mmc/by-name/lk
dd if=/sdcard/00/unlock_tz.bin of=/dev/block/platform/soc/11230000.mmc/by-name/tee1
dd if=/sdcard/00/unlock_tz.bin of=/dev/block/platform/soc/11230000.mmc/by-name/tee2
dd if=/sdcard/00/unlock_recovery-inj.img of=/dev/block/platform/soc/11230000.mmc/by-name/boot
dd if=/sdcard/00/unlock_recovery-inj.img of=/dev/block/platform/soc/11230000.mmc/by-name/recovery
echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/dev/zero of=/dev/block/mmcblk0boot0
echo 'EMMC_BOOT' > /dev/block/mmcblk0boot0
md5sum /dev/block/mmcblk0boot0
```
* You should be in a bricked state, intentionally, disconnect the tablet and turn it off.
* On your linux computer:
```
python -m platform | grep --quiet Ubuntu && sudo apt remove modemmanager
sudo su
amonet-lite/bootrom-step.sh
```
* Attach the bricked tablet to the computer with USB cable, try to use a true USB-2 port.
* Wait as the tablet enters BootRom mode and interacts with the running `bootrom-step.sh` script.
* Follow instructions on screen from the `bootrom-step.sh` script.
* If it freezes before finishing, wait for the battery to drain (1 hour per 1% battery life), try again.
* If it succeeds, you should see the thing reboot and show an "Amazon" screen. Then it should enter TWRP.
    If you see a black screen:
    *  Tap the power button a couple times, TWRP sometimes startups up as a black screen.
    *  Try charging the laptop a little bit, then turn it on again.
* Restore boot partition to its original location:
    * In TWRP click "Install" button.
    * Navigate up and to `/sdcard/00` folder, select the "Install Image" button in the lower right hand of the screen.
    * Select the file named `boot_orig.img`, select the `boot partition` radio button.
    * Swipe the slider at the bottom of the screen to install.
* Install Magisk:
    * On the main TWRP screen, click the "Install" button.
    * Navigate up and to `/sdcard/00` folder, select the "Install Zip" button in the lower right hand of the screen.
    * Select the file named `Magisk-v18.0.zip`
    * Swipe the slider at the bottom of the screen to install.     
* Disable Over-The-Air updating:
    * On the main TWRP screen, click the "Install" button.
    * Navigate up and to `/sdcard/00` folder, select the "Install Zip" button in the lower right hand of the screen.
    * Select the file named `finalize_no_ota.zip`
    * Swipe the slider at the bottom of the screen to install.
* Reboot from TWRP and Fire OS should boot, now rooted.

## Install Lineage OS

* Download lastest of [Lineage OS 14.1 releases](https://github.com/mt8163/android_device_amazon_karnak/releases)
* Download [G-Apps](https://opengapps.org/) Pico 7.1 for ARM (not arm 64):
    * Select `ARM` (not arm64), `7.1`, and `pico` radio buttons and then the download button.
* Push the files to the tablet device:
```
adb push lineage-14.1-20190717-UNOFFICIAL-karnak.zip /sdcard/00/
adb push  open_gapps-arm64-7.1-pico-20190712.zip  /sdcard/00
```
* Boot TWRP by turning off the tablet, then holding down the power and volume buttons continuously whli ethe device boots into TWRP.
* Wipe device's existing the caches
    * From main TWRP screen, press the Wipe button
    * Press the Advanced Wipe Button
    * Select the "System", "Data", and "Cache" check-boxes
    * Swipe the slider to wipe the partitions
    * Press the back button
* Install LineageOS
    * Select the Install button
    * Select the LineageOS zip in `/sdcard/00`
    * Select Add More Zips
    * Select G-Apps zip in `/sdcard/00`  (arm 7.1 pico, NOT arm64)
    * Swipe to confirm flash
    * Reboot
* Sideload MagiskManager (optional)
    * From the [Magisk page](https://forum.xda-developers.com/apps/magisk/official-magisk-v7-universal-systemless-t3473445), download the latest [Magisk Manager APK](https://github.com/topjohnwu/Magisk/releases/download/manager-v7.3.2/MagiskManager-v7.3.2.apk)
    * `adb install -r MagiskManager-v7.3.2.apk`

## References:

The following forum posts and articles are where all the information was gathered from:

* Installing G-Apps on (unmodified) Fire HD 8 2018: https://www.xda-developers.com/amazon-fire-hd-8-google-play-store/
* Rooting the Fire HD 8 2018 (and installing TWRP): https://forum.xda-developers.com/hd8-hd10/general/tut-root-hd82018-via-magisk-t3906554
* LineageOS 14.1 for Fire HD 8 2018: https://forum.xda-developers.com/hd8-hd10/general/lineageos-14-1-fire-hd8-2018-t3936242

## Example Output:

This is my output from various steps.

My output from the BootRom step:
```
aoeu@derp in /home/aoeu/Downloads/amonet-lite at 2019-18-07 22:22:14
> sudo su
[root@derp amonet-lite]# ./bootrom-step.sh
[2019-07-18 22:22:26.852535] Waiting for bootrom
[2019-07-18 22:22:35.140752] Found port = /dev/ttyACM0
[2019-07-18 22:22:35.141903] Handshake
[2019-07-18 22:22:35.142644] Disable watchdog

 * * * Remove the short and press Enter * * *


[2019-07-18 22:22:55.211340] Init crypto engine
[2019-07-18 22:22:55.234236] Disable caches
[2019-07-18 22:22:55.236025] Disable bootrom range checks
[2019-07-18 22:22:55.249573] Load payload from ../brom-payload/build/payload.bin = 0x4690 bytes
[2019-07-18 22:22:55.251852] Send payload
[2019-07-18 22:22:55.924547] Let's rock
[2019-07-18 22:22:55.925434] Wait for the payload to come online...
[2019-07-18 22:22:57.295633] all good
[2019-07-18 22:22:57.296188] Check GPT
[2019-07-18 22:22:57.632427] gpt_parsed = {'proinfo': (1024, 6144), 'PMT': (7168, 9216), 'kb': (16384, 2048), 'dkb': (18432, 2048), 'lk': (20480, 2048), 'tee1': (22528, 10240), 'tee2': (32768, 10240), 'metadata': (43008, 80896), 'MISC': (123904, 1024), 'reserved': (124928, 16384), 'boot': (141312, 32768), 'recovery': (174080, 40960), 'system': (215040, 6354944), 'vendor': (6569984, 460800), 'cache': (7030784, 1024000), 'userdata': (8054784, 53016543)}
[2019-07-18 22:22:57.632696] Check boot0
[2019-07-18 22:22:57.879854] Check rpmb
[2019-07-18 22:22:58.089028] Downgrade rpmb
[2019-07-18 22:22:58.091038] Recheck rpmb
[2019-07-18 22:22:58.985634] rpmb downgrade ok
[2019-07-18 22:22:58.985930] Flash lk-payload
[4 / 4]
[2019-07-18 22:22:59.316918] Flash preloader
[288 / 288]
[2019-07-18 22:23:05.970769] Reboot to unlocked fastboot
[root@derp amonet-lite]# 
```
