variable "name" {}
variable "location" {}
variable "resource_group_name" {}


// Frontdoor
variable "backend_cert_check" {
  description = "Check for a valid cert on the backend"
  type = bool
  default = false
}

variable "custom_https" {
  description = ""
  type = bool
  default = false
}

variable "backend_protocol_health" {
  description = "Protocol for backend health check"
  default = "Https"
}

variable "backend_pools" {
  description = "API Backends"
  type        = list
  default = []
}

variable "routing_rules" {
  description = "Routing rules to forward to API backend"
  type        = list
  default = []
}


// WAF
variable waf_enabled {
  type = bool
  default = false
}
variable waf_mode {
  description = "Actively prevent or log and detect"
  default = "Detection"
}
variable block_response_code {
  description = "HTTP response code when blocked"
  type = number
  default = 403
}
variable block_response_body {
  description = "Body of HTML block response"
  // Base64 encode
  default = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkJsb2NrZWQ8L3RpdGxlPjwvaGVhZGVyPgogPHN0eWxlPgouY2VudGVyIHsKICBtYXJnaW46IDA7CiAgcG9zaXRpb246IGFic29sdXRlOwogIHRvcDogNTAlOwogIGxlZnQ6IDUwJTsKICAtbXMtdHJhbnNmb3JtOiB0cmFuc2xhdGUoLTUwJSwgLTUwJSk7CiAgdHJhbnNmb3JtOiB0cmFuc2xhdGUoLTUwJSwgLTUwJSk7Cn0KPC9zdHlsZT4KPGJvZHkgYmdjb2xvcj0iI2NjOTk5OSI+CjxkaXYgY2xhc3M9ImNvbnRhaW5lciI+CiAgPGRpdiBjbGFzcz0iY2VudGVyIj4KICAgIDxoMT5CbG9ja2VkPC9oMT4KICA8L2Rpdj4KPC9kaXY+CjwvYm9keT4KPC9odG1sPgo="
}

variable "custom_rules" {
  description = "Custom WAF Ruleset"
  type        = list

  default = [
    {
      name                  = "IPBlacklist"
      enabled               = false
      priority              = 1
      type                  = "MatchRule"
      action                = "Block"
      match_variable        = "RemoteAddr"
      operator              = "IPMatch"
      match_values          = ["10.0.0.0"]
    },
  ]
}
