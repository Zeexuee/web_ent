<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*" %>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  // Ambil keranjang dari session
  Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
  if (cart == null) cart = new HashMap<>();

  // Jika ada POST (tambah barang)
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    int id = Integer.parseInt(request.getParameter("id"));
    int qty = Integer.parseInt(request.getParameter("qty"));
    cart.put(id, cart.getOrDefault(id, 0) + qty);
    session.setAttribute("cart", cart);
    response.sendRedirect("keranjang.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Keranjang Belanja</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body { background: linear-gradient(135deg, #e0f7fa, #ffffff); padding-top: 60px; }
    .content { max-width: 900px; margin: 40px auto; }
  </style>
</head>
<body>
<div class="content">
  <a href="welcome.jsp" class="btn btn-secondary mb-3">&larr; Kembali</a>
  <h2 class="mb-4">🛒 Keranjang Belanja</h2>
  <%
    if (cart.isEmpty()) {
      out.println("<div class='alert alert-info'>Keranjang kosong.</div>");
    } else {
      int total = 0;
  %>
  <form action="pembayaran.jsp" method="get">
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>Nama Barang</th>
          <th>Harga</th>
          <th>Jumlah</th>
          <th>Subtotal</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
      <%
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
              int harga = rs.getInt("harga");
              int subtotal = harga * qty;
              total += subtotal;
      %>
        <tr>
          <td><%= rs.getString("nama") %></td>
          <td>Rp <%= harga %></td>
          <td><%= qty %></td>
          <td>Rp <%= subtotal %></td>
          <td>
            <a href="keranjang.jsp?remove=<%= id %>" class="btn btn-danger btn-sm">Hapus</a>
          </td>
        </tr>
      <%
            }
            rs.close();
          }
          conn.close();
        } catch (Exception e) {
          out.println("<tr><td colspan='5' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
        }
      %>
      </tbody>
      <tfoot>
        <tr>
          <th colspan="3" class="text-end">Total</th>
          <th colspan="2">Rp <%= total %></th>
        </tr>
      </tfoot>
    </table>
    <button type="submit" class="btn btn-primary">Lanjut Pembayaran</button>
  </form>
  <%
    }
    // Hapus barang dari keranjang
    String removeId = request.getParameter("remove");
    if (removeId != null) {
      cart.remove(Integer.parseInt(removeId));
      session.setAttribute("cart", cart);
      response.sendRedirect("keranjang.jsp");
      return;
    }
  %>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>