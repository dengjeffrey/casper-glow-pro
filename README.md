# What
Allows you to use Siri shortcuts to turn on and off your Casper Glow. This app only works with one Glow lamp at a time. Currently the data is hardcoded for my own personal Glow lamp, but you can configure it to work with your own. In order to get this to work with your glow you can record the packets and replace the bytes in [GlowData.swift](https://github.com/dengjeffrey/casper-glow-pro/blob/main/CasperGlowPro/CasperGlowPro/GlowData.swift). 

# How
First the app will replay the handshake and when that is complete the app will be in a state where you can send on and off signals to the lamp. Without the traces from other Glows and a jailbroken device I have not yet reversed what the schema of the packets are. 

## Steps to make this work with your Glow
1. Follow https://www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/ to setup your iOS device to record Bluetooth packets.
2. Once the PacketLogger is recording, open the official Casper app and turn the light on and off.
3. Look in the logs for Decoded Packet that contains a local device name that is prefixed with the name `Jar`. I suspect this is what the factory name for the Glow lamps are.

![image](https://user-images.githubusercontent.com/2238961/110734083-1b4e0280-81f5-11eb-9205-f8ae0f49ff12.png)

3. Filter the packets by this device.
4. Look for a packet with a Value of 6 bytes. This should be one of the smallest ATT Send packets. This will be the Reconnect packet or the Connect packet, depending on whether this is your first time using the official Casper app.

![image](https://user-images.githubusercontent.com/2238961/110735080-0f634000-81f7-11eb-941c-29a7a79cecbb.png)

5. The following packets will be the handshake. The values of packets that are highlighted below should replace the cooresponding data in [GlowData.swift](https://github.com/dengjeffrey/casper-glow-pro/blob/main/CasperGlowPro/CasperGlowPro/GlowData.swift). The first arrow points to the data for `.connect`/`.reconnct`. The second arrow points to the data for `READY_BYTES`, it may be cut-off in the PacketLogger, so if this is the case then you may need to put some logs in the app and record what the value of that packet is. The last arrow points to the data for `.connectAck`.
![image](https://user-images.githubusercontent.com/2238961/110737011-9d8cf580-81fa-11eb-8072-63f6d9781790.png)

# Contribute
I do not currently have access to a jailbroken phone or additional Bluetooth traces from a different Glow device, so finding out what the data packets consist of is a difficult task.

If you have ideas or a bluetooth trace of your Casper Glow please do share in an issue or PR.

