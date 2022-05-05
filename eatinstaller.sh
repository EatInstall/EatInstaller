# Bash UI for bootstrapping Eat

if ! command -v dialog &> /dev/null; then
   echo "You need to install dialog before starting the graphical interface. On Ubuntu,"
   echo "it appears to be in the \"universe\" repositories. On (open)SUSE, it's in repo-oss."
   echo "On Debian, it's in the main repository."
   exit 1
fi
if [[ $SOTYPE -ne "linux-gnu" ]]; then
   dialog --title "Unsupported OS" --msgbox "Eat is only supported on Linux and Windows Subsystem for Linux, but macOS is planned." 1000 1000
fi
if ! [[ $(id -u) -ne 0 ]]; then
   dialog --title "Root Permissions Not Allowed" --msgbox "To prevent sudo conflicts, the Eat installer UI cannot be run as root (superuser). Did you accidentally put \"sudo\" at the start? If so, run the command again without sudo." 8 60
   clear
   exit 1
fi
if [ -d "/home/$(whoami)/Eat-PKG-Manager" ]; then
   dialog --title "Too Many Installations" --msgbox "To prevent conflicts and errors, only one installation of Eat per OS is allowed to be installed." 1000 1000
   clear
   exit 1
fi

# Get Linux distribution and set the name of it
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    OS=SUSE
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS=RHEL
else
    dialog --title "Unsupported Linux Distribution" --msgbox "EatInstaller has detected an unsupported Linux distro. Supported distros are Debian GNU/Linux, Ubuntu, Kali, Linux Mint, openSUSE, SUSE, Pengwin, Raspberry Pi OS, Fedora, Red Hat, CentOS, other RHEL/SUSE/Debian based distributions." 1000 1000
    clear
    exit 1
fi

# Check distro and pick the right command for installing dependencies.
if [ ! OS -ne "Debian" ]; then # on Debian, use apt-get
    INSTALL_COMMAND="sudo apt-get update && sudo apt-get install git python3 python3-pip -y"
elif [ ! OS -ne "RHEL" ]; then # om RHEL, use yum
    INSTALL_COMMAND="sudo yum install -y python310 python310-pip git"
elif [ ! OS -ne "SUSE" ]; then # on (open)SUSE, use zypper
    INSTALL_COMMAND="sudo zypper refresh && sudo zypper install -y python310 python310-pip git"
fi

# Print an error if user is not in sudoers or hackers are installing eat (implemented in next line)
autherror() {
  echo "failed to authenticate, are you in the sudoers file? The message should be above"
  exit 1
}

# Check for authentication (may fail if user is not in SUDOers)
sudo echo -n "" || autherror

# Before doing anything, clear the screen
sleep 1
clear

# Install dependencies, return output in the UI
dialog --title "Installing OS Dependencies" --prgbox "Eat is installing it's dependencies. This will take a while, and the progress can be seen below." "$INSTALL_COMMAND" 1000 1000
dialog --title "Installing Python Dependencies" --prgbox "Eat is installing additional dependencies for Python 3." "pip install colorama distro requests pyyaml distro" 1000 1000
clear

# Ask the user to configure the Eat sources
if dialog --title "Installation" --yesno "The Eat network and Eat itself will be installed NOW. The network will contain each package you install using Eat. Removing the network is possible, but will lead to Eat recovering the network. The UI will be temporarily disabled, but it will appear again soon. Continue?" 1000 1000
then
   clear # clear to exit the GUI
   echo "Warning: The GUI has been disabled."
   git clone "https://github.com/EatInstall/Eat" ~/Eat-PKG-Manager --depth 1
   git clone "https://github.com/EatInstall/Eat" ~/eat_sources --depth 1
   clear
else
   clear
   exit
fi
clear
echo "" >> ~/.bashrc
echo "# Add eat package manager commands." >> ~/.bashrc
echo "alias eat='python ~/Eat-PKG-Manager/eat.py'" >> ~/.bashrc
echo "alias eatinst='python ~/Eat-PKG-Manager/eat-install.py'" >> ~/.bashrc
echo "alias eathelp='python ~/Eat-PKG-Manager/man-eat.py'" >> ~/.bashrc
dialog --title "Setup Complete" --msgbox "Eat has been installed! You can configure Eat to your favourites by editing ~/eatconfig.yaml, so you can make Eat your favourite package manager. Thank you for installing Eat!" 1000 1000
clear
exit 0