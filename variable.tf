variable "cidr_block" {
  
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
    default = "default"
  
}
variable "public_subnet_cidr" {
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
}
variable "private_subnet_cidr" {
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  
}

variable "route_table_cidr" {
    default = "0.0.0.0/0"
  
}