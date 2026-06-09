# Thiết kế phần mềm quét virus “MaiAntivirus”

MaiAntivirus là một ứng dụng bảo mật di động đa năng được phát triển bằng Flutter, kết hợp với Backend bằng ngôn ngữ Go và tích hợp Trí tuệ nhân tạo (AI). Ứng dụng cung cấp các giải pháp bảo vệ thiết bị, quản lý mật khẩu và hỗ trợ người dùng thông qua trợ lý ảo thông minh.

---

## Tính Năng Chính

### 1. Quét Virus và Tệp Tin Độc Hại
- Quét toàn bộ thư mục hệ thống (đặc biệt là mục Download).
- Nhận diện mã độc dựa trên chữ ký (Signatures) và định dạng tệp nguy hiểm (.apk, .exe...).
- Tính năng Test: Hỗ trợ tải và nhận diện tệp tiêu chuẩn quốc tế EICAR để kiểm thử an toàn.
- Cho phép xóa vĩnh viễn các mối đe dọa ngay trên ứng dụng.

### 2. Trợ Lý AI Bảo Mật
- Tích hợp mô hình ngôn ngữ lớn để giải đáp các thắc mắc về bảo mật.
- Hỗ trợ người dùng nhận diện các hình thức lừa đảo mạng và cách phòng tránh virus.
- Giao diện chat hiện đại, thân thiện.

### 3. Kiểm Tra và Ví Mật Khẩu
- Kiểm tra: Phân tích độ mạnh mật khẩu (độ dài, ký tự đặc biệt, số...).
- Ví bảo mật: Lưu trữ mật khẩu an toàn trong Ví được mã hóa cục bộ bằng thuật toán XOR/Base64.
- Truy xuất và quản lý mật khẩu dễ dàng.

### 4. Phân Tích Ứng Dụng
- Kiểm tra danh sách các ứng dụng đã cài đặt trên thiết bị.
- Cảnh báo về các quyền hạn nhạy cảm mà ứng dụng đang yêu cầu.

### 5. Cài Đặt và Tùy Biến
- Hỗ trợ chế độ nền tối (Dark Mode) và nền sáng (Light Mode).
- Đa ngôn ngữ: Tiếng Việt và Tiếng Anh.
- Cấu hình linh hoạt địa chỉ Backend API.

---

## Công Nghệ Sử Dụng

### Frontend (Mobile App)
- Framework: Flutter (Dart)
- State Management: Provider
- Storage: Shared Preferences (Mã hóa)
- UI: Google Fonts

### Backend (Server)
- Ngôn ngữ: Go (Golang)
- Framework: Gin Gonic
- Cơ sở dữ liệu: MySQL / PostgreSQL
- Bảo mật: JWT, Hashing

---

## Tác Giả
- Phát triển bởi: Hoàng thị hoa mai
- Đồ án: Hệ thống bảo mật Android tích hợp AI.
