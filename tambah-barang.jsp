<%@ page import="java.sql.*, java.io.*, jakarta.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Koneksi database langsung dalam file
  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
  } catch (Exception e) {
    out.println("Connection Error: " + e.getMessage());
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  String nama = request.getParameter("nama");
  String deskripsi = request.getParameter("deskripsi");
  String harga = request.getParameter("harga");
  String stok = request.getParameter("stok");
  Part filePart = request.getPart("gambar");
  String fileName = null;

  if (filePart != null && filePart.getSize() > 0) {
    fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();

    // Simpan ke folder project (web/uploads)
    String uploadPath = application.getRealPath("/uploads");
    // Jika folder belum ada, buat folder
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    try (InputStream input = filePart.getInputStream()) {
      File file = new File(uploadPath, fileName);
      try (FileOutputStream fos = new FileOutputStream(file)) {
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = input.read(buffer)) != -1) {
          fos.write(buffer, 0, bytesRead);
        }
      }
    } catch(Exception e) {
      System.out.println("Upload error: " + e.getMessage());
      e.printStackTrace();
    }
  }

  if (nama != null && deskripsi != null && harga != null && stok != null && fileName != null) {
    try {
      String sql = "INSERT INTO barang (nama, deskripsi, harga, stok, gambar) VALUES (?, ?, ?, ?, ?)";
      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setString(1, nama);
      ps.setString(2, deskripsi);
      ps.setInt(3, Integer.parseInt(harga));
      ps.setInt(4, Integer.parseInt(stok));
      ps.setString(5, fileName);
      ps.executeUpdate();
      ps.close();
    } catch (Exception e) {
      out.println("Gagal menambah barang: " + e.getMessage());
      e.printStackTrace();
    }
  }
  response.sendRedirect("data-barang.jsp");
%>