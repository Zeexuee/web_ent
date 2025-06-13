<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*" %>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  String namaPenerima = request.getParameter("nama_penerima");
  String alamat = request.getParameter("alamat");
  String metode = request.getParameter("metode");
  int total = Integer.parseInt(request.getParameter("total"));

  // Ambil data barang dari parameter
  String[] barang_id = request.getParameterValues("barang_id");
  String[] barang_nama = request.getParameterValues("barang_nama");
  String[] barang_harga = request.getParameterValues("barang_harga");
  String[] barang_qty = request.getParameterValues("barang_qty");
  String[] barang_subtotal = request.getParameterValues("barang_subtotal");

  int invoiceId = -1;
  boolean success = false;

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    // Insert ke tabel invoice
    PreparedStatement ps = conn.prepareStatement(
      "INSERT INTO invoice (user, nama_penerima, alamat, metode, total) VALUES (?, ?, ?, ?, ?)",
      Statement.RETURN_GENERATED_KEYS
    );
    ps.setString(1, userName);
    ps.setString(2, namaPenerima);
    ps.setString(3, alamat);
    ps.setString(4, metode);
    ps.setInt(5, total);
    ps.executeUpdate();

    ResultSet rs = ps.getGeneratedKeys();
    if (rs.next()) {
      invoiceId = rs.getInt(1);
    }
    rs.close();
    ps.close();

    // Insert ke tabel invoice_detail dan update stok barang
    if (invoiceId > 0 && barang_id != null) {
      for (int i = 0; i < barang_id.length; i++) {
        // Simpan detail invoice
        PreparedStatement psDetail = conn.prepareStatement(
          "INSERT INTO invoice_detail (invoice_id, barang_id, nama_barang, harga, qty, subtotal) VALUES (?, ?, ?, ?, ?, ?)"
        );
        psDetail.setInt(1, invoiceId);
        psDetail.setInt(2, Integer.parseInt(barang_id[i]));
        psDetail.setString(3, barang_nama[i]);
        psDetail.setInt(4, Integer.parseInt(barang_harga[i]));
        psDetail.setInt(5, Integer.parseInt(barang_qty[i]));
        psDetail.setInt(6, Integer.parseInt(barang_subtotal[i]));
        psDetail.executeUpdate();
        psDetail.close();

        // Update stok barang
        PreparedStatement psUpdateStok = conn.prepareStatement(
          "UPDATE barang SET stok = stok - ? WHERE id = ?"
        );
        psUpdateStok.setInt(1, Integer.parseInt(barang_qty[i]));
        psUpdateStok.setInt(2, Integer.parseInt(barang_id[i]));
        psUpdateStok.executeUpdate();
        psUpdateStok.close();
      }
      success = true;
      // Kosongkan keranjang di session
      session.removeAttribute("cart");
    }
    conn.close();
  } catch (Exception e) {
    out.println("<div class='alert alert-danger'>Gagal menyimpan invoice: " + e.getMessage() + "</div>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Invoice</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body { background: linear-gradient(135deg, #e0f7fa, #ffffff); padding-top: 60px; }
    .content { max-width: 700px; margin: 40px auto; }
  </style>
</head>
<body>
<div class="content">
  <h2 class="mb-4">🧾 Invoice</h2>
  <% if (success) { %>
    <div class="alert alert-success">Pembayaran berhasil! Berikut detail invoice Anda.</div>
    <div class="mb-3"><b>ID Invoice:</b> <%= invoiceId %></div>
    <div class="mb-3"><b>Nama Penerima:</b> <%= namaPenerima %></div>
    <div class="mb-3"><b>Alamat:</b> <%= alamat %></div>
    <div class="mb-3"><b>Metode Pembayaran:</b> <%= metode %></div>
    <div class="mb-3"><b>Total:</b> Rp <%= total %></div>
    <h5 class="mt-4">Barang yang Dibeli:</h5>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>Nama Barang</th>
          <th>Harga</th>
          <th>Jumlah</th>
          <th>Subtotal</th>
        </tr>
      </thead>
      <tbody>
        <% for (int i = 0; i < barang_id.length; i++) { %>
        <tr>
          <td><%= barang_nama[i] %></td>
          <td>Rp <%= barang_harga[i] %></td>
          <td><%= barang_qty[i] %></td>
          <td>Rp <%= barang_subtotal[i] %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
    <a href="welcome.jsp" class="btn btn-primary mt-3">Kembali ke Home</a>
  <% } else { %>
    <div class="alert alert-danger">Terjadi kesalahan saat menyimpan invoice.</div>
  <% } %>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>