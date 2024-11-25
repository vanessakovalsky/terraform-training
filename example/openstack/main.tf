# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "demo"
  password    = "superpassword"
  auth_url    = "http://127.0.0.1/identity"
  region      = "RegionOne"
}

# Create image 

resource "openstack_images_image_v2" "image" {
  container_format = "bare"
  disk_format      = "iso"
  image_source_url = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-standard-3.20.3-x86_64.iso"
  name             = "Alpine linux"
}

# Create flavor

resource "openstack_compute_flavor_v2" "test-flavor" {
  name  = "my-flavor"
  ram   = "1024"
  vcpus = "1"
  disk  = "2"
}

# Create keypair

resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "my-keypair"
}

# Create network and subnetwork

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}



# Create a web server
resource "openstack_compute_instance_v2" "test-server" {
  name            = "basic"
  image_id        = openstack_images_image_v2.image.id
  flavor_id       = openstack_compute_flavor_v2.test-flavor.id
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.network_1.name
  }
}