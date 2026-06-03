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
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

  <style>
    html, body {
      min-height: 100vh;
      overflow-x: hidden;
      overflow-y: auto;
    }

    .gf-payout-table-wrapper {
      width: 100%;
      overflow-x: auto;
      display: block !important;
      visibility: visible !important;
      opacity: 1 !important;
    }

    .gf-payout-table {
      width: 100%;
      min-width: 1050px;
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
  </style>
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;overflow-y:auto;">
  <div class="gf-decor-pill" style="top:12%;left:2%;background:var(--gf-yellow);transform:rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top:58%;right:3%;background:var(--gf-lavender);transform:rotate(-18deg);width:26px;height:26px;"></div>

  <nav class="gf-navbar" style="background:#18181b;border-bottom:3px solid #000;">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">

        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="shield-check" width="20" height="20"></i>
          </div>

          <span class="fs-5 fw-black fw-bold text-white">
            GAME<span style="color:var(--gf-green)">FORGE</span>
            <span class="badge bg-danger ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;">ADMIN</span>
          </span>
        </a>

        <div class="d-flex align-items-center gap-2 flex-wrap">
          <a href="${pageContext.request.contextPath}/admin/dashboard"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 py-2 px-3">
            Dashboard
          </a>

          <a href="${pageContext.request.contextPath}/admin/users"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 py-2 px-3">
            Người dùng
          </a>

          <a href="${pageContext.request.contextPath}/admin/kyc"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 py-2 px-3">
            KYC
          </a>

          <a href="${pageContext.request.contextPath}/admin/payouts"
             class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 py-2 px-3"
             style="background:var(--gf-green);border-color:#000;">
            Payout
          </a>

          <a href="${pageContext.request.contextPath}/admin/settings"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 py-2 px-3">
            Settings
          </a>

          <a href="${pageContext.request.contextPath}/logout"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press text-white fw-bold rounded-3 py-2 px-3"
             style="background:#18181b;">
            Đăng xuất
          </a>
        </div>

      </div>
    </div>
  </nav>

  <main class="container-xl py-5">

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
        Duyệt các yêu cầu rút tiền từ nhà phát hành.
      </p>
    </div>

    <c:if test="${param.success == 'approved'}">
      <div class="alert alert-success fw-bold border border-3 border-dark">
        Đã duyệt payout thành công.
      </div>
    </c:if>

    <c:if test="${param.success == 'rejected'}">
      <div class="alert alert-warning fw-bold border border-3 border-dark">
        Đã từ chối payout.
      </div>
    </c:if>

    <c:if test="${not empty param.error}">
      <div class="alert alert-danger fw-bold border border-3 border-dark">
        Có lỗi khi xử lý payout.
      </div>
    </c:if>

    <div class="row g-3 mb-4">

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:48px;height:48px;background:var(--gf-yellow);">
              <i data-lucide="clock" width="20" height="20"></i>
            </div>

            <div>
              <div class="fs-3 fw-black">${stats.pending}</div>
              <div class="fw-bold text-secondary">Chờ duyệt</div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:48px;height:48px;background:#94FFB4;">
              <i data-lucide="check-circle" width="20" height="20"></i>
            </div>

            <div>
              <div class="fs-3 fw-black">${stats.approved}</div>
              <div class="fw-bold text-secondary">Đã duyệt</div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="bg-white gf-border rounded-4 gf-shadow p-3">
          <div class="d-flex align-items-center gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center"
                 style="width:48px;height:48px;background:var(--gf-lavender);">
              <i data-lucide="banknote" width="20" height="20"></i>
            </div>

            <div>
              <div class="fs-3 fw-black">${stats.total}</div>
              <div class="fw-bold text-secondary">Tổng yêu cầu</div>
            </div>
          </div>
        </div>
      </div>

    </div>

    <div class="bg-white gf-border rounded-4 gf-shadow p-4 mb-4">
      <div class="d-flex flex-wrap gap-2">

        <a href="${pageContext.request.contextPath}/admin/payouts"
           class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${empty param.status ? 'text-white' : 'bg-light text-dark'}"
           style="${empty param.status ? 'background:var(--gf-lavender);color:#000!important;' : ''}border-radius:999px;padding:6px 18px;">
          Tất cả
        </a>

        <a href="${pageContext.request.contextPath}/admin/payouts?status=PENDING"
           class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'PENDING' ? 'text-white' : 'bg-light text-dark'}"
           style="${param.status == 'PENDING' ? 'background:var(--gf-yellow);color:#000!important;' : ''}border-radius:999px;padding:6px 18px;">
          Chờ duyệt (${stats.pending})
        </a>

        <a href="${pageContext.request.contextPath}/admin/payouts?status=PAID"
           class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'PAID' ? 'text-white' : 'bg-light text-dark'}"
           style="${param.status == 'PAID' ? 'background:#94FFB4;color:#000!important;' : ''}border-radius:999px;padding:6px 18px;">
          Đã duyệt (${stats.approved})
        </a>

        <a href="${pageContext.request.contextPath}/admin/payouts?status=REJECTED"
           class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-pill ${param.status == 'REJECTED' ? 'text-white' : 'bg-light text-dark'}"
           style="${param.status == 'REJECTED' ? 'background:var(--gf-pink);color:#000!important;' : ''}border-radius:999px;padding:6px 18px;">
          Từ chối (${stats.rejected})
        </a>

      </div>
    </div>

    <c:set var="payoutList" value="${not empty pageResult.content ? pageResult.content : requests}" />

    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb:set var="payoutList" value="${not empty pageResult.content ? pageResult.content : requests}" />

    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-5"
         style="display:block!important;visibility:visible!important;opacity:1!important;min-height:260px!important;">

      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-green);border-bottom:3px solid #000;color:#000;">
        <i data-lucide="banknote" width="18" height="18"></i>
        Danh sách Payout

        <span class="badge bg-black text-white ms-auto border border-2 border-white"
              style="border-radius:999px;min-width:28px;height:28px;display:grid;place-items:center;padding:0 8px;font-size:12px;">
          ${pageResult.totalElements}
        </span>
      </div>

      <div class="gf-payout-table-wrapper">
        <table class="table table-hover gf-payout-table">

          <thead>
            <tr>
              <th>#</th>
              <th>Nhà phát hành</th>
              <th>Số tiền</th>
              <th>Ngân hàng</th>
              <th>Trạng thái</th>
              <th>Ngày yêu cầu</th>
              <th>Xử lý lúc</th>
              <th class="text-center">Hành động</th>
            </tr>
          </thead>

          <tbody>
            <c:choose>

              <c:when test="${not empty payoutList}">
                <c:forEach var="payout" items="${payoutList}">
                  <tr>
                    <td class="fw-bold text-secondary">
                      #GF-PAY-${payout.id}
                    </td>

                    <td>
                      <div class="fw-bold">
                        <c:choose>
                          <c:when test="${not empty payout.publisher and not empty payout.publisher.companyName}">
                            ${fn:escapeXml(payout.publisher.companyName)}
                          </c:when>
                          <c:when test="${not empty payout.publisher and not empty payout.publisher.user and not empty payout.publisher.user.fullName}">
                            ${fn:escapeXml(payout.publisher.user.fullName)}
                          </c:when>
                          <c:otherwise>
                            Publisher #${payout.id}
                          </c:otherwise>
                        </c:choose>
                      </div>

                      <div class="small text-secondary">
                        <c:choose>
                          <c:when test="${not empty payout.publisher and not empty payout.publisher.user and not empty payout.publisher.user.email}">
                            ${fn:escapeXml(payout.publisher.user.email)}
                          </c:when>
                          <c:otherwise>
                            —
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </td>

                    <td class="fw-black">
                      <fmt:formatNumber value="${payout.amount}" type="number" maxFractionDigits="0"/>đ
                    </td>

                    <td class="small text-secondary" style="max-width:240px;">
                      <c:choose>
                        <c:when test="${not empty payout.bankAccountInfo}">
                          <span class="text-truncate d-block" title="${fn:escapeXml(payout.bankAccountInfo)}">
                            ${fn:escapeXml(payout.bankAccountInfo)}
                          </span>
                        </c:when>
                        <c:otherwise>
                          —
                        </c:otherwise>
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
                        <c:otherwise>
                          Không rõ
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td class="small text-secondary">
                      <c:choose>
                        <c:when test="${not empty payout.processedAt}">
                          ${fn:replace(payout.processedAt, 'T', ' ')}
                        </c:when>
                        <c:otherwise>
                          —
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td class="text-center">
                      <c:choose>
                        <c:when test="${payout.status == 'PENDING'}">
                          <div class="d-flex justify-content-center gap-2 flex-wrap">

                            <form action="${pageContext.request.contextPath}/admin/payouts/approve"
                                  method="post"
                                  onsubmit="return confirm('Duyệt yêu cầu payout #${payout.id}?');">

                              <input type="hidden" name="_csrf" value="${_csrf.token}" />
                              <input type="hidden" name="requestId" value="${payout.id}" />

                              <button type="submit"
                                      class="btn btn-sm gf-btn-neo"
                                      style="background:#94FFB4;">
                                Duyệt
                              </button>
                            </form>

                            <form action="${pageContext.request.contextPath}/admin/payouts/reject"
                                  method="post"
                                  onsubmit="return confirm('Từ chối yêu cầu payout #${payout.id}?');">

                              <input type="hidden" name="_csrf" value="${_csrf.token}" />
                              <input type="hidden" name="requestId" value="${payout.id}" />

                              <button type="submit"
                                      class="btn btn-sm gf-btn-neo"
                                      style="background:var(--gf-pink);">
                                Từ chối
                              </button>
                            </form>

                          </div>
                        </c:when>

                        <c:otherwise>
                          <span class="small fw-bold text-secondary">Đã xử lý</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                  </tr>
                </c:forEach>
              </c:when>

              <c:otherwise>
                <tr>
                  <td colspan="8" class="text-center py-5">
                    <h5 class="fw-bold">Không có yêu cầu payout</h5>
                    <p class="small text-secondary">
                      Chưa có ai yêu cầu rút tiền.
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
                     href="${pageContext.request.contextPath}/admin/payouts?page=${pageResult.currentPage - 1}&status=${fn:escapeXml(param.status)}">
                    &laquo;
                  </a>
                </li>
              </c:if>

              <c:forEach var="i" begin="1" end="${pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link ${i == pageResult.currentPage ? 'active' : ''}"
                     href="${pageContext.request.contextPath}/admin/payouts?page=${i}&status=${fn:escapeXml(param.status)}">
                    ${i}
                  </a>
                </li>
              </c:forEach>

              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link"
                     href="${pageContext.request.contextPath}/admin/payouts?page=${pageResult.currentPage + 1}&status=${fn:escapeXml(param.status)}">
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
      © 2026 GameForge Admin &mdash; Neo-Brutalism Dashboard
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