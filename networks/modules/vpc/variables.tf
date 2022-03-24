/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  type        = string
  description = "Project ID for Private Shared VPC."
}

variable "env" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization."
}

variable "region" {
  description = "Region for the network creation."
  type        = string
  default     = "europe-west3"
}

variable "nat_enabled" {
  type        = bool
  description = "Toggle creation of NAT cloud router."
  default     = true
}

variable "nat_num_addresses" {
  type        = number
  description = "Number of external IPs to reserve for Cloud NAT."
  default     = 2
}

variable "subnets" {
  type = map(object({
    subnet_ip             = string,
    subnet_region         = string,
    subnet_private_access = string
  }))
  description = "The list of subnets being created."
  default     = {}
}

variable "secondary_ranges" {
  type        = map(list(object({ designation = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets."
  default     = {}
}

variable "routes" {
  type        = list(map(string))
  description = "The list of VPC routes."
  default     = []
}
