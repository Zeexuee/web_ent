<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Ambil data dari form login
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  String firebaseUid = request.getParameter("firebaseUid");

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try {
    // Load JDBC driver dan koneksi ke database
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    if (firebaseUid != null && !firebaseUid.isEmpty()) {
      // Login menggunakan Google (Firebase)
      ps = conn.prepareStatement("SELECT * FROM users WHERE firebase_uid = ?");
      ps.setString(1, firebaseUid);
      rs = ps.executeQuery();

      if (rs.next()) {
        // Ambil data user dari database
        String userName = rs.getString("nama");
        String userRole = rs.getString("role");
        String photoUrl = rs.getString("profile_photo");

        // Set session
        session.setAttribute("user", userName);
        session.setAttribute("userEmail", rs.getString("email"));
        session.setAttribute("userRole", userRole);
        if (photoUrl != null && !photoUrl.isEmpty()) {
          session.setAttribute("userPhotoUrl", photoUrl);
        }

        // Redirect berdasarkan role
        if ("admin".equalsIgnoreCase(userRole)) {
          response.sendRedirect("admin.jsp");
        } else {
          response.sendRedirect("welcome.jsp");
        }
      } else {
        response.sendRedirect("login.jsp?error=firebase_user_not_found");
      }
    } else if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
      // Validasi input kosong
      System.out.println("Login failed: Missing email or password");
      response.sendRedirect("login.jsp?error=missing_fields");
    } else {
      // Login menggunakan email dan password
      ps = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?");
      ps.setString(1, email);
      ps.setString(2, password);
      rs = ps.executeQuery();

      if (rs.next()) {
        // Ambil data user dari database
        int userId = rs.getInt("id");
        String userName = rs.getString("nama");
        String userRole = rs.getString("role");
        String photoUrl = rs.getString("profile_photo");

        // Set session
        session.setAttribute("user", userName);
        session.setAttribute("userId", userId);
        session.setAttribute("userEmail", email);
        if (photoUrl != null && !photoUrl.isEmpty()) {
          session.setAttribute("userPhotoUrl", photoUrl);
        }

        // Redirect berdasarkan role
        if ("admin".equalsIgnoreCase(userRole)) {
          response.sendRedirect("admin.jsp");
        } else {
          response.sendRedirect("welcome.jsp");
        }
      } else {
        response.sendRedirect("login.jsp?error=invalid_credentials");
      }
    }
  } catch (Exception e) {
    // Tangani error
    response.sendRedirect("login.jsp?error=" + e.getMessage());
  } finally {
    // Tutup resource
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
  }
%>
