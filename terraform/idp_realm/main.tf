module "globals" {
  source = "../_shared/globals"
}

module "realm" {
  source = "../_shared/realm_setup"

  realm_name = "identity_provider"
}

resource "keycloak_openid_client" "idp_client" {
  realm_id  = module.realm.realm.id
  client_id = "idp_client"

  description              = "Will be used to map roles to user attribute 'group' in target realm"
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  client_secret            = "zBDg8ehQ0mHcxfNQgMdnYMdD3Zg35SEq"
  admin_url                = "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/idp/endpoint"
  full_scope_allowed       = false
  service_accounts_enabled = true
  standard_flow_enabled    = true
  valid_redirect_uris      = [
    "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/idp/endpoint"
  ]
  login_theme = "keycloak"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "idp_group_attribute_to_roles_mapper" {
  realm_id  = module.realm.realm.id
  client_id = keycloak_openid_client.idp_client.id
  name      = "group_attribute_to_roles_mapper"

  user_attribute      = "group"
  claim_name          = "realm_access.roles"
  multivalued         = true
  add_to_access_token = true
}

resource "keycloak_openid_client" "keycloak_client" {
  realm_id  = module.realm.realm.id
  client_id = "keycloak_client"

  description              = "Will be used to map roles to realm roles in target realm"
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  client_secret            = "zBDg8ehQ0mHcxfNQgMdnYMdD3Zg35SEq"
  admin_url                = "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/keycloak-idp/endpoint"
  full_scope_allowed       = false
  service_accounts_enabled = true
  standard_flow_enabled    = true
  valid_redirect_uris      = [
    "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/keycloak-idp/endpoint"
  ]
  login_theme = "keycloak"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "keycloak_group_attribute_to_roles_mapper" {
  realm_id  = module.realm.realm.id
  client_id = keycloak_openid_client.keycloak_client.id
  name      = "group_attribute_to_roles_mapper"

  user_attribute      = "group"
  claim_name          = "realm_access.roles"
  multivalued         = true
  add_to_access_token = true
}

resource "keycloak_openid_client" "jwks_client" {
  realm_id  = module.realm.realm.id
  client_id = "jwks_client"

  description               = "Uses client auth with realm key of target realm"
  enabled                   = true
  access_type               = "CONFIDENTIAL"
  client_authenticator_type = "client-jwt"
  admin_url                 = "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/jwks-idp/endpoint"
  full_scope_allowed        = false
  service_accounts_enabled  = true
  standard_flow_enabled     = true
  valid_redirect_uris = [
    "http://host.docker.internal:${module.globals.port}/realms/user_facing/broker/jwks-idp/endpoint"
  ]
  login_theme = "keycloak"

  extra_config = {
    "token.endpoint.auth.signing.alg" = "RS256"
    "jwks.url"                        = "http://host.docker.internal:${module.globals.port}/realms/user_facing/protocol/openid-connect/certs"
    "use.jwks.url"                    = true
  }
}

resource "keycloak_openid_user_attribute_protocol_mapper" "jwks_group_attribute_to_roles_mapper" {
  realm_id  = module.realm.realm.id
  client_id = keycloak_openid_client.jwks_client.id
  name      = "group_attribute_to_roles_mapper"

  user_attribute      = "group"
  claim_name          = "realm_access.roles"
  multivalued         = true
  add_to_access_token = true
}

resource "keycloak_user" "user" {
  realm_id = module.realm.realm.id
  username = "user"
  enabled  = true

  email      = "user@example.com"
  first_name = "John"
  last_name  = "Doe"

  attributes = {
    group = "dyngrp1_role1##dyngrp1_role2##dyngrp2_role1"
  }

  initial_password {
    value     = "user"
    temporary = false
  }
}
