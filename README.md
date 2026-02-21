# conky-mh

**Conky** is a free, light-weight system monitor for X, that displays any kind of information on your desktop. It can also run on Wayland (with caveats), macOS, output to your console, a file, or even HTTP. 

Learn more in the [Conky git repository](https://github.com/brndnmtthws/conky), which has a useful wiki that you probably want to read through.

**conky-mh** is nothing more than my personal Conky configuration. I've taken ideas from dozens of others over the many years I've used Conky, but what you see here is otherwise my work, especially the Bash scria weather forecast. The center shows pts used to get information.

To use it, I place the files in `~/conky` on my machine and run the `start_conky.sh` script. The example screenshot comes from me running it on a Linux workstation running [Pop_OS! 24.04](https://system76.com/pop/) which uses [Wayland](https://wayland.freedesktop.org/).

<img src="matthews_conky.png" style="display: block; margin: auto; width: 90%;" alt="Screenshot of Conky system monitor displaying detailed hardware and weather information on a black desktop background. Left side shows a weather forecast. The center shows a dramatic black and white skull illustration. Right side contains multiple text sections with system stats including system information, battery backup UPS status, storage details, CPU metrics, GPU information, network statistics, and remote service ports. The overall tone is technical and utilitarian, with a darker aesthetic suitable for a developer workstation." />


## Files included

This section describes each of the files included in this repo, except for these, which are not needed to run my configuration:

- `README.md`
- `conky_main.png`
- `conky_weather.png`


### conky_main

Here you will find my main configuration, which includes a simple set of Conky config settings followed by the display settings to configure what is shown on my deaktop.

Some notes for this file:

- The battery backup UPS section uses `pwrstat`, which I've only tested with my [Cyberpower UPS](https://www.cyberpowersystems.com/) and which I originally downloaded from their site. I don't know if it's currently offered software, but it still works great for me, including in automation for triggering a power down event on the workstation X minutes after a blackout power loss. I've replaced the battery inside the UPS as the original aged out, otherwise it's been great for many years. Anyway, if you don't have the same setup, this section will probably need editing or removing. The app requires sudo privileges, so that may require some configuration on your machine to be able to use it in Conky; I added a line to my `/etc/sudoers` file to permit running the command to get status without requiring a password. I don't recommend doing that for `pwrstat` as a whole, though, since it can be used to shutdown your system among other things.
- In the Storage section, I list four devices. I hard-code the names of the devices mostly to make my life easier if/when I need them; you could just use labels like `/` or `filesystem root` and so on. Adjust to taste. I'm certain your main drive will be different and you may not have a secondary drive or a [Buffalo Linkstation NAS](https://buffaloamericas.com/products/category/network-attached-storage/Network-Attached-Storage-for-Home) or use [Dropbox](https://buffaloamericas.com/products/category/network-attached-storage/Network-Attached-Storage-for-Home). Edit accordingly.
- In the CPU section, unless you have the exact same CPU, you will need to make edits. There are probably too many or too few CPUs being polled, etc.
- Unless you have an NVIDIA GPU, that section won't work for you and it may not work on all of their hardware, depending on age and what driver version you have.
- Your network hardware names like `enp12s0` and `wlp170s0` will likely be different. Your machine may not have both wireless and wired connections; I only show the wired network in my graphic above as I don't use wireless on my workstation, but on my laptop, I use both. I thought providing the more detailed code might be useful to someone. You get to explore and find the proper names and adjust the settings. Hint: Run `ip address`.


### conky_weather

This is my configuration to display a weather report on the opposite side of my monitor from the main info. This also includes a simple set of Conky config settings followed by the display settings to configure what is shown on my workstation. In this case, all the work is done in a script, so this file is quite short.


### get_gpu_info.sh

I have an NVIDIA GPU. This script uses `nvidia-smi` to grab specific information. That info gets parsed and cached in the `gpu_info.txt` file in `data_files` as a one-item-per-line list of values. That file is parsed and those values are displayed with context in `conky_main`.


### get_my_ip.sh

This just uses `curl` to hit a web URL that returns just the external IP address of the machine that made the request. This way you get the IP that is seen outside of your internal network as something like `ip address` above will give you the IP of your machine from your router, etc.

There are many services like the sample I put in this file in this repo. The one shown here isn't actually what I use, but I tested it and it works fine. In my deployments I poll a file I placed on a web server I own, but it works the same way. I made the change because I would use services that would go down or because I enountered usage limits.


### get_weather_report.sh

This is the script that does all the heavy lifting for displaying the weather.

Some notes:

- You will need your own API key to use [Open Weather Map](https://openweathermap.org/).
- You will have to look up your latitude and longitude (Open Weather Map has instructions or you can use Google Maps to find yours).
- The code in the script is well commented, so it should be easy enough to use once you have the info above. I made it obvious where to put the key, lat, and lon info into the script to use as variables.


### start_conky.sh

This is a simple startup script. The `sleep` lines are included to force a pause because I include this script in my automated startup routine and I want to make sure other things have a chance to startup before Conky.


## data_files (directory)

I left a couple of sample temp files in the `data_files` directory so you can see what the scripts create.

- `gpu_info.txt` is created by `get_gpu_info.sh` where it is also explained.
- `openweathermap.json` is a sample of what is returned by the API call in `get_weather_report.sh`. See [OpenWeather One Call API 3.0](https://openweathermap.org/api/one-call-3) to learn about their API and parse the details of my simple query.


## License

This program is free software; you can redistribute it and/or modify it under the terms of the [MIT License](LICENSE.txt).

I don't know if you can copyright configuration files and I don't really feel the need. However, I did write the scripts and the slightly more complex ones have copyright notices. I sincerely don't care if or how you use them or any of this code. Have fun!


## Contributions

This repository is just a place for me to share what I use. I'm not currently accepting contributions.


