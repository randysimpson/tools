#/bin/bash
#https://docs.docker.com/engine/install/ubuntu/
#run script like: sudo sh install-ubuntu.sh $USER

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io

#check if username parameter was passed in
if [ "$1" != "" ]
then
    echo "Adding user $1 to group docker."
    usermod -aG docker "$1"
    sleep 2
fi

#restart docker
systemctl daemon-reload
sleep 3
systemctl restart docker
sleep 3

#restart shell so usergroup takes effect
if [ "$1" != "" ]
then
    su $1
    sleep 2
fi
