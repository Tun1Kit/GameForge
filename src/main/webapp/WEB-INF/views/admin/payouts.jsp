<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Quản lý Payout</title>
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
  <div class="gf-decor-pill" style="top:8%;right:3%;background:var(--gf-green);transform:rotate(20deg);"></div>
  <div class="gf-decor-pill" style="top:62%;left:2%;background:var(--gf-yellow);transform:rotate(-22deg);width:26px;height:26px;"></div>

  <!-- ADMIN NAVBAR -->
  <nav class="gf-navbar" style="background:#18181b;border-bottom:3px solid #000;">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="shield-check" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-white">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge bg-danger ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;">ADMIN</span></span>
        </a>
        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="users" width="14" height="14"></i> Người dùng
          </a>
          <a href="${pageContext.request.contextPath}/admin/kyc" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <a href="${pageContext.request.contextPath}/admin/payouts" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3" style="background:var(--gf-green);border-color:#000;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/admin/settings" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="settings" width="14" height="14"></i> Settings
          </a>
          <div class="dropdown">
            <button class="btn dropdown-toggle gf-press d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown"
                    style="background:#18181b;border:3px solid var(--gf-green);border-radius:999px;height:40px;padding:4px 14px 4px 6px;color:#fff;box-shadow:3px 3px 0 0 #000;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Admin'}" alt="Avatar" style="width:28px;height:28px;border-radius:50%;object-fit:cover;border:2px solid var(--gf-green);">
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
      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:500px;">Duyệt các yêu cầu rút tiền từ nhà phát hành.</p>
    </div>

    <!-- STATS -->
    <div class="row g-3 mb-4">
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:var(--gf-yellow);flex-shrink:0;">
              <i data-lucide="clock" width="18" height="18"></i>
            </div>
            <div>
              <div class="fs-4 fw-black">${stats.pending}</div>
              <div class="small fw-bold text-secondary">Chờ duyệt</div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:#94FFB4;flex-shrink:0;">
              <i data-lucide="check-circle" width="18" height="18"></i>
            </div>
            <div>
              <div class="fs-4 fw-black"><fmt:formatNumber value="${stats.approvedAmount}" type="number" maxFractionDigits="0"/>đ</div>
              <div class="small fw-bold text-secondary">Đã duyệt (tổng)</div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-2">
            <div class="gf-border-2 rounded-3 d-grid place-items-center" style="width:40px;height:40px;background:var(--gf-lavender);flex-shrink:0;">
              <i data-lucide="banknote" width="18" height="18"></i>
            </div>
            <div>
              <div class="fs-4 fw-black"><fmt:formatNumber value="${stats.totalRequests}" type="number"/></div>
              <div class="small fw-bold text-secondary">Tổng yêu cầu</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- FILTER TABS -->
    <div class="bg-white gf-border rounded-4 gf-shadow p-4 mb-4">
      <div class="d-flex flex-wrap gap-2">
        <a href="?status=PENDING" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'PENDING' || empty param.status ? 'text-white' : 'bg-light text-dark'}"
           style="${(empty param.status && not empty stats) || param.status == 'PENDING' ? 'background:var(--gf-yellow);' : ''}border-radius:999px;padding:5px 16px;">
          <i data-lucide="clock" width="13" height="13"></i> Chờ duyệt (${stats.pending})
        </a>
        <a href="?status=APPROVED" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'APPROVED' ? 'text-white' : 'bg-light text-dark'}"
           style="${param.status == 'APPROVED' ? 'background:#94FFB4;' : ''}border-radius:999px;padding:5px 16px;">
          <i data-lucide="check-circle" width="13" height="13"></i> Đã duyệt
        </a>
        <a href="?status=REJECTED" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'REJECTED' ? 'text-white' : 'bg-light text-dark'}"
           style="${param.status == 'REJECTED' ? 'background:var(--gf-pink);' : ''}border-radius:999px;padding:5px 16px;">
          <i data-lucide="x-circle" width="13" height="13"></i> Từ chối
        </a>
      </div>
    </div>

    <!-- PAYOUT TABLE -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden">
      <div class="p-3 fw-black d-flex align-items-center gap-2" style="background:var(--gf-green);color:#000;border-bottom:3px solid #000;">
        <i data-lucide="banknote" width="18" height="18"></i> Danh sách Payout
        <span class="badge bg-black text-white ms-auto border border-2 border-white" style="border-radius:50%;width:26px;height:26px;display:grid;place-items:center;padding:0;font-size:11px;">
          ${pageResult.totalElements}
        </span>
      </div>
      <div class="table-responsive">
        <table class="table table-hover mb-0 gf-admin-table">
          <thead>
            <tr>
              <th class="fw-black px-4 py-3">#</th>
              <th class="fw-black py-3">Nhà phát hành</th>
              <th class="fw-black py-3">Số tiền</th>
              <th class="fw-black py-3">Trạng thái</th>
              <th class="fw-black py-3">Ngày yêu cầu</th>
              <th class="fw-black py-3">Ghi chú</th>
              <th class="fw-black py-3 text-center">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty pageResult.content}">
                <c:forEach var="payout" items="${pageResult.content}">
                  <tr data-payout-id="${payout.id}">
                    <td class="px-4 py-3 small fw-bold text-secondary">#${payout.id}</td>
                    <td class="py-3">
                      <div class="d-flex align-items-center gap-3">
                        <img src="${not empty payout.publisher.user.avatar ? payout.publisher.user.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed='.concat(payout.publisher.user.username)}"
                             alt="${fn:escapeXml(payout.publisher.user.fullName)}" class="gf-border-2 rounded-circle"
                             style="width:36px;height:36px;object-fit:cover;border-color:var(--gf-muted);">
                        <div>
                          <div class="fw-bold">${fn:escapeXml(payout.publisher.user.fullName)}</div>
                          <div class="small text-secondary">@${fn:escapeXml(payout.publisher.user.username)}</div>
                        </div>
                      </div>
                    </td>
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
                    <td class="py-3 small text-secondary" style="max-width:120px;">
                      <span class="text-truncate d-block" title="${fn:escapeXml(payout.adminNote)}">${fn:escapeXml(payout.adminNote)}</span>
                    </td>
                    <td class="py-3 text-center">
                      <c:if test="${payout.status == 'PENDING'}">
                        <div class="d-flex align-items-center justify-content-center gap-2 flex-wrap">
                          <button type="button" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 approve-payout-btn"
                                  data-payout-id="${payout.id}" data-amount="${payout.amount}"
                                  style="background:#94FFB4;border-radius:8px;padding:5px 10px;font-size:12px;">
                            <i data-lucide="check" width="13" height="13"></i> Duyệt
                          </button>
                          <button type="button" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 reject-payout-btn"
                                  data-payout-id="${payout.id}"
                                  style="background:var(--gf-pink);border-radius:8px;padding:5px 10px;font-size:12px;">
                            <i data-lucide="x" width="13" height="13"></i> Từ chối
                          </button>
                        </div>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr>
                  <td colspan="7" class="text-center py-5">
                    <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3 place-items-center" style="width:48px;height:48px;background:var(--gf-green);">
                      <i data-lucide="banknote" width="22" height="22"></i>
                    </div>
                    <h5 class="fw-bold">Không có yêu cầu payout</h5>
                    <p class="small text-secondary gf-muted">Chưa có ai yêu cầu rút tiền.</p>
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
                <li class="page-item"><a class="page-link gf-page-link" href="?page=${pageResult.currentPage - 1}&status=${fn:escapeXml(param.status)}">&laquo;</a></li>
              </c:if>
              <c:forEach var="i" begin="1" end="${pageResult.totalPages > 5 ? 5 : pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link ${i == pageResult.currentPage ? 'active' : ''}" href="?page=${i}&status=${fn:escapeXml(param.status)}">${i}</a>
                </li>
              </c:forEach>
              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item"><a class="page-link gf-page-link" href="?page=${pageResult.currentPage + 1}&status=${fn:escapeXml(param.status)}">&raquo;</a></li>
              </c:if>
            </ul>
          </nav>
        </div>
      </c:if>
    </div>
  </main>

  <!-- REJECT MODAL -->
  <div class="modal fade" id="rejectPayoutModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content gf-border-2" style="border-radius:16px;border:3px solid #000;">
        <div class="modal-header gf-border-2" style="background:var(--gf-pink);border-bottom:3px solid #000;">
          <h5 class="modal-title fw-black"><i data-lucide="x-circle" width="18" height="18"></i> Từ chối Payout</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="rejectPayoutId">
          <div class="mb-3">
            <label class="form-label fw-bold small">Ghi chú từ chối <span class="text-danger">*</span></label>
            <textarea id="rejectPayoutNote" class="form-control gf-input" rows="3" placeholder="Lý do từ chối..."></textarea>
          </div>
        </div>
        <div class="modal-footer border-top border-2 border-dark">
          <button type="button" class="btn gf-border gf-shadow-sm gf-press fw-bold" data-bs-dismiss="modal" style="border-radius:10px;">Hủy</button>
          <button type="button" class="btn gf-border gf-shadow-sm gf-press fw-bold text-white" id="confirmRejectPayout" style="background:var(--gf-pink);border-radius:10px;">
            <i data-lucide="x" width="14" height="14"></i> Xác nhận từ chối
          </button>
        </div>
      </div>
    </div>
  </div>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge Admin &mdash; Neo-Brutalism Dashboard
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
