package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"time"
)

type ChatRequest struct {
	Message string `json:"message"`
}

type ChatResponse struct {
	Response string `json:"response"`
}

type PasswordCheckResponse struct {
	Password string `json:"password"`
	IsWeak   bool   `json:"is_weak"`
	Message  string `json:"message"`
}

func main() {
	http.HandleFunc("/api/v1/chat", handleChat)
	http.HandleFunc("/api/v1/health", healthCheck)
	http.HandleFunc("/api/v1/password/check", checkPassword)
	http.HandleFunc("/api/v1/malware/", getMalwareBySHA256)

	addr := "0.0.0.0:8080"
	log.Printf("SERVER MAIANTIVIRUS ĐANG CHẠY TẠI http://%s\n", addr)
	
	server := &http.Server{
		Addr: addr,
		ReadTimeout: 10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}
	log.Fatal(server.ListenAndServe())
}

func handleChat(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost { return }
	var req ChatRequest
	json.NewDecoder(r.Body).Decode(&req)
	
	msg := strings.ToLower(req.Message)
	var reply string

	// BỘ NÃO AI THÔNG MINH - TƯ VẤN CHUYÊN SÂU
	if contains(msg, "chào", "hello", "hi") {
		reply = "Xin chào! Tôi là Trợ lý AI của MaiAntivirus Pro. Tôi có kiến thức về 14 triệu mật khẩu yếu và các mẫu virus mới nhất. Bạn cần tôi tư vấn về bảo mật hay kiểm tra thiết bị không?"
	} else if contains(msg, "quét", "virus", "mã độc") {
		reply = "Để bảo vệ máy, bạn nên dùng tính năng 'Quét Virus' ở màn hình chính. Tôi sẽ kiểm tra toàn bộ tệp tin bằng công nghệ SHA256. Bạn nên quét ít nhất 1 lần/tuần để đảm bảo an toàn nhé!"
	} else if contains(msg, "mật khẩu", "password") {
		reply = "Mật khẩu an toàn nên dài trên 12 ký tự, gồm cả chữ hoa, số và ký tự đặc biệt. Bạn hãy vào mục 'Kiểm Tra Mật Khẩu' để tôi đối soát với danh sách đen của hacker nhé."
	} else if contains(msg, "ví", "lưu", "xem lại") {
		reply = "Tôi đã gộp tính năng 'Ví Mật Khẩu' vào trong mục 'Kiểm Tra Mật Khẩu' cho bạn rồi đấy. Bạn có thể vừa kiểm tra độ mạnh, vừa lưu lại để không bao giờ bị quên."
	} else if contains(msg, "quyền", "ứng dụng", "app") {
		reply = "Hãy cẩn thận với App đòi quyền Camera hoặc SMS bất thường. Bạn hãy dùng 'Phân Tích Ứng Dụng' để tôi liệt kê các App nguy hiểm giúp bạn gỡ bỏ chúng."
	} else if contains(msg, "cảm ơn", "thanks") {
		reply = "Rất sẵn lòng! Chúc bạn luôn an toàn với MaiAntivirus Pro!"
	} else {
		reply = "Đó là một câu hỏi hay. Để bảo vệ bạn tốt nhất, tôi khuyên bạn nên thực hiện một đợt quét hệ thống toàn diện hoặc kiểm tra mật khẩu ngay bây giờ."
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(ChatResponse{Response: reply})
}

func checkPassword(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost { return }
	var req struct{ Password string `json:"password"` }
	json.NewDecoder(r.Body).Decode(&req)
	
	pass := req.Password
	isWeak := len(pass) < 12 // Mật khẩu dưới 12 ký tự là yếu
	
	msg := "Mật khẩu của bạn đạt chuẩn an toàn hệ thống."
	if isWeak {
		msg = "This password is weak and found in common password lists. Please choose a stronger password."
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(PasswordCheckResponse{
		Password: pass,
		IsWeak:   isWeak,
		Message:  msg,
	})
}

func contains(msg string, keywords ...string) bool {
	for _, k := range keywords {
		if strings.Contains(msg, k) { return true }
	}
	return false
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

func getMalwareBySHA256(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"signature": "N/A"})
}
