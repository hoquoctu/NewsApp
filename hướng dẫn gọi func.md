Import thư viện trong file Swift:
```swift
import FirebaseFunctions
```

## 2. API: Lưu bài viết (saveArticle)
Hàm này sẽ copy data bài báo và toàn bộ hình ảnh liên quan về thư mục cá nhân của User.

- **Tên Function:** `saveArticle`
- **Tham số truyền lên (Parameters):**
  - `userId` (String): ID của user đang đăng nhập.
  - `articleId` (String): ID của bài báo gốc.

**Code Swift mẫu:**
```swift
lazy var functions = Functions.functions()

func saveArticle(userId: String, articleId: String) {
    let data: [String: Any] = [
        "userId": userId,
        "articleId": articleId
    ]
    
    functions.httpsCallable("saveArticle").call(data) { result, error in
        if let error = error as NSError? {
            // Xử lý lỗi
            print("Lỗi khi lưu bài viết: \(error.localizedDescription)")
            return
        }
        
        // Thành công
        if let res = result?.data as? [String: Any], 
           let success = res["success"] as? Bool, success == true {
            print("Lưu bài viết thành công!")
        }
    }
}
```

## 3. API: Xoá bài viết (deleteArticle)
Hàm này sẽ xoá bản ghi bài báo đã lưu và dọn dẹp sạch toàn bộ hình ảnh được copy ra khỏi Storage.

- **Tên Function:** `deleteArticle`
- **Tham số truyền lên (Parameters):**
  - `userId` (String): ID của user đang đăng nhập.
  - `articleId` (String): ID của bài báo gốc cần xoá khỏi danh sách đã lưu.

**Code Swift mẫu:**
```swift
func deleteArticle(userId: String, articleId: String) {
    let data: [String: Any] = [
        "userId": userId,
        "articleId": articleId
    ]
    
    functions.httpsCallable("deleteArticle").call(data) { result, error in
        if let error = error as NSError? {
            // Xử lý lỗi
            print("Lỗi khi xóa bài viết: \(error.localizedDescription)")
            return
        }
        
        // Thành công
        if let res = result?.data as? [String: Any], 
           let success = res["success"] as? Bool, success == true {
            print("Xóa bài viết thành công!")
        }
    }
}
```

## 4. Cấu trúc Database lưu bài (Để query hiển thị)
Sau khi lưu thành công, dữ liệu của bài báo sẽ nằm ở đường dẫn Firestore sau:
`users/{userId}/note_articles/{articleId}`

có thể dùng đường dẫn này để hiển thị danh sách "Các bài đã lưu" của user. Mọi link ảnh bên trong trường `content` (HTML) và `imageUrls` đều đã được Backend tự động đổi sang link an toàn, không sợ bị mất ảnh khi bài báo gốc bị xoá.
