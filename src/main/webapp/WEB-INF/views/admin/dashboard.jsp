<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Admin Dashboard</title>
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <script>
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:12%;left:2%;background:var(--gf-yellow);transform:rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top:60%;left:3%;background:var(--gf-lavender);transform:rotate(-25deg);width:28px;height:28px;"></div>
  <div class="gf-decor-pill" style="top:18%;right:4%;background:var(--gf-pink);transform:rotate(40deg);width:24px;height:24px;border-radius:50%;"></div>
  <div class="gf-decor-pill" style="top:72%;right:2%;background:#94FFB4;transform:rotate(-8deg);"></div>

  <!-- ADMIN NAVBAR -->
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
          <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
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
          <a href="${pageContext.request.contextPath}/admin/settings" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
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
    <div class="mb-5">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-pink);box-shadow:3px 3px 0 #000;">
        <i data-lucide="bar-chart-3" width="16" height="16"></i> Tổng quan hệ thống
      </div>
      <h1 class="fw-black fw-bold mb-2" style="font-size:clamp(2rem,5vw,3rem);line-height:1.1;letter-spacing:-0.03em;">
        Admin <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Dashboard</span>
      </h1>
      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:500px;">Theo dõi toàn bộ hoạt động của nền tảng GameForge.</p>
    </div>

    <!-- STATS CARDS -->
    <div class="row g-4 mb-5">
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-blue);">
              <i data-lucide="users" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-2 fw-black mb-1"><fmt:formatNumber value="${stats.totalUsers}" type="number"/></div>
          <div class="small fw-bold text-secondary">Tổng người dùng</div>
          <div class="small fw-bold mt-1" style="color:var(--gf-green);">+<fmt:formatNumber value="${stats.activeUsers}" type="number"/> active</div>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-yellow);">
              <i data-lucide="gamepad-2" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-2 fw-black mb-1"><fmt:formatNumber value="${stats.totalGames}" type="number"/></div>
          <div class="small fw-bold text-secondary">Tổng game</div>
          <div class="small fw-bold mt-1" style="color:var(--gf-green);">+<fmt:formatNumber value="${stats.activeGames}" type="number"/> active</div>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-lavender);">
              <i data-lucide="receipt" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-2 fw-black mb-1"><fmt:formatNumber value="${stats.totalOrders}" type="number"/></div>
          <div class="small fw-bold text-secondary">Tổng đơn hàng</div>
          <div class="small fw-bold mt-1" style="color:var(--gf-green);"><fmt:formatNumber value="${stats.completedOrders}" type="number"/> completed</div>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:#94FFB4;">
              <i data-lucide="wallet" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-4 fw-black mb-1"><fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0"/>đ</div>
          <div class="small fw-bold text-secondary">Tổng doanh thu</div>
          <div class="small fw-bold mt-1" style="color:var(--gf-green);"><fmt:formatNumber value="${stats.platformRevenue}" type="number" maxFractionDigits="0"/>đ platform</div>
        </div>
      </div>
    </div>

    <!-- SECONDARY STATS -->
    <div class="row g-4 mb-5">
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:var(--gf-pink);">
              <i data-lucide="id-card" width="18" height="18"></i>
            </div>
            <span class="fw-bold small text-secondary">KYC chờ duyệt</span>
          </div>
          <div class="fs-3 fw-black"><fmt:formatNumber value="${stats.pendingKyc}" type="number"/></div>
          <a href="${pageContext.request.contextPath}/admin/kyc" class="small fw-bold text-decoration-none" style="color:var(--gf-green);">Xem ngay &rarr;</a>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:var(--gf-yellow);">
              <i data-lucide="banknote" width="18" height="18"></i>
            </div>
            <span class="fw-bold small text-secondary">Payout chờ duyệt</span>
          </div>
          <div class="fs-3 fw-black"><fmt:formatNumber value="${stats.pendingPayouts}" type="number"/></div>
          <a href="${pageContext.request.contextPath}/admin/payouts" class="small fw-bold text-decoration-none" style="color:var(--gf-green);">Xem ngay &rarr;</a>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:var(--gf-lavender);">
              <i data-lucide="shopping-cart" width="18" height="18"></i>
            </div>
            <span class="fw-bold small text-secondary">Đơn hàng hôm nay</span>
          </div>
          <div class="fs-3 fw-black"><fmt:formatNumber value="${stats.ordersToday}" type="number"/></div>
        </div>
      </div>
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:#94FFB4;">
              <i data-lucide="user-check" width="18" height="18"></i>
            </div>
            <span class="fw-bold small text-secondary">Nhà phát hành</span>
          </div>
          <div class="fs-3 fw-black"><fmt:formatNumber value="${stats.totalPublishers}" type="number"/></div>
        </div>
      </div>
    </div>

    <!-- QUICK ACTIONS -->
    <div class="row g-4">
      <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/users" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:56px;height:56px;background:var(--gf-blue);">
              <i data-lucide="users" width="26" height="26"></i>
            </div>
            <h5 class="fw-black mb-1">Quản lý người dùng</h5>
            <p class="small text-secondary gf-muted mb-0">Xem, khóa/mở khóa tài khoản người dùng</p>
          </div>
        </a>
      </div>
      <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/games" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:56px;height:56px;background:#94FFB4;">
              <i data-lucide="gamepad-2" width="26" height="26"></i>
            </div>
            <h5 class="fw-black mb-1">Duyệt game mới</h5>
            <p class="small text-secondary gf-muted mb-0">Phê duyệt game từ nhà phát hành</p>
          </div>
        </a>
      </div>
      <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/kyc" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:56px;height:56px;background:var(--gf-yellow);">
              <i data-lucide="shield-check" width="26" height="26"></i>
            </div>
            <h5 class="fw-black mb-1">Duyệt KYC</h5>
            <p class="small text-secondary gf-muted mb-0">Xác minh danh tính nhà phát hành</p>
          </div>
        </a>
      </div>
      <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/settings" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:56px;height:56px;background:var(--gf-lavender);">
              <i data-lucide="settings" width="26" height="26"></i>
            </div>
            <h5 class="fw-black mb-1">Cài đặt hệ thống</h5>
            <p class="small text-secondary gf-muted mb-0">Phí nền tảng, cấu hình chung</p>
          </div>
        </a>
      </div>
    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForce Admin Dashboard
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
