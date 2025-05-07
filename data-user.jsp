<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>

<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }
%>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Data Pengguna</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 60px;
    }
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100%;
      width: 250px;
      background-color: #343a40;
      padding-top: 20px;
    }
    .sidebar a {
      color: white;
      padding: 10px 15px;
      text-decoration: none;
      display: block;
    }
    .sidebar a:hover {
      background-color: #575757;
    }
    .content {
      margin-left: 260px;
      padding: 20px;
    }
  </style>
</head>
<body>

<div class="sidebar">
  <h3 class="text-white text-center">Menu</h3>
  <a href="welcome.jsp">🏠 Home</a>
  <a href="data-user.jsp">📋 Data Pengguna</a>
  <a href="logout.jsp" class="btn btn-outline-danger mt-3">🚪 Logout</a>
</div>

<div class="content">
  <div class="card">
    <h4 class="mb-3">📋 Daftar Pengguna</h4>
    <table class="table table-striped">
      <thead class="table-light">
        <tr>
          <th>Nama</th>
          <th>Email</th>
          <th>Waktu Daftar</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
<%
  Connection conn = null;
  Statement stmt = null;
  ResultSet rs = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    stmt = conn.createStatement();
    rs = stmt.executeQuery("SELECT id, nama, email, created_at FROM users");

    SimpleDateFormat sdf = new SimpleDateFormat("d MMMM yyyy HH:mm", new Locale("id", "ID"));

    while (rs.next()) {
      int id = rs.getInt("id");
      String nama = rs.getString("nama");
      String email = rs.getString("email");
      java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
      String formattedDate = (createdAt != null) ? sdf.format(createdAt) : "-";
%>
        <tr>
          <td><%= nama %></td>
          <td><%= email %></td>
          <td><%= formattedDate %></td>
          <td><a href="edit-user.jsp?id=<%= id %>" class="btn btn-warning btn-sm">Edit</a></td>
        </tr>
<%
    }
  } catch (SQLException e) {
    out.println("<tr><td colspan='4' class='text-danger'>Terjadi kesalahan: " + e.getMessage() + "</td></tr>");
  } finally {
    try { if (rs != null) rs.close(); } catch (SQLException e) {}
    try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
    try { if (conn != null) conn.close(); } catch (SQLException e) {}
  }
%>
      </tbody>
    </table>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
