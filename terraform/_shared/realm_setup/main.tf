resource "keycloak_realm" "realm" {
  realm   = var.realm_name
  enabled = true
}

resource "keycloak_user" "realmadmin" {
  realm_id = keycloak_realm.realm.id
  username = "realm-admin"
  enabled  = true

  email = "realmadmin@example.com"

  initial_password {
    value     = "admin"
    temporary = false
  }
}

data "keycloak_openid_client" "realmmanagement" {
  realm_id  = keycloak_realm.realm.id
  client_id = "realm-management"
}

data "keycloak_role" "manage_auth" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "manage-authorization"
}

data "keycloak_role" "query_realms" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "query-realms"
}

data "keycloak_role" "view_auth" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "view-authorization"
}

data "keycloak_role" "view_clients" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "view-clients"
}

data "keycloak_role" "view_realm" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "view-realm"
}

data "keycloak_role" "view_users" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realmmanagement.id
  name      = "view-users"
}

resource "keycloak_user_roles" "realmadmin_roles" {
  realm_id = keycloak_realm.realm.id
  user_id  = keycloak_user.realmadmin.id

  role_ids = [
    data.keycloak_role.manage_auth.id,
    data.keycloak_role.query_realms.id,
    data.keycloak_role.view_auth.id,
    data.keycloak_role.view_clients.id,
    data.keycloak_role.view_realm.id,
    data.keycloak_role.view_users.id
  ]
}
