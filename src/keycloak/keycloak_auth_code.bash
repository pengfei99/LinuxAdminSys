#!/bin/bash

# This script will perform the following steps:
#
# 1. Initialize variables and functions.
# 2. Prompt for the user's password.
# 3. Obtain the authentication URL from Keycloak.
# 4. Send username and password to Keycloak to receive a code URL.
# 5. Extract the code from the received URL.
# 6. Send the code to Keycloak to receive the Access Token.
# 7. Decode and display the Access Token.
# 8. Clean up the cookie file used for authentication.

# Initialize variables
init() {
    KEYCLOAK_URL="https://keycloak.casd.local"
    REDIRECT_URL="http://localhost:8080"
    USERNAME="jsnow"
    REALM="Data-catalog"
    CLIENTID="open-metadata"
}

# Function to decode the access token
decode() {
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}

# Prompt for password
read -rp "Password: " -s PASSWORD
echo " "

# Initialize
init

# Cookie file path
COOKIE="$(pwd)/cookie.jar"

# Step 1: Obtain the authentication URL
AUTHENTICATE_URL=$(curl -sSL --get --cookie "$COOKIE" --cookie-jar "$COOKIE" \
    --data-urlencode "client_id=${CLIENTID}" \
    --data-urlencode "redirect_uri=${REDIRECT_URL}" \
    --data-urlencode "scope=openid" \
    --data-urlencode "response_type=code" \
    "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/auth" | pup "form#kc-form-login attr{action}")

# Convert &amp; to &
AUTHENTICATE_URL=$(echo "$AUTHENTICATE_URL" | sed -e 's/\&amp;/\&/g')

echo "Sending Username Password to the following authentication URL of Keycloak: $AUTHENTICATE_URL"
echo " "

# Step 2: Obtain the code URL
CODE_URL=$(curl -sS --cookie "$COOKIE" --cookie-jar "$COOKIE" \
    --data-urlencode "username=$USERNAME" \
    --data-urlencode "password=$PASSWORD" \
    --write-out "%{REDIRECT_URL}" \
    "$AUTHENTICATE_URL")

echo "Following URL with code received from Keycloak: $CODE_URL"
echo " "

# Extract code from URL
code=$(echo "$CODE_URL" | awk -F "code=" '{print $2}' | awk '{print $1}')

echo "Extracted code: $code"
echo " "

echo "Sending code=$code to Keycloak to receive Access token"
echo " "

# Step 3: Obtain the Access Token
ACCESS_TOKEN=$(curl -sS --cookie "$COOKIE" --cookie-jar "$COOKIE" \
    --data-urlencode "client_id=$CLIENTID" \
    --data-urlencode "redirect_uri=$REDIRECT_URL" \
    --data-urlencode "code=$code" \
    --data-urlencode "grant_type=authorization_code" \
    "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" | jq -r ".access_token")

echo " "

# Print decoded Access Token
echo "Decoded Access Token: "
decode "$ACCESS_TOKEN"

# Clean up the cookie file
rm "$COOKIE"
