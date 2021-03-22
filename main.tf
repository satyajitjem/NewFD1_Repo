/**
 * frontdoor
 * ===========
 * The module creates
 *
 * EXAMPLE
 * -------
 *
 * ```hcl
 * ```
 */
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
  health_probe_name     = "${var.name}-backend-health"
  load_balancing_name   = "${var.name}-backend-api-lb"
}

resource "azurerm_frontdoor" "front-door" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  enforce_backend_pools_certificate_name_check = var.backend_cert_check

  frontend_endpoint {
    name                                    = "${var.name}"
    host_name                               = "${var.name}.azurefd.net"
    custom_https_provisioning_enabled       = var.custom_https
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.wafpolicy.id
  }

  backend_pool_load_balancing {
    name = "${local.load_balancing_name}"
  }

  backend_pool_health_probe {
    name     = "${local.health_probe_name}"
    protocol = "${var.backend_protocol_health}"
  }

  dynamic "backend_pool" {
    for_each = var.backend_pools
    iterator = pool
    content {
        name                = lookup(pool.value, "name")
        load_balancing_name = local.load_balancing_name
        health_probe_name   = local.health_probe_name
        dynamic "backend" {
          for_each = lookup(pool.value, "backends", [])
          iterator = backend

          content {
            address           = lookup(backend.value, "backend_address")
            host_header       = lookup(backend.value, "backend_address")
            http_port         = lookup(backend.value, "backend_http_port")
            https_port        = lookup(backend.value, "backend_https_port")
            priority          = lookup(backend.value, "priority")
          }
        }
      }
    }

  dynamic "routing_rule" {
    for_each = var.routing_rules
    iterator = rules
    content {
        name               = lookup(rules.value, "name")
        accepted_protocols = lookup(rules.value, "accepted_protocols")
        patterns_to_match  = lookup(rules.value, "patterns_to_match")
        frontend_endpoints = lookup(rules.value, "frontend_endpoints")

        dynamic "forwarding_configuration" {
          for_each = lookup(rules.value, "forwarding_configuration", [])
          iterator = f_conf

          content {
            forwarding_protocol = lookup(f_conf.value, "forwarding_protocol")
            backend_pool_name   = lookup(f_conf.value, "backend_pool_name")
            }
          }

        dynamic "redirect_configuration" {
          for_each = lookup(rules.value, "redirect_configuration", [])
          iterator = r_conf

          content {
            redirect_protocol  = lookup(r_conf.value, "redirect_protocol")
            redirect_type      = lookup(r_conf.value, "redirect_type")
            //Hack - TF errors if custom_host is not set despite being an optional var
            custom_host        = "${var.name}.azurefd.net"
            }
        }
      }
  }
}
