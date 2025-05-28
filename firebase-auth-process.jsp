<!-- filepath: d:\Campus\Kelas\Kelas - Enterprise\WebApplication2\web\firebase-auth-process.jsp -->
<%@ page import="java.sql.*, java.io.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Ambil data yang dikirim dari client-side setelah autentikasi Firebase
  String firebaseUid = request.getParameter("firebaseUid");
  String displayName = request.getParameter("displayName");
  String email = request.getParameter("email");
  String photoURL = request.getParameter("photoURL");
  
  // Debug info
  System.out.println("Firebase Auth Process - Data received:");
  System.out.println("Firebase UID: " + firebaseUid);
  System.out.println("Display Name: " + displayName);
  System.out.println("Email: " + email);
  System.out.println("Photo URL: " + photoURL);
  
  if (firebaseUid == null || email == null) {
    System.out.println("Missing data - redirecting to login page");
    response.sendRedirect("login.html?error=missing_data");
    return;
  }
  
  Connection conn = null;
  try {
    // Koneksi ke database
    Class.forName("com.mysql.cj.jdbc.Driver");
    System.out.println("JDBC Driver loaded successfully");
    
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    System.out.println("Database connection established");
    
    // Cek apakah user sudah ada di database (berdasarkan firebase_uid atau email)
    PreparedStatement checkPs = conn.prepareStatement("SELECT * FROM users WHERE firebase_uid = ? OR email = ?");
    checkPs.setString(1, firebaseUid);
    checkPs.setString(2, email);
    
    System.out.println("Executing query to check if user exists");
    ResultSet rs = checkPs.executeQuery();
    
    if (rs.next()) {
      // User sudah ada, update data jika perlu
      int userId = rs.getInt("id");
      System.out.println("User found in database, ID: " + userId);
      
      String sql = "UPDATE users SET nama = ?, email = ?, profile_photo = ?, firebase_uid = ? WHERE id = ?";
      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setString(1, displayName);
      ps.setString(2, email);
      ps.setString(3, photoURL);
      ps.setString(4, firebaseUid);
      ps.setInt(5, userId);
      
      System.out.println("Executing update query");
      int rowsUpdated = ps.executeUpdate();
      System.out.println("Update completed: " + rowsUpdated + " rows affected");
      
      // Set session dan redirect
      System.out.println("Setting session attributes");
      session.setAttribute("user", displayName);
      session.setAttribute("userId", userId);
      session.setAttribute("userEmail", email);
      session.setAttribute("userPhotoUrl", photoURL);
      
      // Cek role untuk redirect yang sesuai
      String role = rs.getString("role");
      System.out.println("User role: " + role);
      
      if ("admin".equalsIgnoreCase(role)) {
        System.out.println("Redirecting to admin page");
        response.sendRedirect("welcome.jsp");
      } else {
        System.out.println("Redirecting to welcome page");
        response.sendRedirect("welcome.jsp");
      }
      
    } else {
      // User belum ada, tambahkan user baru
      System.out.println("User not found, creating new user");
      
      String sql = "INSERT INTO users (nama, email, password, firebase_uid, profile_photo, role) VALUES (?, ?, ?, ?, ?, ?)";
      PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
      ps.setString(1, displayName);
      ps.setString(2, email);
      ps.setString(3, ""); // Password kosong karena login dengan Google
      ps.setString(4, firebaseUid);
      ps.setString(5, photoURL);
      ps.setString(6, "user"); // Default role adalah user
      
      System.out.println("Executing insert query");
      int rowsInserted = ps.executeUpdate();
      System.out.println("Insert completed: " + rowsInserted + " rows affected");
      
      // Ambil ID yang baru dibuat
      ResultSet generatedKeys = ps.getGeneratedKeys();
      int userId = -1;
      if (generatedKeys.next()) {
        userId = generatedKeys.getInt(1);
        System.out.println("New user ID: " + userId);
      }
      
      // Set session dan redirect
      System.out.println("Setting session attributes for new user");
      session.setAttribute("user", displayName);
      session.setAttribute("userId", userId);
      session.setAttribute("userEmail", email);
      session.setAttribute("userPhotoUrl", photoURL);
      
      System.out.println("Redirecting to welcome page");
      response.sendRedirect("welcome.jsp");
    }
    
  } catch (Exception e) {
    System.out.println("ERROR: " + e.getMessage());
    e.printStackTrace();
    out.println("<h2>Error occurred:</h2>");
    out.println("<p>" + e.getMessage() + "</p>");
    out.println("<h3>Stack Trace:</h3>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    out.println("<p><a href='login.html'>Return to login page</a></p>");
  } finally {
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
  }
%>