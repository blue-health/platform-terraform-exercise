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
  env          = "development"
  parent_id    = "organizations/${var.org_id}"
  project_name = "sample-vpc-project"
  project_id   = data.google_projects.network_project.projects[0].project_id
  /*
   * Please supply example subnet in the
   * RFC1918 address range, e.g 10.0.0.0/8
   */
  base_subnets = {}
  /*
   * Please supply example secondary ranges
   * for the subnet above. You can look for
   * hints at https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
   */
  base_subnet_secondary_ranges = {}
}

/******************************************
  Environment Project
 *****************************************/

data "google_active_folder" "env" {
  display_name = "${var.folder_prefix}-${local.env}"
  parent       = local.parent_id
}

/******************************************
  VPC Project
*****************************************/

data "google_projects" "network_project" {
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=${project_name} labels.environment=${local.env} lifecycleState=ACTIVE"
}

/******************************************
 Sample VPC - Virtual Private Cloud
*****************************************/

/*
 * Hint: if you're not familiar with Google
 * Terraform module, please check our this page:
 * https://registry.terraform.io/namespaces/terraform-google-modules
 * It contains the registry of the ones used in this exercise.
 */
module "sample_vpc" {
  source            = "../../modules/vpc"
  project_id        = local.project_id
  env               = local.env
  org_id            = var.org_id
  region            = var.region
  nat_enabled       = var.nat_enabled
  nat_num_addresses = var.nat_num_addresses
  subnets           = local.base_subnets
  secondary_ranges  = local.base_subnet_secondary_ranges
}
