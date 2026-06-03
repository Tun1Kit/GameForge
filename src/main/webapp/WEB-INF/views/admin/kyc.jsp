<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Quản lý KYC</title>

  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

  <style>
    html, body {
      min-height: 100vh;
      overflow-x: hidden;
      overflow-y: auto;
      background: #fffdf7;
      color: #18181b;
    }

    .gf-page-main {
      padding-bottom: 80px;
    }

    .gf-card-safe {
      background: #fff;
      border: 3px solid #000;
      border-radius: 18px;
      box-shadow: 8px 8px 0 #000;
    }

    .gf-stat-card {
      min-height: 110px;
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 22px;
    }

    .gf-stat-icon {
      width: 48px;
      height: 48px;
      border: 3px solid #000;
      border-radius: 10px;
      display: grid;
      place-items: center;
      flex-shrink: 0;
    }

    .gf-table-wrap {
      width: 100%;
      overflow-x: auto;
      display: block;
    }

    .gf-kyc-table {
      width: 100%;
      min-width: 1000px;
      margin-bottom: 0;
      color: #18181b;
    }

    .gf-kyc-table th {
      background: #18181b;
      color: #fff;
      font-weight: 800;
      padding: 14px;
      white-space: nowrap;
    }

    .gf-kyc-table td {
      padding: 14px;
      vertical-align: middle;
      color: #18181b;
    }

    .gf-btn-neo {
      border: 3px solid #000 !important;
      border-radius: 10px !important;
      box-shadow: 3px 3px 0 #000 !important;
      font-weight: 800 !important;
    }

    .gf-filter-btn {
      border: 3px solid #000;
      border-radius: 999px;
      box-shadow: 3px 3px 0 #000;
      font-weight: 800;
      padding: 8px 18px;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      color: #18181b;
      background: #fff;
    }

    .gf-filter-btn.active {
      background: #FFE14D;
      color: #18181b;
    }

    .gf-status-badge {
      border: 2px solid #000;
      border-radius: 999px;
      padding: 5px 12px;
      font-weight: 800;
      font-size: 12px;
      color: #18181b;
      display: inline-block;
    }

    .gf-navbar {
      background: #18181b;
      border-bottom: 3px solid #000;
    }
  </style>
</head>

