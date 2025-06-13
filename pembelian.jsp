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
  <title>Data Pembelian</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 80px;
    }
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100%;
      width: 210px;
      background: #212529;
      padding-top: 30px;
      box-shadow: 2px 0 10px rgba(0,0,0,0.07);
      z-index: 100;
    }
    .sidebar .logo {
      font-size: 1.6rem;
      font-weight: bold;
      color: #00bcd4;
      text-align: center;
      margin-bottom: 30px;
      letter-spacing: 1px;
    }
    .sidebar a {
      color: #f8f9fa;
      padding: 12px 22px;
      text-decoration: none;
      display: flex;
      align-items: center;
      font-size: 1.08rem;
      border-radius: 8px 0 0 8px;
      margin-bottom: 6px;
      transition: background 0.2s;
    }
    .sidebar a:hover, .sidebar a.active {
      background: #00bcd4;
      color: #fff;
    }
    .content {
      margin-left: 230px;
      padding: 30px 20px 20px 20px;
      min-height: 100vh;
    }
    .table {
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      border-radius: 8px;
      overflow: hidden;
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo mb-4">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="welcome.jsp"><i class="bi bi-house-door me-2"></i> Home</a>
  <a href="pembelian.jsp" class="active"><i class="bi bi-box me-2"></i> Pembelian</a>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top" style="left:210px;">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle"></i> <%= userName %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
            <li><a class="dropdown-item" href="data-user.jsp"><i class="bi bi-person"></i> Profil</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
              <a href="logout.jsp" class="dropdown-item text-danger">
                <i class="bi bi-box-arrow-right"></i> Logout
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<!-- Content -->
<div class="content">
  <h2 class="mb-4"><i class="bi bi-box"></i> Data Pembelian</h2>
  <table class="table table-striped">
    <thead class="table-light">
      <tr>
        <th>ID Pembelian</th>
        <th>Nama Penerima</th>
        <th>Alamat</th>
        <th>Metode</th>
        <th>Total</th>
        <th>Tanggal</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
    <%
      Connection conn = null;
      PreparedStatement ps = null;
      ResultSet rs = null;
      try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        
        String sql = "SELECT id, nama_penerima, alamat, metode, total, tanggal, status FROM invoice WHERE user = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, userName);
        rs = ps.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("d MMMM yyyy HH:mm", new Locale("id", "ID"));
        while (rs.next()) {
          int id = rs.getInt("id");
          String namaPenerima = rs.getString("nama_penerima");
          String alamat = rs.getString("alamat");
          String metode = rs.getString("metode");
          int total = rs.getInt("total");
          String tanggal = sdf.format(rs.getTimestamp("tanggal"));
          String status = rs.getString("status");
    %>
      <tr>
        <td><%= id %></td>
        <td><%= namaPenerima %></td>
        <td><%= alamat %></td>
        <td><%= metode %></td>
        <td>Rp <%= String.format("%,d", total) %></td>
        <td><%= tanggal %></td>
        <td><%= status %></td>
      </tr>
    <%
        }
      } catch (Exception e) {
        out.println("<tr><td colspan='7' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
      } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (ps != null) ps.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
      }
    %>
    </tbody>
  </table>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>