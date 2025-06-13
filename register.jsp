<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Register</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #f8f9fa, #e2e6ea);
      padding-top: 80px;
    }
    .card {
      border: none;
      border-radius: 16px;
    }
  </style>
</head>
<body>
  <div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="col-md-6">
      <div class="card p-4 shadow">
        <h3 class="text-center mb-4 text-primary">📝 Register</h3>
        <% 
          String error = request.getParameter("error");
          if (error != null) { 
        %>
          <div class="alert alert-danger mb-3">
            <% if ("email_exists".equals(error)) { %>
              Email sudah terdaftar. Silakan gunakan email lain.
            <% } else { %>
              Terjadi kesalahan: <%= error %>
            <% } %>
          </div>
        <% } %>
        <form action="register-process.jsp" method="post">
          <div class="mb-3">
            <label for="nama" class="form-label">Nama Lengkap</label>
            <input type="text" class="form-control" id="nama" name="nama" required>
          </div>
          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" id="email" name="email" required>
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="password" class="form-control" id="password" name="password" required>
          </div>
          <div class="d-grid">
            <button type="submit" class="btn btn-primary btn-lg">Daftar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</body>
</html>