<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*" %>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }
  String idStr = request.getParameter("id");
  int id = (idStr != null) ? Integer.parseInt(idStr) : -1;
  Connection conn = null;
  ResultSet rs = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM barang WHERE id=?");
    ps.setInt(1, id);
    rs = ps.executeQuery();
    if (!rs.next()) {
      out.println("<div class='alert alert-danger'>Barang tidak ditemukan.</div>");
      return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Detail Barang - <%= rs.getString("nama") %></title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 80px;
    }
    .content {
      padding: 30px 20px 20px 20px;
      min-height: 100vh;
      max-width: 1200px;
      margin: 0 auto;
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
    .navbar-nav .nav-item {
      margin-right: 15px;
    }
    .navbar-nav .nav-item:last-child {
      margin-right: 0;
    }
    .navbar .navbar-nav .nav-link {
      padding: 8px 15px;
    }
    .card {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      overflow: hidden;
    }
    .product-img {
      height: 400px;
      object-fit: cover;
      transition: transform 0.3s;
    }
    .product-img:hover {
      transform: scale(1.03);
    }
    .product-title {
      font-size: 2rem;
      font-weight: 600;
      margin-bottom: 15px;
      color: #212529;
    }
    .product-description {
      color: #555;
      font-size: 1.1rem;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    .product-price {
      font-size: 1.4rem;
      font-weight: 600;
      color: #00bcd4;
      margin-bottom: 15px;
    }
    .product-stock {
      font-size: 1rem;
      margin-bottom: 20px;
      padding: 8px 15px;
      background-color: #f8f9fa;
      border-radius: 8px;
      display: inline-block;
    }
    .product-stock.in-stock {
      color: #388e3c;
    }
    .product-stock.low-stock {
      color: #ff9800;
    }
    .product-stock.out-stock {
      color: #f44336;
    }
    .btn-cart {
      background: #4caf50;
      border-color: #4caf50;
      font-weight: 500;
      padding: 8px 20px;
      border-radius: 8px;
    }
    .btn-cart:hover {
      background: #388e3c;
      border-color: #388e3c;
    }
    .btn-buy {
      background: #00bcd4;
      border-color: #00bcd4;
      font-weight: 500;
      padding: 8px 20px;
      border-radius: 8px;
    }
    .btn-buy:hover {
      background: #0097a7;
      border-color: #0097a7;
    }
    .qty-input {
      width: 80px;
      border-radius: 8px;
      text-align: center;
      padding: 8px;
      margin-right: 10px;
      border: 1px solid #ced4da;
    }
    .back-button {
      display: flex;
      align-items: center;
      color: #555;
      text-decoration: none;
      margin-bottom: 20px;
      font-weight: 500;
      transition: color 0.2s;
    }
    .back-button:hover {
      color: #00bcd4;
    }
    .product-action {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 12px;
      margin-top: 20px;
    }
    @media (max-width: 768px) {
      .content { padding: 15px; }
      .product-title { font-size: 1.5rem; }
    }
  </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top">
  <div class="container">
    <a class="navbar-brand" href="welcome.jsp">
      <i class="bi bi-bag-check-fill"></i> TokoKita
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item me-3">
          <a class="nav-link" href="keranjang.jsp">
            <i class="bi bi-cart3"></i> Keranjang
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
  <a href="welcome.jsp" class="back-button">
    <i class="bi bi-arrow-left me-2"></i> Kembali ke Daftar Barang
  </a>
  
  <div class="row">
    <div class="col-md-5 mb-4">
      <div class="card h-100">
        <% if (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) { %>
          <img src="uploads/<%= rs.getString("gambar") %>" class="product-img" alt="<%= rs.getString("nama") %>">
        <% } else { %>
          <img src="https://via.placeholder.com/400x400?text=No+Image" class="product-img" alt="No Image">
        <% } %>
      </div>
    </div>
    
    <div class="col-md-7">
      <div class="card h-100">
        <div class="card-body p-4">
          <h1 class="product-title"><%= rs.getString("nama") %></h1>
          
          <div class="product-price">
            <i class="bi bi-tag-fill me-1"></i> 
            Rp <%= String.format("%,d", rs.getInt("harga")) %>
          </div>
          
          <% 
            int stok = rs.getInt("stok");
            String stockClass = stok > 10 ? "in-stock" : (stok > 0 ? "low-stock" : "out-stock");
            String stockIcon = stok > 10 ? "bi-check-circle-fill" : (stok > 0 ? "bi-exclamation-circle-fill" : "bi-x-circle-fill");
          %>
          <div class="product-stock <%= stockClass %>">
            <i class="bi <%= stockIcon %> me-1"></i>
            <% if (stok > 10) { %>
              Stok Tersedia (<%= stok %> unit)
            <% } else if (stok > 0) { %>
              Stok Terbatas (Sisa <%= stok %> unit)
            <% } else { %>
              Stok Habis
            <% } %>
          </div>
          
          <div class="product-description">
            <%= rs.getString("deskripsi") %>
          </div>
          
          <div class="product-action">
            <form action="keranjang.jsp" method="post" class="mb-3">
              <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
              <div class="d-flex align-items-center">
                <label for="qty" class="me-3"><strong>Jumlah:</strong></label>
                <input type="number" id="qty" name="qty" value="1" min="1" max="<%= rs.getInt("stok") %>" 
                       class="form-control qty-input" <%= stok == 0 ? "disabled" : "" %>>
                <button type="submit" class="btn btn-cart" <%= stok == 0 ? "disabled" : "" %>>
                  <i class="bi bi-cart-plus me-1"></i> Tambah ke Keranjang
                </button>
              </div>
            </form>
            
            <div class="mt-3">
              <a href="pembayaran.jsp?id=<%= rs.getInt("id") %>&qty=1" 
                 class="btn btn-buy <%= stok == 0 ? "disabled" : "" %>"
                 <%= stok == 0 ? "aria-disabled='true'" : "" %>>
                <i class="bi bi-credit-card me-1"></i> Beli Sekarang
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Related Products Section -->
  <div class="mt-5">
    <h3 class="mb-3"><i class="bi bi-grid me-2"></i>Produk Lainnya</h3>
    <div class="row">
    <%
      try {
        PreparedStatement ps2 = conn.prepareStatement(
          "SELECT * FROM barang WHERE id != ? ORDER BY RAND() LIMIT 3");
        ps2.setInt(1, id);
        ResultSet relatedProducts = ps2.executeQuery();
        
        while (relatedProducts.next()) {
    %>
      <div class="col-md-4 mb-4">
        <div class="card h-100">
          <% if (relatedProducts.getString("gambar") != null && !relatedProducts.getString("gambar").isEmpty()) { %>
            <img src="uploads/<%= relatedProducts.getString("gambar") %>" class="card-img-top" height="200" style="object-fit: cover;">
          <% } else { %>
            <img src="https://via.placeholder.com/300x200?text=No+Image" class="card-img-top" height="200" style="object-fit: cover;">
          <% } %>
          <div class="card-body">
            <h5 class="card-title"><%= relatedProducts.getString("nama") %></h5>
            <p class="card-text">Rp <%= String.format("%,d", relatedProducts.getInt("harga")) %></p>
            <a href="item-detail.jsp?id=<%= relatedProducts.getInt("id") %>" class="btn btn-outline-primary">
              <i class="bi bi-eye me-1"></i> Lihat Detail
            </a>
          </div>
        </div>
      </div>
    <%
        }
        relatedProducts.close();
        ps2.close();
      } catch (Exception e) {
        // Silently handle errors in related products
      }
    %>
    </div>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
  } catch (Exception e) {
    out.println("<div class='alert alert-danger'>Gagal mengambil detail barang: " + e.getMessage() + "</div>");
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>