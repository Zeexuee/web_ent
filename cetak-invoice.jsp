<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.util.*, com.google.gson.*" %>
<%
  // Check authentication
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  String invoiceIdStr = request.getParameter("id");
  String format = request.getParameter("format");
  
  if (invoiceIdStr == null || format == null) {
    out.println("Parameter tidak lengkap");
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
    
    // Get invoice details
    ps = conn.prepareStatement("SELECT * FROM invoice_detail WHERE invoice_id=?");
    ps.setInt(1, invoiceId);
    rs = ps.executeQuery();
    
    List<Map<String, Object>> items = new ArrayList<>();
    while (rs.next()) {
      Map<String, Object> item = new HashMap<>();
      item.put("nama_barang", rs.getString("nama_barang"));
      item.put("harga", rs.getInt("harga"));
      item.put("qty", rs.getInt("qty"));
      item.put("subtotal", rs.getInt("subtotal"));
      items.add(item);
    }
    
    if ("json".equals(format)) {
      // JSON Format
      response.setContentType("application/json");
      response.setHeader("Content-Disposition", "attachment; filename=invoice_" + invoiceId + ".json");
      
      Map<String, Object> invoiceData = new HashMap<>();
      invoiceData.put("id", invoiceId);
      invoiceData.put("user", user);
      invoiceData.put("nama_penerima", namaPenerima);
      invoiceData.put("alamat", alamat);
      invoiceData.put("metode", metode);
      invoiceData.put("tanggal", tanggal);
      invoiceData.put("status", status);
      invoiceData.put("total", total);
      invoiceData.put("items", items);
      
      Gson gson = new GsonBuilder().setPrettyPrinting().create();
      out.print(gson.toJson(invoiceData));
      
    } else if ("txt".equals(format)) {
      // TXT Format (Plain text, could be enhanced to PDF)
      response.setContentType("text/plain");
      response.setHeader("Content-Disposition", "attachment; filename=invoice_" + invoiceId + ".txt");
      
      NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("id", "ID"));
      
      out.println("=================================================");
      out.println("                INVOICE TOKOKITA");
      out.println("=================================================");
      out.println();
      out.println("Invoice ID     : " + invoiceId);
      out.println("Username       : " + user);
      out.println("Nama Penerima  : " + namaPenerima);
      out.println("Alamat         : " + alamat);
      out.println("Metode Bayar   : " + metode);
      out.println("Tanggal        : " + tanggal);
      out.println("Status         : " + status.toUpperCase());
      out.println();
      out.println("=================================================");
      out.println("                DETAIL PESANAN");
      out.println("=================================================");
      out.println();
      
      for (Map<String, Object> item : items) {
        out.println("Nama Barang    : " + item.get("nama_barang"));
        out.println("Harga          : Rp " + formatter.format(item.get("harga")));
        out.println("Jumlah         : " + item.get("qty"));
        out.println("Subtotal       : Rp " + formatter.format(item.get("subtotal")));
        out.println("-------------------------------------------------");
      }
      
      out.println();
      out.println("TOTAL PEMBAYARAN: Rp " + formatter.format(total));
      out.println();
      out.println("=================================================");
      out.println("        Terima kasih atas pembelian Anda!");
      out.println("=================================================");
      
    } else {
      out.println("Format tidak didukung");
    }
    
  } catch (Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace();
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (ps != null) try { ps.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
  }
%>