Dựa trên việc phân tích toàn bộ mã nguồn, cấu trúc thư mục (đặc biệt là sau khi refactor theo hướng **Feature-based**) và các thư viện được sử dụng (SwiftData, Supabase, SwiftUI Charts...), dưới đây là file `README.md` chi tiết và chuyên nghiệp dành cho dự án **CapyVocab** (tên lấy từ `Info.plist`) của bạn.

Bạn có thể tạo một file tên là `README.md` ở thư mục gốc của dự án và dán nội dung này vào.

---

# 🧢 CapyVocab - Ứng dụng học tiếng Anh thông minh

**CapyVocab** là ứng dụng iOS được xây dựng bằng **SwiftUI**, giúp người dùng học và ghi nhớ từ vựng tiếng Anh hiệu quả thông qua phương pháp **Lặp lại ngắt quãng (Spaced Repetition System - SRS)**. Ứng dụng kết hợp giữa việc học theo chủ đề, trò chơi tương tác và biểu đồ theo dõi tiến độ trực quan.

---

## 🌟 Tính năng nổi bật

### 1. 📚 Học tập (Learn)

* **Lộ trình bài bản:** Danh sách các khóa học và bài học được tổ chức khoa học (Dữ liệu từ JSON).
* **Phương pháp đa dạng:**
* **Flashcard:** Lật thẻ để xem nghĩa, tự động phát âm và đánh dấu trạng thái.
* **Listen & Write:** Nghe phát âm và gõ lại từ vựng.
* **Spelling Game:** Sắp xếp các ký tự lộn xộn thành từ đúng.
* **Fill in Blank:** Điền từ vào câu ví dụ.



### 2. 🧠 Ôn tập thông minh (Review & SRS)

* **Thuật toán SRS:** Tự động tính toán thời gian ôn tập tối ưu cho từng từ vựng dựa trên mức độ ghi nhớ của người dùng (Level 0 - Level 5).
* **Hệ thống nhắc nhở:** Tự động gửi thông báo (Local Notification) khi đến giờ ôn tập, gộp thông báo thông minh để tránh spam.
* **Các dạng bài ôn tập:**
* Trắc nghiệm (Multiple Choice).
* Gõ từ (Typing).
* Chọn từ theo ngữ cảnh.



### 3. 📊 Thống kê & Theo dõi (Dashboard)

* **Biểu đồ Swift Charts:** Hiển thị trực quan số lượng từ thuộc các cấp độ ghi nhớ khác nhau.
* **Sổ tay từ vựng (Handbook):** Tra cứu lại tất cả các từ đã học, lọc theo Level.

### 4. ☁️ Đồng bộ & Dữ liệu

* **Supabase Integration:** Đăng ký, Đăng nhập, và đồng bộ dữ liệu người dùng (User Profile) lên đám mây.
* **Offline First:** Sử dụng **SwiftData** để lưu trữ cục bộ, cho phép học tập ngay cả khi không có mạng.

---

## 🛠 Tech Stack

Dự án sử dụng các công nghệ hiện đại nhất của hệ sinh thái Apple:

* **Ngôn ngữ:** Swift 5.
* **Giao diện:** SwiftUI (MVVM Architecture).
* **Cơ sở dữ liệu cục bộ:** SwiftData (thay thế Core Data).
* **Backend / Auth:** Supabase (thông qua `supabase-swift`).
* **Biểu đồ:** Swift Charts.
* **Âm thanh:** AVFoundation (Text-to-Speech).
* **Cấu trúc dự án:** Modular Feature-based (Chia theo tính năng).

---

## 📂 Cấu trúc dự án

Dự án được tổ chức theo kiến trúc **Feature-based** giúp dễ dàng mở rộng và bảo trì:

```text
Project2_MI3390_20251
├── App                 # Entry point (RootView, App setup)
├── Core                # Các thành phần dùng chung (Extensions, DesignSystem, Utils)
├── Data                # Quản lý dữ liệu (SwiftData Models, API Services, Managers)
│   ├── Managers        # Logic nghiệp vụ (LearningManager, NotificationManager...)
│   └── Services        # Giao tiếp bên ngoài (SupabaseAuthService...)
├── Features            # Các màn hình chức năng chính
│   ├── Authentication  # Đăng nhập, Đăng ký
│   ├── Learn           # Quy trình học, Flashcard, Game
│   ├── Review          # Logic ôn tập, SRS, Biểu đồ
│   ├── Onboarding      # Màn hình chào, Khảo sát người dùng
│   ├── Handbook        # Sổ tay từ vựng
│   ├── Search          # Tra từ
│   └── Settings        # Cài đặt, Đổi ngôn ngữ
└── Resources           # Assets, Fonts, Localizations

```

---

## 🚀 Cài đặt và Chạy dự án

### Yêu cầu

* Xcode 15.0 trở lên.
* iOS 17.0 trở lên (do sử dụng SwiftData).

### Các bước thực hiện

1. **Clone dự án:**
```bash
git clone https://github.com/username/project2_englishapp.git
cd project2_englishapp

```


2. **Mở dự án:**
Mở file `Project2_MI3390_20251.xcodeproj` bằng Xcode.
3. **Cài đặt Dependencies:**
Xcode sẽ tự động fetch gói `supabase-swift` thông qua Swift Package Manager (SPM). Hãy đợi quá trình này hoàn tất.
4. **Cấu hình Supabase (Quan trọng):**
* Mở file `Constants.swift` (hoặc nơi bạn lưu Config).
* Đảm bảo `SUPABASE_URL` và `SUPABASE_KEY` đã được điền chính xác thông tin dự án Supabase của bạn.


5. **Chạy ứng dụng:**
Chọn máy ảo (Simulator) hoặc thiết bị thật và nhấn `Cmd + R`.

---

## 📸 Ảnh minh họa (Screenshots)

| Màn hình chính | Học từ (Flashcard) | Ôn tập (Review) | Thống kê |
| --- | --- | --- | --- |
| *(Đặt ảnh MainTabView tại đây)* | *(Đặt ảnh Flashcard tại đây)* | *(Đặt ảnh ReviewView tại đây)* | *(Đặt ảnh Chart tại đây)* |

---

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh! Nếu bạn muốn cải thiện ứng dụng, hãy:

1. Fork dự án.
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`).
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`).
4. Push lên branch (`git push origin feature/AmazingFeature`).
5. Tạo Pull Request.

---

## 📝 License

Dự án này được phát triển cho mục đích học tập (Project 2 - MI3390).
Bản quyền thuộc về **Nguyễn Quang Anh**.

---

**Made with ❤️ and Swift**
