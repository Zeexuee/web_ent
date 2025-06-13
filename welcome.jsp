<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale, java.util.Map, java.util.HashMap" %>

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
  <title>Selamat Datang</title>
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
    .navbar .badge {
      font-size: 0.8em;
      background: #00bcd4;
      color: #fff;
      vertical-align: top;
      margin-left: -8px;
    }
    .welcome-card {
      border-radius: 18px;
      background: linear-gradient(120deg, #e0f7fa 60%, #fff 100%);
      box-shadow: 0 2px 12px rgba(0,188,212,0.09);
    }
    .card-product {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      transition: transform 0.12s;
    }
    .card-product:hover {
      transform: translateY(-4px) scale(1.02);
      box-shadow: 0 6px 24px rgba(0,188,212,0.13);
    }
    .card-product .card-title {
      font-size: 1.15rem;
      font-weight: 600;
      margin-bottom: 8px;
    }
    .card-product .card-text {
      color: #009688;
      font-size: 1.08rem;
      margin-bottom: 16px;
    }
    .btn-detail {
      background: #00bcd4;
      color: #fff;
      border-radius: 6px;
      font-weight: 500;
      letter-spacing: 0.5px;
      transition: background 0.15s;
    }
    .btn-detail:hover {
      background: #0097a7;
      color: #fff;
    }
    .category-badge {
      background: #fff;
      color: #00bcd4;
      border: 1px solid #00bcd4;
      font-size: 0.85em;
      border-radius: 8px;
      padding: 2px 10px;
      margin-bottom: 8px;
      display: inline-block;
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
  <a href="welcome.jsp" class="active"><i class="bi bi-house-door me-2"></i> Home</a>
  <a href="pembelian.jsp"><i class="bi bi-box me-2"></i> Pembelian</a>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top" style="left:210px;">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item">
          <a class="nav-link" href="keranjang.jsp">
            <i class="bi bi-cart3"></i> Keranjang
            <%
              Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
              int cartCount = 0;
              if (cart != null) {
                for (int qty : cart.values()) cartCount += qty;
              }
              if (cartCount > 0) {
            %>
              <span class="badge rounded-pill"><%= cartCount %></span>
            <%
              }
            %>
          </a>
        </li>
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
  <div class="card shadow-sm border-0 text-center mb-5 welcome-card">
    <div class="card-body py-4">
      <h1 class="text-success mb-2"><i class="bi bi-emoji-smile"></i> Selamat Datang, <%= userName %>!</h1>
      <p class="lead mb-0">Selamat berbelanja di <b>TokoKita</b>. Temukan produk terbaik untukmu!</p>
      <div class="mt-3">
        <span class="badge bg-success me-2"><i class="bi bi-truck"></i> Gratis Ongkir</span>
        <span class="badge bg-warning text-dark me-2"><i class="bi bi-cash-coin"></i> Bayar di Tempat</span>
        <span class="badge bg-info text-dark"><i class="bi bi-shield-check"></i> Belanja Aman</span>
      </div>
    </div>
  </div>
  <h3 class="mb-4"><i class="bi bi-shop"></i> Daftar Barang Dijual</h3>
  <div class="row">
    <%
      Connection conn = null;
      try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM barang ORDER BY id DESC");
        while (rs.next()) {
    %>
      <div class="col-md-4 col-sm-6 mb-4">
        <div class="card card-product h-100">
          <% if (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) { %>
            <img src="uploads/<%= rs.getString("gambar") %>" class="card-img-top" style="height:210px;object-fit:cover;border-radius:18px 18px 0 0;">
          <% } else { %>
            <img src="https://via.placeholder.com/300x210?text=No+Image" class="card-img-top" style="height:210px;object-fit:cover;border-radius:18px 18px 0 0;">
          <% } %>
          <div class="card-body d-flex flex-column">
            <h5 class="card-title"><%= rs.getString("nama") %></h5>
            <p class="card-text">Rp <%= String.format("%,d", rs.getInt("harga")) %></p>
            <a href="item-detail.jsp?id=<%= rs.getInt("id") %>" class="btn btn-detail mt-auto">
              <i class="bi bi-eye"></i> Lihat Detail
            </a>
          </div>
        </div>
      </div>
    <%
        }
        rs.close();
        st.close();
        conn.close();
      } catch (Exception e) {
        out.println("<div class='text-danger'>Gagal mengambil data barang: " + e.getMessage() + "</div>");
      }
    %>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
