variable "cluster_name" {
  type = string
  default = "my-eks-cluster"
}

variable "cluster_version" {
  type = number
  default = 1.25
}

variable "region" {
  type = string
  default = "us-west-2"
}

variable "availability_zones" {
  type = list
  default = ["us-west-2a", "us-west-2b"]
}


