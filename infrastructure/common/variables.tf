variable "sns_email" {
  type        = list(string)
  description = "Email used to subscribe to events notifications"
  default     = ["dmitriymigirov@gmail.com"]
}


variable "image_id" {
  type        = string
  description = "AMI ID"
  default     = "ami-080e1f13689e07408" # Ubuntu 22.04  (HVM), SSD Volume Type 
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"               
}

variable "key_name" {
  type        = string
  description = "Key name"
  default     = "nodejs-prod-key"     
}

variable "min_size" {
  type        = number
  description = "Minimum size for the auto scaling group"
  default     = 2                        
}

variable "max_size" {
  type        = number
  description = "Maximum size for the auto scaling group"
  default     = 4                       
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity for the auto scaling group"
  default     = 2                        
}

variable "region" {
  description = "The AWS region where the S3 bucket is located"
  type        = string
  default     = "us-east-1"
}


variable "azs" {
 type        = list(string)
 description = "Availability Zones for VPC"
 default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"  
}

variable "pub_sub1_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pub_sub2_cidr_block" {
  type    = string
  default = "10.0.2.0/24"
}
