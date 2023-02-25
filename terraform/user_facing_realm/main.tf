module "globals" {
  source = "../_shared/globals"
}

module "realm" {
  source = "../_shared/realm_setup"

  realm_name = "user_facing"
}

resource "keycloak_oidc_identity_provider" "idp" {
  realm             = module.realm.realm.id
  alias             = "idp"
  client_id         = "idp_client"
  client_secret     = "zBDg8ehQ0mHcxfNQgMdnYMdD3Zg35SEq"
  authorization_url = "http://${module.globals.ip}:${module.globals.port}/realms/identity_provider/protocol/openid-connect/auth"
  token_url         = "http://${module.globals.ip}:${module.globals.port}/realms/identity_provider/protocol/openid-connect/token"

  hide_on_login_page            = false
  store_token                   = true
  add_read_token_role_on_create = true

  extra_config = {
    "clientAuthMethod" = "client_secret_post"
  }
}

resource "keycloak_openid_client" "frontend" {
  realm_id  = module.realm.realm.id
  client_id = "frontend"

  enabled               = true
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris   = [
    "https://oauth.pstmn.io/v1/callback",
    "http://${module.globals.ip}:${module.globals.port}/realms/${module.realm.realm.realm}/*"
  ]
  login_theme = "keycloak"
}
