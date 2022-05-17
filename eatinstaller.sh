# Bash UI for bootstrapping Eat

if ! command -v dialog &> /dev/null; then
   echo "You need to install dialog before starting the graphical interface. On Ubuntu,"
   echo "it appears to be in the \"universe\" repositories. On (open)SUSE, it's in repo-oss."
   echo "On Debian, it's in the main repository."
   exit 1
fi
if [[ "$SOTYPE" -ne "linux-gnu" ]]; then
   dialog --no-shadow --title "Unsupported OS" --msgbox "Eat is only supported on Linux and Windows Subsystem for Linux, but macOS is planned." 1000 1000
   clear
   exit 1
fi
if ! [[ $(id -u) -ne 0 ]]; then
   dialog --title "Root Permissions Not Allowed" --msgbox "To prevent sudo conflicts, the Eat installer UI cannot be run as root (superuser). Did you accidentally put \"sudo\" at the start? If so, run the command again without sudo." 8 60
   clear
   exit 1
fi
if [ -d "/home/$(whoami)/Eat-PKG-Manager" ]; then
   dialog --no-shadow --title "Too Many Installations" --msgbox "To prevent conflicts and errors, only one installation of Eat per OS is allowed to be installed." 1000 1000
   clear
   exit 1
fi

# Get Linux distribution and set the dependency installation command for it
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu/etc.
     INSTALL_COMMAND="apt-get update && sudo apt-get install git python3 python3-pip -y"
elif [ -f /etc/redhat-release ]; then
    # Red Hat, CentOS, etc.
    INSTALL_COMMAND="sudo yum install -y python3 git && python3 -m ensurepip"
else
    if command -v zypper &> /dev/null; then
        # SuSE/etc.
        INSTALL_COMMAND="sudo zypper refresh && sudo zypper install -y python310 python310-pip git && python3 -m ensurepip"
    elif command -v pacman &> /dev/null; then
        # Arch/etc.
        INSTALL_COMMAND="sudo pacman -Sy && sudo pacman -S python git --needed --noconfirm && python3 -m ensurepip"
    elif command -v apt &> /dev/null; then
        # fix detection on android termux
        INSTALL_COMMAND="apt-get update && apt-get install python git -y && python3 -m ensurepip"

    else
        dialog --title "Unsupported Linux Distribution" --msgbox "EatInstaller has detected an unsupported Linux distro. Supported distros are Debian GNU/Linux, Ubuntu, Kali, Linux Mint, openSUSE, SUSE, Pengwin, Raspberry Pi OS, Fedora, Red Hat, CentOS, ArchLinux, Android (Termux), other RHEL/SUSE/Debian/Arch based distributions." 1000 1000
        clear
        exit 1
    fi
fi

# Print an error if user is not in sudoers or hackers are installing eat (implemented in next line)
autherror() {
  echo "failed to authenticate, are you in the sudoers file? The message should be above"
  exit 1
}

# Check for authentication (may fail if user is not in SUDOers)
sudo echo -n "" || autherror

# Before doing anything, clear the screen
clear

# Install dependencies, return output in the UI
dialog --no-shadow --title "Installing OS Dependencies" --prgbox "Eat is installing it's dependencies. This will take a while, and the progress can be seen below." "$INSTALL_COMMAND" 1000 1000
dialog --no-shadow --title "Installing Python Dependencies" --prgbox "Eat is installing additional dependencies for Python 3." "python3 -m pip install colorama distro requests pyyaml distro" 1000 1000

# Ask the user to configure the Eat sources
if dialog --no-shadow --title "Installation" --yesno "The Eat network and Eat itself will be installed NOW. The network will contain each package you install using Eat. Removing the network is possible, but will lead to Eat recovering the network. The UI will be temporarily disabled, but it will appear again soon. Continue?" 1000 1000
then
   clear # clear to exit the GUI
   echo "Warning: The GUI has been disabled."
   git clone "https://github.com/EatInstall/Eat" ~/Eat-PKG-Manager --depth 1
   git clone "https://github.com/EatInstall/Network" ~/eat_sources --depth 1
   clear
else
   clear
   exit
fi
clear
echo "" >> ~/.bashrc
echo "# Add eat package manager commands." >> ~/.bashrc
echo "alias eat='python3 ~/Eat-PKG-Manager/eat.py'" >> ~/.bashrc
echo "alias eatinst='python3 ~/Eat-PKG-Manager/eat-install.py'" >> ~/.bashrc
echo "alias eathelp='python3 ~/Eat-PKG-Manager/man-eat.py'" >> ~/.bashrc
dialog --no-shadow --title "Setup Complete" --msgbox "Eat has been installed! You can configure Eat to your favourites by editing ~/eatconfig.yaml, so you can make Eat your favourite package manager. Thank you for installing Eat!" 1000 1000
clear
exit 0
