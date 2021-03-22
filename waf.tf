resource "azurerm_frontdoor_firewall_policy" "wafpolicy" {
  //TODO: Fix name standard
  // "Policy name must start with a letter and contain only numbers and letters\"."
  name                              = "wafpolicy"
  resource_group_name               = "${var.resource_group_name}"
  enabled                           = "${var.waf_enabled}"
  mode                              = "${var.waf_mode}"
#  redirect_url                      = "https://www.google.com"
  custom_block_response_status_code = "${var.block_response_code}"
  custom_block_response_body        = "${var.block_response_body}"

  dynamic "custom_rule" {
    for_each = var.custom_rules
    iterator = rule
    content {
      name                 = lookup(rule.value, "name")
      enabled              = lookup(rule.value, "enabled", null)
      priority             = lookup(rule.value, "priority")
      type                 = lookup(rule.value, "type")
      action               = lookup(rule.value, "action")

      match_condition {
        match_variable     = lookup(rule.value, "match_variable")
        operator           = lookup(rule.value, "operator")
        match_values       = lookup(rule.value, "match_values")
      }
    }
  }

  //TODO: Split out to default dict
  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
  }

}
