<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %>
<%
  // Check if user is logged in as admin
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String invoiceIdStr = request.getParameter("id");
  int invoiceId = (invoiceIdStr != null && !invoiceIdStr.isEmpty()) ? Integer.parseInt(invoiceIdStr) : -1;

  if (invoiceId == -1) {
    out.println("<div class='alert alert-danger'>ID invoice tidak ditemukan.</div>");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  String user = "", namaPenerima = "", alamat = "", metode = "", tanggal = "", status = "";
  int total = 0;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    // Ambil data invoice
    ps = conn.prepareStatement("SELECT * FROM invoice WHERE id=?");
    ps.setInt(1, invoiceId);
    rs = ps.executeQuery();
    if (rs.next()) {
      user = rs.getString("user");
      namaPenerima = rs.getString("nama_penerima");
      alamat = rs.getString("alamat");
      metode = rs.getString("metode");
      tanggal = rs.getString("tanggal");
      status = rs.getString("status");
      total = rs.getInt("total");
    } else {
      out.println("<div class='alert alert-danger'>Invoice tidak ditemukan.</div>");
      return;
    }
    rs.close();
    ps.close();
  %>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Detail Invoice Admin</title>
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
      box-shadow: 0 2px 8px rgba(0,0,0,0.03);
    }
    .table thead {
      background-color: #f8f9fa;
    }
    .invoice-header {
      background: linear-gradient(120deg, #f8f9fa 60%, #e0f7fa 100%);
      border-radius: 18px;
      padding: 20px;
      margin-bottom: 20px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.03);
    }
    .status-badge {
      padding: 6px 12px;
      border-radius: 20px;
      font-weight: 500;
      font-size: 0.85rem;
      display: inline-block;
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
    .detail-row {
      padding: 10px 0;
      border-bottom: 1px solid #f0f0f0;
    }
    .detail-row:last-child {
      border-bottom: none;
    }
    .detail-label {
      font-weight: 600;
      color: #555;
    }
    .detail-value {
      font-weight: 500;
    }
    .total-row {
      background-color: #f8f9fa;
      font-weight: 700;
      color: #00bcd4;
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
    <h2><i class="bi bi-receipt"></i> Detail Invoice #<%= invoiceId %></h2>
    <a href="list-invoice-admin.jsp" class="btn btn-outline-secondary">
      <i class="bi bi-arrow-left"></i> Kembali ke Daftar
    </a>
  </div>

  <div class="card mb-4">
    <div class="card-body">
      <div class="invoice-header d-flex justify-content-between align-items-center mb-3">
        <div>
          <h5 class="mb-1">Invoice #<%= invoiceId %></h5>
          <div><small><i class="bi bi-calendar3"></i> <%= tanggal %></small></div>
        </div>
        <div>
          <%
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
          <span class="status-badge <%= statusClass %>">
            <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i> <%= status.toUpperCase() %>
          </span>
        </div>
      </div>

      <div class="row g-4">
        <div class="col-md-6">
          <div class="card h-100">
            <div class="card-body">
              <h6 class="card-title mb-3"><i class="bi bi-person"></i> Informasi Pelanggan</h6>
              <div class="detail-row">
                <div class="detail-label">Username</div>
                <div class="detail-value"><%= user %></div>
              </div>
              <div class="detail-row">
                <div class="detail-label">Nama Penerima</div>
                <div class="detail-value"><%= namaPenerima %></div>
              </div>
              <div class="detail-row">
                <div class="detail-label">Alamat Pengiriman</div>
                <div class="detail-value"><%= alamat %></div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card h-100">
            <div class="card-body">
              <h6 class="card-title mb-3"><i class="bi bi-credit-card"></i> Informasi Pembayaran</h6>
              <div class="detail-row">
                <div class="detail-label">Metode Pembayaran</div>
                <div class="detail-value"><%= metode %></div>
              </div>
              <div class="detail-row">
                <div class="detail-label">Status Pembayaran</div>
                <div class="detail-value">
                  <span class="status-badge <%= statusClass %>">
                    <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i> <%= status.toUpperCase() %>
                  </span>
                </div>
              </div>
              <div class="detail-row">
                <div class="detail-label">Total Pembayaran</div>
                <div class="detail-value text-primary fw-bold">
                  Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(total) %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <h5 class="mt-4 mb-3"><i class="bi bi-box-seam"></i> Detail Barang</h5>
      <div class="table-responsive">
        <table class="table table-striped">
          <thead class="table-light">
            <tr>
              <th>Nama Barang</th>
              <th class="text-center">Harga</th>
              <th class="text-center">Jumlah</th>
              <th class="text-end">Subtotal</th>
            </tr>
          </thead>
          <tbody>
            <%
              // Ambil detail barang
              ps = conn.prepareStatement("SELECT * FROM invoice_detail WHERE invoice_id=?");
              ps.setInt(1, invoiceId);
              rs = ps.executeQuery();
              while (rs.next()) {
                int harga = rs.getInt("harga");
                int qty = rs.getInt("qty");
                int subtotal = rs.getInt("subtotal");
            %>
            <tr>
              <td><strong><%= rs.getString("nama_barang") %></strong></td>
              <td class="text-center">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(harga) %></td>
              <td class="text-center"><%= qty %></td>
              <td class="text-end">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(subtotal) %></td>
            </tr>
            <% } rs.close(); ps.close(); %>
            <tr class="total-row">
              <td colspan="3" class="text-end"><strong>Total:</strong></td>
              <td class="text-end"><strong>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(total) %></strong></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-4">
        <form action="update-status-invoice.jsp" method="post" class="d-flex align-items-center">
          <input type="hidden" name="id" value="<%= invoiceId %>">
          <div class="me-3">
            <select name="status" class="form-select">
              <option value="menunggu" <%= status.equals("menunggu") ? "selected" : "" %>>Menunggu</option>
              <option value="dibayar" <%= status.equals("dibayar") ? "selected" : "" %>>Dibayar</option>
              <option value="dikirim" <%= status.equals("dikirim") ? "selected" : "" %>>Dikirim</option>
              <option value="selesai" <%= status.equals("selesai") ? "selected" : "" %>>Selesai</option>
              <option value="batal" <%= status.equals("batal") ? "selected" : "" %>>Batal</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary">
            <i class="bi bi-arrow-clockwise"></i> Update Status
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
  } catch (Exception e) {
    out.println("<div class='alert alert-danger'>Gagal mengambil data invoice: " + e.getMessage() + "</div>");
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (ps != null) try { ps.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>