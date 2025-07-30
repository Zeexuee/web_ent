<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*, java.text.SimpleDateFormat, java.util.Date, org.apache.poi.xwpf.usermodel.*, org.apache.poi.ss.usermodel.*, org.apache.poi.xssf.usermodel.*" %>
<%
  String barangId = request.getParameter("id");
  String format = request.getParameter("format");
  
  if (barangId == null || format == null) {
    response.sendRedirect("data-barang.jsp");
    return;
  }
  
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    
    ps = conn.prepareStatement("SELECT * FROM barang WHERE id = ?");
    ps.setInt(1, Integer.parseInt(barangId));
    rs = ps.executeQuery();
    
    if (rs.next()) {
      String nama = rs.getString("nama");
      String deskripsi = rs.getString("deskripsi");
      int harga = rs.getInt("harga");
      int stok = rs.getInt("stok");
      String gambar = rs.getString("gambar");
      
      String fileName = "Data_Barang_" + nama.replaceAll("[^a-zA-Z0-9]", "_");
      String currentDate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date());
      
      if ("docx".equals(format)) {
        // Generate DOCX
        response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".docx\"");
        
        XWPFDocument document = new XWPFDocument();
        
        // Title
        XWPFParagraph title = document.createParagraph();
        title.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun titleRun = title.createRun();
        titleRun.setText("DATA BARANG TOKO KITA");
        titleRun.setBold(true);
        titleRun.setFontSize(16);
        
        // Date
        XWPFParagraph dateP = document.createParagraph();
        dateP.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun dateRun = dateP.createRun();
        dateRun.setText("Dicetak pada: " + currentDate);
        dateRun.setFontSize(10);
        
        // Empty line
        document.createParagraph().createRun().addBreak();
        
        // Product details
        XWPFParagraph details = document.createParagraph();
        XWPFRun detailsRun = details.createRun();
        detailsRun.setText("ID Barang: " + barangId);
        detailsRun.addBreak();
        detailsRun.setText("Nama Barang: " + nama);
        detailsRun.addBreak();
        detailsRun.setText("Deskripsi: " + deskripsi);
        detailsRun.addBreak();
        detailsRun.setText("Harga: Rp " + String.format("%,d", harga));
        detailsRun.addBreak();
        detailsRun.setText("Stok: " + stok + " unit");
        detailsRun.addBreak();
        detailsRun.setText("Gambar: " + (gambar != null ? gambar : "Tidak ada gambar"));
        
        document.write(response.getOutputStream());
        document.close();
        
      } else if ("excel".equals(format)) {
        // Generate Excel
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".xlsx\"");
        
        XSSFWorkbook workbook = new XSSFWorkbook();
        XSSFSheet sheet = workbook.createSheet("Data Barang");
        
        // Create header style
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);
        
        // Title row
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("DATA BARANG TOKO KITA");
        titleCell.setCellStyle(headerStyle);
        
        // Date row
        Row dateRow = sheet.createRow(1);
        Cell dateCell = dateRow.createCell(0);
        dateCell.setCellValue("Dicetak pada: " + currentDate);
        
        // Empty row
        sheet.createRow(2);
        
        // Data rows
        String[] labels = {"ID Barang", "Nama Barang", "Deskripsi", "Harga", "Stok", "Gambar"};
        String[] values = {
          barangId,
          nama,
          deskripsi,
          "Rp " + String.format("%,d", harga),
          stok + " unit",
          gambar != null ? gambar : "Tidak ada gambar"
        };
        
        for (int i = 0; i < labels.length; i++) {
          Row row = sheet.createRow(3 + i);
          
          Cell labelCell = row.createCell(0);
          labelCell.setCellValue(labels[i]);
          labelCell.setCellStyle(headerStyle);
          
          Cell valueCell = row.createCell(1);
          valueCell.setCellValue(values[i]);
        }
        
        // Auto-size columns
        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
        
        workbook.write(response.getOutputStream());
        workbook.close();
      }
      
    } else {
      response.sendRedirect("data-barang.jsp?error=Data tidak ditemukan");
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("data-barang.jsp?error=" + e.getMessage());
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (ps != null) try { ps.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>