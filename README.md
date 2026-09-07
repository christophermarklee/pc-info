# pc-info
PC Info Utils

## recon.sh

`recon.sh` gathers a quick hardware/system report using [inxi](https://github.com/smxi/inxi).
It automatically installs `inxi` using whatever package manager is available on the
system (apt, dnf, yum, pacman, zypper, apk, brew, xbps, or emerge) if it isn't
already installed, then runs `inxi -m -C -G -D -M -z`.

Run it directly from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/christophermarklee/pc-info/main/recon.sh | sudo sh
```

Or download and run it locally:

```sh
sudo sh recon.sh
```
