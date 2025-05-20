# User Management Database Setup

hey read this first!  
if u wondering why my code is error, maybe u forget to make sure the SQL configuration is the same, don't ask questions, keep focusing!  
This project includes a basic user table schema for managing user data, such as names, emails, and passwords. It also includes `barang`, `invoice`, and `invoice_detail` tables for basic e-commerce logic.

---

## 📋 Table Structure

### `users` Table

| Field    | Type         | Null | Key | Default           | Extra          |
|----------|--------------|------|-----|-------------------|----------------|
| id       | INT          | NO   | PRI | NULL              | auto_increment |
| nama     | VARCHAR(100) | NO   |     | NULL              |                |
| email    | VARCHAR(100) | NO   | UNI | NULL              |                |
| password | VARCHAR(255) | NO   |     | NULL              |                |
| created_at | DATETIME   | YES  |     | CURRENT_TIMESTAMP |                |
| role     | ENUM         | YES  |     | 'user'            |                |

---

## 🛠️ How to Use

To use this structure in your own MySQL or MariaDB setup, follow these steps:

1. Open your MySQL client or admin tool (e.g., phpMyAdmin, MySQL Workbench).
2. Run the following SQL script:

```sql
-- Create the database
CREATE DATABASE IF NOT EXISTS nugas_db;

USE nugas_db;

-- Create table: users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    role ENUM('admin', 'user') DEFAULT 'user'
);

-- Create table: barang
CREATE TABLE IF NOT EXISTS barang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga DECIMAL(10,2) NOT NULL,
    stok INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    gambar VARCHAR(255)
);

-- Create table: invoice
CREATE TABLE IF NOT EXISTS invoice (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user INT,
    nama_penerima VARCHAR(100),
    alamat TEXT,
    metode VARCHAR(50),
    total DECIMAL(10,2),
    tanggal DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'paid', 'shipped', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (user) REFERENCES users(id)
);

-- Create table: invoice_detail
CREATE TABLE IF NOT EXISTS invoice_detail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT,
    barang_id INT,
    nama_barang VARCHAR(100),
    harga DECIMAL(10,2),
    qty INT,
    subtotal DECIMAL(10,2),
    FOREIGN KEY (invoice_id) REFERENCES invoice(id),
    FOREIGN KEY (barang_id) REFERENCES barang(id)
);
