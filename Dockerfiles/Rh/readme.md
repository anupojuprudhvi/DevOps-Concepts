
---

# 🚀 **Dockerized NGINX Application with Multi-Stage Build**

This repository contains a **multi-stage Dockerfile** designed to build and serve a production-ready Angular (or similar frontend framework) application using **Node.js** for the build process and **NGINX** as the web server. The Dockerfile ensures a clean separation between the build and runtime environments, optimizing the final image size.

---

## 📋 **Table of Contents**
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Dockerfile Stages](#dockerfile-stages)
4. [How to Use](#how-to-use)
5. [Directory Structure](#directory-structure)
6. [Troubleshooting](#troubleshooting)

---

## 🌟 **Overview**

The Dockerfile is divided into two stages:
1. **Build Stage**: Uses a Node.js image to install dependencies, build the application, and generate static assets.
2. **Run Stage**: Uses an NGINX image to serve the static files generated in the build stage.

This approach ensures that the final image is lightweight and only contains the necessary files to run the application.

---

## ⚙️ **Prerequisites**

Before building and running the Docker image, ensure the following prerequisites are met:

1. **Docker Installed**:
   - Install Docker on your machine: [Docker Installation Guide](https://docs.docker.com/get-docker/).

2. **Application Code**:
   - Ensure the application code (e.g., Angular project) is present in the repository.
   - The `package.json` file should define all dependencies and scripts.

3. **NGINX Configuration**:
   - Provide an `nginx.conf` file to configure NGINX for serving the application.

---

## 🛠️ **Dockerfile Stages**

### **Stage 1: Build**
- **Base Image**: `node:14.17.3`
- **Purpose**: Compiles the application and generates static assets.
- **Steps**:
  1. Creates a working directory (`/usr/src/app`).
  2. Copies `package.json` and installs dependencies using `npm install --force`.
  3. Copies the entire application code.
  4. Runs the build command (`npm run build --prod`) to generate optimized static files.

### **Stage 2: Run**
- **Base Image**: `nginx:1.17.1-alpine`
- **Purpose**: Serves the static files generated in the build stage.
- **Steps**:
  1. Copies the `nginx.conf` file to configure NGINX.
  2. Copies the built application files from the `build` stage to the NGINX HTML directory (`/usr/share/nginx/html/pcc`).

---

## 🚀 **How to Use**

### 1. Build the Docker Image
Run the following command to build the Docker image:
```bash
docker build -t patientconsentportal .
```

### 2. Run the Docker Container
Start the container using the following command:
```bash
docker run -d -p 80:80 --name patientconsentportal-container patientconsentportal
```

### 3. Access the Application
Open your browser and navigate to `http://localhost` to view the application.

---

## 📂 **Directory Structure**

The repository should have the following structure:

```
.
├── Dockerfile          # Multi-stage Dockerfile for building and running the app.
├── nginx.conf          # NGINX configuration file.
├── package.json        # Defines dependencies and build scripts.
├── src/                # Source code of the application.
└── README.md           # This file.
```

---

## ❓ **Troubleshooting**

### 1. **Build Fails During Dependency Installation**
- Ensure `package.json` is correctly configured.
- If specific dependencies fail, consider updating them or using the `--legacy-peer-deps` flag:
  ```bash
  RUN npm install --legacy-peer-deps
  ```

### 2. **NGINX Configuration Issues**
- Verify that the `nginx.conf` file is valid and properly configured.
- Test the configuration locally:
  ```bash
  nginx -t
  ```

### 3. **Application Not Loading**
- Check the NGINX logs for errors:
  ```bash
  docker logs patientconsentportal-container
  ```
- Ensure the `dist/patientconsentportal` directory exists after the build stage.

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
