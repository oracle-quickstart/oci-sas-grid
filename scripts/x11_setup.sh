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
#mkdir -p /home/sas/.ssh/
#echo "ssh-rsa id_rsa.pub file" > /home/sas/.ssh/authorized_keys


