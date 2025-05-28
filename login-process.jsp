<%@ page import="java.sql.*, java.io.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Ambil data form login
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  
  // Debug info
  System.out.println("==========================================");
  System.out.println("Login Process - Email/Password Authentication");
  System.out.println("Email: " + email);
  System.out.println("Password: [HIDDEN]");
  
  if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
    System.out.println("Login failed: Missing email or password");
    response.sendRedirect("login.html?error=missing_fields");
    return;
  }
  
  Connection conn = null;
  try {
    // Koneksi ke database
    Class.forName("com.mysql.cj.jdbc.Driver");
    System.out.println("JDBC Driver loaded successfully");
    
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    System.out.println("Database connection established");
    
    // Query untuk memeriksa user
    String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setString(1, email);
    ps.setString(2, password);
    
    System.out.println("Executing query to check user credentials");
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
      // Login berhasil
      int userId = rs.getInt("id");
      String userName = rs.getString("nama");
      String userRole = rs.getString("role");
      String photoUrl = rs.getString("profile_photo");
      
      System.out.println("Login successful!");
      System.out.println("User ID: " + userId);
      System.out.println("User Name: " + userName);
      System.out.println("User Role: " + userRole);
      
      // Set session
      session.setAttribute("user", userName);
      session.setAttribute("userId", userId);
      session.setAttribute("userEmail", email);
      if (photoUrl != null && !photoUrl.isEmpty()) {
        session.setAttribute("userPhotoUrl", photoUrl);
      }
      
      // Redirect berdasarkan role
      if ("admin".equalsIgnoreCase(userRole)) {
        System.out.println("Redirecting to admin page (welcome.jsp)");
        response.sendRedirect("welcome.jsp");
      } else {
        System.out.println("Redirecting to user page (welcome.jsp)");
        response.sendRedirect("welcome.jsp");
      }
    } else {
      // Login gagal
      System.out.println("Login failed: Invalid credentials for email " + email);
      response.sendRedirect("login.html?error=invalid_credentials");
    }
    
    rs.close();
    ps.close();
    
  } catch (Exception e) {
    System.out.println("ERROR during login: " + e.getMessage());
    e.printStackTrace();
    response.sendRedirect("login.html?error=" + e.getMessage());
  } finally {
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
    System.out.println("==========================================");
  }
%>
