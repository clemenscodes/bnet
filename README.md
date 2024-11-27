# Warcraft 3 Champions on Linux

## Setup

Using nix (with flakes enabled):

```
nix develop -C $SHELL
```

### Install Battle.net

```sh
./scripts/bnet.sh
```

### Install W3Champions

```sh
./scripts/w3c.sh
```

### Install 64-Bit Bonjour

```sh
./scripts/bonjour/install_bonjour.sh
```

## Launch

Run W3Champions

```sh
./scripts/w3c.sh
```

- Click Play

- Let Battle.net launch

- Click Play again -> Warcraft 3 launches

In a new terminal

```sh
./scripts/bonjour/restart_bonjour.sh
```

Now connecting to Flo in W3Champions should work.
