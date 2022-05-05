# `eatinstaller.sh`

A community-maintained graphical Eat installer, just for you.

## Running

In order to use EatInstaller, you need to use a *Debian-based Linux*.
Examples include Ubuntu, Pengwin (formerly WinLinux), and Raspberry
Pi OS (formerly Raspbian). You may also use Debian, but beware that on
WSL, you'll need to add the `non-free` repo as many packages in `main`
only appear with `non-free` added to your `apt`'s `sources.list`. To
verify that your distro is supported, use `screenfetch`.

This installer also requires:
* `sudo`
* The `dialog` program
* [cURL](https://curl.se/index.html)

To install `dialog`:
```shell
sudo add-apt-repository -y universe
sudo apt update
sudo apt install dialog
```

**WARNING**: You may need to remove the first line on Debian, as Debian does not have
`universe`, `restricted`, and `multiverse`. `multiverse`/`restricted` is instead called
`non-free` (meaning ***not** DFSG-compliant*), and `universe` is called `main` (meaning
*DFSG-compilant*).

* * *

To install cURL, run
```shell
sudo apt update
sudo apt install curl
```

* * *

To run EatInstaller, run:
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/EatInstall/EatInstaller/main/eatinstaller.sh)"
```
