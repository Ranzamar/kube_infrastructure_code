echo "*********************************************************************************"
echo " E L A B O R A Z I O N E"
hostname
echo "*********************************************************************************"

cd /tmp 
wget https://github.com/containerd/containerd/releases/download/v1.7.16/containerd-1.7.16-linux-amd64.tar.gz 
tar Cxzvf /usr/local containerd-1.7.16-linux-amd64.tar.gz 
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service 
cp containerd.service /lib/systemd/system; systemctl daemon-reload 

mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd 
apt install runc
mkdir -p /opt/cni/bin 
wget https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz 
mkdir -p /opt/cni/bin 
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.1.tgz

echo "*********************************************************************************"
echo "Installing Kuectl Kubeadm Kubelet"
echo "*********************************************************************************"

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

echo "*********************************************************************************"
echo "Enable BR_NETFILTER on the kernel"
echo "*********************************************************************************"
modprobe br_netfilter
echo "1" > /proc/sys/net/ipv4/ip_forward
