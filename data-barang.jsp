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
    .navbar {
      box-shadow: 0 2px 12px rgba(0,188,212,0.07);
      background: #fff;
      left: 210px;
    }
    .page-header {
      display: flex;
      justify-content: between;
      align-items: center;
      margin-bottom: 30px;
    }
    .page-title {
      font-size: 2rem;
      font-weight: bold;
      color: #212529;
    }
    .btn-add {
      background: #00bcd4;
      border-color: #00bcd4;
      color: white;
    }
    .btn-add:hover {
      background: #0097a7;
      border-color: #0097a7;
      color: white;
    }
    .btn-print-all {
      background: #17a2b8;
      border-color: #17a2b8;
      color: white;
    }
    .btn-print-all:hover {
      background: #138496;
      border-color: #138496;
      color: white;
    }
    .products-table {
      background: white;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      overflow: hidden;
    }
    .products-table table {
      margin-bottom: 0;
    }
    .products-table th {
      background-color: #f8f9fa;
      font-weight: 600;
      border: none;
      padding: 15px;
    }
    .products-table td {
      padding: 15px;
      border: none;
      border-bottom: 1px solid #f1f3f4;
    }
    .btn-print {
      background: #28a745;
      border-color: #28a745;
      color: white;
    }
    .btn-print:hover {
      background: #218838;
      border-color: #218838;
      color: white;
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo mb-4">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="admin.jsp" class=""><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
  <a href="data-user.jsp"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp" class="active"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
  <a href="list-invoice-admin.jsp"><i class="bi bi-box me-2"></i> Pesanan</a>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top">
  <div class="container-fluid">
    <div class="collapse navbar-collapse justify-content-end">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle"></i> <%= userName %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="#"><i class="bi bi-person"></i> Profil</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
              <form action="logout.jsp" method="post" style="margin: 0;">
                <button type="submit" class="dropdown-item"><i class="bi bi-box-arrow-right"></i> Logout</button>
              </form>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="content">
  <div class="page-header">
    <h1 class="page-title"><i class="bi bi-box-seam"></i> Data Barang</h1>
    <div class="d-flex gap-2">
      <button class="btn btn-print-all" data-bs-toggle="modal" data-bs-target="#modalPrintAllBarang">
        <i class="bi bi-printer"></i> Cetak Semua Data
      </button>
      <button class="btn btn-add" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">
        <i class="bi bi-plus-circle"></i> Tambah Barang
      </button>
    </div>
  </div>
  
  <div class="products-table">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>ID</th>
          <th>Gambar</th>
          <th>Nama Barang</th>
          <th>Deskripsi</th>
          <th>Harga</th>
          <th>Stok</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
        <%
          PreparedStatement ps = null;
          ResultSet rs = null;
          boolean hasData = false;
          
          try {
            ps = conn.prepareStatement("SELECT * FROM barang ORDER BY id DESC");
            rs = ps.executeQuery();
            
            while (rs.next()) {
              hasData = true;
              int id = rs.getInt("id");
              String nama = rs.getString("nama");
              String deskripsi = rs.getString("deskripsi");
              int harga = rs.getInt("harga");
              int stok = rs.getInt("stok");
              String gambar = rs.getString("gambar");
        %>
        <tr>
          <td><%= id %></td>
          <td>
            <% if (gambar != null && !gambar.isEmpty()) { %>
              <img src="uploads/<%= gambar %>" alt="<%= nama %>" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;">
            <% } else { %>
              <div style="width: 50px; height: 50px; background: #f8f9fa; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                <i class="bi bi-image text-muted"></i>
              </div>
            <% } %>
          </td>
          <td><strong><%= nama %></strong></td>
          <td><%= deskripsi %></td>
          <td>Rp <%= String.format("%,d", harga) %></td>
          <td>
            <span class="badge <%= stok > 10 ? "bg-success" : (stok > 0 ? "bg-warning" : "bg-danger") %>">
              <%= stok %> unit
            </span>
          </td>
          <td>
            <div class="d-flex gap-1">
              <button class="btn btn-sm btn-print" data-id="<%= id %>" data-bs-toggle="modal" data-bs-target="#modalPrintBarang">
                <i class="bi bi-printer"></i>
              </button>
              <button class="btn btn-sm btn-warning btn-edit" 
                      data-id="<%= id %>"
                      data-nama="<%= nama %>"
                      data-deskripsi="<%= deskripsi %>"
                      data-harga="<%= harga %>"
                      data-stok="<%= stok %>"
                      data-gambar="<%= gambar != null ? gambar : "" %>"
                      data-bs-toggle="modal" 
                      data-bs-target="#modalEditBarang">
                <i class="bi bi-pencil-square"></i>
              </button>
              <a href="delete-barang.jsp?id=<%= id %>" class="btn btn-sm btn-danger" onclick="return confirm('Yakin ingin menghapus barang ini?')">
                <i class="bi bi-trash"></i>
              </a>
            </div>
          </td>
        </tr>
        <%
            }
            
            if (!hasData) {
        %>
        <tr>
          <td colspan="7" class="text-center py-4">
            <i class="bi bi-box" style="font-size: 2rem; opacity: 0.3;"></i>
            <p class="mt-2 mb-0">Belum ada data barang</p>
          </td>
        </tr>
        <%
            }
          } catch (Exception e) {
            out.println("<tr><td colspan='7' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
          } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
          }
        %>
      </tbody>
    </table>
  </div>
</div>

<!-- Modal Print Per Item -->
<div class="modal fade" id="modalPrintBarang" tabindex="-1" aria-labelledby="modalPrintBarangLabel" aria-hidden="true">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="modalPrintBarangLabel">
          <i class="bi bi-printer me-2"></i>Cetak Data Barang
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body text-center">
        <p class="mb-3">Pilih format cetak:</p>
        <p class="fw-bold mb-3">ID Barang: <span id="print-barang-id"></span></p>
        
        <div class="d-grid gap-2">
          <button type="button" class="btn btn-danger" id="printDocx">
            <i class="bi bi-file-earmark-word me-2"></i>Download DOCX
          </button>
          <button type="button" class="btn btn-success" id="printExcel">
            <i class="bi bi-file-earmark-excel me-2"></i>Download Excel
          </button>
        </div>
      </div>
      <div class="modal-footer justify-content-center">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Batal</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal Print Semua Barang -->
<div class="modal fade" id="modalPrintAllBarang" tabindex="-1" aria-labelledby="modalPrintAllBarangLabel" aria-hidden="true">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header bg-info text-white">
        <h5 class="modal-title" id="modalPrintAllBarangLabel">
          <i class="bi bi-printer me-2"></i>Cetak Semua Data Barang
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body text-center">
        <p class="mb-3">Pilih format cetak untuk semua data barang:</p>
        
        <div class="d-grid gap-2">
          <button type="button" class="btn btn-danger" id="printAllDocx">
            <i class="bi bi-file-earmark-word me-2"></i>Download DOCX
          </button>
          <button type="button" class="btn btn-success" id="printAllExcel">
            <i class="bi bi-file-earmark-excel me-2"></i>Download Excel
          </button>
          <button type="button" class="btn btn-primary" id="printAllPdf">
            <i class="bi bi-file-earmark-pdf me-2"></i>Download PDF
          </button>
        </div>
      </div>
      <div class="modal-footer justify-content-center">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Batal</button>
      </div>
    </div>
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
  
  // Handle print button click
  document.querySelectorAll('.btn-print').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const barangId = this.getAttribute('data-id');
      const barangNama = this.getAttribute('data-nama');
      
      document.getElementById('print-barang-id').textContent = barangNama;
      
      // Set up download buttons
      document.getElementById('printDocx').onclick = function() {
        window.open('print-barang.jsp?id=' + barangId + '&format=docx', '_blank');
        bootstrap.Modal.getInstance(document.getElementById('modalPrintBarang')).hide();
      };
      
      document.getElementById('printExcel').onclick = function() {
        window.open('print-barang.jsp?id=' + barangId + '&format=excel', '_blank');
        bootstrap.Modal.getInstance(document.getElementById('modalPrintBarang')).hide();
      };
    });
  });
  
  // Handle print all items
  document.getElementById('printAllDocx').onclick = function() {
    window.open('print-all-barang.jsp?format=docx', '_blank');
    const modal = bootstrap.Modal.getInstance(document.getElementById('modalPrintAllBarang'));
    if (modal) modal.hide();
  };
  
  document.getElementById('printAllExcel').onclick = function() {
    window.open('print-all-barang.jsp?format=excel', '_blank');
    const modal = bootstrap.Modal.getInstance(document.getElementById('modalPrintAllBarang'));
    if (modal) modal.hide();
  };
  
  document.getElementById('printAllPdf').onclick = function() {
    window.open('print-all-barang.jsp?format=pdf', '_blank');
    const modal = bootstrap.Modal.getInstance(document.getElementById('modalPrintAllBarang'));
    if (modal) modal.hide();
  };
</script>
</body>
</html>