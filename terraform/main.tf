# Terraform configuration for OpenStack provider
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.54.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {}

# Create security group for SSH access
resource "openstack_networking_secgroup_v2" "allow_ssh" {
  name        = "doan-tf-allow-ssh"
  description = "Allow SSH traffic"
}

# Create security group rule for SSH (port 22)
resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.allow_ssh.id
}

# Create production server instance
resource "openstack_compute_instance_v2" "production_server" {
  name             = "doan-tf-production-server"
  image_name       = "ubuntu-24.04"
  flavor_name      = "m1.small"
  key_pair         = "doan-key"
  security_groups  = [openstack_networking_secgroup_v2.allow_ssh.name]
  network {
    name = "student-net"
  }
}

# Output the IP address of the production server
output "server_ip" {
  value = openstack_compute_instance_v2.production_server.access_ip_v4
}