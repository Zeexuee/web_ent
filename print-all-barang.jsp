<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*, java.text.SimpleDateFormat, java.util.Date, org.apache.poi.xwpf.usermodel.*, org.apache.poi.ss.usermodel.*, org.apache.poi.xssf.usermodel.*" %>
<%
  String format = request.getParameter("format");
  
  if (format == null) {
    response.sendRedirect("data-barang.jsp");
    return;
  }
  
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
    
    ps = conn.prepareStatement("SELECT * FROM barang ORDER BY id ASC");
    rs = ps.executeQuery();
    
    String fileName = "Data_Semua_Barang_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
    String currentDate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date());
    
    if ("docx".equals(format)) {
      // Generate DOCX untuk semua barang
      response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
      response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".docx\"");
      
      XWPFDocument document = new XWPFDocument();
      
      // Title
      XWPFParagraph title = document.createParagraph();
      title.setAlignment(ParagraphAlignment.CENTER);
      XWPFRun titleRun = title.createRun();
      titleRun.setText("DATA SEMUA BARANG TOKO KITA");
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
      
      // Table
      XWPFTable table = document.createTable();
      
      // Header row
      XWPFTableRow headerRow = table.getRow(0);
      headerRow.getCell(0).setText("ID");
      headerRow.addNewTableCell().setText("Nama Barang");
      headerRow.addNewTableCell().setText("Deskripsi");
      headerRow.addNewTableCell().setText("Harga");
      headerRow.addNewTableCell().setText("Stok");
      headerRow.addNewTableCell().setText("Gambar");
      
      // Data rows
      while (rs.next()) {
        XWPFTableRow row = table.createRow();
        row.getCell(0).setText(String.valueOf(rs.getInt("id")));
        row.getCell(1).setText(rs.getString("nama"));
        row.getCell(2).setText(rs.getString("deskripsi"));
        row.getCell(3).setText("Rp " + String.format("%,d", rs.getInt("harga")));
        row.getCell(4).setText(rs.getInt("stok") + " unit");
        row.getCell(5).setText(rs.getString("gambar") != null ? rs.getString("gambar") : "Tidak ada gambar");
      }
      
      document.write(response.getOutputStream());
      document.close();
      
    } else if ("excel".equals(format)) {
      // Generate Excel untuk semua barang
      response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".xlsx\"");
      
      XSSFWorkbook workbook = new XSSFWorkbook();
      XSSFSheet sheet = workbook.createSheet("Data Semua Barang");
      
      // Create header style
      CellStyle headerStyle = workbook.createCellStyle();
      Font headerFont = workbook.createFont();
      headerFont.setBold(true);
      headerStyle.setFont(headerFont);
      headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
      headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
      
      // Title row
      Row titleRow = sheet.createRow(0);
      Cell titleCell = titleRow.createCell(0);
      titleCell.setCellValue("DATA SEMUA BARANG TOKO KITA");
      
      // Date row
      Row dateRow = sheet.createRow(1);
      Cell dateCell = dateRow.createCell(0);
      dateCell.setCellValue("Dicetak pada: " + currentDate);
      
      // Empty row
      sheet.createRow(2);
      
      // Header row
      Row headerRow = sheet.createRow(3);
      String[] headers = {"ID", "Nama Barang", "Deskripsi", "Harga", "Stok", "Gambar"};
      for (int i = 0; i < headers.length; i++) {
        Cell cell = headerRow.createCell(i);
        cell.setCellValue(headers[i]);
        cell.setCellStyle(headerStyle);
      }
      
      // Data rows
      int rowNum = 4;
      while (rs.next()) {
        Row row = sheet.createRow(rowNum++);
        row.createCell(0).setCellValue(rs.getInt("id"));
        row.createCell(1).setCellValue(rs.getString("nama"));
        row.createCell(2).setCellValue(rs.getString("deskripsi"));
        row.createCell(3).setCellValue("Rp " + String.format("%,d", rs.getInt("harga")));
        row.createCell(4).setCellValue(rs.getInt("stok") + " unit");
        row.createCell(5).setCellValue(rs.getString("gambar") != null ? rs.getString("gambar") : "Tidak ada gambar");
      }
      
      // Auto-size columns
      for (int i = 0; i < headers.length; i++) {
        sheet.autoSizeColumn(i);
      }
      
      workbook.write(response.getOutputStream());
      workbook.close();
      
    } else if ("pdf".equals(format)) {
      // Generate HTML untuk PDF (tanpa library iText)
      response.setContentType("text/html");
      response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".html\"");
      
      out.println("<!DOCTYPE html>");
      out.println("<html>");
      out.println("<head>");
      out.println("<title>Data Semua Barang</title>");
      out.println("<style>");
      out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
      out.println("table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
      out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
      out.println("th { background-color: #f2f2f2; font-weight: bold; }");
      out.println("h1 { text-align: center; }");
      out.println(".date { text-align: right; margin-bottom: 20px; }");
      out.println("</style>");
      out.println("</head>");
      out.println("<body>");
      out.println("<h1>DATA SEMUA BARANG TOKO KITA</h1>");
      out.println("<div class='date'>Dicetak pada: " + currentDate + "</div>");
      out.println("<table>");
      out.println("<tr><th>ID</th><th>Nama Barang</th><th>Deskripsi</th><th>Harga</th><th>Stok</th><th>Gambar</th></tr>");
      
      while (rs.next()) {
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id") + "</td>");
        out.println("<td>" + rs.getString("nama") + "</td>");
        out.println("<td>" + rs.getString("deskripsi") + "</td>");
        out.println("<td>Rp " + String.format("%,d", rs.getInt("harga")) + "</td>");
        out.println("<td>" + rs.getInt("stok") + " unit</td>");
        out.println("<td>" + (rs.getString("gambar") != null ? rs.getString("gambar") : "Tidak ada gambar") + "</td>");
        out.println("</tr>");
      }
      
      out.println("</table>");
      out.println("</body>");
      out.println("</html>");
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