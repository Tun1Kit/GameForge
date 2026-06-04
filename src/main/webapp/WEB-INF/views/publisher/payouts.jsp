<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Yêu cầu Payout</title>

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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/publisher.css">

  <style>
    html,
    body {
      min-height: 100vh;
      overflow-x: hidden;
      overflow-y: auto;
    }

    .gf-payout-table {
      width: 100%;
      min-width: 950px;
      margin-bottom: 0;
    }

    .gf-payout-table th {
      background: #18181b !important;
      color: #fff !important;
      padding: 14px !important;
      font-weight: 900 !important;
      white-space: nowrap;
    }

    .gf-payout-table td {
      padding: 14px !important;
      vertical-align: middle !important;
      color: #18181b !important;
    }

    .gf-status-badge {
      display: inline-block;
      border: 2px solid #000;
      border-radius: 999px;
      padding: 5px 12px;
      font-weight: 900;
      font-size: 12px;
      color: #18181b;
      white-space: nowrap;
    }

    .gf-btn-neo {
      border: 3px solid #000 !important;
      border-radius: 10px !important;
      box-shadow: 3px 3px 0 #000 !important;
      font-weight: 900 !important;
    }

    .gf-payout-input {
      border: 3px solid #000 !important;
      border-radius: 12px !important;
      box-shadow: 4px 4px 0 #000 !important;
      font-weight: 700;
      min-height: 52px;
    }

    .gf-payout-textarea {
      border: 3px solid #000 !important;
      border-radius: 12px !important;
      box-shadow: 4px 4px 0 #000 !important;
      font-weight: 700;
      min-height: 100px;
    }
  </style>
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:15%;right:3%;background:var(--gf-yellow);transform:rotate(16deg);"></div>
  <div class="gf-decor-pill" style="top:55%;left:2%;background:var(--gf-lavender);transform:rotate(-12deg);"></div>

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
          <a href="${pageContext.request.contextPath}/publisher/games" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="package" width="14" height="14"></i> Game đã đăng
          </a>
          <a href="${pageContext.request.contextPath}/publisher/payouts" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
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

  <main class="container-xl py-5">

    <!-- TITLE -->
    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3"
           style="background:var(--gf-yellow);box-shadow:3px 3px 0 #000;">
        <i data-lucide="banknote" width="16" height="16"></i>
        Quản lý Payout
      </div>

      <h1 class="fw-black fw-bold mb-2"
          style="font-size:clamp(1.8rem,4vw,2.8rem);line-height:1.1;letter-spacing:-0.03em;">
        Yêu cầu <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Rút tiền</span>
      </h1>

      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:600px;">
        Tạo yêu cầu rút tiền và theo dõi trạng thái xử lý từ Admin.
      </p>
    </div>

    <!-- ALERT -->
    <c:if test="${not empty sessionScope.payoutSuccess}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2"
           style="background:#94FFB4;border:3px solid #000;border-radius:12px;">
        <i data-lucide="check-circle" width="18" height="18"></i>
        ${fn:escapeXml(sessionScope.payoutSuccess)}
        <c:remove var="payoutSuccess" scope="session" />
      </div>
    </c:if>

    <c:if test="${not empty sessionScope.payoutError}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2"
           style="background:var(--gf-pink);border:3px solid #000;border-radius:12px;">
        <i data-lucide="alert-circle" width="18" height="18"></i>
        ${fn:escapeXml(sessionScope.payoutError)}
        <c:remove var="payoutError" scope="session" />
      </div>
    </c:if>

    <c:if test="${not empty error}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2"
           style="background:var(--gf-pink);border:3px solid #000;border-radius:12px;">
        <i data-lucide="alert-circle" width="18" height="18"></i>
        ${fn:escapeXml(error)}
      </div>
    </c:if>

    <!-- WALLET SUMMARY -->
    <div class="row g-3 mb-4">

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:52px;height:52px;background:var(--gf-green);flex-shrink:0;color:#000;">
              <i data-lucide="wallet" width="22" height="22"></i>
            </div>

            <div>
              <div class="small fw-bold text-secondary">Số dư ví</div>
              <div class="fs-4 fw-black">
                <fmt:formatNumber value="${wallet.balance}" type="number" maxFractionDigits="0"/>đ
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:52px;height:52px;background:var(--gf-yellow);flex-shrink:0;">
              <i data-lucide="clock" width="22" height="22"></i>
            </div>

            <div>
              <div class="small fw-bold text-secondary">Đang chờ</div>
              <div class="fs-4 fw-black">
                <fmt:formatNumber value="${pendingAmount}" type="number" maxFractionDigits="0"/>đ
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:52px;height:52px;background:#94FFB4;flex-shrink:0;">
              <i data-lucide="banknote" width="22" height="22"></i>
            </div>

            <div>
              <div class="small fw-bold text-secondary">Khả dụng rút</div>
              <div class="fs-4 fw-black">
                <fmt:formatNumber value="${availableAmount}" type="number" maxFractionDigits="0"/>đ
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- NEW PAYOUT REQUEST -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-green);color:#000;border-bottom:3px solid #000;">
        <i data-lucide="plus-circle" width="18" height="18"></i>
        Yêu cầu rút tiền mới
      </div>

      <div class="p-4">
        <form action="${pageContext.request.contextPath}/publisher/payouts/request"
              method="post"
              id="payoutForm">

          <input type="hidden" name="_csrf" value="${_csrf.token}" />

          <div class="row g-4">

            <div class="col-lg-4">
              <label for="payoutAmount" class="form-label fw-bold text-secondary">
                Số tiền muốn rút (đ)
              </label>

              <input type="number"
                     name="amount"
                     id="payoutAmount"
                     min="10000"
                     step="1000"
                     class="form-control gf-payout-input"
                     placeholder="VD: 500000"
                     required>

              <div class="form-text small mt-2">
                Tối thiểu:
                <strong>10.000đ</strong>.
                Số dư khả dụng:
                <strong>
                  <fmt:formatNumber value="${availableAmount}" type="number" maxFractionDigits="0"/>đ
                </strong>
              </div>
            </div>

            <div class="col-lg-5">
              <label for="bankAccountInfo" class="form-label fw-bold text-secondary">
                Thông tin tài khoản ngân hàng
              </label>

              <textarea name="bankAccountInfo"
                        id="bankAccountInfo"
                        rows="4"
                        class="form-control gf-payout-textarea"
                        placeholder="VD: MB Bank - STK 0123456789 - Chủ TK: NGUYEN VAN A"
                        required></textarea>

              <div class="form-text small mt-2">
                Nhập ngân hàng, số tài khoản và tên chủ tài khoản.
              </div>
            </div>

            <div class="col-lg-3 d-flex align-items-end">
              <button type="submit"
                      class="btn w-100 gf-btn-neo d-flex align-items-center justify-content-center gap-2"
                      style="background:var(--gf-yellow);min-height:56px;">
                <i data-lucide="send" width="16" height="16"></i>
                Gửi yêu cầu
              </button>
            </div>

          </div>
        </form>
      </div>
    </div>

    <!-- HISTORY -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-5">
      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-lavender);border-bottom:3px solid #000;">
        <i data-lucide="history" width="18" height="18"></i>
        Lịch sử Payout

        <span class="badge bg-black text-white ms-auto border border-2 border-white"
              style="border-radius:999px;min-width:28px;height:28px;display:grid;place-items:center;padding:0 8px;font-size:12px;">
          ${pageResult.totalElements}
        </span>
      </div>

      <div class="table-responsive">
        <table class="table table-hover gf-payout-table">

          <thead>
            <tr>
              <th>#</th>
              <th>Số tiền</th>
              <th>Ngân hàng</th>
              <th>Trạng thái</th>
              <th>Ngày yêu cầu</th>
              <th>Xử lý lúc</th>
            </tr>
          </thead>

          <tbody>
            <c:choose>

              <c:when test="${not empty pageResult.content}">
                <c:forEach var="payout" items="${pageResult.content}">
                  <tr>
                    <td class="fw-bold text-secondary">
                      #GF-PAY-${payout.id}
                    </td>

                    <td class="fw-black">
                      <fmt:formatNumber value="${payout.amount}" type="number" maxFractionDigits="0"/>đ
                    </td>

                    <td class="small text-secondary" style="max-width:280px;">
                      <c:choose>
                        <c:when test="${not empty payout.bankAccountInfo}">
                          <span class="text-truncate d-block" title="${fn:escapeXml(payout.bankAccountInfo)}">
                            ${fn:escapeXml(payout.bankAccountInfo)}
                          </span>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${payout.status == 'PAID'}">
                          <span class="gf-status-badge" style="background:#94FFB4;">PAID</span>
                        </c:when>

                        <c:when test="${payout.status == 'REJECTED'}">
                          <span class="gf-status-badge" style="background:var(--gf-pink);">REJECTED</span>
                        </c:when>

                        <c:otherwise>
                          <span class="gf-status-badge" style="background:var(--gf-yellow);">PENDING</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td class="small text-secondary">
                      <c:choose>
                        <c:when test="${not empty payout.requestedAt}">
                          ${fn:replace(payout.requestedAt, 'T', ' ')}
                        </c:when>
                        <c:otherwise>Không rõ</c:otherwise>
                      </c:choose>
                    </td>

                    <td class="small text-secondary">
                      <c:choose>
                        <c:when test="${not empty payout.processedAt}">
                          ${fn:replace(payout.processedAt, 'T', ' ')}
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>

              <c:otherwise>
                <tr>
                  <td colspan="6" class="text-center py-5">
                    <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3 place-items-center"
                         style="width:52px;height:52px;background:var(--gf-yellow);">
                      <i data-lucide="banknote" width="24" height="24"></i>
                    </div>

                    <h5 class="fw-bold">Chưa có yêu cầu payout</h5>
                    <p class="small text-secondary gf-muted">
                      Tạo yêu cầu rút tiền ở form phía trên.
                    </p>
                  </td>
                </tr>
              </c:otherwise>

            </c:choose>
          </tbody>

        </table>
      </div>

      <c:if test="${not empty pageResult.totalPages && pageResult.totalPages > 1}">
        <div class="p-3 border-top border-2 border-dark d-flex align-items-center justify-content-end">
          <nav>
            <ul class="pagination pagination-sm mb-0 gap-1">

              <c:if test="${pageResult.currentPage > 1}">
                <li class="page-item">
                  <a class="page-link gf-page-link"
                     href="${pageContext.request.contextPath}/publisher/payouts?page=${pageResult.currentPage - 1}">
                    &laquo;
                  </a>
                </li>
              </c:if>

              <c:forEach var="i" begin="1" end="${pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link ${i == pageResult.currentPage ? 'active' : ''}"
                     href="${pageContext.request.contextPath}/publisher/payouts?page=${i}">
                    ${i}
                  </a>
                </li>
              </c:forEach>

              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link"
                     href="${pageContext.request.contextPath}/publisher/payouts?page=${pageResult.currentPage + 1}">
                    &raquo;
                  </a>
                </li>
              </c:if>

            </ul>
          </nav>
        </div>
      </c:if>

    </div>

  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge Publisher &mdash; Neo-Brutalism Dashboard
    </div>
  </footer>

  <script>
    if (window.lucide) {
      lucide.createIcons();
    }
  </script>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>