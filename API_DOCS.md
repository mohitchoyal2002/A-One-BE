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
    "reward_points": 100,
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
    "email": "user@example.com",
    "address": "123 Main St, Springfield",
    "reward_points": 100,
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

---

## 3. Product Listing
Fetch all products.

**Endpoint:** `GET /products`

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Product Name",
    "price": "99.99",
    "discount": "10.0",
    "description": "Product Description",
    "created_at": "2026-01-18T21:49:37.000Z",
    "updated_at": "2026-01-18T21:49:37.000Z",
    "product_images": [
      {
        "id": 1,
        "image_url": "http://example.com/image.jpg",
        "product_id": 1,
        ...
      }
    ]
  }
]
```

---

## 4. Product Details
Fetch a single product by ID.

**Endpoint:** `GET /products/:id`

**Success Response (200 OK):**
```json
{
  "id": 1,
  "name": "Product Name",
  "price": "99.99",
  "discount": "10.0",
  "description": "Product Description",
  "created_at": "2026-01-18T21:49:37.000Z",
  "updated_at": "2026-01-18T21:49:37.000Z",
  "product_images": [
    {
      "id": 1,
      "image_url": "http://example.com/image.jpg",
      "product_id": 1,
      ...
    }
  ]
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Product not found"
}
```

---

## 5. Create Reward Application
Creates a new reward application for a user.

**Endpoint:** `POST /reward_applications`

**Request Body (JSON):**
```json
{
  "reward_application": {
    "user_id": 1,
    "title": "My Reward Application",
    "reward_application_items_attributes": [
      {
        "product_id": 1,
        "price": 99.99
      },
      {
        "product_id": 2,
        "price": 49.50,
        "quantity": 2
      }
    ]
  }
}
```

**Fields:**
- `user_id`: (integer, required) The ID of the user creating the application.
- `title`: (string, required) The title of the application.
- `reward_application_items_attributes`: (array, required) List of products associated with the application.
  - `product_id`: (integer, required) The ID of the product.
  - `price`: (decimal, required) The price of the product at purchase time.
  - `quantity`: (integer, optional) Quantity of the product (default: 1).

**Success Response (201 Created):**
```json
{
  "id": 1,
  "user_id": 1,
  "title": "My Reward Application",
  "status": "in_progress",
  "created_at": "...",
  "updated_at": "..."
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "title": [
    "can't be blank"
  ]
}
```

---

## 6. List Reward Applications
Fetch all reward applications for a specific user.

**Endpoint:** `GET /reward_applications`

**Query Parameters:**
- `user_id`: (integer, required) The ID of the user whose applications you want to list.

**Example Request:**
`GET /reward_applications?user_id=1`

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "title": "My Reward Application",
    "status": "in_progress",
    "created_at": "...",
    "updated_at": "...",
    "reward_application_items": [
      {
        "id": 1,
        "reward_application_id": 1,
        "product_id": 1,
        "price": "99.99",
        "quantity": 1,
        "total_price": "99.99",
        "created_at": "...",
        "updated_at": "..."
      }
    ]
  }
]
```
