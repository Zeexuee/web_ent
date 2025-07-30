<%@ page contentType="application/pdf" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.io.*, java.util.*" %>
<%@ page import="com.itextpdf.text.*, com.itextpdf.text.pdf.*" %>
<%
  // Check authentication
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String invoiceIdStr = request.getParameter("id");
  if (invoiceIdStr == null) {
    out.println("ID Invoice tidak ditemukan");
    return;
  }
  
  int invoiceId = Integer.parseInt(invoiceIdStr);
  
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    
    // Get invoice data
    ps = conn.prepareStatement("SELECT * FROM invoice WHERE id=?");
    ps.setInt(1, invoiceId);
    rs = ps.executeQuery();
    
    if (!rs.next()) {
      out.println("Invoice tidak ditemukan");
      return;
    }
    
    String user = rs.getString("user");
    String namaPenerima = rs.getString("nama_penerima");
    String alamat = rs.getString("alamat");
    String metode = rs.getString("metode");
    String tanggal = rs.getString("tanggal");
    String status = rs.getString("status");
    int total = rs.getInt("total");
    
    rs.close();
    ps.close();
    
    // Set response headers for PDF
    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "attachment; filename=invoice_" + invoiceId + ".pdf");
    
    // Create PDF document
    Document document = new Document();
    PdfWriter.getInstance(document, response.getOutputStream());
    document.open();
    
    // Add content to PDF
    Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
    Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
    Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
    
    // Title
    Paragraph title = new Paragraph("INVOICE TOKOKITA", titleFont);
    title.setAlignment(Element.ALIGN_CENTER);
    document.add(title);
    document.add(new Paragraph(" "));
    
    // Invoice details
    document.add(new Paragraph("Invoice ID: " + invoiceId, headerFont));
    document.add(new Paragraph("Username: " + user, normalFont));
    document.add(new Paragraph("Nama Penerima: " + namaPenerima, normalFont));
    document.add(new Paragraph("Alamat: " + alamat, normalFont));
    document.add(new Paragraph("Metode Pembayaran: " + metode, normalFont));
    document.add(new Paragraph("Tanggal: " + tanggal, normalFont));
    document.add(new Paragraph("Status: " + status.toUpperCase(), normalFont));
    document.add(new Paragraph(" "));
    
    // Items table
    PdfPTable table = new PdfPTable(4);
    table.setWidthPercentage(100);
    table.addCell(new PdfPCell(new Phrase("Nama Barang", headerFont)));
    table.addCell(new PdfPCell(new Phrase("Harga", headerFont)));
    table.addCell(new PdfPCell(new Phrase("Jumlah", headerFont)));
    table.addCell(new PdfPCell(new Phrase("Subtotal", headerFont)));
    
    // Get invoice details
    ps = conn.prepareStatement("SELECT * FROM invoice_detail WHERE invoice_id=?");
    ps.setInt(1, invoiceId);
    rs = ps.executeQuery();
    
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("id", "ID"));
    
    while (rs.next()) {
      table.addCell(new PdfPCell(new Phrase(rs.getString("nama_barang"), normalFont)));
      table.addCell(new PdfPCell(new Phrase("Rp " + formatter.format(rs.getInt("harga")), normalFont)));
      table.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("qty")), normalFont)));
      table.addCell(new PdfPCell(new Phrase("Rp " + formatter.format(rs.getInt("subtotal")), normalFont)));
    }
    
    document.add(table);
    document.add(new Paragraph(" "));
    
    // Total
    Paragraph totalParagraph = new Paragraph("TOTAL: Rp " + formatter.format(total), headerFont);
    totalParagraph.setAlignment(Element.ALIGN_RIGHT);
    document.add(totalParagraph);
    
    document.close();
    
  } catch (Exception e) {
    // Handle error - redirect to error page or show message
    response.setContentType("text/html");
    out.println("<html><body><h3>Error generating PDF: " + e.getMessage() + "</h3></body></html>");
    e.printStackTrace();
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (ps != null) try { ps.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>