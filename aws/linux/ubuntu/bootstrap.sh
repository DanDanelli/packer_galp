truncate -s 0 /etc/machine-id
cloud-init clean --logs
sudo sed -i /etc/hosts -e "s/^127.0.0.1 localhost$/127.0.0.1 localhost $(hostname)/"