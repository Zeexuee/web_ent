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
    .btn-warning {
      background: #ff9800;
      border-color: #ff9800;
    }
    .btn-warning:hover {
      background: #f57c00;
      border-color: #f57c00;
    }
    .btn-danger {
      background: #f44336;
      border-color: #f44336;
    }
    .btn-danger:hover {
      background: #d32f2f;
      border-color: #d32f2f;
    }
    @media (max-width: 900px) {
      .sidebar { width: 100%; height: auto; position: static; box-shadow: none; }
      .content { margin-left: 0; padding: 15px; }
    }
  </style>
</head>
<body>

<div class="sidebar">
  <div class="logo mb-4">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="admin.jsp" class=""><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
  <a href="data-user.jsp"  class="active"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
  <a href="list-invoice-admin.jsp"><i class="bi bi-box me-2"></i> Pesanan</a>
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
          <ul class="dropdown-menu dropdown-menu-e nd" aria-labelledby="userDropdown">
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
  <div class="card p-4">
    <h4 class="mb-3"><i class="bi bi-people"></i> 📋 Daftar Pengguna</h4>
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
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
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
          <td>
            <button class="btn btn-warning btn-sm" data-bs-toggle="modal" data-bs-target="#editModal"
              data-id="<%= id %>" data-nama="<%= nama %>" data-email="<%= email %>">Edit</button>
            <button class="btn btn-danger btn-sm" data-bs-toggle="modal" data-bs-target="#deleteModal"
              data-id="<%= id %>" data-nama="<%= nama %>">Delete</button>
          </td>
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

<!-- Edit Modal -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="update-user.jsp" method="post">
      <div class="modal-content">
        <div class="modal-header bg-warning">
          <h5 class="modal-title" id="editModalLabel">Edit Pengguna</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="edit-id" name="id">
          <div class="mb-3">
            <label for="edit-nama" class="form-label">Nama</label>
            <input type="text" class="form-control" id="edit-nama" name="nama" required>
          </div>
          <div class="mb-3">
            <label for="edit-email" class="form-label">Email</label>
            <input type="email" class="form-control" id="edit-email" name="email" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
        </div>
      </div>
    </form>
  </div>
</div>

<!-- Delete Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="delete-user.jsp" method="post">
      <div class="modal-content">
        <div class="modal-header bg-danger text-white">
          <h5 class="modal-title" id="deleteModalLabel">Konfirmasi Hapus</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="delete-id" name="id">
          <p>Apakah Anda yakin ingin menghapus pengguna <strong id="delete-nama"></strong>?</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-danger">Ya, Hapus</button>
        </div>
      </div>
    </form>
  </div>
</div>

<!-- Script untuk mengisi data modal -->
<script>
  var editModal = document.getElementById('editModal');
  if (editModal) {
    editModal.addEventListener('show.bs.modal', function (event) {
      var button = event.relatedTarget;
      var id = button.getAttribute('data-id');
      var nama = button.getAttribute('data-nama');
      var email = button.getAttribute('data-email');

      editModal.querySelector('#edit-id').value = id;
      editModal.querySelector('#edit-nama').value = nama;
      editModal.querySelector('#edit-email').value = email;
    });
  }
</script>

<script>
  var deleteModal = document.getElementById('deleteModal');
  if (deleteModal) {
    deleteModal.addEventListener('show.bs.modal', function (event) {
      var button = event.relatedTarget;
      var id = button.getAttribute('data-id');
      var nama = button.getAttribute('data-nama');

      deleteModal.querySelector('#delete-id').value = id;
      deleteModal.querySelector('#delete-nama').textContent = nama;
    });
  }
</script>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
