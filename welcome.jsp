<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>

<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  Connection conn = null;
  Statement stmt = null;
  ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Selamat Datang</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 60px;
    }
    .card {
      padding: 30px;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }
    table th, table td {
      vertical-align: middle;
    }
  </style>
</head>
<body>

<div class="container">
  <div class="card text-center mb-5">
    <h1 class="text-success mb-3">👋 Selamat Datang, <%= userName %>!</h1>
    <p class="lead">Berikut ini adalah daftar semua pengguna terdaftar:</p>
    <a href="logout.jsp" class="btn btn-outline-danger mt-3">🚪 Logout</a>
  </div>

  <div class="card">
    <h4 class="mb-3">📋 Daftar Pengguna</h4>
    <table class="table table-striped">
      <thead class="table-light">
        <tr>
          <th>Nama</th>
          <th>Email</th>
          <th>Waktu Daftar</th>
        </tr>
      </thead>
      <tbody>
<%
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    stmt = conn.createStatement();
    rs = stmt.executeQuery("SELECT nama, email, created_at FROM users");

    SimpleDateFormat sdf = new SimpleDateFormat("d MMMM yyyy HH:mm", new Locale("id", "ID"));

    while (rs.next()) {
      String nama = rs.getString("nama");
      String email = rs.getString("email");
      java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
      String formattedDate = (createdAt != null) ? sdf.format(createdAt) : "-";
%>
        <tr>
          <td><%= nama %></td>
          <td><%= email %></td>
          <td><%= formattedDate %></td>
        </tr>
<%
    }
  } catch (Exception e) {
%>
        <tr><td colspan="3" class="text-danger">Terjadi kesalahan: <%= e.getMessage() %></td></tr>
<%
  } finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (stmt != null) stmt.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>
      </tbody>
    </table>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
