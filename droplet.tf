# Create a new SSH key
resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file(var.pub_key)
}

resource "digitalocean_droplet" "all-infra" {
    image = "coreos-stable"
    name = "all-infra-${count.index}"
    region = "SFO2"
    size = "4gb"
    count=2
    private_networking = true
    ssh_keys = [var.ssh_fingerprint]
    tags = ["DEMO"]

 	connection {
      user = "core"
      type = "ssh"
      private_key = file(var.pvt_key)
      timeout = "10m"
      host = self.ipv4_address
  	}

    provisioner "local-exec" {
      command = "cd lb-clients-db; zip -r ../lb-clients-db.zip .; cd ..;"
    }

    provisioner "file" {
        source = "./lb-clients-db.zip"
        destination = "/home/core/lb-clients-db.zip"
    }

	provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/bin",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)\" -o /opt/bin/docker-compose",
      "sudo chmod +x /opt/bin/docker-compose",
      "cd /home/core/ && unzip /home/core/lb-clients-db.zip",
      "cd /home/core/ && docker build -t lb-clients:0.1.0 .",
      "cd /home/core/ && /opt/bin/docker-compose -p lb-clients up -d"
    ]
  }

   provisioner "local-exec" {
      command = "rm ./lb-clients-db.zip"
    }
}


resource "digitalocean_droplet" "nginx" {
    image = "ubuntu-18-04-x64"
    name = "nginx"
    region = "SFO2"
    size = "1gb"
    count = 1
    private_networking = true
    ssh_keys = [var.ssh_fingerprint]
    tags = ["DEMO"]


    connection {
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
        host = digitalocean_droplet.nginx[count.index].ipv4_address
    }
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }
}
