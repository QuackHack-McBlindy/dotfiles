sudo rm /etc/resolv.conf  # 🦆says⮞remove any broken symlink
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
