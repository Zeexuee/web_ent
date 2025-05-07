<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>

<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String userId = request.getParameter("id");
  String nama = request.getParameter("nama");
  String email = request.getParameter("email");

  if (userId == null || nama == null || email == null) {
    out.println("<p class='text-danger'>Data tidak lengkap.</p>");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  String sql = "UPDATE users SET nama = ?, email = ? WHERE id = ?";
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    ps = conn.prepareStatement(sql);
    ps.setString(1, nama);
    ps.setString(2, email);
    ps.setInt(3, Integer.parseInt(userId));

    int rowsUpdated = ps.executeUpdate();
    if (rowsUpdated > 0) {
      out.println("<p class='text-success'>Data pengguna berhasil diperbarui.</p>");
    } else {
      out.println("<p class='text-warning'>Tidak ada perubahan pada data pengguna.</p>");
    }
  } catch (Exception e) {
    out.println("<p class='text-danger'>Terjadi kesalahan: " + e.getMessage() + "</p>");
  } finally {
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>
