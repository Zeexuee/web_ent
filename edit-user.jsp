<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>

<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String userId = request.getParameter("id");
  if (userId == null) {
    out.println("<p class='text-danger'>ID pengguna tidak ditemukan.</p>");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  String sql = "SELECT id, nama, email FROM users WHERE id = ?";
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(userId));
    rs = ps.executeQuery();

    if (rs.next()) {
      String nama = rs.getString("nama");
      String email = rs.getString("email");
%>
      <h2>Edit Data Pengguna</h2>
      <form action="update-user.jsp" method="post">
        <input type="hidden" name="id" value="<%= userId %>" />
        <div class="form-group">
          <label for="nama">Nama:</label>
          <input type="text" id="nama" name="nama" class="form-control" value="<%= nama %>" required />
        </div>
        <div class="form-group">
          <label for="email">Email:</label>
          <input type="email" id="email" name="email" class="form-control" value="<%= email %>" required />
        </div>
        <button type="submit" class="btn btn-primary mt-3">Simpan Perubahan</button>
      </form>
<%
    } else {
      out.println("<p class='text-danger'>Pengguna tidak ditemukan.</p>");
    }
  } catch (Exception e) {
    out.println("<p class='text-danger'>Terjadi kesalahan: " + e.getMessage() + "</p>");
  } finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>
