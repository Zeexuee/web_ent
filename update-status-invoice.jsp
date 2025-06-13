<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String invoiceIdStr = request.getParameter("id");
  String newStatus = request.getParameter("status");

  if (invoiceIdStr == null || invoiceIdStr.isEmpty() || newStatus == null || newStatus.isEmpty()) {
    response.sendRedirect("list-invoice-admin.jsp?error=InvalidInput");
    return;
  }

  int invoiceId = Integer.parseInt(invoiceIdStr);

  Connection conn = null;
  PreparedStatement ps = null;

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    String sql = "UPDATE invoice SET status = ? WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setString(1, newStatus);
    ps.setInt(2, invoiceId);

    int rowsUpdated = ps.executeUpdate();
    if (rowsUpdated > 0) {
      response.sendRedirect("list-invoice-admin.jsp?success=StatusUpdated");
    } else {
      response.sendRedirect("list-invoice-admin.jsp?error=UpdateFailed");
    }
  } catch (Exception e) {
    response.sendRedirect("list-invoice-admin.jsp?error=" + e.getMessage());
  } finally {
    if (ps != null) try { ps.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>