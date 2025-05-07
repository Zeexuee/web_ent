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
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Selamat Datang</title>
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
  <a href="data-user.jsp">📋 Data Pengguna</a>
  <a href="logout.jsp" class="btn btn-outline-danger mt-3">🚪 Logout</a>
</div>

<div class="content">
  <div class="card text-center mb-5">
    <h1 class="text-success mb-3">👋 Selamat Datang, <%= userName %>!</h1>
    <p class="lead">Selamat datang web aplikasi punya saya hhahahah.</p>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
