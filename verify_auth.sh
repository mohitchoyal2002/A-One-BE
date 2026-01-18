#!/bin/bash

# Configuration
BASE_URL="http://localhost:3000/api/v1"
TIMESTAMP=$(date +%s)
FULL_NAME="User_$TIMESTAMP"
PHONE="555$TIMESTAMP"
EMAIL="test$TIMESTAMP@example.com"
ADDRESS="123 Test Lane"
PASSWORD="password123"

echo "---------------------------------------------------"
echo "Testing Sign Up (with Phone)..."
echo "---------------------------------------------------"
SIGNUP_PAYLOAD=$(cat <<EOF
{
  "full_name": "$FULL_NAME",
  "phone_number": "$PHONE",
  "address": "$ADDRESS",
  "email": "$EMAIL",
  "password": "$PASSWORD"
}
EOF
)
SIGNUP_RESPONSE=$(curl -s -X POST "$BASE_URL/signup" \
  -H "Content-Type: application/json" \
  -d "$SIGNUP_PAYLOAD")

echo "Response: $SIGNUP_RESPONSE"
echo "$SIGNUP_RESPONSE" | grep -q "User created successfully" && echo "✅ Sign Up Successful" || echo "❌ Sign Up Failed"
echo ""

echo "---------------------------------------------------"
echo "Testing Sign In (with Phone)..."
echo "---------------------------------------------------"
SIGNIN_PHONE_RESPONSE=$(curl -s -X POST "$BASE_URL/signin" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\", \"password\": \"$PASSWORD\"}")

echo "Response: $SIGNIN_PHONE_RESPONSE"
echo "$SIGNIN_PHONE_RESPONSE" | grep -q "Logged in successfully" && echo "✅ Sign In (Phone) Successful" || echo "❌ Sign In (Phone) Failed"
echo ""

echo "---------------------------------------------------"
echo "Testing Sign In (with Email)..."
echo "---------------------------------------------------"
SIGNIN_EMAIL_RESPONSE=$(curl -s -X POST "$BASE_URL/signin" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}")

echo "Response: $SIGNIN_EMAIL_RESPONSE"
echo "$SIGNIN_EMAIL_RESPONSE" | grep -q "Logged in successfully" && echo "✅ Sign In (Email) Successful" || echo "❌ Sign In (Email) Failed"
echo ""

echo "---------------------------------------------------"
echo "Testing Sign In (Invalid)..."
echo "---------------------------------------------------"
FAIL_RESPONSE=$(curl -s -X POST "$BASE_URL/signin" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\", \"password\": \"wrongpassword\"}")

echo "Response: $FAIL_RESPONSE"
echo "$FAIL_RESPONSE" | grep -q "Invalid credentials" && echo "✅ Invalid Login Check Successful" || echo "❌ Invalid Login Check Failed"
echo "---------------------------------------------------"
