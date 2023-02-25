# Sample project to test kecloak identity brokering

## Local setup

1. Start the keycloak container with docker
   ```
   cd docker
   docker compose up -d
   cd ..
   ```
   Wait a bit until the keycloak container is up and running.
   It's ready when `docker logs -f keycloak_brokering` shows "Running the server in development mode. DO NOT use this configuration in production."
2. Set your local IP address by editing `terraform/_shared/globals/output.tf` 
   ```
   output "ip" {
     value = "192.168.178.42" # use your local IP here
   }

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

This example uses Postman and the default IP and Port from `terraform/_shared/globals/output.tf`.
If you changed those, edit the URLs blow accordingly.

1. Create a new request in Postman, e.g. GET http://192.168.178.42:8103/realms/user_facing/.well-known/openid-configuration
2. Setup OAuth 2.0 token for this request with these settings
   - Grant Type: Authorization Code
   - Callback URL: http://192.168.178.42:8103/realms/user_facing/.well-known/openid-configuration
   - Auth URL: http://192.168.178.42:8103/realms/user_facing/protocol/openid-connect/auth
   - Access Token URL: http://192.168.178.42:8103/realms/user_facing/protocol/openid-connect/token
   - Client ID: frontend
3. Get a token
   1. Click "Get New Access Token" in Postman
   2. In the window that opens click the "idp" button below "Or sign in with"
   3. Enter Username `user` and Password `user` and click the "Sign In" button
