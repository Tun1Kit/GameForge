<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Cài đặt hệ thống</title>

  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:15%;left:3%;background:var(--gf-lavender);transform:rotate(10deg);"></div>
  <div class="gf-decor-pill" style="top:60%;right:4%;background:var(--gf-yellow);transform:rotate(-14deg);"></div>

  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">

        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="shield-check" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge bg-danger ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;">ADMIN</span></span>
        </a>
        
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="users" width="14" height="14"></i> Người dùng
          </a>
          <a href="${pageContext.request.contextPath}/admin/games" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="gamepad-2" width="14" height="14"></i> Quản lý Game
          </a>
          <a href="${pageContext.request.contextPath}/admin/kyc" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <a href="${pageContext.request.contextPath}/admin/payouts" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/admin/badges" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="award" width="14" height="14"></i> Huy hiệu
          </a>
          <a href="${pageContext.request.contextPath}/admin/settings" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
            <i data-lucide="settings" width="14" height="14"></i> Settings
          </a>
          
          <!-- Notification Bell -->
          <a href="${pageContext.request.contextPath}/admin/notifications" class="btn btn-sm gf-border-2 gf-press bg-white text-dark rounded-3 d-flex align-items-center justify-content-center p-0 position-relative" style="width:38px; height:38px; border-color:#000; flex-shrink:0;">
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
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Admin'}" alt="Avatar" style="width:24px;height:24px;border-radius:50%;object-fit:cover;border:1.5px solid #000;">
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

  <!-- MAIN CONTENT -->
  <main class="container-xl py-5">

    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3"
           style="background:var(--gf-lavender);box-shadow:3px 3px 0 #000;">
        <i data-lucide="settings" width="16" height="16"></i> Cài đặt hệ thống
      </div>

      <h1 class="fw-black fw-bold mb-2"
          style="font-size:clamp(1.8rem,4vw,2.8rem);line-height:1.1;letter-spacing:-0.03em;">
        Thiết lập <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Hệ thống</span>
      </h1>

      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:500px;">
        Cấu hình các thông số vận hành nền tảng GameForge.
      </p>
    </div>

    <!-- SUCCESS / ERROR ALERTS -->
    <c:if test="${not empty sessionScope.settingSuccess}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2"
           style="background:#94FFB4;border:3px solid #000;border-radius:12px;"
           role="alert">
        <i data-lucide="check-circle" width="18" height="18"></i>
        ${fn:escapeXml(sessionScope.settingSuccess)}
        <% session.removeAttribute("settingSuccess"); %>
      </div>
    </c:if>

    <c:if test="${not empty sessionScope.settingError}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2"
           style="background:var(--gf-pink);border:3px solid #000;border-radius:12px;"
           role="alert">
        <i data-lucide="alert-circle" width="18" height="18"></i>
        ${fn:escapeXml(sessionScope.settingError)}
        <% session.removeAttribute("settingError"); %>
      </div>
    </c:if>

    <!-- COMMISSION SETTINGS -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-yellow);border-bottom:3px solid #000;">
        <i data-lucide="percent" width="18" height="18"></i>
        Phí nền tảng (Platform Commission)
      </div>

      <div class="p-4">
        <form action="${pageContext.request.contextPath}/admin/settings/commission"
              method="post"
              id="commissionForm">

          <input type="hidden" name="_csrf" value="${_csrf.token}" />

          <div class="row g-4 align-items-end">

            <div class="col-md-6">
              <label for="commissionRate" class="form-label fw-bold small text-secondary">
                Tỷ lệ phí hoa hồng nền tảng (%)
              </label>

              <div class="position-relative">
                <input type="number"
                       name="commissionRate"
                       id="commissionRate"
                       value="${commissionRate}"
                       min="0"
                       max="100"
                       step="0.01"
                       class="form-control gf-input ps-5"
                       placeholder="VD: 15.00"
                       required>

                <span class="position-absolute fw-black"
                      style="top:50%;left:14px;transform:translateY(-50%);font-size:18px;">
                  %
                </span>
              </div>

              <div class="form-text small">
                Phần trăm doanh thu game nền tảng giữ lại từ mỗi giao dịch.
              </div>
            </div>

            <div class="col-md-3">
              <div class="p-3 gf-border-2 rounded-3"
                   style="background:var(--gf-lavender);border:2px solid #000;">
                <div class="small fw-bold text-secondary">Hiện tại</div>
                <div class="fs-4 fw-black">${commissionRate}%</div>
              </div>
            </div>

            <div class="col-md-3">
              <button type="submit"
                      class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold d-flex align-items-center justify-content-center gap-2"
                      style="background:var(--gf-green);border-radius:10px;padding:10px 20px;">
                <i data-lucide="save" width="16" height="16"></i>
                Lưu phí hoa hồng
              </button>
            </div>

          </div>
        </form>
      </div>
    </div>

    <!-- SYSTEM INFO -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden">
      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-lavender);border-bottom:3px solid #000;">
        <i data-lucide="info" width="18" height="18"></i>
        Thông tin hệ thống
      </div>

      <div class="p-4">
        <div class="row g-4">

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:#94FFB4;border:2px solid #000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="database" width="16" height="16"></i>
                <span class="fw-bold small text-secondary">Database</span>
              </div>
              <div class="fw-black">SQL Server</div>
            </div>
          </div>

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:var(--gf-blue);border:2px solid #000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="server" width="16" height="16"></i>
                <span class="fw-bold small text-secondary">Server</span>
              </div>
              <div class="fw-black">Apache Tomcat</div>
            </div>
          </div>

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:var(--gf-yellow);border:2px solid #000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="cpu" width="16" height="16"></i>
                <span class="fw-bold small text-secondary">Framework</span>
              </div>
              <div class="fw-black">Spring MVC</div>
            </div>
          </div>

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:var(--gf-pink);border:2px solid #000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="git-branch" width="16" height="16"></i>
                <span class="fw-bold small text-secondary">Phiên bản</span>
              </div>
              <div class="fw-black">GameForge v2.0</div>
            </div>
          </div>

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:var(--gf-lavender);border:2px solid #000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="shield" width="16" height="16"></i>
                <span class="fw-bold small text-secondary">Auth</span>
              </div>
              <div class="fw-black">BCrypt + OTP</div>
            </div>
          </div>

          <div class="col-sm-6 col-md-4">
            <div class="gf-border-2 rounded-3 p-3" style="background:var(--gf-green);border:2px solid #000;color:#000;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="zap" width="16" height="16"></i>
                <span class="fw-bold small" style="color:#18181b;">Trạng thái</span>
              </div>
              <div class="fw-black">Hoạt động</div>
            </div>
          </div>

        </div>
      </div>
    </div>

  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge Admin &mdash; Neo-Brutalism Dashboard
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>