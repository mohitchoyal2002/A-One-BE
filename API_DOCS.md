# Shop Authentication API Documentation

This documentation details the API endpoints for User Authentication in the Shop Backend.

## Base URL
`/api/v1`

---

## 1. Sign Up
Creates a new user account using phone number.

**Endpoint:** `POST /signup`

**Request Body (JSON):**
```json
{
  "full_name": "John Doe",
  "phone_number": "1234567890",
  "address": "123 Main St, Springfield",
  "password": "securepassword123"
}
```

**Fields:**
- `full_name`: (string, required) User's full name.
- `phone_number`: (string, required) Unique phone number.
- `address`: (string, required) User's address.
- `password`: (string, required) User's password.
- `email`: (string, optional) User's email address.

**Success Response (201 Created):**
```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "full_name": "John Doe",
    "phone_number": "1234567890",
    "address": "123 Main St, Springfield",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "errors": [
    "Phone number has already been taken"
  ]
}
```

---

## 2. Sign In
Authenticates a user using either Email or Phone Number.

**Endpoint:** `POST /signin`

**Request Body (Option 1: Phone Number):**
```json
{
  "phone_number": "1234567890",
  "password": "securepassword123"
}
```

**Request Body (Option 2: Email):**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Logged in successfully",
  "user": {
    "id": 1,
    "full_name": "John Doe",
    "phone_number": "1234567890",
    "email": "user@example.com",
    "address": "123 Main St, Springfield",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid credentials"
}
```