<body>

  <!-- ADMIN NAVBAR -->
  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3 flex-wrap">

        <a href="${pageContext.request.contextPath}/"
           class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div style="width:44px;height:44px;background:#31d176;border:3px solid #000;border-radius:12px;box-shadow:4px 4px 0 #000;display:grid;place-items:center;">
            <i data-lucide="shield-check" width="22" height="22"></i>
          </div>
          <span class="fs-5 fw-bold text-white">
            GAME<span style="color:#31d176;">FORGE</span>
            <span class="badge bg-danger ms-1" style="font-size:10px;border-radius:999px;">ADMIN</span>
          </span>
        </a>

        <div class="d-flex align-items-center gap-2 flex-wrap">
          <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn gf-btn-neo bg-white text-dark">
            Dashboard
          </a>

          <a href="${pageContext.request.contextPath}/admin/users" class="btn gf-btn-neo bg-white text-dark">
            Người dùng
          </a>

          <a href="${pageContext.request.contextPath}/admin/kyc" class="btn gf-btn-neo text-white" style="background:#31d176;">
            KYC
          </a>

          <a href="${pageContext.request.contextPath}/admin/payouts" class="btn gf-btn-neo bg-white text-dark">
            Payout
          </a>

          <a href="${pageContext.request.contextPath}/admin/settings" class="btn gf-btn-neo bg-white text-dark">
            Settings
          </a>

          <a href="${pageContext.request.contextPath}/logout" class="btn gf-btn-neo text-white" style="background:#18181b;">
            Đăng xuất
          </a>
        </div>

      </div>
    </div>
  </nav>

  <main class="container-xl py-5 gf-page-main">

    <!-- TITLE -->
    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 rounded-pill px-4 py-2 fw-bold text-black mb-3"
           style="background:#FFE14D;border:3px solid #000;box-shadow:4px 4px 0 #000;">
        <i data-lucide="shield-check" width="16" height="16"></i>
        Xác minh KYC
      </div>

      <h1 class="fw-bold mb-2" style="font-size:clamp(2rem,5vw,3.2rem);line-height:1.1;">
        Duyệt Yêu cầu <span style="color:#31d176;text-shadow:2px 2px 0 #000;">KYC</span>
      </h1>

      <p class="fs-5 fw-semibold text-secondary" style="max-width:560px;">
        Xác minh danh tính nhà phát hành trước khi cấp quyền đăng game.
      </p>
    </div>

    <!-- MESSAGE -->
    <c:if test="${param.success == 'approved'}">
      <div class="alert alert-success fw-bold border border-3 border-dark">
        Đã duyệt yêu cầu KYC thành công.
      </div>
    </c:if>

    <c:if test="${param.success == 'rejected'}">
      <div class="alert alert-warning fw-bold border border-3 border-dark">
        Đã từ chối yêu cầu KYC.
      </div>
    </c:if>

    <c:if test="${not empty param.error}">
      <div class="alert alert-danger fw-bold border border-3 border-dark">
        Có lỗi khi xử lý yêu cầu KYC.
      </div>
    </c:if>

    <!-- STATS -->
    <div class="row g-4 mb-4">

      <div class="col-md-4">
        <div class="gf-card-safe gf-stat-card">
          <div class="gf-stat-icon" style="background:#FFE14D;">
            <i data-lucide="clock" width="22" height="22"></i>
          </div>
          <div>
            <div class="fs-2 fw-bold text-dark">${stats.pending}</div>
            <div class="fw-bold text-secondary">Chờ duyệt</div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="gf-card-safe gf-stat-card">
          <div class="gf-stat-icon" style="background:#94FFB4;">
            <i data-lucide="check-circle" width="22" height="22"></i>
          </div>
          <div>
            <div class="fs-2 fw-bold text-dark">${stats.approved}</div>
            <div class="fw-bold text-secondary">Đã duyệt</div>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="gf-card-safe gf-stat-card">
          <div class="gf-stat-icon" style="background:#FFB4A8;">
            <i data-lucide="x-circle" width="22" height="22"></i>
          </div>
          <div>
            <div class="fs-2 fw-bold text-dark">${stats.rejected}</div>
            <div class="fw-bold text-secondary">Từ chối</div>
          </div>
        </div>
      </div>

    </div>

    <!-- FILTER -->
    <div class="gf-card-safe p-4 mb-4">
      <div class="d-flex flex-wrap gap-3">

        <a href="${pageContext.request.contextPath}/admin/kyc"
           class="gf-filter-btn ${empty param.status ? 'active' : ''}">
          <i data-lucide="list" width="15" height="15"></i>
          Tất cả
        </a>

        <a href="${pageContext.request.contextPath}/admin/kyc?status=PENDING"
           class="gf-filter-btn ${param.status == 'PENDING' ? 'active' : ''}">
          <i data-lucide="clock" width="15" height="15"></i>
          Chờ duyệt (${stats.pending})
        </a>

        <a href="${pageContext.request.contextPath}/admin/kyc?status=APPROVED"
           class="gf-filter-btn ${param.status == 'APPROVED' ? 'active' : ''}">
          <i data-lucide="check-circle" width="15" height="15"></i>
          Đã duyệt (${stats.approved})
        </a>

        <a href="${pageContext.request.contextPath}/admin/kyc?status=REJECTED"
           class="gf-filter-btn ${param.status == 'REJECTED' ? 'active' : ''}">
          <i data-lucide="x-circle" width="15" height="15"></i>
          Từ chối (${stats.rejected})
        </a>

      </div>
    </div>

    <!-- LIST -->
    <div class="gf-card-safe overflow-hidden">

      <div class="p-3 fw-bold d-flex align-items-center gap-2"
           style="background:#c8b6ff;border-bottom:3px solid #000;">
        <i data-lucide="id-card" width="18" height="18"></i>
        Yêu cầu KYC

        <span class="badge bg-dark text-white ms-auto" style="border-radius:999px;">
          ${pageResult.totalElements}
        </span>
      </div>

      <div class="gf-table-wrap">
        <table class="table table-hover gf-kyc-table">

          <thead>
            <tr>
              <th>#</th>
              <th>Người dùng</th>
              <th>Email</th>
              <th>Số giấy tờ</th>
              <th>Trạng thái</th>
              <th>Ngày nộp</th>
              <th>Ảnh</th>
              <th>Thao tác</th>
            </tr>
          </thead>

          <tbody>
            <c:choose>

              <c:when test="${not empty pageResult.content}">
                <c:forEach var="kyc" items="${pageResult.content}">
                  <tr>
                    <td class="fw-bold">#${kyc.id}</td>

                    <td>
                      <div class="fw-bold">
                        <c:choose>
                          <c:when test="${not empty kyc.user.fullName}">
                            ${fn:escapeXml(kyc.user.fullName)}
                          </c:when>
                          <c:when test="${not empty kyc.user.username}">
                            ${fn:escapeXml(kyc.user.username)}
                          </c:when>
                          <c:otherwise>
                            User #${kyc.user.id}
                          </c:otherwise>
                        </c:choose>
                      </div>

                      <div class="small text-secondary">
                        @${fn:escapeXml(kyc.user.username)}
                      </div>
                    </td>

                    <td>
                      ${fn:escapeXml(kyc.user.email)}
                    </td>

                    <td>
                      <span class="gf-status-badge" style="background:#bde0fe;">
                        ${fn:escapeXml(kyc.taxId)}
                      </span>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${kyc.status == 'APPROVED'}">
                          <span class="gf-status-badge" style="background:#94FFB4;">APPROVED</span>
                        </c:when>
                        <c:when test="${kyc.status == 'REJECTED'}">
                          <span class="gf-status-badge" style="background:#FFB4A8;">REJECTED</span>
                        </c:when>
                        <c:otherwise>
                          <span class="gf-status-badge" style="background:#FFE14D;">PENDING</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${not empty kyc.submittedAt}">
                          ${kyc.submittedAt}
                        </c:when>
                        <c:otherwise>
                          Không rõ
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${not empty kyc.documentUrl}">
                          <a href="${pageContext.request.contextPath}${kyc.documentUrl}"
                             target="_blank"
                             class="btn btn-sm gf-btn-neo"
                             style="background:#c8b6ff;">
                            Xem ảnh
                          </a>
                        </c:when>
                        <c:otherwise>
                          <span class="text-secondary">Không có</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${kyc.status == 'PENDING'}">
                          <div class="d-flex gap-2 flex-wrap">

                            <form action="${pageContext.request.contextPath}/admin/kyc/approve"
                                  method="post"
                                  onsubmit="return confirm('Duyệt yêu cầu KYC này?');">
                              <input type="hidden" name="_csrf" value="${_csrf.token}" />
                              <input type="hidden" name="requestId" value="${kyc.id}" />

                              <button type="submit"
                                      class="btn btn-sm gf-btn-neo"
                                      style="background:#94FFB4;">
                                Duyệt
                              </button>
                            </form>

                            <form action="${pageContext.request.contextPath}/admin/kyc/reject"
                                  method="post"
                                  onsubmit="return confirm('Từ chối yêu cầu KYC này?');">
                              <input type="hidden" name="_csrf" value="${_csrf.token}" />
                              <input type="hidden" name="requestId" value="${kyc.id}" />

                              <button type="submit"
                                      class="btn btn-sm gf-btn-neo"
                                      style="background:#FFB4A8;">
                                Từ chối
                              </button>
                            </form>

                          </div>
                        </c:when>

                        <c:otherwise>
                          <span class="text-secondary fw-bold">Đã xử lý</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>

              <c:otherwise>
                <tr>
                  <td colspan="8" class="text-center py-5">
                    <div class="fw-bold fs-5 mb-2">Không có yêu cầu KYC</div>
                    <div class="text-secondary">
                      Tất cả yêu cầu đã được xử lý hoặc chưa có ai nộp.
                    </div>
                  </td>
                </tr>
              </c:otherwise>

            </c:choose>
          </tbody>

        </table>
      </div>

      <!-- PAGINATION -->
      <c:if test="${pageResult.totalPages > 1}">
        <div class="p-3 border-top border-3 border-dark d-flex justify-content-end">
          <nav>
            <ul class="pagination pagination-sm mb-0">

              <c:if test="${pageResult.currentPage > 1}">
                <li class="page-item">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/kyc?page=${pageResult.currentPage - 1}&status=${fn:escapeXml(param.status)}">
                    &laquo;
                  </a>
                </li>
              </c:if>

              <c:forEach var="i" begin="1" end="${pageResult.totalPages}">
                <li class="page-item ${i == pageResult.currentPage ? 'active' : ''}">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/kyc?page=${i}&status=${fn:escapeXml(param.status)}">
                    ${i}
                  </a>
                </li>
              </c:forEach>

              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/kyc?page=${pageResult.currentPage + 1}&status=${fn:escapeXml(param.status)}">
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