variable "region" {
  description = "AWS Region"
  type        = string
}

variable "name" {
  description = "the name of your stack"
  type        = string
  default     = "computervision"
}

variable "lambda_name" {
  description = "the Lambda function name"
  type        = string
  default     = "trigger_fargate"
}


variable "container_port" {
  description = "Port of container"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 1024
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 2048
}

variable "service_desired_count" {
  description = "Minimum number of services running in parallel"
  type        = string
  default     = 1
}

variable "vpc_cidr_range" {
  type = string
}

variable "private_subnets_list" {
  description = "Private subnet list for infrastructure"
  type        = list(string)
}

variable "public_subnets_list" {
  description = "Public subnet list for infrastructure"
  type        = list(string)
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to (not required for operation)"
  default     = 3000
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
