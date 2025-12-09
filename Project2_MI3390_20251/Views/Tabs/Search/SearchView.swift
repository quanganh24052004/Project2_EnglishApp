struct SearchView: View {
    // 1. Biến state để lưu từ khóa tìm kiếm
    @State private var searchText = ""
    
    // Dữ liệu mẫu để demo việc lọc
    let dataItems = ["Apple", "Banana", "Orange", "Pear", "Grape", "Melon"]

    // Logic lọc dữ liệu dựa trên searchText
    var filteredItems: [String] {
        if searchText.isEmpty {
            return dataItems
        } else {
            return dataItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        // 2. Bắt buộc phải bọc trong NavigationStack để thanh search hiển thị trên Toolbar
        NavigationStack {
            List(filteredItems, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("Tìm kiếm")
            
            // 3. Modifier tạo thanh Search chuẩn Apple
            .searchable(text: $searchText, placement: .automatic, prompt: "Nhập tên trái cây...")
            
            // (Tuỳ chọn) Hiển thị nội dung khi chưa tìm thấy gì hoặc danh sách rỗng
            .overlay {
                if filteredItems.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }
}