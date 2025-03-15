# Warcraft 3 Champions on Linux

Running the new tauri launcher of W3Champions does not work on linux as of time of writing, due to issues with WebView2.
The old launcher has some support though. This project aims to help anyone interested in getting this to work on a linux system.

## Requirements

Using nix with flakes is the recommended approach. Alternatively, installing the [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher) manually is required.
Refer to the documentation to see how to install it for your distro.
Additionally, `curl` is required to fetch the installers when running the scripts.
To clone this project, we need `git` installed as well.

## Setup

There are three scripts that work in tandem to make Warcraft III with W3Champions work on linux.

### Installing Battle.net

First, we need to install the Battle.net launcher. There are lutris scripts available, however they all don't seem to work flawlessly.
Using umu-launcher has been the most reliable and seemless way to install Battle.net.

I wrote a [script](./scripts/bnet.sh) to fetch the Battle.net installer if the Battle.net binary does not exist in the exptected location and then run it.

To run it, clone this repository.

```sh
git clone https://github.com/clemenscodes/bnet.git
cd bnet
```

After cloning, you can run the script to install Battle.net

```sh
./scripts/bnet.sh
```

Alternatively, you can also just use nix directly to install Battle.net in a oneliner.

```sh
nix run --extra-experimental-features "nix-command flakes" github:clemenscodes/bnet#battlenet
```

### Installing W3Champions

After installing Battle.net, we can proceed to install the old W3Champions launcher.
I wrote a [script](./scripts/w3c.sh) for that as well.
The script will download the old launcher and run it using umu-launcher as well, in the same wineprefix as Battle.net.

```sh
./scripts/w3c.sh
```

W3Champions should install and open using the script. Login with your Battle.net account after installation.
Then launch Battle.net using the PLAY button in the W3Champions window.
Technically this is all that should be required, but as time of writing, there is still an issue with Bonjour used by Warcraft.

### Bonjour

Bonjour is used to facilitate the networking components of Warcraft.
To play ladder, it is required to restart the Bonjour Service in the same wineprefix after launching Battle.net using W3Champions.
I wrote a [script](./scripts/bonjour/restart_bonjour.sh) for that as well

```sh
./scripts/bonjour/restart_bonjour.sh
```

After successful restart of the Bonjour Service, everything should be good to go.
Queuing and even viewing FLO TV should work on linux now.

## Advanced Setup

To see a more advanced and convenient setup using this in a NixOS system, see my configuration [here](https://github.com/clemenscodes/cymenixos/blob/main/modules/gaming/battlenet/warcraft/default.nix).

## Contributions

Please! Feel free to contribute.


## Acknowledgements

Thanks to everyone in the W3Champions Discord server helping each other figuring this stuff out, especially Bogdan for his help and support for linux in the old launcher.

