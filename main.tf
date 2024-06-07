resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "kube_network" {
  name          = "k8snet"
  ip_cidr_range = "172.16.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ssh" {
  name = "allow-all"
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
    allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}



resource "google_compute_instance" "k8s-controlplane" {
  name         = "k8s-controlplane"
#  hostname     = "k8s-controlplane"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.kube_network.id
    network_ip = "172.16.1.11"

#      access_config {    }
  }
}

resource "google_compute_instance" "k8s-node-1" {
  name         = "k8s-node-1"
#  hostname     = "k8s-controlplane"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.kube_network.id
    network_ip = "172.16.1.21"

#      access_config {    }
  }
}

resource "google_compute_instance" "k8s-node-2" {
  name         = "k8s-node-2"
#  hostname     = "k8s-controlplane"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask cd /tmp; wget https://github.com/containerd/containerd/releases/download/v1.7.16/containerd-1.7.16-linux-amd64.tar.gz; tar Cxzvf /usr/local containerd-1.7.16-linux-amd64.tar.gz; wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service; cp containerd.service /lib/systemd/system; systemctl daemon-reload; systemctl enable --now containerd; apt install runc; mkdir -p /opt/cni/bin; wget https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz; mkdir -p /opt/cni/bin; tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.1.tgz;"

  network_interface {
    subnetwork = google_compute_subnetwork.kube_network.id
    network_ip = "172.16.1.22"

#      access_config {    }
  }

}
resource "google_compute_router" "nat-router-us-west1" {
  name    = "nat-router-us-west1"
  region  = "us-west1"
  network  = "my-custom-mode-network"
}

resource "google_compute_router_nat" "nat-config" {
  name                               = "nat-config"
  router                             = "nat-router-us-west1"
  region                             = "us-west1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
