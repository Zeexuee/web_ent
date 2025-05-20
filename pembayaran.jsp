<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*" %>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
  List<Map<String, Object>> items = new ArrayList<>();
  int total = 0;

  String idParam = request.getParameter("id");
  String qtyParam = request.getParameter("qty");

  if (idParam != null && qtyParam != null) {
    // Beli satu barang langsung
    int id = Integer.parseInt(idParam);
    int qty = Integer.parseInt(qtyParam);
    Connection conn = null;
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
      PreparedStatement ps = conn.prepareStatement("SELECT * FROM barang WHERE id=?");
      ps.setInt(1, id);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        Map<String, Object> item = new HashMap<>();
        item.put("id", id);
        item.put("nama", rs.getString("nama"));
        item.put("harga", rs.getInt("harga"));
        item.put("qty", qty);
        item.put("subtotal", rs.getInt("harga") * qty);
        total += rs.getInt("harga") * qty;
        items.add(item);
      }
      rs.close();
      conn.close();
    } catch (Exception e) {
      out.println("<div class='alert alert-danger'>Gagal mengambil data barang: " + e.getMessage() + "</div>");
    }
  } else if (cart != null && !cart.isEmpty()) {
    // Dari keranjang
    Connection conn = null;
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
      for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
        int id = entry.getKey();
        int qty = entry.getValue();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM barang WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
          Map<String, Object> item = new HashMap<>();
          item.put("id", id);
          item.put("nama", rs.getString("nama"));
          item.put("harga", rs.getInt("harga"));
          item.put("qty", qty);
          item.put("subtotal", rs.getInt("harga") * qty);
          total += rs.getInt("harga") * qty;
          items.add(item);
        }
        rs.close();
      }
      conn.close();
    } catch (Exception e) {
      out.println("<div class='alert alert-danger'>Gagal mengambil data barang: " + e.getMessage() + "</div>");
    }
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Pembayaran</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body { background: linear-gradient(135deg, #e0f7fa, #ffffff); padding-top: 60px; }
    .content { max-width: 700px; margin: 40px auto; }
  </style>
</head>
<body>
<div class="content">
  <a href="keranjang.jsp" class="btn btn-secondary mb-3">&larr; Kembali</a>
  <h2 class="mb-4">💳 Pembayaran</h2>
  <h5>Ringkasan Belanja:</h5>
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
      <% for (Map<String, Object> item : items) { %>
      <tr>
        <td><%= item.get("nama") %></td>
        <td>Rp <%= item.get("harga") %></td>
        <td><%= item.get("qty") %></td>
        <td>Rp <%= item.get("subtotal") %></td>
      </tr>
      <% } %>
    </tbody>
    <tfoot>
      <tr>
        <th colspan="3" class="text-end">Total</th>
        <th>Rp <%= total %></th>
      </tr>
    </tfoot>
  </table>
  <form action="invoice.jsp" method="post" class="mt-4">
    <input type="hidden" name="total" value="<%= total %>">
    <%-- Kirim data barang yang dibeli ke invoice.jsp --%>
    <% for (Map<String, Object> item : items) { %>
      <input type="hidden" name="barang_id" value="<%= item.get("id") %>">
      <input type="hidden" name="barang_nama" value="<%= item.get("nama") %>">
      <input type="hidden" name="barang_harga" value="<%= item.get("harga") %>">
      <input type="hidden" name="barang_qty" value="<%= item.get("qty") %>">
      <input type="hidden" name="barang_subtotal" value="<%= item.get("subtotal") %>">
    <% } %>
    <div class="mb-3">
      <label class="form-label">Nama Penerima</label>
      <input type="text" name="nama_penerima" class="form-control" required>
    </div>
    <div class="mb-3">
      <label class="form-label">Alamat Pengiriman</label>
      <textarea name="alamat" class="form-control" required></textarea>
    </div>
    <div class="mb-3">
      <label class="form-label">Metode Pembayaran</label>
      <select name="metode" id="metode" class="form-select" required onchange="toggleBankInput()">
        <option value="Transfer Bank">Transfer Bank</option>
        <option value="COD">COD</option>
        <option value="E-Wallet">E-Wallet</option>
      </select>
    </div>
    <div class="mb-3" id="bankInput" style="display: block;">
      <label class="form-label">Pilih Bank</label>
      <select name="nama_bank" class="form-select">
        <option value="BCA">BCA</option>
        <option value="BNI">BNI</option>
        <option value="BRI">BRI</option>
        <option value="Mandiri">Mandiri</option>
        <option value="CIMB">CIMB</option>
      </select>
    </div>
    <button type="submit" class="btn btn-success">Konfirmasi & Bayar</button>
  </form>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
<script>
function toggleBankInput() {
  var metode = document.getElementById('metode').value;
  document.getElementById('bankInput').style.display = (metode === 'Transfer Bank') ? 'block' : 'none';
}
window.onload = toggleBankInput;
</script>
</body>
</html>