 <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>
<%-- Connection Declaration --%>
<%
  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
  } catch (Exception e) {
    out.println("Connection Error: " + e.getMessage());
  }
%>
<%-- End of Connection --%>
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
  <title>Data Barang</title>
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
    .btn-success {
      background: #4caf50;
      border-color: #4caf50;
    }
    .btn-success:hover {
      background: #388e3c;
      border-color: #388e3c;
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
  <a href="welcome.jsp"><i class="bi bi-house-door me-2"></i> Home</a>
  <a href="data-user.jsp"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp" class="active"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
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
  <div class="card p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h4 class="mb-0"><i class="bi bi-box-seam"></i> 📦 Data Barang</h4>
      <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">
        <i class="bi bi-plus-circle"></i> Tambah Barang
      </button>
    </div>
    
    <table class="table table-striped align-middle">
      <thead class="table-light">
        <tr>
          <th>No</th>
          <th>Gambar</th>
          <th>Nama</th>
          <th>Deskripsi</th>
          <th>Harga</th>
          <th>Stok</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
        <%
          int no = 1;
          try {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM barang ORDER BY id DESC");
            while (rs.next()) {
        %>
        <tr>
          <td><%= no++ %></td>
          <td style="width: 100px">
            <% if (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) { %>
              <img src="uploads/<%= rs.getString("gambar") %>" class="img-thumbnail" style="width:80px; height:80px; object-fit:cover;">
            <% } else { %>
              <img src="https://via.placeholder.com/80?text=No+Image" class="img-thumbnail" style="width:80px; height:80px; object-fit:cover;">
            <% } %>
          </td>
          <td><%= rs.getString("nama") %></td>
          <td>
            <%= rs.getString("deskripsi").length() > 50 ? rs.getString("deskripsi").substring(0, 50) + "..." : rs.getString("deskripsi") %>
          </td>
          <td>Rp <%= String.format("%,d", rs.getInt("harga")) %></td>
          <td><%= rs.getInt("stok") %></td>
          <td>
            <button 
              class="btn btn-warning btn-sm btn-edit-barang"
              data-id="<%= rs.getInt("id") %>"
              data-nama="<%= rs.getString("nama") %>"
              data-deskripsi="<%= rs.getString("deskripsi") %>"
              data-harga="<%= rs.getInt("harga") %>"
              data-stok="<%= rs.getInt("stok") %>"
              data-bs-toggle="modal"
              data-bs-target="#modalEditBarang"
            >Edit</button>
            <a href="delete-barang.jsp?id=<%= rs.getInt("id") %>" 
              class="btn btn-danger btn-sm" 
              onclick="return confirm('Yakin ingin menghapus barang ini?')">Delete</a>
          </td>
        </tr>
        <%
            }
            rs.close();
            st.close();
          } catch (Exception e) {
            out.println("<tr><td colspan='7' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
          }
        %>
      </tbody>
    </table>
  </div>
</div>

<!-- Modal Tambah Barang -->
<div class="modal fade" id="modalTambahBarang" tabindex="-1" aria-labelledby="modalTambahBarangLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="tambah-barang.jsp" method="post" class="modal-content" enctype="multipart/form-data">
      <div class="modal-header" style="background-color: #4caf50; color: white;">
        <h5 class="modal-title" id="modalTambahBarangLabel">Tambah Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label for="nama" class="form-label">Nama Barang</label>
          <input type="text" class="form-control" id="nama" name="nama" required>
        </div>
        <div class="mb-3">
          <label for="deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="deskripsi" name="deskripsi" required></textarea>
        </div>
        <div class="mb-3">
          <label for="harga" class="form-label">Harga</label>
          <input type="number" class="form-control" id="harga" name="harga" min="0" required>
        </div>
        <div class="mb-3">
          <label for="stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="stok" name="stok" min="0" required>
        </div>
        <div class="mb-3">
          <label for="gambar" class="form-label">Gambar</label>
          <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*" required>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-success">Simpan</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Edit Barang -->
<div class="modal fade" id="modalEditBarang" tabindex="-1" aria-labelledby="modalEditBarangLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="edit-barang.jsp" method="post" class="modal-content" enctype="multipart/form-data">
      <div class="modal-header bg-warning">
        <h5 class="modal-title" id="modalEditBarangLabel">Edit Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="edit-id" name="id">
        <div class="mb-3">
          <label for="edit-nama" class="form-label">Nama Barang</label>
          <input type="text" class="form-control" id="edit-nama" name="nama" required>
        </div>
        <div class="mb-3">
          <label for="edit-deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="edit-deskripsi" name="deskripsi" required></textarea>
        </div>
        <div class="mb-3">
          <label for="edit-harga" class="form-label">Harga</label>
          <input type="number" class="form-control" id="edit-harga" name="harga" min="0" required>
        </div>
        <div class="mb-3">
          <label for="edit-stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="edit-stok" name="stok" min="0" required>
        </div>
        <div class="mb-3">
          <label for="edit-gambar" class="form-label">Ganti Gambar (opsional)</label>
          <input type="file" class="form-control" id="edit-gambar" name="gambar" accept="image/*">
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
      </div>
    </form>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
  // Isi modal edit barang saat tombol edit diklik
  document.querySelectorAll('.btn-edit-barang').forEach(function(btn) {
    btn.addEventListener('click', function() {
      document.getElementById('edit-id').value = this.getAttribute('data-id');
      document.getElementById('edit-nama').value = this.getAttribute('data-nama');
      document.getElementById('edit-deskripsi').value = this.getAttribute('data-deskripsi');
      document.getElementById('edit-harga').value = this.getAttribute('data-harga');
      document.getElementById('edit-stok').value = this.getAttribute('data-stok');
    });
  });
</script>
</body>
</html>