#/bin/bash
# 1/27/22
# install tanzu community edition
# run script like: sudo sh install-ubuntu.sh $USER

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

#install kubectl
echo "Install kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client

#install tanzu
echo "Install TCE"
apt-get install -y jq

curl -H "Accept: application/vnd.github.v3.raw" \
    -L https://api.github.com/repos/vmware-tanzu/community-edition/contents/hack/get-tce-release.sh | \
    bash -s v0.9.1 linux

tar xzvf tce-linux-amd64-v0.9.1.tar.gz

./tce-linux-amd64-v0.9.1/install.sh
sleep 3

tanzu

