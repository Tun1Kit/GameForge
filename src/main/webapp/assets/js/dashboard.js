document.addEventListener("DOMContentLoaded", function() {
  if (window.lucide) {
    window.lucide.createIcons();
  }

  const contextPath = window.GAMEFORGE_CONTEXT_PATH || '';

  // Hàm AJAX xóa item trực tiếp khỏi giỏ hàng trên Dashboard
  window.removeDashboardCart = function(btn, gameId) {
    if (!confirm("Bạn có chắc chắn muốn xóa game này khỏi giỏ hàng?")) return;
    
    const formData = new FormData();
    formData.append("itemId", gameId);

    var dashCsrfToken = window.GAMEFORGE_CSRF_TOKEN;
    var dashCsrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";
    var dashHeaders = {};
    if (dashCsrfToken) dashHeaders[dashCsrfHeader] = dashCsrfToken;

    fetch(contextPath + "/api/cart/remove", {
      method: "POST",
      headers: dashHeaders,
      body: formData
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        // Tải lại trang nhanh để cập nhật đầy đủ số dư và giỏ hàng
        window.location.reload();
      } else {
        alert("Lỗi: " + data.message);
      }
    })
    .catch(err => {
      console.error("Cart remove error:", err);
      alert("Đã xảy ra lỗi khi kết nối máy chủ.");
    });
  };
});
