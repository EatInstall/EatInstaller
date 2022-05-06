# `eatinstaller.sh`

A community-maintained graphical Eat installer, just for you.

## Running

This installer requires:
* `sudo`
* The `dialog` program (enter `apt:dialog` in the browser address bar)
* [cURL](https://curl.se/index.html)

To install `dialog` on Debian, Ubuntu, etc.:
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

To install cURL on Debian, Ubuntu, etc., run
```shell
sudo apt update
sudo apt install curl
```

* * *

To run EatInstaller, run:
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/EatInstall/EatInstaller/main/eatinstaller.sh)"
```
