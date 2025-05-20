<%@ page import="java.sql.*, java.io.*, jakarta.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Koneksi database
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
  String idStr = request.getParameter("id");
  String nama = request.getParameter("nama");
  String deskripsi = request.getParameter("deskripsi");
  String harga = request.getParameter("harga");
  String stok = request.getParameter("stok");
  Part filePart = request.getPart("gambar");
  String fileName = null;
  boolean fileUploaded = false;

  // Periksa apakah ID valid
  if (idStr != null && !idStr.trim().isEmpty()) {
    int id = Integer.parseInt(idStr);
    
    try {
      // Jika ada file yang diupload
      if (filePart != null && filePart.getSize() > 0) {
        fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
        
        // Menggunakan path relatif terhadap aplikasi web
        String uploadPath = getServletContext().getRealPath("/") + "uploads";
        
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
          uploadDir.mkdirs();
        }
        
        // Logging untuk debugging
        System.out.println("Upload directory: " + uploadDir.getAbsolutePath());
        System.out.println("File will be saved as: " + uploadDir.getAbsolutePath() + File.separator + fileName);
        
        // Tulis file ke direktori uploads
        filePart.write(uploadDir.getAbsolutePath() + File.separator + fileName);
        fileUploaded = true;
        
        System.out.println("File successfully uploaded: " + fileName);
      }
      
      // Update data barang
      String sql;
      PreparedStatement ps;
      
      if (fileUploaded) {
        // Jika gambar diganti
        sql = "UPDATE barang SET nama=?, deskripsi=?, harga=?, stok=?, gambar=? WHERE id=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nama);
        ps.setString(2, deskripsi);
        ps.setInt(3, Integer.parseInt(harga));
        ps.setInt(4, Integer.parseInt(stok));
        ps.setString(5, fileName);
        ps.setInt(6, id);
      } else {
        // Jika gambar tidak diganti
        sql = "UPDATE barang SET nama=?, deskripsi=?, harga=?, stok=? WHERE id=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nama);
        ps.setString(2, deskripsi);
        ps.setInt(3, Integer.parseInt(harga));
        ps.setInt(4, Integer.parseInt(stok));
        ps.setInt(5, id);
      }
      
      int result = ps.executeUpdate();
      ps.close();
      
      if (result > 0) {
        System.out.println("Barang berhasil diupdate dengan ID: " + id);
      } else {
        System.out.println("Gagal mengupdate barang dengan ID: " + id);
      }
      
    } catch (Exception e) {
      System.out.println("Error saat mengupdate barang: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  // Redirect kembali ke halaman data barang
  response.sendRedirect("data-barang.jsp");
%>