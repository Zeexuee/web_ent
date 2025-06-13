<!-- filepath: d:\Campus\Kelas\Kelas - Enterprise\WebApplication2\web\firebase-auth-process.jsp -->
<%@ page import="java.sql.*, java.io.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String firebaseUid = request.getParameter("firebaseUid");
  String displayName = request.getParameter("displayName");
  String email = request.getParameter("email");
  String photoURL = request.getParameter("photoURL");

  if (firebaseUid == null || email == null) {
    response.sendRedirect("form.html?error=missing_data");
    return;
  }

  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    PreparedStatement checkPs = conn.prepareStatement("SELECT * FROM users WHERE firebase_uid = ? OR email = ?");
    checkPs.setString(1, firebaseUid);
    checkPs.setString(2, email);
    ResultSet rs = checkPs.executeQuery();

    if (rs.next()) {
      String userRole = rs.getString("role");
      session.setAttribute("user", rs.getString("nama"));
      session.setAttribute("userEmail", email);
      session.setAttribute("userRole", userRole);
      session.setAttribute("userPhotoUrl", photoURL);

      if ("admin".equalsIgnoreCase(userRole)) {
        response.sendRedirect("admin.jsp");
      } else {
        response.sendRedirect("welcome.jsp");
      }
    } else {
      PreparedStatement insertPs = conn.prepareStatement("INSERT INTO users (nama, email, firebase_uid, profile_photo, role) VALUES (?, ?, ?, ?, ?)");
      insertPs.setString(1, displayName);
      insertPs.setString(2, email);
      insertPs.setString(3, firebaseUid);
      insertPs.setString(4, photoURL);
      insertPs.setString(5, "user");
      insertPs.executeUpdate();

      session.setAttribute("user", displayName);
      session.setAttribute("userEmail", email);
      session.setAttribute("userRole", "user");
      session.setAttribute("userPhotoUrl", photoURL);

      response.sendRedirect("welcome.jsp");
    }
  } catch (Exception e) {
    response.sendRedirect("form.html?error=" + e.getMessage());
  } finally {
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
  }
%>