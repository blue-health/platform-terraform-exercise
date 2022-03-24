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
  Deny Egress by default
 *****************************************/

resource "google_compute_firewall" "deny_all_egress" {
  name        = "fw-${local.environment_code}-shared-base-65535-e-d-all-all-all"
  description = "Deny all egress traffic by default"
  network     = module.main.network_name
  project     = var.project_id
  direction   = "EGRESS"
  priority    = 65535

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

/******************************************
  Allow traffic from internal Load Balancers
 *****************************************/

resource "google_compute_firewall" "allow_load_balancers" {
  name        = "fw-${local.environment_code}-shared-base-1000-i-a-all-allow-lb-tcp-80-8080-443"
  description = "Allow ingress from health checkers to common hosts within the network"
  network     = module.main.network_name
  project     = var.project_id
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = concat(
    data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4,
    data.google_netblock_ip_ranges.legacy_health_checkers.cidr_blocks_ipv4
  )

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  target_tags = ["allow-lb"]
}

/******************************************
  Allow traffic to private Google Services
 *****************************************/

resource "google_compute_firewall" "allow_private_api_egress" {
  name        = "fw-${local.environment_code}-shared-base-65532-e-a-all-allow-google-apis-tcp-443"
  description = "Allow egress to private google services"
  network     = module.main.network_name
  project     = var.project_id
  direction   = "EGRESS"
  priority    = 65532

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = [local.private_googleapis_cidr]

  target_tags = ["allow-private-api"]
}

/******************************************
  Deny egress to the network
 *****************************************/

resource "google_compute_firewall" "deny_all_network" {
  name        = "fw-${local.environment_code}-shared-base-65533-e-d-all-deny-egress-network-all"
  description = "Deny all egress traffic to the network by default"
  network     = module.main.network_name
  project     = var.project_id
  direction   = "EGRESS"
  priority    = 65533

  deny {
    protocol = "all"
  }

  destination_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]
}

/******************************************
  Allow tagged egress to the Internet
 *****************************************/

resource "google_compute_firewall" "allow_egress_internet" {
  name        = "fw-${local.environment_code}-shared-base-65534-e-a-allow-egress-internet-all"
  description = "Allow tagged egress to the Internet"
  network     = module.main.network_name
  project     = var.project_id
  direction   = "EGRESS"
  priority    = 65534

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]

  target_tags = ["egress-internet"]
}
