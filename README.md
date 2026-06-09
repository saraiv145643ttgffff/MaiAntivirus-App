# 🛡️ MaiAntivirus Pro - Hệ Thống Bảo Mật Toàn Diện

**MaiAntivirus Pro** là một ứng dụng bảo mật di động đa năng được phát triển bằng Flutter, kết hợp với Backend mạnh mẽ bằng ngôn ngữ Go và tích hợp Trí tuệ nhân tạo (AI). Ứng dụng cung cấp các giải pháp bảo vệ thiết bị, quản lý mật khẩu và hỗ trợ người dùng thông qua trợ lý ảo thông minh.

---

## ✨ Tính Năng Chính

### 🔍 1. Quét Virus & Tệp Tin Độc Hại
- Quét toàn bộ thư mục hệ thống (đặc biệt là mục Download).
- Nhận diện mã độc dựa trên chữ ký (Signatures) và định dạng tệp nguy hiểm (.apk, .exe...).
- **Tính năng Test:** Hỗ trợ tải và nhận diện tệp tiêu chuẩn quốc tế **EICAR** để kiểm thử an toàn.
- Cho phép xóa vĩnh viễn các mối đe dọa ngay trên ứng dụng.

### 🤖 2. Trợ Lý AI Bảo Mật
- Tích hợp mô hình ngôn ngữ lớn để giải đáp các thắc mắc về bảo mật.
- Hỗ trợ người dùng nhận diện các hình thức lừa đảo mạng và cách phòng tránh virus.
- Giao diện chat hiện đại, thân thiện.

### 🔐 3. Kiểm Tra & Ví Mật Khẩu (Vault)
- **Kiểm tra:** Phân tích độ mạnh mật khẩu (độ dài, ký tự đặc biệt, số...).
- **Ví bảo mật:** Lưu trữ mật khẩu an toàn trong "Ví" được mã hóa cục bộ bằng thuật toán XOR/Base64.
- Truy xuất và quản lý mật khẩu dễ dàng.

### 📊 4. Phân Tích Ứng Dụng
- Kiểm tra danh sách các ứng dụng đã cài đặt trên thiết bị.
- Cảnh báo về các quyền hạn nhạy cảm mà ứng dụng đang yêu cầu.

### ⚙️ 5. Cài Đặt & Tùy Biến
- Hỗ trợ **Dark Mode** / Light Mode giúp bảo vệ mắt.
- Đa ngôn ngữ: Tiếng Việt và Tiếng Anh.
- Cấu hình linh hoạt địa chỉ Backend API.

---

## 🚀 Công Nghệ Sử Dụng

### Frontend (Mobile App)
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Storage:** Shared Preferences (Encrypted)
- **UI:** Google Fonts, FontAwesome

### Backend (Server)
- **Language:** Go (Golang)
- **Framework:** Gin Gonic
- **Database:** MySQL / PostgreSQL
- **Security:** JWT, Hashing

---

## 🛠️ Hướng Dẫn Cài Đặt

### 1. Cấu hình Backend
```bash
cd backend-master/backend-master
go run main.go
```
*Đảm bảo Server đang chạy tại cổng :8080*

### 2. Cấu hình Mobile App
```bash
cd app-master/app-master
flutter pub get
flutter run
```

### 3. Kết nối
Vào mục **Cài đặt** trên App và nhập địa chỉ IP của máy tính (Ví dụ: `http://192.168.1.5:8080`) để kết nối với Backend.

---

## 📸 Ảnh Chụp Màn Hình
*(Bạn có thể chụp ảnh màn hình và dán link vào đây để minh họa)*

---

## 👨‍💻 Tác Giả
- Phát triển bởi: **[Tên của bạn]**
- Đồ án: Hệ thống bảo mật Android tích hợp AI.

---
⭐ Nếu bạn thấy dự án này hữu ích, hãy tặng cho mình 1 sao (Star) trên GitHub nhé!
