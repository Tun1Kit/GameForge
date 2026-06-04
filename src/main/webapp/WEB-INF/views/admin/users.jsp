<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Quản lý người dùng</title>

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
  <div class="gf-decor-pill" style="top:10%;left:2%;background:var(--gf-yellow);transform:rotate(12deg);"></div>
  <div class="gf-decor-pill" style="top:55%;right:3%;background:var(--gf-lavender);transform:rotate(-18deg);width:26px;height:26px;"></div>

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
          <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
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
    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3"
           style="background:var(--gf-blue);box-shadow:3px 3px 0 #000;">
        <i data-lucide="users" width="16" height="16"></i> Quản lý người dùng
      </div>

      <h1 class="fw-black fw-bold mb-2"
          style="font-size:clamp(1.8rem,4vw,2.8rem);line-height:1.1;letter-spacing:-0.03em;">
        Người dùng <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Hệ thống</span>
      </h1>
    </div>

    <c:if test="${param.success == 'locked'}">
      <div class="alert alert-warning fw-bold gf-border-2">
        Đã khóa tài khoản thành công.
      </div>
    </c:if>

    <c:if test="${param.success == 'unlocked'}">
      <div class="alert alert-success fw-bold gf-border-2">
        Đã mở khóa tài khoản thành công.
      </div>
    </c:if>

    <c:if test="${param.error == 'self-lock'}">
      <div class="alert alert-danger fw-bold gf-border-2">
        Không thể khóa chính tài khoản Admin đang đăng nhập.
      </div>
    </c:if>

    <!-- FILTER / SEARCH BAR -->
    <div class="bg-white gf-border rounded-4 gf-shadow-sm p-4 mb-4">
      <form method="get" action="${pageContext.request.contextPath}/admin/users" class="row g-3 align-items-end">

        <div class="col-md-4">
          <label class="form-label fw-bold small text-secondary">Tìm kiếm</label>
          <div class="position-relative">
            <i data-lucide="search" width="16" height="16" class="position-absolute" style="top:50%;left:12px;transform:translateY(-50%);color:var(--gf-muted);"></i>
            <input type="text" name="search" value="${fn:escapeXml(param.search)}" class="form-control gf-input ps-5" placeholder="Tên, email hoặc username..." maxlength="100">
          </div>
        </div>

        <div class="col-md-2">
          <label class="form-label fw-bold small text-secondary">Trạng thái</label>
          <select name="status" class="form-select gf-input">
            <option value="">Tất cả</option>
            <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
            <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
            <option value="LOCKED" ${param.status == 'LOCKED' ? 'selected' : ''}>Locked</option>
          </select>
        </div>

        <div class="col-md-2">
          <label class="form-label fw-bold small text-secondary">Vai trò</label>
          <select name="role" class="form-select gf-input">
            <option value="">Tất cả</option>
            <option value="ROLE_ADMIN" ${param.role == 'ROLE_ADMIN' ? 'selected' : ''}>Admin</option>
            <option value="ROLE_PUBLISHER" ${param.role == 'ROLE_PUBLISHER' ? 'selected' : ''}>Publisher</option>
            <option value="ROLE_USER" ${param.role == 'ROLE_USER' ? 'selected' : ''}>User</option>
          </select>
        </div>

        <div class="col-md-2">
          <label class="form-label fw-bold small text-secondary">&nbsp;</label>
          <button type="submit"
                  class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold d-flex align-items-center justify-content-center gap-2"
                  style="background:var(--gf-green);border-radius:10px;">
            <i data-lucide="filter" width="16" height="16"></i> Lọc
          </button>
        </div>

        <div class="col-md-2">
          <label class="form-label fw-bold small text-secondary">&nbsp;</label>
          <a href="${pageContext.request.contextPath}/admin/users"
             class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold d-flex align-items-center justify-content-center gap-2 bg-light"
             style="border-radius:10px;">
            <i data-lucide="x" width="16" height="16"></i> Reset
          </a>
        </div>

      </form>
    </div>

    <!-- USER TABLE -->
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden">
      <div class="p-3 fw-black d-flex align-items-center gap-2"
           style="background:var(--gf-yellow);border-bottom:3px solid #000;">
        <i data-lucide="list" width="18" height="18"></i> Danh sách người dùng

        <span class="badge bg-black text-white ms-auto border border-2 border-white"
              style="border-radius:50%;width:26px;height:26px;display:grid;place-items:center;padding:0;font-size:11px;">
          ${pageResult.totalElements}
        </span>
      </div>

      <div class="table-responsive">
        <table class="table table-hover mb-0 gf-admin-table">
          <thead>
            <tr>
              <th class="fw-black px-4 py-3">#</th>
              <th class="fw-black py-3">Người dùng</th>
              <th class="fw-black py-3">Email</th>
              <th class="fw-black py-3">Vai trò</th>
              <th class="fw-black py-3">Trạng thái</th>
              <th class="fw-black py-3">Ngày tạo</th>
              <th class="fw-black py-3 text-center">Hành động</th>
            </tr>
          </thead>

          <tbody>
            <c:choose>

              <c:when test="${not empty pageResult.content}">
                <c:forEach var="user" items="${pageResult.content}">
                  <tr data-user-id="${user.id}">

                    <td class="px-4 py-3 small fw-bold text-secondary">
                      #${user.id}
                    </td>

                    <td class="py-3">
                      <div class="d-flex align-items-center gap-3">
                        <img src="${not empty user.avatar ? user.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed='.concat(user.username)}"
                             alt="${fn:escapeXml(user.fullName)}"
                             class="gf-border-2 rounded-circle"
                             style="width:38px;height:38px;object-fit:cover;border-color:var(--gf-muted);">

                        <div>
                          <div class="fw-bold">${fn:escapeXml(user.fullName)}</div>
                          <div class="small text-secondary">@${fn:escapeXml(user.username)}</div>
                        </div>
                      </div>
                    </td>

                    <td class="py-3 small">
                      ${fn:escapeXml(user.email)}
                    </td>

                    <td class="py-3">
                      <c:forEach var="role" items="${user.roles}">
                        <span class="badge fw-bold me-1 mb-1"
                              style="background:var(--gf-lavender);border:2px solid #000;border-radius:999px;font-size:10px;padding:3px 8px;">
                          ${fn:escapeXml(role.code)}
                        </span>
                      </c:forEach>
                    </td>

                    <td class="py-3">
                      <span class="badge fw-bold px-3 py-1.5 rounded-pill"
                            style="font-size:11px;border:2px solid #000;
                                   background:${user.status == 'ACTIVE' ? '#94FFB4' : user.status == 'LOCKED' ? 'var(--gf-pink)' : 'var(--gf-blue)'};">
                        ${fn:escapeXml(user.status)}
                      </span>
                    </td>

                    <td class="py-3 small text-secondary">
                      <c:choose>
                        <c:when test="${not empty user.createdAt}">
                          <fmt:parseDate value="${user.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                          <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                        </c:when>
                        <c:otherwise>
                          Không rõ
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <td class="py-3 text-center">
                      <div class="d-flex align-items-center justify-content-center gap-2">

                        <c:choose>
                          <c:when test="${user.status == 'LOCKED'}">
                            <button type="button"
                                    class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 unlock-btn"
                                    data-user-id="${user.id}"
                                    data-username="${fn:escapeXml(user.username)}"
                                    style="background:#94FFB4;border-radius:8px;padding:5px 10px;font-size:12px;">
                              <i data-lucide="unlock" width="13" height="13"></i> Mở khóa
                            </button>
                          </c:when>

                          <c:when test="${user.status == 'ACTIVE'}">
                            <button type="button"
                                    class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 lock-btn"
                                    data-user-id="${user.id}"
                                    data-username="${fn:escapeXml(user.username)}"
                                    style="background:var(--gf-pink);border-radius:8px;padding:5px 10px;font-size:12px;">
                              <i data-lucide="lock" width="13" height="13"></i> Khóa
                            </button>
                          </c:when>
                        </c:choose>

                      </div>
                    </td>

                  </tr>
                </c:forEach>
              </c:when>

              <c:otherwise>
                <tr>
                  <td colspan="7" class="text-center py-5">
                    <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3 place-items-center"
                         style="width:48px;height:48px;background:var(--gf-lavender);">
                      <i data-lucide="users" width="22" height="22"></i>
                    </div>

                    <h5 class="fw-bold">Không tìm thấy người dùng</h5>
                    <p class="small text-secondary gf-muted">
                      Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.
                    </p>
                  </td>
                </tr>
              </c:otherwise>

            </c:choose>
          </tbody>
        </table>
      </div>

      <!-- PAGINATION -->
      <c:if test="${pageResult.totalPages > 1}">
        <div class="p-3 border-top border-2 border-dark d-flex align-items-center justify-content-between flex-wrap gap-2">
          <span class="small fw-bold text-secondary">
            Trang ${pageResult.currentPage} / ${pageResult.totalPages} &mdash; ${pageResult.totalElements} người dùng
          </span>

          <nav>
            <ul class="pagination pagination-sm mb-0 gap-1">

              <c:if test="${pageResult.currentPage > 1}">
                <li class="page-item">
                  <a class="page-link gf-page-link"
                     href="?page=${pageResult.currentPage - 1}&search=${fn:escapeXml(param.search)}&status=${fn:escapeXml(param.status)}&role=${fn:escapeXml(param.role)}">
                    &laquo;
                  </a>
                </li>
              </c:if>

              <c:forEach var="i" begin="1" end="${pageResult.totalPages > 5 ? 5 : pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link ${i == pageResult.currentPage ? 'active' : ''}"
                     href="?page=${i}&search=${fn:escapeXml(param.search)}&status=${fn:escapeXml(param.status)}&role=${fn:escapeXml(param.role)}">
                    ${i}
                  </a>
                </li>
              </c:forEach>

              <c:if test="${pageResult.currentPage < pageResult.totalPages}">
                <li class="page-item">
                  <a class="page-link gf-page-link"
                     href="?page=${pageResult.currentPage + 1}&search=${fn:escapeXml(param.search)}&status=${fn:escapeXml(param.status)}&role=${fn:escapeXml(param.role)}">
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
      © 2026 GameForce Admin Dashboard
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>