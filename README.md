# Sample project to test keycloak identity brokering

## Local setup

1. Start the keycloak container with docker
   ```
   cd docker
   docker compose up -d
   cd ..
   ```
   Wait a bit until the keycloak container is up and running.
   It's ready when `docker logs -f keycloak_brokering` shows "Running the server in development mode. DO NOT use this configuration in production."
2. Change the local port if necessary by editing `terraform/_shared/globals/output.tf` 
   output "port" {
     value = "8103" # only change if you need/want a different port
   }
   ```
3. Create the realm that acts as an identity provider
   ```
   cd terraform/idp_realm
   terraform init
   terraform apply
   cd ../..
   ```
4. Create the realm that is used by the users
   ```
   cd terraform/user_facing_realm
   terraform init
   terraform apply
   cd ../..
   ```

## Test identity brokering

### API

This example uses Postman and the default IP and Port from `terraform/_shared/globals/output.tf`.
If you changed those, edit the URLs blow accordingly.

1. Create a new request in Postman, GET http://host.docker.internal:8103/realms/user_facing/broker/idp/token
2. Setup OAuth 2.0 token for this request with these settings
   - Grant Type: Authorization Code
   - Callback URL: https://oauth.pstmn.io/v1/callback
   - Auth URL: http://host.docker.internal:8103/realms/user_facing/protocol/openid-connect/auth
   - Access Token URL: http://host.docker.internal:8103/realms/user_facing/protocol/openid-connect/token
   - Client ID: frontend
3. Get a token
   1. Click "Get New Access Token" in Postman
   2. In the window that opens click the "idp" or "keycloak-idp" button below "Or sign in with"
   3. Enter Username `user` and Password `user` and click the "Sign In" button
4. Use this token to execute the request to get the original id_token of the identity provider
   1. Click "Proceed" after successful login
   2. Click "Use Token" after selecting the new token
   3. Click "Send" on the actual request

### Via browser

1. Open http://host.docker.internal:8103/realms/user_facing/account
2. Click "Sign in"
3. Click "idp" or "keycloak-idp" in the "Or sign in with" section
4. Enter "user" as both username and password and hit enter

And as admin, use "admin/admin" when opening http://localhost:8103/admin/master/console/

"idp" will import the roles of the "idp_realm" into the user attribute "group".
"keycloak-idp" will import the roles of the "idp_realm" into realm role assignments of the user.

To see the actual token that transfers the roles from realm "idp_realm" to "user_facing_realm" during the identity brokering
check the docker log.

## Further information

* https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs
