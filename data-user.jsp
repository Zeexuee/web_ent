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
  <title>Data Pengguna</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 60px;
    }
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100%;
      width: 250px;
      background-color: #343a40;
      padding-top: 20px;
    }
    .sidebar a {
      color: white;
      padding: 10px 15px;
      text-decoration: none;
      display: block;
    }
    .sidebar a:hover {
      background-color: #575757;
    }
    .sidebar a.active {
      background-color: #495057;
      font-weight: bold;
    }
    .content {
      margin-left: 260px;
      padding: 20px;
    }
  </style>
</head>
<body>

<div class="sidebar">
  <h3 class="text-white text-center">Menu</h3>
  <a href="welcome.jsp">🏠 Home</a>
  <a href="data-user.jsp" class="active">📋 Data Pengguna</a>
  <a href="logout.jsp" class="btn btn-outline-danger mt-3">🚪 Logout</a>
</div>

<div class="content">
  <div class="card p-4">
    <h4 class="mb-3">📋 Daftar Pengguna</h4>
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
