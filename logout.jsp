<!-- filepath: d:\Campus\Kelas\Kelas - Enterprise\WebApplication2\web\logout.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Logout</title>
  <!-- Firebase SDK -->
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
  <script>
    // Konfigurasi Firebase
    const firebaseConfig = {
      apiKey: "AIzaSyD9H6zdJh50_lRtmJJHN9AYyrYgF3OlL5M",
      authDomain: "entreprise-b4307.firebaseapp.com",
      projectId: "entreprise-b4307",
      storageBucket: "entreprise-b4307.firebasestorage.app",
      messagingSenderId: "585290944703",
      appId: "1:585290944703:web:0cc9e343d1c9139fcab60a",
      measurementId: "G-DG8GMYB4PM"
    };

    // Inisialisasi Firebase
    firebase.initializeApp(firebaseConfig);
    
    // Logout dari Firebase (jika user login dengan Google)
    firebase.auth().signOut().then(() => {
      console.log('Logged out from Firebase');
    }).catch((error) => {
      console.error('Firebase logout error:', error);
    });
  </script>
</head>
<body>
<%
  // Invalidate the session
  session.invalidate();
  response.sendRedirect("login.jsp");
%>
</body>
</html>