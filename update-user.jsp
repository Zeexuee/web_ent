<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*" %>
<%
  String id = request.getParameter("id");
  String nama = request.getParameter("nama");
  String email = request.getParameter("email");

  if (id == null || nama == null || email == null || id.isEmpty() || nama.isEmpty() || email.isEmpty()) {
    response.sendRedirect("data-user.jsp?error=invalid-input");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    String sql = "UPDATE users SET nama = ?, email = ? WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setString(1, nama);
    ps.setString(2, email);
    ps.setInt(3, Integer.parseInt(id));

    int result = ps.executeUpdate();

    if (result > 0) {
      response.sendRedirect("data-user.jsp?status=update-success");
    } else {
      response.sendRedirect("data-user.jsp?error=update-failed");
    }

  } catch (Exception e) {
    response.sendRedirect("data-user.jsp?error=update-error&message=" + e.getMessage());
  } finally {
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>
