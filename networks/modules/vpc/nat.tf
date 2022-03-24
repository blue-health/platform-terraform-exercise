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

/******************************************
  Cloud NAT configuration
 *****************************************/

resource "google_compute_address" "nat_external_addresses" {
  project     = var.project_id
  name        = "ca-nat-external-${local.vpc_name}-${var.region}-${count.index}"
  description = "External IP address No. ${count.index} for Cloud NAT cr-nat-${local.vpc_name}-${var.region}"
  count       = var.nat_enabled ? var.nat_num_addresses : 0
  region      = var.region
}

module "cloud_nat_router" {
  source      = "terraform-google-modules/cloud-router/google"
  version     = "~> 1.3.0"
  count       = var.nat_enabled ? 1 : 0
  name        = "cr-nat-${local.vpc_name}-${var.region}"
  description = "The Cloud NAT router for network ${local.vpc_name} in ${var.region}"
  project     = var.project_id
  region      = var.region
  network     = module.main.network_self_link
  nats = [
    {
      name             = "cn-${local.vpc_name}-${var.region}"
      nat_ips          = google_compute_address.nat_external_addresses.*.self_link
      min_ports_per_vm = 32
    }
  ]
}
