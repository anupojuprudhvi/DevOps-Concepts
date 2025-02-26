

---

# 🌐 **NGINX Configuration for Serving a Single-Page Application (SPA)**

This repository contains an **NGINX configuration** designed to serve a **Single-Page Application (SPA)** like React, Angular, or Vue.js. The configuration ensures seamless routing for SPAs, enables Cross-Origin Resource Sharing (CORS), and provides a robust setup for hosting static files.

---

## 📋 **Table of Contents**
1. [Overview](#overview)
2. [Features](#features)
3. [Configuration Breakdown](#configuration-breakdown)
4. [How to Use](#how-to-use)
5. [Directory Structure](#directory-structure)
6. [Troubleshooting](#troubleshooting)

---

## 🌟 **Overview**

The NGINX configuration is tailored for hosting a **Single-Page Application (SPA)** with the following key features:
- **SPA Routing**: Ensures that all routes are redirected to `index.html`, enabling client-side routing.
- **CORS Support**: Adds headers to handle Cross-Origin Resource Sharing (CORS) for APIs and external services.
- **Static File Serving**: Serves static files (e.g., HTML, CSS, JavaScript) from the specified root directory.

This setup is ideal for applications like dashboards, portals, or any frontend-heavy application that relies on client-side rendering.

---

## ✨ **Features**

1. **SPA Routing**:
   - Redirects all requests to `index.html`, ensuring proper handling of client-side routes.
   - Example: `/about` or `/dashboard` will load `index.html`.

2. **CORS Support**:
   - Handles both **simple requests** (GET, POST) and **preflighted requests** (OPTIONS).
   - Allows cross-origin requests from any domain (`*`) for flexibility.

3. **Static File Serving**:
   - Serves static assets (HTML, CSS, JS, images) from the `/usr/share/nginx/html` directory.

4. **Customizable**:
   - Easily modify the `server_name`, `root`, and CORS headers to suit your needs.

---

## 🛠️ **Configuration Breakdown**

### 1. **Global Settings**
```nginx
http {
    include /etc/nginx/mime.types;
}
```
- Includes MIME types for serving various file formats (e.g., `.html`, `.css`, `.js`).

### 2. **Server Block**
```nginx
server {
    listen 80;
    server_name pccqa.razielhealth.com;
    root /usr/share/nginx/html;
    index index.html;
}
```
- **`listen 80`**: Listens on port 80 for HTTP traffic.
- **`server_name`**: Specifies the domain name (`pccqa.razielhealth.com`).
- **`root`**: Defines the directory where static files are stored.
- **`index`**: Sets the default file to serve (`index.html`).

### 3. **Location Block**
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```
- **`try_files`**: Attempts to serve the requested file or directory. If not found, redirects to `index.html` for SPA routing.

### 4. **CORS Headers**
#### Simple Requests
```nginx
if ($request_method ~* "(GET|POST)") {
    add_header "Access-Control-Allow-Origin" *;
}
```
- Adds the `Access-Control-Allow-Origin` header for GET and POST requests.

#### Preflighted Requests
```nginx
if ($request_method = OPTIONS) {
    add_header "Access-Control-Allow-Origin" *;
    add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD";
    add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    return 200;
}
```
- Handles OPTIONS requests for CORS preflight checks.
- Specifies allowed methods and headers.

---

## 🚀 **How to Use**

### 1. Install NGINX
Install NGINX on your server:
```bash
sudo apt update
sudo apt install nginx
```

### 2. Copy the Configuration
Replace the default NGINX configuration with the provided one:
```bash
sudo cp nginx.conf /etc/nginx/nginx.conf
```

### 3. Place Your Application Files
Place your SPA's static files in the `/usr/share/nginx/html` directory:
```bash
sudo cp -r /path/to/your/app/* /usr/share/nginx/html/
```

### 4. Test the Configuration
Test the NGINX configuration for syntax errors:
```bash
sudo nginx -t
```

### 5. Restart NGINX
Restart NGINX to apply the changes:
```bash
sudo systemctl restart nginx
```

### 6. Access the Application
Open your browser and navigate to `http://pccqa.razielhealth.com` to view your application.

---

## 📂 **Directory Structure**

The repository should have the following structure:

```
.
├── nginx.conf          # NGINX configuration file.
└── README.md           # This file.
```

---

## ❓ **Troubleshooting**

### 1. **404 Errors for Routes**
- Ensure the `try_files` directive is correctly configured in the `location /` block.
- Verify that `index.html` exists in the `/usr/share/nginx/html` directory.

### 2. **CORS Issues**
- Check the browser's developer console for CORS-related errors.
- Ensure the `Access-Control-Allow-Origin` header is set correctly.

### 3. **NGINX Fails to Start**
- Run `sudo nginx -t` to check for syntax errors in the configuration file.
- Review the NGINX error logs:
  ```bash
  sudo tail -f /var/log/nginx/error.log
  ```

---

## 🤝 **Contributing**

If you encounter issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!

---

## 📜 **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 **Contact**

For questions or support, contact the DevOps team:
- Email: devops@example.com
- Slack: #devops-channel

---

