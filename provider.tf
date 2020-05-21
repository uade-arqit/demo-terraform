variable "do_token" {type = string}
variable "pub_key" {
  type = string
  default = "keys/demo.pub"
}
variable "pvt_key" {
  type = string
  default = "keys/demo"
}
variable "ssh_fingerprint" {
  type = string
  default = "ed:74:66:18:6b:bc:a0:f0:45:62:c0:fa:35:2f:c1:88"
}

provider "digitalocean" {
  token = var.do_token
}