# !/bin/bash
set -x 

echo "DISPLAY value is =$DISPLAY"
sudo systemctl status  sshd.service

# X-11 on Unix
# https://www.redwireservices.com/remote-x11-for-linux-unix
# https://support.sas.com/en/documentation/third-party-software-reference/9-4/support-for-other-products.html
sudo yum install xorg-x11-xauth xterm -y
touch ~/.Xauthority && chmod 600 ~/.Xauthority


sudo sed -i "s|#Port 22|Port 22|g"  /etc/ssh/sshd_config
sudo sed -i "s|#AddressFamily any|AddressFamily inet|g"  /etc/ssh/sshd_config
sudo sed -i "s|#X11Forwarding yes|X11Forwarding yes|g"  /etc/ssh/sshd_config
sudo sed -i "s|X11Forwarding no|X11Forwarding yes|g"  /etc/ssh/sshd_config
sudo sed -i "s|#X11DisplayOffset 10|X11DisplayOffset 10|g"  /etc/ssh/sshd_config


sudo systemctl restart sshd.service
echo "DISPLAY value is =$DISPLAY"

sudo yum install firefox -y

sudo yum install junit -y

## TODO
# Add ssh key to /home/sas/.ssh/authorized_key so that you can use the same key to login via mobaterm with X11 forwarding enabled.  or else the $DISPLAY will not be set for sas user and you cannot use GUI for any scripts which requires login via sas users, eg sasdm.sh

mkdir -p /home/sas/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmunISrsi7nZJpq+coCz37E1wbQ7yy87hdzMGglYqd8mIFVa635XT59a3qd5cOFfBNyOrqS24xmbOMeEF4yUGYPa3mhLMhGDpC3PMyBb1HJuzXnrNqQyiouAiiS9NPl6M/pT2StK4fW9aKBzEpzPZ7AyC+V3bxSoAA4H81OMeVUKmxxEUzNY57wkAmVsasKoC5ZWrXvQtzSAlbRhKAt9gSLaxm4vuAOsU246WdtU3wD6cRykzZ4+7h0xO/KUGdeui8zTkxz97qXS1S9Y7KqaAAwMBnJua9JpBeZfccZADe3bbBFiZKBO4hJU2iEUuPvBKxF8BSCdgYzFGcUEB46pC/ opc@pvo-devbox" > /home/sas/.ssh/authorized_keys


