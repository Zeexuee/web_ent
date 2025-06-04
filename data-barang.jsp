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
    :root {
      --primary-color: #4361ee;
      --secondary-color: #3f37c9;
      --accent-color: #4895ef;
      --light-color: #f8f9fa;
      --dark-color: #212529;
      --danger-color: #e63946;
      --warning-color: #ff9f1c;
      --success-color: #4cc9f0;
    }
    
    body {
      background-color: #f5f7fa;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      padding-top: 70px;
    }
    
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100%;
      width: 240px;
      background: var(--dark-color);
      padding-top: 20px;
      box-shadow: 2px 0 10px rgba(0,0,0,0.1);
      z-index: 100;
      transition: all 0.3s;
    }
    
    .sidebar .logo {
      font-size: 1.5rem;
      font-weight: bold;
      color: var(--accent-color);
      text-align: center;
      margin-bottom: 25px;
      padding: 0 15px;
    }
    
    .sidebar a {
      color: rgba(255,255,255,0.85);
      padding: 12px 25px;
      text-decoration: none;
      display: flex;
      align-items: center;
      font-size: 1rem;
      border-radius: 5px;
      margin: 8px 12px;
      transition: all 0.2s;
    }
    
    .sidebar a:hover, .sidebar a.active {
      background: var(--primary-color);
      color: white;
      transform: translateX(5px);
    }
    
    .sidebar a i {
      margin-right: 10px;
      font-size: 1.1rem;
    }
    
    .content {
      margin-left: 260px;
      padding: 25px;
      transition: all 0.3s;
    }
    
    .navbar {
      background-color: white;
      box-shadow: 0 2px 15px rgba(0,0,0,0.05);
      margin-left: 240px;
      padding: 10px 25px;
    }
    
    .navbar .nav-link {
      color: var(--dark-color);
      font-weight: 500;
    }
    
    .navbar .nav-link:hover {
      color: var(--primary-color);
    }
    
    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 25px;
      padding-bottom: 15px;
      border-bottom: 1px solid #eee;
    }
    
    .page-title {
      font-weight: 600;
      color: var(--dark-color);
      margin: 0;
    }
    
    .btn-add {
      background: var(--primary-color);
      color: white;
      border: none;
      padding: 8px 20px;
      border-radius: 5px;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.2s;
    }
    
    .btn-add:hover {
      background: var(--secondary-color);
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    .products-table {
      width: 100%;
      background: white;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
      margin-bottom: 30px;
    }
    
    .products-table table {
      width: 100%;
      border-collapse: collapse;
    }
    
    .products-table th {
      background-color: #f8f9fa;
      padding: 15px;
      text-align: left;
      font-weight: 600;
      color: var(--dark-color);
      border-bottom: 1px solid #eee;
    }
    
    .products-table td {
      padding: 12px 15px;
      border-bottom: 1px solid #eee;
      vertical-align: middle;
    }
    
    .products-table tr:last-child td {
      border-bottom: none;
    }
    
    .products-table tr:hover {
      background-color: rgba(67, 97, 238, 0.03);
    }
    
    .product-img-small {
      width: 70px;
      height: 70px;
      object-fit: cover;
      border-radius: 8px;
    }
    
    .product-stock-cell {
      width: 140px;
    }
    
    .product-actions-cell {
      width: 180px;
    }
    
    .btn-actions {
      display: flex;
      gap: 8px;
    }
    
    .modal-header-success {
      background-color: var(--primary-color);
      color: white;
    }
    
    .modal-header-warning {
      background-color: var(--warning-color);
      color: white;
    }
    
    @media (max-width: 992px) {
      .sidebar {
        width: 70px;
        overflow: hidden;
      }
      
      .sidebar .logo {
        font-size: 1.2rem;
        margin-bottom: 40px;
      }
      
      .sidebar a span {
        display: none;
      }
      
      .sidebar a {
        justify-content: center;
        padding: 15px;
      }
      
      .sidebar a i {
        margin-right: 0;
        font-size: 1.3rem;
      }
      
      .content {
        margin-left: 85px;
      }
      
      .navbar {
        margin-left: 70px;
      }
      
      .products-table {
        overflow-x: auto;
      }
      
      .product-desc-cell {
        max-width: 200px;
      }
    }
    
    @media (max-width: 768px) {
      .product-desc-cell {
        max-width: 150px;
      }
      
      .product-img {
        height: 150px;
      }
    }
    
    @media (max-width: 576px) {
      .sidebar {
        width: 0;
        padding: 0;
      }
      
      .content, .navbar {
        margin-left: 0;
      }
      
      .products-grid {
        grid-template-columns: 1fr 1fr;
      }
      
      .page-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
      }
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="welcome.jsp"><i class="bi bi-house-door"></i> <span>Home</span></a>
  <a href="data-user.jsp"><i class="bi bi-people"></i> <span>Data Pengguna</span></a>
  <a href="data-barang.jsp" class="active"><i class="bi bi-box-seam"></i> <span>Data Barang</span></a>
  <a href="list-invoice-admin.jsp"><i class="bi bi-receipt"></i> <span>Invoice</span></a>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle me-1"></i> <%= userName %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
            <li><a class="dropdown-item" href="data-user.jsp"><i class="bi bi-person me-2"></i> Profil</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
              <a href="logout.jsp" class="dropdown-item text-danger">
                <i class="bi bi-box-arrow-right me-2"></i> Logout
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="content">
  <div class="page-header">
    <h4 class="page-title"><i class="bi bi-box-seam me-2"></i>Data Barang</h4>
    <button class="btn-add" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">
      <i class="bi bi-plus-circle"></i> Tambah Barang
    </button>
  </div>
  
  <div class="products-table">
    <table>
      <thead>
        <tr>
          <th width="80">Gambar</th>
          <th>Nama Barang</th>
          <th>Deskripsi</th>
          <th>Harga</th>
          <th class="product-stock-cell">Stok</th>
          <th class="product-actions-cell">Aksi</th>
        </tr>
      </thead>
      <tbody>
        <%
          try {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM barang ORDER BY id DESC");
            while (rs.next()) {
              int stok = rs.getInt("stok");
              String stockClass = stok > 10 ? "in-stock" : (stok > 0 ? "low-stock" : "out-of-stock");
              String stockText = stok > 10 ? "Stok Tersedia" : (stok > 0 ? "Stok Terbatas" : "Stok Habis");
        %>
        <tr>
          <td>
            <% if (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) { %>
              <img src="uploads/<%= rs.getString("gambar") %>" class="product-img-small">
            <% } else { %>
              <img src="https://via.placeholder.com/70x70?text=No+Image" class="product-img-small">
            <% } %>
          </td>
          <td><strong><%= rs.getString("nama") %></strong></td>
          <td class="product-desc-cell">
            <%= rs.getString("deskripsi").length() > 80 ? rs.getString("deskripsi").substring(0, 80) + "..." : rs.getString("deskripsi") %>
          </td>
          <td>Rp <%= String.format("%,d", rs.getInt("harga")) %></td>
          <td>
            <div class="product-stock <%= stockClass %>">
              <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i> <%= stockText %> (<%= stok %>)
            </div>
          </td>
          <td>
            <div class="btn-actions">
              <button 
                class="btn-edit"
                data-id="<%= rs.getInt("id") %>"
                data-nama="<%= rs.getString("nama") %>"
                data-deskripsi="<%= rs.getString("deskripsi") %>"
                data-harga="<%= rs.getInt("harga") %>"
                data-stok="<%= rs.getInt("stok") %>"
                data-gambar="<%= rs.getString("gambar") %>"
                data-bs-toggle="modal"
                data-bs-target="#modalEditBarang"
              ><i class="bi bi-pencil me-1"></i> Edit</button>
              
              <a href="delete-barang.jsp?id=<%= rs.getInt("id") %>" 
                class="btn-delete" 
                onclick="return confirm('Yakin ingin menghapus barang ini?')"
              ><i class="bi bi-trash me-1"></i> Hapus</a>
            </div>
          </td>
        </tr>
        <%
            }
            rs.close();
            st.close();
          } catch (Exception e) {
            out.println("<tr><td colspan='6'><div class='alert alert-danger'>Gagal mengambil data: " + e.getMessage() + "</div></td></tr>");
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
      <div class="modal-header modal-header-success">
        <h5 class="modal-title" id="modalTambahBarangLabel"><i class="bi bi-plus-circle me-2"></i>Tambah Barang</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label for="nama" class="form-label">Nama Barang</label>
          <input type="text" class="form-control" id="nama" name="nama" required>
        </div>
        <div class="mb-3">
          <label for="deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="deskripsi" name="deskripsi" rows="3" required></textarea>
        </div>
        <div class="mb-3">
          <label for="harga" class="form-label">Harga (Rp)</label>
          <div class="input-group">
            <span class="input-group-text">Rp</span>
            <input type="number" class="form-control" id="harga" name="harga" min="0" required>
          </div>
        </div>
        <div class="mb-3">
          <label for="stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="stok" name="stok" min="0" required>
        </div>
        <div class="mb-3">
          <label for="gambar" class="form-label">Gambar Produk</label>
          <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*" required>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i> Simpan</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Edit Barang -->
<div class="modal fade" id="modalEditBarang" tabindex="-1" aria-labelledby="modalEditBarangLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="edit-barang.jsp" method="post" class="modal-content" enctype="multipart/form-data">
      <div class="modal-header modal-header-warning">
        <h5 class="modal-title" id="modalEditBarangLabel"><i class="bi bi-pencil-square me-2"></i>Edit Barang</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="edit-id" name="id">
        
        <div class="mb-3">
          <label for="edit-nama" class="form-label">Nama Barang</label>
          <input type="text" class="form-control" id="edit-nama" name="nama" required>
        </div>
        <div class="mb-3">
          <label for="edit-deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="edit-deskripsi" name="deskripsi" rows="3" required></textarea>
        </div>
        <div class="mb-3">
          <label for="edit-harga" class="form-label">Harga (Rp)</label>
          <div class="input-group">
            <span class="input-group-text">Rp</span>
            <input type="number" class="form-control" id="edit-harga" name="harga" min="0" required>
          </div>
        </div>
        <div class="mb-3">
          <label for="edit-stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="edit-stok" name="stok" min="0" required>
        </div>
        <div class="mb-3">
          <label for="edit-gambar" class="form-label">Ganti Gambar (opsional)</label>
          <input type="file" class="form-control" id="edit-gambar" name="gambar" accept="image/*">
          <small class="text-muted">Biarkan kosong jika tidak ingin mengubah gambar</small>
        </div>
        
        <!-- Preview Gambar -->
        <div class="mb-3 text-center">
          <img id="current-image-preview" src="" alt="Preview Gambar" class="img-thumbnail" style="max-height: 200px; display: none;">
          <p id="current-image-text" class="small text-muted mt-1" style="display: none;">Gambar saat ini</p>
        </div>

      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-warning text-white"><i class="bi bi-save me-1"></i> Simpan Perubahan</button>
      </div>
    </form>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
  // Isi modal edit barang saat tombol edit diklik
  document.querySelectorAll('.btn-edit').forEach(function(btn) {
    btn.addEventListener('click', function() {
      // Isi form dengan data barang
      document.getElementById('edit-id').value = this.getAttribute('data-id');
      document.getElementById('edit-nama').value = this.getAttribute('data-nama');
      document.getElementById('edit-deskripsi').value = this.getAttribute('data-deskripsi');
      document.getElementById('edit-harga').value = this.getAttribute('data-harga');
      document.getElementById('edit-stok').value = this.getAttribute('data-stok');
      
      // Set preview gambar
      const gambarNama = this.getAttribute('data-gambar');
      const imagePreview = document.getElementById('current-image-preview');
      const imageText = document.getElementById('current-image-text');
      
      if (gambarNama && gambarNama !== 'null' && gambarNama !== '') {
        imagePreview.src = 'uploads/' + gambarNama;
        imagePreview.style.display = 'block';
        imageText.style.display = 'block';
      } else {
        imagePreview.src = 'https://via.placeholder.com/200x150?text=No+Image';
        imagePreview.style.display = 'block'; // Tetap tampilkan placeholder
        imageText.style.display = 'block';
      }
      // Reset input file agar tidak menampilkan nama file sebelumnya
      document.getElementById('edit-gambar').value = ""; 
    });
  });
  
  // Preview gambar baru saat file dipilih (opsional)
  document.getElementById('edit-gambar').addEventListener('change', function() {
    const file = this.files[0];
    const imagePreview = document.getElementById('current-image-preview');
    const imageText = document.getElementById('current-image-text');

    if (file) {
      const reader = new FileReader();
      reader.onload = function(e) {
        imagePreview.src = e.target.result;
        imagePreview.style.display = 'block';
        imageText.style.display = 'block'; // Tampilkan juga teks "Gambar saat ini"
      };
      reader.readAsDataURL(file);
    } else {
        // Jika tidak ada file dipilih (misalnya user membatalkan pilihan),
        // kembali ke gambar asli atau placeholder
        const originalImageSrc = document.querySelector('.btn-edit[data-id="' + document.getElementById('edit-id').value + '"]').getAttribute('data-gambar');
        if (originalImageSrc && originalImageSrc !== 'null' && originalImageSrc !== '') {
            imagePreview.src = 'uploads/' + originalImageSrc;
        } else {
            imagePreview.src = 'https://via.placeholder.com/200x150?text=No+Image';
        }
        // Jangan sembunyikan jika tidak ada file baru, biarkan gambar asli/placeholder terlihat
    }
  });
  
  // Toggle sidebar pada layar kecil
  const toggleSidebar = () => {
    const sidebar = document.querySelector('.sidebar');
    if (window.innerWidth <= 576) {
      sidebar.style.width = sidebar.style.width === '240px' ? '0' : '240px';
    }
  };
  
  // Inisialisasi tooltip
  document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl)
    });
  });
</script>
</body>
</html>