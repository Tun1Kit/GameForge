<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Publisher Dashboard</title>
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <script>
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/publisher.css">
</head>
<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:12%;left:3%;background:var(--gf-green);transform:rotate(14deg);"></div>
  <div class="gf-decor-pill" style="top:60%;right:3%;background:var(--gf-pink);transform:rotate(-20deg);width:26px;height:26px;"></div>
  <div class="gf-decor-pill" style="top:72%;left:2%;background:var(--gf-yellow);transform:rotate(-8deg);"></div>

  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/publisher/dashboard" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;background:var(--gf-yellow);color:#000;">PUBLISHER</span></span>
        </a>
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <a href="${pageContext.request.contextPath}/publisher/dashboard" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/publisher/games" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
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

  <!-- MAIN CONTENT -->
  <main class="container-xl py-5">
    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-green);box-shadow:3px 3px 0 #000;">
        <i data-lucide="bar-chart-2" width="16" height="16"></i> Trang nhà phát hành
      </div>

      <h1 class="fw-black fw-bold mb-2" style="font-size:clamp(2rem,5vw,3rem);line-height:1.1;letter-spacing:-0.03em;">
        Chào mừng, <br>
        <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">${fn:escapeXml(currentUser.fullName)}!</span>
      </h1>

      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:500px;">
        Quản lý doanh thu, theo dõi payout, hồ sơ KYC và đăng game mới.
      </p>
    </div>

    <!-- STATS CARDS -->
    <div class="row g-4 mb-5">
      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-yellow);">
              <i data-lucide="wallet" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-4 fw-black mb-1">
            <fmt:formatNumber value="${wallet.balance}" type="number" maxFractionDigits="0"/>đ
          </div>
          <div class="small fw-bold text-secondary">Số dư ví</div>
        </div>
      </div>

      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:#94FFB4;">
              <i data-lucide="trending-up" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-4 fw-black mb-1">
            <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0"/>đ
          </div>
          <div class="small fw-bold text-secondary">Tổng doanh thu</div>
        </div>
      </div>

      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-lavender);">
              <i data-lucide="gamepad-2" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-2 fw-black mb-1">
            <fmt:formatNumber value="${totalGames}" type="number"/>
          </div>
          <div class="small fw-bold text-secondary">Game đã đăng</div>
        </div>
      </div>

      <div class="col-sm-6 col-lg-3">
        <div class="bg-white gf-border rounded-4 gf-shadow p-4 h-100">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:48px;height:48px;background:var(--gf-pink);">
              <i data-lucide="banknote" width="22" height="22"></i>
            </div>
          </div>
          <div class="fs-2 fw-black mb-1">
            <fmt:formatNumber value="${pendingPayout}" type="number" maxFractionDigits="0"/>đ
          </div>
          <div class="small fw-bold text-secondary">Chờ payout</div>
        </div>
      </div>
    </div>

    <!-- WALLET INFO -->
    <div class="bg-white gf-border rounded-4 gf-shadow p-4 mb-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2 mb-3" style="background:var(--gf-yellow);border-bottom:3px solid #000;">
        <i data-lucide="wallet" width="18" height="18"></i> Thông tin ví
      </div>

      <div class="row g-3">
        <div class="col-sm-4">
          <div class="gf-border-2 rounded-3 p-3 text-center" style="background:#94FFB4;border:2px solid #000;">
            <div class="small fw-bold text-secondary mb-1">Số dư khả dụng</div>
            <div class="fs-4 fw-black">
              <fmt:formatNumber value="${wallet.balance}" type="number" maxFractionDigits="0"/>đ
            </div>
          </div>
        </div>

        <div class="col-sm-4">
          <div class="gf-border-2 rounded-3 p-3 text-center" style="background:var(--gf-lavender);border:2px solid #000;">
            <div class="small fw-bold text-secondary mb-1">Đang chờ payout</div>
            <div class="fs-4 fw-black">
              <fmt:formatNumber value="${pendingPayout}" type="number" maxFractionDigits="0"/>đ
            </div>
          </div>
        </div>

        <div class="col-sm-4">
          <div class="gf-border-2 rounded-3 p-3 text-center" style="background:var(--gf-yellow);border:2px solid #000;">
            <div class="small fw-bold text-secondary mb-1">Khả dụng rút</div>
            <div class="fs-4 fw-black">
              <fmt:formatNumber value="${wallet.balance - pendingPayout > 0 ? wallet.balance - pendingPayout : 0}" type="number" maxFractionDigits="0"/>đ
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- RECENT TRANSACTIONS -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2" style="background:var(--gf-lavender);border-bottom:3px solid #000;">
        <i data-lucide="history" width="18" height="18"></i> Giao dịch gần đây
      </div>

      <div class="table-responsive">
        <table class="table table-hover mb-0 gf-pub-table">
          <thead>
            <tr>
              <th class="fw-black px-4 py-3">Mã GD</th>
              <th class="fw-black py-3">Loại</th>
              <th class="fw-black py-3">Số tiền</th>
              <th class="fw-black py-3">Mô tả</th>
              <th class="fw-black py-3">Ngày</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty recentTransactions}">
                <c:forEach var="tx" items="${recentTransactions}">
                  <tr>
                    <td class="px-4 py-3 small fw-bold text-secondary">#TX-${tx.id}</td>
                    <td class="py-3">
                      <span class="badge fw-bold" style="background:${tx.type == 'CREDIT' ? '#94FFB4' : 'var(--gf-pink)'};border:2px solid #000;border-radius:999px;font-size:10px;padding:3px 8px;">
                        ${fn:escapeXml(tx.type)}
                      </span>
                    </td>
                    <td class="py-3 fw-black ${tx.type == 'CREDIT' ? 'text-success' : 'text-danger'}">
                      ${tx.type == 'CREDIT' ? '+' : '-'}<fmt:formatNumber value="${tx.amount}" type="number" maxFractionDigits="0"/>đ
                    </td>
                    <td class="py-3 small">${fn:escapeXml(tx.description)}</td>
                    <td class="py-3 small text-secondary">
                      <fmt:parseDate value="${tx.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                      <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                    </td>
                  </tr>
                </c:forEach>
              </c:when>

              <c:otherwise>
                <tr>
                  <td colspan="5" class="text-center py-4">
                    <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3 place-items-center" style="width:48px;height:48px;background:var(--gf-lavender);">
                      <i data-lucide="history" width="22" height="22"></i>
                    </div>
                    <h5 class="fw-bold">Chưa có giao dịch nào</h5>
                    <p class="small text-secondary gf-muted">Doanh thu từ bán game sẽ hiển thị tại đây.</p>
                  </td>
                </tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ACTION BUTTONS -->
    <div class="row g-3">
      <div class="col-sm-6 col-lg-4">
        <a href="${pageContext.request.contextPath}/publisher/payouts" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:52px;height:52px;background:var(--gf-yellow);">
              <i data-lucide="banknote" width="24" height="24"></i>
            </div>
            <h5 class="fw-black mb-1">Yêu cầu Payout</h5>
            <p class="small text-secondary gf-muted mb-0">Rút tiền từ ví về tài khoản</p>
          </div>
        </a>
      </div>

      <div class="col-sm-6 col-lg-4">
        <a href="${pageContext.request.contextPath}/publisher/kyc" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:52px;height:52px;background:var(--gf-lavender);">
              <i data-lucide="id-card" width="24" height="24"></i>
            </div>
            <h5 class="fw-black mb-1">Hồ sơ KYC</h5>
            <p class="small text-secondary gf-muted mb-0">Xem trạng thái xác minh Publisher</p>
          </div>
        </a>
      </div>

      <div class="col-sm-6 col-lg-4">
        <a href="${pageContext.request.contextPath}/publisher/games" class="text-decoration-none">
          <div class="bg-white gf-border rounded-4 gf-shadow gf-press p-4 text-center h-100">
            <div class="gf-border-2 rounded-3 d-grid mx-auto mb-3 place-items-center" style="width:52px;height:52px;background:var(--gf-pink);">
              <i data-lucide="plus" width="24" height="24"></i>
            </div>
            <h5 class="fw-black mb-1">Đăng game mới</h5>
            <p class="small text-secondary gf-muted mb-0">Tải game lên cửa hàng GameForge</p>
          </div>
        </a>
      </div>
    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge Publisher &mdash; Neo-Brutalism Dashboard
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/publisher.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    lucide.createIcons();
  </script>
</body>
</html>