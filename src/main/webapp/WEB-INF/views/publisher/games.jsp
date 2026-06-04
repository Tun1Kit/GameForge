<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge Publisher - Quản Lý Game</title>
  
  <!-- CSRF Meta Tags (Spring Security) -->
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

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
    .table-container {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 6px 6px 0 0 #000;
      border-radius: 16px;
      overflow: hidden;
    }
    .table thead th {
      background: var(--gf-yellow) !important;
      color: #000;
      border-bottom: 3px solid #000 !important;
      font-weight: 900;
      text-transform: uppercase;
      font-size: 14px;
    }
    .table td, .table th {
      padding: 16px;
      vertical-align: middle;
      border-bottom: 2px solid #000;
    }
    .game-thumb {
      width: 80px;
      height: 45px;
      object-fit: cover;
      border: 2px solid #000;
      border-radius: 4px;
      box-shadow: 2px 2px 0 0 #000;
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

  <!-- MAIN CONTENT -->
  <main class="container-xl py-5">
    <div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-5">
      <div>
        <h1 class="fw-black fw-bold mb-1">Quản lý sản phẩm</h1>
        <p class="fw-semibold text-secondary gf-muted mb-0">Xem danh sách, chỉnh sửa thông tin game, đăng tải trailer/ảnh screenshot và viết patch notes cập nhật.</p>
      </div>
      <a href="${pageContext.request.contextPath}/publisher/games/add" class="btn gf-border gf-shadow gf-press fw-bold py-2.5 px-4 rounded-3 d-flex align-items-center gap-2" style="background: var(--gf-green); color: #000;">
        <i data-lucide="plus" width="18" height="18"></i> Đăng game mới
      </a>
    </div>

    <!-- Alert Success/Error -->
    <c:if test="${not empty param.success}">
      <div class="alert alert-success d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:#94FFB4; color:#000;">
        <i data-lucide="check-circle" width="20" height="20"></i>
        <c:choose>
          <c:when test="${param.success == 'added'}">Đã thêm game mới thành công và đang chờ quản trị viên phê duyệt!</c:when>
          <c:when test="${param.success == 'edited'}">Cập nhật thông tin game thành công!</c:when>
          <c:when test="${param.success == 'deleted'}">Đã gỡ game khỏi danh sách hiển thị cửa hàng!</c:when>
        </c:choose>
      </div>
    </c:if>
    <c:if test="${not empty param.error}">
      <div class="alert alert-danger d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:var(--gf-pink); color:#000;">
        <i data-lucide="alert-triangle" width="20" height="20"></i>
        <span>${param.error == 'not-authorized' ? 'Bạn không có quyền thực hiện thao tác này!' : 'Đã xảy ra lỗi. Vui lòng thử lại.'}</span>
      </div>
    </c:if>

    <!-- TABLE GAMES -->
    <div class="table-container">
      <div class="table-responsive">
        <table class="table table-hover mb-0">
          <thead>
            <tr>
              <th scope="col" style="width: 120px;">Ảnh bìa</th>
              <th scope="col">Tựa game</th>
              <th scope="col">Thể loại</th>
              <th scope="col" style="width: 140px;">Giá bán</th>
              <th scope="col" style="width: 160px;">Trạng thái</th>
              <th scope="col" style="width: 180px;">Ngày phát hành</th>
              <th scope="col" class="text-center" style="width: 320px;">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="g" items="${games}">
              <tr>
                <td>
                  <c:choose>
                    <c:when test="${not empty g.mediaList}">
                      <!-- Tìm ảnh primary -->
                      <c:set var="coverUrl" value="" />
                      <c:forEach var="m" items="${g.mediaList}">
                        <c:if test="${m.primary}">
                          <c:set var="coverUrl" value="${m.mediaUrl}" />
                        </c:if>
                      </c:forEach>
                      <c:if test="${empty coverUrl}">
                        <c:set var="coverUrl" value="${not fn:startsWith(g.mediaList[0].mediaUrl, 'http') ? g.mediaList[0].mediaUrl : ''}" />
                      </c:if>
                      <c:choose>
                        <c:when test="${not empty coverUrl}">
                          <img src="${pageContext.request.contextPath}${coverUrl}" alt="${fn:escapeXml(g.title)}" class="game-thumb">
                        </c:when>
                        <c:otherwise>
                          <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black game-thumb bg-light" style="font-size: 10px; line-height: 1.2;">
                            Chưa có hình ảnh
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    <c:otherwise>
                      <img src="" alt="Chưa có hình ảnh" alt="Cover" class="game-thumb">
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <h6 class="fw-bold mb-0">${g.title}</h6>
                  <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Slug: ${g.slug}</span>
                </td>
                <td>
                  <c:forEach var="c" items="${g.categories}" varStatus="cs">
                    <span class="badge border border-2 border-black bg-white text-dark small fw-bold px-2 py-1" style="font-size: 11px; border-radius: 6px;">${c.name}</span>
                    <c:if test="${!cs.last}"> </c:if>
                  </c:forEach>
                </td>
                <td class="fw-bold">
                  <c:choose>
                    <c:when test="${g.price == 0}">
                      <span class="text-success">Miễn phí</span>
                    </c:when>
                    <c:otherwise>
                      <fmt:formatNumber value="${g.price}" type="number" maxFractionDigits="0" />đ
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${g.status == 'ACTIVE'}">
                      <span class="badge border border-2 border-black text-dark px-3 py-1.5 fw-bold" style="background:#94FFB4; border-radius:999px; font-size:11px;">Đang kinh doanh</span>
                    </c:when>
                    <c:when test="${g.status == 'PENDING'}">
                      <span class="badge border border-2 border-black text-dark px-3 py-1.5 fw-bold" style="background:var(--gf-yellow); border-radius:999px; font-size:11px;">Chờ Admin duyệt</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge border border-2 border-black text-dark px-3 py-1.5 fw-bold bg-light text-secondary" style="border-radius:999px; font-size:11px;">Tạm ngưng</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <span class="small text-secondary gf-muted">
                    <fmt:parseDate value="${g.releaseDate}" pattern="yyyy-MM-dd" var="parsedRelDate" type="date" />
                    <fmt:formatDate value="${parsedRelDate}" pattern="dd/MM/yyyy" />
                  </span>
                </td>
                <td>
                  <div class="d-flex justify-content-center gap-2">
                    <a href="${pageContext.request.contextPath}/publisher/games/edit/${g.id}" class="btn btn-sm gf-border gf-shadow-sm gf-press bg-white fw-bold py-1.5 px-3" style="border-radius: 8px; font-size: 12px;" title="Chỉnh sửa thông tin">
                      <i data-lucide="edit-3" width="14" height="14" class="me-1"></i> Sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/publisher/games/patch-notes/${g.id}" class="btn btn-sm gf-border gf-shadow-sm gf-press fw-bold py-1.5 px-3" style="background: var(--gf-lavender); border-radius: 8px; font-size: 12px; color: #000;" title="Quản lý patch notes">
                      <i data-lucide="scroll" width="14" height="14" class="me-1"></i> Patch Notes
                    </a>
                    
                    <c:if test="${g.status != 'INACTIVE'}">
                      <form action="${pageContext.request.contextPath}/publisher/games/delete/${g.id}" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn ngừng kinh doanh game này không? (Game sẽ bị ẩn khỏi storefront)')" class="d-inline">
                        <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-white fw-bold py-1.5 px-3" style="background: var(--gf-pink); border-radius: 8px; font-size: 12px;">
                          <i data-lucide="trash-2" width="14" height="14" class="me-1"></i> Gỡ game
                        </button>
                      </form>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>

            <c:if test="${empty games}">
              <tr>
                <td colspan="7" class="text-center py-5">
                  <div class="py-4">
                    <div class="mx-auto mb-3 gf-border rounded-4 gf-shadow-sm d-grid place-items-center" style="width:64px;height:64px;background:var(--gf-pink);color:#000;">
                      <i data-lucide="library" width="32" height="32"></i>
                    </div>
                    <h5 class="fw-black fw-bold mb-1">Chưa có sản phẩm nào</h5>
                    <p class="small text-secondary gf-muted mb-4">Bạn chưa đăng tải tựa game nào lên GameForge.</p>
                    <a href="${pageContext.request.contextPath}/publisher/games/add" class="btn gf-border gf-shadow gf-press fw-bold py-2 px-4" style="background: var(--gf-green); color:#000;">
                      Đăng game ngay
                    </a>
                  </div>
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </main>

  <script>
    lucide.createIcons();
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
