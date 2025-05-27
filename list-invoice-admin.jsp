<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %>
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
  <title>Daftar Invoice</title>
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
    .navbar-brand {
      font-weight: bold;
      font-size: 1.5rem;
      letter-spacing: 1px;
      color: #00bcd4 !important;
    }
    .navbar {
      box-shadow: 0 2px 12px rgba(0,188,212,0.07);
      background: #fff;
    }
    .navbar .nav-link, .navbar .dropdown-toggle {
      color: #212529 !important;
      font-weight: 500;
      margin-right: 10px;
    }
    .navbar .nav-link.active, .navbar .nav-link:hover {
      color: #00bcd4 !important;
    }
    .card {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
    }
    .table {
      border-radius: 12px;
      overflow: hidden;
    }
    .table thead {
      background-color: #f8f9fa;
    }
    .status-badge {
      padding: 6px 12px;
      border-radius: 20px;
      font-weight: 500;
      font-size: 0.85rem;
      display: inline-block;
      text-align: center;
    }
    .status-pending {
      background-color: #fff3cd;
      color: #856404;
    }
    .status-paid {
      background-color: #d4edda;
      color: #155724;
    }
    .status-shipped {
      background-color: #cce5ff;
      color: #004085;
    }
    .status-delivered {
      background-color: #d1e7dd;
      color: #0f5132;
    }
    .status-canceled {
      background-color: #f8d7da;
      color: #721c24;
    }
    .btn-detail {
      background: #00bcd4;
      border-color: #00bcd4;
      color: white;
    }
    .btn-detail:hover {
      background: #0097a7;
      border-color: #0097a7;
      color: white;
    }
    .address-cell {
      max-width: 200px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .search-form {
      background: white;
      border-radius: 12px;
      padding: 15px;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    @media (max-width: 900px) {
      .sidebar { width: 100%; height: auto; position: static; box-shadow: none; }
      .content { margin-left: 0; padding: 15px; }
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo mb-4">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="admin.jsp"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
  <a href="data-user.jsp"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
  <a href="list-invoice-admin.jsp" class="active"><i class="bi bi-receipt me-2"></i> Transaksi</a>
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

<div class="content">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-receipt"></i> Daftar Invoice</h2>
    <a href="admin.jsp" class="btn btn-outline-secondary">
      <i class="bi bi-arrow-left"></i> Kembali ke Dashboard
    </a>
  </div>
  
  <!-- Search Form -->
  <div class="search-form mb-4">
    <form action="list-invoice-admin.jsp" method="get" class="row align-items-end g-2">
      <div class="col-md-3">
        <label for="search-user" class="form-label">Username</label>
        <input type="text" class="form-control" id="search-user" name="user" placeholder="Cari username..." 
               value="<%= request.getParameter("user") != null ? request.getParameter("user") : "" %>">
      </div>
      <div class="col-md-3">
        <label for="search-status" class="form-label">Status</label>
        <select class="form-select" id="search-status" name="status">
          <option value="">Semua Status</option>
          <option value="menunggu" <%= "menunggu".equals(request.getParameter("status")) ? "selected" : "" %>>Menunggu</option>
          <option value="dibayar" <%= "dibayar".equals(request.getParameter("status")) ? "selected" : "" %>>Dibayar</option>
          <option value="dikirim" <%= "dikirim".equals(request.getParameter("status")) ? "selected" : "" %>>Dikirim</option>
          <option value="selesai" <%= "selesai".equals(request.getParameter("status")) ? "selected" : "" %>>Selesai</option>
          <option value="batal" <%= "batal".equals(request.getParameter("status")) ? "selected" : "" %>>Batal</option>
        </select>
      </div>
      <div class="col-md-4">
        <div class="d-flex">
          <button type="submit" class="btn btn-primary me-2">
            <i class="bi bi-search"></i> Cari
          </button>
          <a href="list-invoice-admin.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-x-circle"></i> Reset
          </a>
        </div>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="table-responsive">
        <table class="table table-striped align-middle">
          <thead class="table-light">
            <tr>
              <th scope="col">ID</th>
              <th scope="col">User</th>
              <th scope="col">Nama Penerima</th>
              <th scope="col">Alamat</th>
              <th scope="col">Metode</th>
              <th scope="col">Total</th>
              <th scope="col">Tanggal</th>
              <th scope="col">Status</th>
              <th scope="col" class="text-center">Aksi</th>
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
                
                StringBuilder sql = new StringBuilder("SELECT * FROM invoice WHERE 1=1");
                
                // Add filter conditions
                if (request.getParameter("user") != null && !request.getParameter("user").isEmpty()) {
                  sql.append(" AND user LIKE ?");
                }
                
                if (request.getParameter("status") != null && !request.getParameter("status").isEmpty()) {
                  sql.append(" AND status = ?");
                }
                
                sql.append(" ORDER BY tanggal DESC");
                
                ps = conn.prepareStatement(sql.toString());
                
                int paramIndex = 1;
                
                if (request.getParameter("user") != null && !request.getParameter("user").isEmpty()) {
                  ps.setString(paramIndex++, "%" + request.getParameter("user") + "%");
                }
                
                if (request.getParameter("status") != null && !request.getParameter("status").isEmpty()) {
                  ps.setString(paramIndex, request.getParameter("status"));
                }
                
                rs = ps.executeQuery();
                
                boolean hasData = false;
                
                while (rs.next()) {
                  hasData = true;
                  int invoiceId = rs.getInt("id");
                  String user = rs.getString("user");
                  String namaPenerima = rs.getString("nama_penerima");
                  String alamat = rs.getString("alamat");
                  String metode = rs.getString("metode");
                  int total = rs.getInt("total");
                  String tanggal = rs.getString("tanggal");
                  String status = rs.getString("status");
                  
                  String statusClass = "status-pending";
                  if(status.equalsIgnoreCase("dibayar")) {
                    statusClass = "status-paid";
                  } else if(status.equalsIgnoreCase("dikirim")) {
                    statusClass = "status-shipped";
                  } else if(status.equalsIgnoreCase("selesai")) {
                    statusClass = "status-delivered";
                  } else if(status.equalsIgnoreCase("batal")) {
                    statusClass = "status-canceled";
                  }
            %>
            <tr>
              <td><%= invoiceId %></td>
              <td><strong><%= user %></strong></td>
              <td><%= namaPenerima %></td>
              <td class="address-cell" title="<%= alamat %>"><%= alamat %></td>
              <td><%= metode %></td>
              <td>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(total) %></td>
              <td><%= tanggal %></td>
              <td>
                <span class="status-badge <%= statusClass %>">
                  <%= status.toUpperCase() %>
                </span>
              </td>
              <td class="text-center">
                <a href="detail-invoice-admin.jsp?id=<%= invoiceId %>" class="btn btn-detail btn-sm">
                  <i class="bi bi-eye"></i> Detail
                </a>
              </td>
            </tr>
            <%
                }
                
                if (!hasData) {
            %>
            <tr>
              <td colspan="9" class="text-center py-4">
                <i class="bi bi-search" style="font-size: 2rem; opacity: 0.3;"></i>
                <p class="mt-2 mb-0">Tidak ada data invoice yang ditemukan</p>
              </td>
            </tr>
            <%
                }
              } catch (Exception e) {
                out.println("<tr><td colspan='9' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
              } finally {
                if (rs != null) try { rs.close(); } catch (Exception ex) {}
                if (ps != null) try { ps.close(); } catch (Exception ex) {}
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
              }
            %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>