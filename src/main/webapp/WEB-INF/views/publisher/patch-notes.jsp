<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge Publisher - Ghi chú Patch Notes: ${game.title}</title>

  <script>
    document.documentElement.classList.remove('gf-dark-mode');
  </script>

  <!-- Bootstrap 5 + Lucide -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">

  <style>
    body {
      background-color: #f4f4f5;
    }
    .panel-box {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 6px 6px 0 0 #000;
      border-radius: 16px;
      padding: 24px;
    }
    .form-control {
      border: 2px solid #000;
      font-weight: 600;
      padding: 12px;
      border-radius: 8px;
    }
    .form-control:focus {
      border-color: #000;
      box-shadow: 3px 3px 0 0 #000;
      outline: none;
    }
    .form-label {
      font-weight: 950;
      text-transform: uppercase;
      font-size: 13px;
    }
    .patch-note-card {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 4px 4px 0 0 #000;
      border-radius: 12px;
      margin-bottom: 24px;
      overflow: hidden;
    }
    .patch-note-header {
      background: var(--gf-lavender);
      border-bottom: 3px solid #000;
      padding: 14px 20px;
    }
  </style>
</head>

<body>
  <!-- NAVBAR -->
  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;background:var(--gf-yellow);color:#000;">PUBLISHER</span></span>
        </a>
        
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <a href="${pageContext.request.contextPath}/publisher/dashboard" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/publisher/games" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
            <i data-lucide="package" width="14" height="14"></i> Game đã đăng
          </a>
          <a href="${pageContext.request.contextPath}/publisher/payouts" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/kyc" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <a href="${pageContext.request.contextPath}/publisher/games/add" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="gamepad-2" width="14" height="14"></i> Đăng game
          </a>
          
          <!-- Notification Bell -->
          <a href="${pageContext.request.contextPath}/publisher/notifications" class="btn btn-sm gf-border-2 gf-press bg-white text-dark rounded-3 d-flex align-items-center justify-content-center p-0 position-relative" style="width:38px; height:38px; border-color:#000; flex-shrink:0;">
            <i data-lucide="bell" width="16" height="16"></i>
            <c:if test="${unreadNotificationCount > 0}">
              <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size:9px; padding: 3px 6px;">
                ${unreadNotificationCount}
              </span>
            </c:if>
          </a>

          <!-- Dropdown User -->
          <div class="dropdown" style="flex-shrink: 0;">
            <button class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown" style="height:38px;border-color:#000;padding:4px 12px 4px 6px;flex-shrink:0;line-height:1;">
              <img src="${(not empty currentUser.avatar && currentUser.avatar != 'default-avatar.png') ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Publisher'}" alt="Avatar" style="width:24px;height:24px;border-radius:50%;object-fit:cover;border:1.5px solid #000;">
              <span class="d-none d-sm-inline fw-black text-dark" style="font-size:12px;">${fn:escapeXml(currentUser.username)}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:180px;">
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/logout"><i data-lucide="log-out" width="14" height="14"></i> Đăng xuất</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- MAIN CONTAINER -->
  <main class="container-xl py-5">
    <div class="mb-5">
      <span class="d-inline-block border border-2 border-black rounded-pill px-3 py-1 fw-bold text-uppercase small bg-light text-dark mb-2">Ghi Chú Bản Cập Nhật</span>
      <h1 class="fw-black fw-bold mb-1">${game.title} &mdash; Patch Notes</h1>
      <p class="fw-semibold text-secondary gf-muted">Quản lý và xuất bản các ghi chú cập nhật phiên bản phát hành của trò chơi tới cộng đồng.</p>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty param.success}">
      <div class="alert alert-success d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:#94FFB4; color:#000;">
        <i data-lucide="check-circle" width="20" height="20"></i>
        <span>Gửi ghi chú patch notes mới thành công!</span>
      </div>
    </c:if>
    <c:if test="${not empty param.error}">
      <div class="alert alert-danger d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:var(--gf-pink); color:#000;">
        <i data-lucide="alert-circle" width="20" height="20"></i>
        <span>Vui lòng không để trống bất kỳ trường thông tin nào!</span>
      </div>
    </c:if>

    <div class="row g-4">
      
      <!-- PHẦN 1: FORM THÊM MỚI BÊN TRÁI -->
      <div class="col-lg-5">
        <div class="panel-box">
          <h4 class="fw-black mb-4 d-flex align-items-center gap-2" style="font-size:18px;">
            <i data-lucide="plus-circle" width="20" height="20" class="text-success"></i> Đăng patch note mới
          </h4>
          
          <form action="${pageContext.request.contextPath}/publisher/games/patch-notes/${game.id}/add" method="POST">
            <div class="mb-3">
              <label class="form-label text-dark">Phiên bản phát hành *</label>
              <input type="text" name="version" required class="form-control" placeholder="Ví dụ: v1.0.1 hoặc Patch 1.1">
            </div>
            
            <div class="mb-4">
              <label class="form-label text-dark">Nội dung thay đổi *</label>
              <textarea name="content" required rows="8" class="form-control" placeholder="- Sửa lỗi crash game khi khởi động&#10;- Cân bằng chỉ số nhân vật&#10;- Tối ưu hiệu năng đồ họa..."></textarea>
            </div>
            
            <button type="submit" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5" style="background: var(--gf-green); color:#000;">
              <i data-lucide="send" width="16" height="16" class="me-1"></i> Xuất bản ghi chú
            </button>
          </form>
        </div>
      </div>

      <!-- PHẦN 2: LỊCH SỬ PHIÊN BẢN BÊN PHẢI -->
      <div class="col-lg-7">
        <h4 class="fw-black mb-4 d-flex align-items-center gap-2" style="font-size:18px;">
          <i data-lucide="history" width="20" height="20" class="text-primary"></i> Lịch sử phiên bản
        </h4>
        
        <c:forEach var="note" items="${patchNotes}">
          <div class="patch-note-card">
            <div class="patch-note-header d-flex justify-content-between align-items-center">
              <span class="fs-5 fw-black text-dark"><i data-lucide="tag" width="18" height="18" class="me-1"></i> ${note.version}</span>
              <span class="small fw-semibold text-secondary" style="font-size:12px; color: #4b5563 !important;">
                Đăng ngày: <fmt:parseDate value="${note.publishedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedPubDate" type="both" /><fmt:formatDate value="${parsedPubDate}" pattern="dd/MM/yyyy HH:mm" />
              </span>
            </div>
            <div class="p-4" style="background:#fff;">
              <p class="mb-0 fw-semibold text-dark" style="white-space: pre-wrap; line-height:1.6;">${fn:escapeXml(note.content)}</p>
            </div>
          </div>
        </c:forEach>

        <c:if test="${empty patchNotes}">
          <div class="panel-box text-center py-5">
            <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:52px;height:52px;">
              <i data-lucide="scroll" width="24" height="24" class="text-secondary"></i>
            </div>
            <h5 class="fw-black fw-bold mb-1 text-dark">Chưa có ghi chú nào</h5>
            <p class="small text-secondary gf-muted mb-0">Viết patch note đầu tiên của bạn để thông báo cho người dùng.</p>
          </div>
        </c:if>
      </div>

    </div>
  </main>

  <script>
    lucide.createIcons();
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
