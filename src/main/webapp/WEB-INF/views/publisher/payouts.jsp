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
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/publisher.css">
</head>
<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:15%;right:3%;background:var(--gf-yellow);transform:rotate(16deg);"></div>
  <div class="gf-decor-pill" style="top:55%;left:2%;background:var(--gf-lavender);transform:rotate(-12deg);"></div>

  <!-- PUBLISHER NAVBAR -->
  <nav class="gf-navbar" style="background:#18181b;border-bottom:3px solid #000;">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-white">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;background:var(--gf-yellow);color:#000;">PUBLISHER</span></span>
        </a>
        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/publisher" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/publisher/payouts" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3" style="background:var(--gf-green);border-color:#000;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/kyc" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <div class="dropdown">
            <button class="btn dropdown-toggle gf-press d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown"
                    style="background:#18181b;border:3px solid var(--gf-green);border-radius:999px;height:40px;padding:4px 14px 4px 6px;color:#fff;box-shadow:3px 3px 0 0 #000;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Publisher'}" alt="Avatar" style="width:28px;height:28px;border-radius:50%;object-fit:cover;border:2px solid var(--gf-green);">
              <span class="d-none d-sm-inline fw-black text-white" style="font-size:12px;">${fn:escapeXml(currentUser.username)}</span>
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
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-yellow);box-shadow:3px 3px 0 #000;">
        <i data-lucide="banknote" width="16" height="16"></i> Quản lý Payout
      </div>
      <h1 class="fw-black fw-bold mb-2" style="font-size:clamp(1.8rem,4vw,2.8rem);line-height:1.1;letter-spacing:-0.03em;">
        Yêu cầu <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Rút tiền</span>
      </h1>
    </div>

    <!-- SUCCESS/ERROR -->
    <c:if test="${not empty sessionScope.payoutSuccess}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2" style="background:#94FFB4;border:3px solid #000;border-radius:12px;" role="alert">
        <i data-lucide="check-circle" width="18" height="18"></i> ${fn:escapeXml(sessionScope.payoutSuccess)}
        <% session.removeAttribute("payoutSuccess"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.payoutError}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2" style="background:var(--gf-pink);border:3px solid #000;border-radius:12px;" role="alert">
        <i data-lucide="alert-circle" width="18" height="18"></i> ${fn:escapeXml(sessionScope.payoutError)}
        <% session.removeAttribute("payoutError"); %>
      </div>
    </c:if>

    <!-- WALLET SUMMARY -->
    <div class="row g-3 mb-4">
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:44px;height:44px;background:var(--gf-green);flex-shrink:0;color:#000;">
              <i data-lucide="wallet" width="20" height="20"></i>
            </div>
            <div>
              <div class="small fw-bold text-secondary">Số dư ví</div>
              <div class="fs-5 fw-black"><fmt:formatNumber value="${wallet.balance}" type="number" maxFractionDigits="0"/>đ</div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:44px;height:44px;background:var(--gf-yellow);flex-shrink:0;">
              <i data-lucide="clock" width="20" height="20"></i>
            </div>
            <div>
              <div class="small fw-bold text-secondary">Đang chờ</div>
              <div class="fs-5 fw-black"><fmt:formatNumber value="${pendingAmount}" type="number" maxFractionDigits="0"/>đ</div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:44px;height:44px;background:#94FFB4;flex-shrink:0;">
              <i data-lucide="banknote" width="20" height="20"></i>
            </div>
            <div>
              <div class="small fw-bold text-secondary">Khả dụng rút</div>
              <div class="fs-5 fw-black"><fmt:formatNumber value="${wallet.balance - pendingAmount > 0 ? wallet.balance - pendingAmount : 0}" type="number" maxFractionDigits="0"/>đ</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- NEW PAYOUT REQUEST -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4" id="payoutRequestCard">
      <div class="p-3 fw-black d-flex align-items-center gap-2" style="background:var(--gf-green);color:#000;border-bottom:3px solid #000;">
        <i data-lucide="plus-circle" width="18" height="18"></i> Yêu cầu rút tiền mới
      </div>
      <div class="p-4">
        <form action="${pageContext.request.contextPath}/publisher/payouts" method="post" id="payoutForm">
          <input type="hidden" name="_csrf" value="${_csrf.token}" />
          <div class="row g-3 align-items-end">
            <div class="col-md-5">
              <label class="form-label fw-bold small text-secondary">Số tiền muốn rút (đ)</label>
              <input type="number" name="amount" id="payoutAmount" min="10000" step="1000"
                     value="${fn:escapeXml(param.amount)}"
                     class="form-control gf-input" placeholder="VD: 500000" required>
              <div class="form-text small">Tối thiểu: 10.000đ. Số dư khả dụng: <strong><fmt:formatNumber value="${wallet.balance - pendingAmount > 0 ? wallet.balance - pendingAmount : 0}" type="number" maxFractionDigits="0"/>đ</strong></div>
            </div>
            <div class="col-md-3">
              <button type="submit" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold d-flex align-items-center justify-content-center gap-2"
                      style="background:var(--gf-yellow);border-radius:10px;padding:10px 20px;">
                <i data-lucide="send" width="16" height="16"></i> Gửi yêu cầu
              </button>
            </div>
            <div class="col-md-4">
              <div class="p-3 gf-border-2 rounded-3 text-center" style="background:var(--gf-lavender);border:2px solid #000;">
                <div class="small fw-bold text-secondary">Phương thức</div>
                <div class="fw-black">Chuyển khoản ngân hàng</div>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- PAYOUT HISTORY TABLE -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden">
      <div class="p-3 fw-black d-flex align-items-center gap-2" style="background:var(--gf-lavender);border-bottom:3px solid #000;">
        <i data-lucide="history" width="18" height="18"></i> Lịch sử Payout
        <span class="badge bg-black text-white ms-auto border border-2 border-white" style="border-radius:50%;width:26px;height:26px;display:grid;place-items:center;padding:0;font-size:11px;">
          ${pageResult.totalElements}
        </span>
      </div>
      <div class="table-responsive">
        <table class="table table-hover mb-0 gf-pub-table">
          <thead>
            <tr>
              <th class="fw-black px-4 py-3">#</th>
              <th class="fw-black py-3">Số tiền</th>
              <th class="fw-black py-3">Trạng thái</th>
              <th class="fw-black py-3">Ngày yêu cầu</th>
              <th class="fw-black py-3">Xử lý lúc</th>
              <th class="fw-black py-3">Ghi chú</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty pageResult.content}">
                <c:forEach var="payout" items="${pageResult.content}">
                  <tr>
                    <td class="px-4 py-3 small fw-bold text-secondary">#GF-PAY-${payout.id}</td>
                    <td class="py-3 fw-black"><fmt:formatNumber value="${payout.amount}" type="number" maxFractionDigits="0"/>đ</td>
                    <td class="py-3">
                      <span class="badge fw-bold px-3 py-1.5 rounded-pill"
                            style="font-size:11px;border:2px solid #000;
                                   background:${payout.status == 'APPROVED' ? '#94FFB4' : payout.status == 'REJECTED' ? 'var(--gf-pink)' : 'var(--gf-yellow)'};">
                        ${fn:escapeXml(payout.status)}
                      </span>
                    </td>
                    <td class="py-3 small text-secondary">
                      <fmt:parseDate value="${payout.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                      <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                    </td>
                    <td class="py-3 small text-secondary">
                      <c:if test="${payout.processedAt != null}">
                        <fmt:parseDate value="${payout.processedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedProcessed" type="both" />
                        <fmt:formatDate value="${parsedProcessed}" pattern="dd/MM/yyyy HH:mm" />
                      </c:if>
                      <c:if test="${payout.processedAt == null}">—</c:if>
                    </td>
                    <td class="py-3 small text-secondary" style="max-width:120px;">
                      <span class="text-truncate d-block">${fn:escapeXml(payout.adminNote)}</span>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr>
                  <td colspan="6" class="text-center py-5">
                    <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3 place-items-center" style="width:48px;height:48px;background:var(--gf-yellow);">
                      <i data-lucide="banknote" width="22" height="22"></i>
                    </div>
                    <h5 class="fw-bold">Chưa có yêu cầu nào</h5>
                    <p class="small text-secondary gf-muted">Tạo yêu cầu rút tiền ở trên.</p>
                  </td>
                </tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>

      <!-- PAGINATION -->
      <c:if test="${pageResult.totalPages > 1}">
        <div class="p-3 border-top border-2 border-dark d-flex align-items-center justify-content-end">
          <nav>
            <ul class="pagination pagination-sm mb-0 gap-1">
              <c:if test="${pageResult.currentPage > 1}">
                <li class="page-item"><a class="page-link gf-page-link" href="?page=${pageResult.currentPage - 1}">&laquo;</a></li>
              </c:if>
              <c:forEach var="i" begin="1" end="${pageResult.totalPages > 5 ? 5 : pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link ${i == pageResult.currentPage ? 'active' : ''}" href="?page=${i}">${i}</a>
                </li>
              </c:forEach>
              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item"><a class="page-link gf-page-link" href="?page=${pageResult.currentPage + 1}">&raquo;</a></li>
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

  <script src="${pageContext.request.contextPath}/assets/js/publisher.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
