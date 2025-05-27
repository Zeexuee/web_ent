<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
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
  <title>Admin Page</title>
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
      border: none;
    }
    .card {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
    }
    .stat-card {
      transition: transform 0.2s;
      cursor: default;
    }
    .stat-card:hover {
      transform: translateY(-5px);
    }
    .stat-card i {
      font-size: 2.5rem;
      opacity: 0.2;
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);
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
  <a href="admin.jsp" class="active"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
  <a href="data-user.jsp"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
  <a href="list-invoice-admin.jsp"><i class="bi bi-box me-2"></i> Invoice</a>
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
  <!-- Welcome Card -->
  <div class="card welcome-card mb-4">
    <div class="card-body text-center py-4">
      <h1 class="text-primary mb-3"><i class="bi bi-person-circle me-2"></i>Selamat Datang Admin, <%= userName %>!</h1>
      <p class="lead">Ini adalah halaman dashboard admin. Silakan kelola data pengguna, barang, dan fitur lainnya.</p>
    </div>
  </div>
  
  <!-- Stat Cards -->
  <div class="row mb-4">
    <div class="col-md-4 mb-3">
      <div class="card stat-card bg-primary text-white h-100">
        <div class="card-body p-4">
          <h5 class="card-title">Data Pengguna</h5>
          <h2 class="mt-3 mb-0">
            <a href="data-user.jsp" class="text-white text-decoration-none">
              <i class="bi bi-arrow-right-circle"></i> Kelola
            </a>
          </h2>
          <i class="bi bi-people"></i>
        </div>
      </div>
    </div>
    <div class="col-md-4 mb-3">
      <div class="card stat-card bg-success text-white h-100">
        <div class="card-body p-4">
          <h5 class="card-title">Data Barang</h5>
          <h2 class="mt-3 mb-0">
            <a href="data-barang.jsp" class="text-white text-decoration-none">
              <i class="bi bi-arrow-right-circle"></i> Kelola
            </a>
          </h2>
          <i class="bi bi-box-seam"></i>
        </div>
      </div>
    </div>
    <div class="col-md-4 mb-3">
      <div class="card stat-card bg-warning text-dark h-100">
        <div class="card-body p-4">
          <h5 class="card-title">Laporan Toko</h5>
          <h2 class="mt-3 mb-0">
            <a href="#" class="text-dark text-decoration-none">
              <i class="bi bi-arrow-right-circle"></i> Lihat
            </a>
          </h2>
          <i class="bi bi-graph-up"></i>
        </div>
      </div>
    </div>
  </div>

  <!-- Quick Actions -->
  <div class="card">
    <div class="card-body">
      <h4 class="card-title mb-4"><i class="bi bi-lightning-charge"></i> Aksi Cepat</h4>
      <div class="row text-center">
        <div class="col-md-3 col-6 mb-3">
          <a href="data-barang.jsp" class="btn btn-outline-primary p-3 w-100">
            <i class="bi bi-plus-circle mb-2" style="font-size: 24px;"></i><br>
            Tambah Barang
          </a>
        </div>
        <div class="col-md-3 col-6 mb-3">
          <a href="data-user.jsp" class="btn btn-outline-success p-3 w-100">
            <i class="bi bi-person-plus mb-2" style="font-size: 24px;"></i><br>
            Tambah Pengguna
          </a>
        </div>
        <div class="col-md-3 col-6 mb-3">
          <a href="#" class="btn btn-outline-info p-3 w-100">
            <i class="bi bi-gear mb-2" style="font-size: 24px;"></i><br>
            Pengaturan
          </a>
        </div>
        <div class="col-md-3 col-6 mb-3">
          <a href="welcome.jsp" class="btn btn-outline-secondary p-3 w-100">
            <i class="bi bi-shop mb-2" style="font-size: 24px;"></i><br>
            Lihat Toko
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>