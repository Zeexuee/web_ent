<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Login Pengguna</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  
  <!-- Firebase SDK -->
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
  
  <style>
    body {
      background: linear-gradient(135deg, #f8f9fa, #e2e6ea);
    }
    .card {
      border: none;
      border-radius: 16px;
    }
    .form-control:focus {
      border-color: #0d6efd;
      box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
    }
    .btn-google {
      background-color: white;
      color: #757575;
      border: 1px solid #ddd;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      transition: all 0.3s;
    }
    .btn-google:hover {
      background-color: #f1f3f4;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    }
    .google-icon {
      width: 18px;
      height: 18px;
    }
    .or-divider {
      display: flex;
      align-items: center;
      text-align: center;
      margin: 20px 0;
    }
    .or-divider::before, .or-divider::after {
      content: '';
      flex: 1;
      border-bottom: 1px solid #ddd;
    }
    .or-divider span {
      padding: 0 10px;
      color: #757575;
      font-size: 0.9rem;
    }
  </style>
</head>
<body>

  <div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="col-md-6">
      <div class="card p-4 shadow">
        <h3 class="text-center mb-4 text-primary">🔐 Login Pengguna</h3>
        
        <% 
          String error = request.getParameter("error");
          String success = request.getParameter("success");
          
          if (error != null) { 
        %>
          <div class="alert alert-danger mb-3">
            <% if ("invalid_credentials".equals(error)) { %>
              Email atau password salah. Silakan coba lagi.
            <% } else if ("missing_fields".equals(error)) { %>
              Mohon lengkapi semua field.
            <% } else { %>
              Terjadi kesalahan: <%= error %>
            <% } %>
          </div>
        <% } %>

        <% if (success != null) { %>
          <div class="alert alert-success mb-3">
            <% if ("registration_complete".equals(success)) { %>
              Pendaftaran berhasil! Silakan login.
            <% } else if ("logout_success".equals(success)) { %>
              Anda telah berhasil logout.
            <% } %>
          </div>
        <% } %>
        
        <!-- Login dengan Google Button -->
        <button id="googleLogin" class="btn btn-lg btn-google mb-3">
          <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" class="google-icon" alt="Google logo">
          Masuk dengan Google
        </button>
        
        <div class="or-divider">
          <span>ATAU</span>
        </div>
        
        <!-- Form login normal -->
        <form action="login-process.jsp" method="post">
          <div class="mb-3">
            <label for="email" class="form-label">📧 Email</label>
            <input type="email" class="form-control" id="email" name="email" placeholder="email@example.com" required>
          </div>
          <div class="mb-4">
            <label for="password" class="form-label">🔒 Password</label>
            <input type="password" class="form-control" id="password" name="password" placeholder="********" required>
          </div>
          <div class="d-grid">
            <button type="submit" class="btn btn-primary btn-lg">➡️ Masuk</button>
          </div>
        </form>
        <div class="text-center mt-3">
          <small>Belum punya akun? <a href="form.html" class="text-decoration-none">Daftar di sini</a></small>
        </div>
      </div>
    </div>
  </div>

  <script>
    // Konfigurasi Firebase dari project Anda - DIPERBAIKI
    const firebaseConfig = {
      apiKey: "AIzaSyD9H6zdJh50_lRtmJJHN9AYyrYgF3OlL5M",
      authDomain: "entreprise-b4307.firebaseapp.com",
      projectId: "entreprise-b4307",
      storageBucket: "entreprise-b4307.appspot.com", // PERBAIKAN: format appspot.com yang benar
      messagingSenderId: "585290944703",
      appId: "1:585290944703:web:0cc9e343d1c9139fcab60a",
      measurementId: "G-DG8GMYB4PM"
    };

    // Inisialisasi Firebase
    firebase.initializeApp(firebaseConfig);
    console.log("Firebase initialized successfully");
    
    // Test koneksi Firebase
    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        console.log("User is signed in:", user.email);
      } else {
        console.log("No user is signed in.");
      }
    });
    
    // Setup Google login dengan error handling yang lebih baik
    document.getElementById('googleLogin').addEventListener('click', function() {
      console.log("Google login button clicked");
      
      const provider = new firebase.auth.GoogleAuthProvider();
      
      // Tambahkan scope untuk akses lebih baik (opsional)
      provider.addScope('profile');
      provider.addScope('email');
      
      // Set language (opsional)
      firebase.auth().languageCode = 'id';
      
      firebase.auth().signInWithPopup(provider)
        .then((result) => {
          // User berhasil login
          const user = result.user;
          console.log("Google login success:", user);
          console.log("Firebase UID:", user.uid);
          console.log("Display Name:", user.displayName);
          console.log("Email:", user.email);
          console.log("Photo URL:", user.photoURL);
          
          // Kirim data ke server untuk diproses
          sendUserDataToServer(user);
        })
        .catch((error) => {
          // Handle errors
          console.error("Error code:", error.code);
          console.error("Error message:", error.message);
          console.error("Error email:", error.email);
          console.error("Error credential:", error.credential);
          
          alert("Login gagal: " + error.message);
        });
    });
    
    // Fungsi untuk mengirim data ke server
    function sendUserDataToServer(user) {
      // Buat form tersembunyi untuk mengirim data ke server
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = 'firebase-auth-process.jsp';
      
      // Tambahkan field yang diperlukan
      const fields = {
        'firebaseUid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL
      };
      
      for (const key in fields) {
        if (fields[key]) {
          const hiddenField = document.createElement('input');
          hiddenField.type = 'hidden';
          hiddenField.name = key;
          hiddenField.value = fields[key];
          form.appendChild(hiddenField);
        }
      }
      
      document.body.appendChild(form);
      form.submit();
    }
  </script>
  
  <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
