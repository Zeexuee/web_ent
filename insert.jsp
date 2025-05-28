<%@ page import="java.sql.*, java.io.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head >
    <title>Registrasi</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow">
        <div class="card-body">

<%
  // Ambil data form pendaftaran
  String nama = request.getParameter("nama");
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  
  // Debug info
  System.out.println("==========================================");
  System.out.println("Registration Process - Email/Password Registration");
  System.out.println("Nama: " + nama);
  System.out.println("Email: " + email);
  System.out.println("Password: [HIDDEN]");
  
  if (nama == null || email == null || password == null || 
      nama.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
    System.out.println("Registration failed: Missing required fields");
    response.sendRedirect("form.html?error=missing_fields");
    return;
  }
  
  Connection conn = null;
  try {
    // Koneksi ke database
    Class.forName("com.mysql.cj.jdbc.Driver");
    System.out.println("JDBC Driver loaded successfully");
    
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    System.out.println("Database connection established");
    
    // Cek apakah email sudah terdaftar
    PreparedStatement checkPs = conn.prepareStatement("SELECT * FROM users WHERE email = ?");
    checkPs.setString(1, email);
    
    System.out.println("Checking if email already exists");
    ResultSet checkRs = checkPs.executeQuery();
    
    if (checkRs.next()) {
      // Email sudah terdaftar
      System.out.println("Registration failed: Email " + email + " already registered");
      response.sendRedirect("form.html?error=email_exists");
      return;
    }
    
    // Email belum terdaftar, lanjutkan pendaftaran
    String sql = "INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)";
    PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
    ps.setString(1, nama);
    ps.setString(2, email);
    ps.setString(3, password);
    ps.setString(4, "user"); // Default role adalah user
    
    System.out.println("Executing registration query");
    int rowsInserted = ps.executeUpdate();
    System.out.println("Registration completed: " + rowsInserted + " rows affected");
    
    // Ambil ID yang baru dibuat
    ResultSet generatedKeys = ps.getGeneratedKeys();
    int userId = -1;
    if (generatedKeys.next()) {
      userId = generatedKeys.getInt(1);
      System.out.println("New user ID: " + userId);
    }
    
    // Redirect ke halaman login
    System.out.println("Registration successful! Redirecting to login page");
    response.sendRedirect("login.html?success=registration_complete");
    
  } catch (Exception e) {
    System.out.println("ERROR during registration: " + e.getMessage());
    e.printStackTrace();
    response.sendRedirect("form.html?error=" + e.getMessage());
  } finally {
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
    System.out.println("==========================================");
  }
%>

            <a href="form.html" class="btn btn-primary mt-3">Kembali ke Form</a>
        </div>
    </div>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
