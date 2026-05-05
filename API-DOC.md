
---

```markdown
# Zenit Backend API Documentation

Base URL:  
```

https://zenit-api-tuir.onrender.com
````

Authentication:  
All APIs require **Bearer Token (JWT)**

---

# 1. Authentication APIs

## Register
**POST /Accounts/register**

### Request
```json
{
  "username": "string",
  "email": "string",
  "phone": "string",
  "address": "string",
  "password": "string"
}
````

---

## Login

**POST /Accounts/login**

### Request

```json
{
  "email": "string",
  "password": "string"
}
```

---

## Get Current User

**GET /Accounts/me**

---

## Update Profile

**PATCH /Accounts/me**

```json
{
  "phone": "string",
  "address": "string"
}
```

---

## Delete Account

**DELETE /Accounts/me**

---

## Send OTP

**POST /Accounts/send-otp**

```json
{
  "email": "string"
}
```

---

## Verify OTP

**POST /Accounts/verify-otp**

```json
{
  "email": "string",
  "otp": "string"
}
```

---

## Reset Password

**POST /Accounts/reset-password**

```json
{
  "resetToken": "string",
  "newPassword": "string"
}
```

---

# 2. Wallet APIs

## Data Model

```json
{
  "id": "UUID",
  "name": "string",
  "amount": "int",
  "backgroundColor": "string",
  "icon": "string",
  "note": "string",
  "isIncludeInTotalBalance": "boolean"
}
```

---

## Create Wallet

**POST /Wallets**

```json
{
  "name": "string",
  "amount": 100000,
  "backgroundColor": "#FFFFFF",
  "icon": "wallet",
  "note": "string",
  "isIncludeInTotalBalance": true
}
```

---

## Get Wallets

**GET /Wallets**

### Query Params

* `Search`
* `BeforeId`
* `PageSize` (required)
* `UseCountTotal`

---

## Get Wallet Detail

**GET /Wallets/{id}**

---

## Update Wallet

**PATCH /Wallets/{id}**

```json
{
  "id": "UUID",
  "name": "string",
  "amount": 200000,
  "note": "string"
}
```

---

## Delete Wallet

**DELETE /Wallets/{id}**

---

# 3. Money Transfer APIs

## Data Model

```json
{
  "id": "UUID",
  "fromWalletId": "UUID",
  "toWalletId": "UUID",
  "amount": "int",
  "transferDate": "datetime",
  "note": "string"
}
```

---

## Create Transfer

**POST /MoneyTransfer**

```json
{
  "fromWalletId": "UUID",
  "toWalletId": "UUID",
  "amount": 500000,
  "transferDate": "2025-01-01T10:00:00",
  "note": "string"
}
```

---

## Get Transfers

**GET /MoneyTransfer**

### Query Params

* `FromDate`
* `ToDate`
* `Search`
* `BeforeId`
* `PageSize` (required)
* `UseCountTotal`

---

## Get Transfer Detail

**GET /MoneyTransfer/{id}**

---

## Update Transfer

**PATCH /MoneyTransfer/{id}**

```json
{
  "id": "UUID",
  "amount": 700000,
  "note": "string"
}
```

---

## Delete Transfer

**DELETE /MoneyTransfer/{id}**

---

# 4. Transaction APIs

## Create Transaction

**POST /Transactions**

```json
{
  "title": "string",
  "note": "string",
  "amount": 100000,
  "transactionDate": "datetime",
  "categoryId": "UUID"
}
```

---

## Get Transactions

**GET /Transactions**

### Query Params

* `FromDate`
* `ToDate`
* `CategoryId`
* `Search`
* `BeforeId`
* `PageSize` (required)
* `UseCountTotal`

---

## Get Transaction Detail

**GET /Transactions/{id}**

---

## Update Transaction

**PATCH /Transactions/{id}**

```json
{
  "id": "UUID",
  "amount": 200000,
  "note": "string"
}
```

---

## Delete Transaction

**DELETE /Transactions/{id}**

---

## Create Multiple Transactions

**POST /Transactions/many**

```json
{
  "transactions": [
    {
      "title": "string",
      "amount": 100000,
      "transactionDate": "datetime",
      "categoryId": "UUID"
    }
  ]
}
```

---

## Update Multiple Transactions

**PATCH /Transactions**

```json
{
  "transactions": [
    {
      "id": "UUID",
      "amount": 200000
    }
  ]
}
```

---

# 5. Category APIs

## Create Category

**POST /Categories**

```json
{
  "name": "string",
  "icon": "string",
  "color": "string",
  "backgroundColor": "string",
  "expenseLimit": 1000000,
  "expenseAlertThreshold": 0.8,
  "groupType": 0
}
```

---

## Get Categories

**GET /Categories**

### Query Params

* `groupType`

---

## Get Category Detail

**GET /Categories/{id}**

---

## Update Category

**PATCH /Categories/{id}**

```json
{
  "id": "UUID",
  "name": "string"
}
```

---

## Delete Category

**DELETE /Categories/{id}**

---

## Delete Multiple Categories

**DELETE /Categories**

```json
{
  "ids": ["UUID"]
}
```

---

# 6. Statistics APIs

## Get Statistics

**GET /Statistics**

### Query Params

* `From`
* `To`

---

## Generate Report

**POST /Statistics/reports**

### Query Params

* `FromDate` (required)
* `ToDate` (required)

---

# 7. Notes

* All endpoints return `200 OK` on success
* Pagination uses cursor-based (`BeforeId`)
* All IDs are UUID format
* DateTime uses ISO 8601 format

---
