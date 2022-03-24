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

locals {
  environment_code = element(split("", var.env), 0)
  vpc_name         = "${local.environment_code}-shared-base"
  network_name     = "vpc-${local.vpc_name}"
  subnets = [for name, config in var.subnets : {
    subnet_name           = "sb-${local.environment_code}-shared-base-${var.region}-${name}"
    subnet_ip             = config.subnet_ip
    subnet_region         = config.subnet_region
    subnet_private_access = config.subnet_private_access
    subnet_flow_logs      = tostring(var.subnetworks_enable_logging)
    description           = "A ${var.env} subnet in ${var.region} for ${name}."
  }]
  secondary_ranges = {
    for name, ranges in var.secondary_ranges :
    "sb-${local.environment_code}-shared-base-${var.region}-${name}" => [
      for range in ranges : {
        range_name    = "rn-${local.environment_code}-shared-base-${var.region}-${name}-${range.designation}"
        ip_cidr_range = range.ip_cidr_range
      }
    ]
  }
}

/******************************************
  VPC configuration
 *****************************************/

module "main" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 5.0"
  project_id                             = var.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = true
  delete_default_internet_gateway_routes = true
  description                            = "The ${var.env} VPC in ${var.region}"

  subnets          = local.subnets
  secondary_ranges = local.secondary_ranges

  routes = concat([
    {
      name              = "rt-${local.vpc_name}-1000-all-default-private-api"
      description       = "Route through Internet Gateway to allow private google api access."
      destination_range = local.private_googleapis_cidr
      next_hop_internet = true
      priority          = 1000
    },
    {
      name              = "rt-${local.vpc_name}-1000-egress-internet-default"
      description       = "Tag based route through Internet Gateway to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-internet"
      next_hop_internet = true
      priority          = 1000
    }
  ], var.routes)
}
