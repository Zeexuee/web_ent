<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%
  String nama = request.getParameter("nama");
  String email = request.getParameter("email");
  String password = request.getParameter("password");

  if (nama == null || email == null || password == null || nama.isEmpty() || email.isEmpty() || password.isEmpty()) {
    response.sendRedirect("form.html?error=missing_fields");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    // Cek apakah email sudah terdaftar
    ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
    ps.setString(1, email);
    rs = ps.executeQuery();
    if (rs.next()) {
      response.sendRedirect("form.html?error=email_exists");
      return;
    }

    // Hash password
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte b : hashedPassword) {
      sb.append(String.format("%02x", b));
    }
    String hashedPasswordStr = sb.toString();

    // Insert user baru
    ps = conn.prepareStatement("INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)");
    ps.setString(1, nama);
    ps.setString(2, email);
    ps.setString(3, hashedPasswordStr);
    ps.setString(4, "user");
    ps.executeUpdate();

    response.sendRedirect("form.html?success=registration_complete");
  } catch (Exception e) {
    response.sendRedirect("form.html?error=" + e.getMessage());
  } finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
  }
%>