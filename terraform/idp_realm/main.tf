module "globals" {
  source = "../_shared/globals"
}

module "realm" {
  source = "../_shared/realm_setup"

  realm_name = "identity_provider"
}

resource "keycloak_openid_client" "openid_client" {
  realm_id  = module.realm.realm.id
  client_id = "idp_client"

  enabled                  = true
  access_type              = "CONFIDENTIAL"
  client_secret            = "zBDg8ehQ0mHcxfNQgMdnYMdD3Zg35SEq"
  admin_url                = "http://${module.globals.ip}:${module.globals.port}/realms/user_facing/broker/idp/endpoint"
  service_accounts_enabled = true
  standard_flow_enabled    = true
  valid_redirect_uris      = [
    "http://${module.globals.ip}:${module.globals.port}/realms/user_facing/broker/idp/endpoint"
  ]
  login_theme = "keycloak"
}

resource "keycloak_user" "user" {
  realm_id = module.realm.realm.id
  username = "user"
  enabled  = true

  email = "user@example.com"

  initial_password {
    value     = "user"
    temporary = false
  }
}
