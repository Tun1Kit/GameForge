<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge Admin - Quản lý & Duyệt Game</title>
  
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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

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
    
    /* Custom Neo-Brutalism Tabs */
    .nav-tabs {
      border-bottom: 3px solid #000 !important;
    }
    .nav-tabs .nav-link {
      background: #fff;
      border: 3px solid #000 !important;
      border-bottom: none !important;
      margin-bottom: -3px;
      color: #000 !important;
      font-weight: bold;
      border-radius: 8px 8px 0 0 !important;
      padding: 10px 20px;
    }
    .nav-tabs .nav-link:hover {
      border-color: #000 !important;
      background: #f8f9fa;
    }
    .nav-tabs .nav-link.active {
      background: var(--gf-yellow) !important;
      font-weight: 900 !important;
      border-color: #000 !important;
      box-shadow: 2px -2px 0 0 #000;
    }
  </style>
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
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
          <a href="${pageContext.request.contextPath}/admin/games" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
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
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-yellow);box-shadow:3px 3px 0 #000;">
        <i data-lucide="gamepad-2" width="16" height="16"></i> Quản trị sản phẩm & bản vá
      </div>
      <h1 class="fw-black fw-bold mb-2">Quản Lý Game & Phê Duyệt</h1>
      <p class="fs-5 fw-semibold text-secondary gf-muted">Xem xét phê duyệt game mới đăng, yêu cầu gỡ game/hoàn tiền và duyệt các ghi chú bản vá (patch notes) từ Nhà phát hành.</p>
    </div>

    <!-- Alert Status -->
    <c:if test="${not empty param.success}">
      <div class="alert alert-success d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:#94FFB4; color:#000;">
        <i data-lucide="check-circle" width="20" height="20"></i>
        <span>
          <c:choose>
            <c:when test="${param.success == 'approved'}">Phê duyệt phát hành game thành công!</c:when>
            <c:when test="${param.success == 'rejected'}">Đã từ chối đơn đăng ký game!</c:when>
            <c:when test="${param.success == 'deleted-approved'}">Đã duyệt yêu cầu xóa game và hoàn tiền thành công cho người dùng!</c:when>
            <c:when test="${param.success == 'delete-rejected'}">Đã từ chối yêu cầu xóa game, khôi phục lại trạng thái bán!</c:when>
            <c:when test="${param.success == 'pn-approved'}">Phê duyệt patch note thành công!</c:when>
            <c:when test="${param.success == 'pn-rejected'}">Đã từ chối patch note!</c:when>
            <c:otherwise>Thao tác xử lý thành công!</c:otherwise>
          </c:choose>
        </span>
      </div>
    </c:if>

    <!-- TABS MENU -->
    <ul class="nav nav-tabs gap-2 mb-4" id="adminGamesTab" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active gf-press" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending-pane" type="button" role="tab" aria-controls="pending-pane" aria-selected="true">
          <i data-lucide="plus-circle" width="16" height="16" class="me-1"></i> Game mới chờ duyệt (${fn:length(pendingGames)})
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link gf-press" id="delete-tab" data-bs-toggle="tab" data-bs-target="#delete-pane" type="button" role="tab" aria-controls="delete-pane" aria-selected="false">
          <i data-lucide="trash-2" width="16" height="16" class="me-1"></i> Yêu cầu xóa & hoàn tiền (${fn:length(pendingDeleteGames)})
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link gf-press" id="patchnotes-tab" data-bs-toggle="tab" data-bs-target="#patchnotes-pane" type="button" role="tab" aria-controls="patchnotes-pane" aria-selected="false">
          <i data-lucide="scroll" width="16" height="16" class="me-1"></i> Bản vá chờ duyệt (${fn:length(pendingPatchNotes)})
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link gf-press" id="all-tab" data-bs-toggle="tab" data-bs-target="#all-pane" type="button" role="tab" aria-controls="all-pane" aria-selected="false">
          <i data-lucide="database" width="16" height="16" class="me-1"></i> Tất cả game (${fn:length(allGames)})
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link gf-press" id="transactions-tab" data-bs-toggle="tab" data-bs-target="#transactions-pane" type="button" role="tab" aria-controls="transactions-pane" aria-selected="false">
          <i data-lucide="banknote" width="16" height="16" class="me-1"></i> Giao dịch ví (${fn:length(walletTransactions)})
        </button>
      </li>
    </ul>

    <div class="tab-content" id="adminGamesTabContent">
      
      <!-- Tab 1: Game mới chờ duyệt -->
      <div class="tab-pane fade show active" id="pending-pane" role="tabpanel" aria-labelledby="pending-tab">
        <div class="table-container">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 120px;">Ảnh bìa</th>
                  <th scope="col">Tựa game</th>
                  <th scope="col">Nhà phát triển (Publisher)</th>
                  <th scope="col" style="width: 140px;">Giá bán</th>
                  <th scope="col">Thể loại</th>
                  <th scope="col" class="text-center" style="width: 250px;">Quyết định</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="g" items="${pendingGames}">
                  <tr>
                    <td>
                      <c:choose>
                        <c:when test="${not empty g.mediaList && not fn:startsWith(g.mediaList[0].mediaUrl, 'http')}">
                          <img src="${pageContext.request.contextPath}${g.mediaList[0].mediaUrl}" alt="${fn:escapeXml(g.title)}" class="game-thumb">
                        </c:when>
                        <c:otherwise>
                          <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black game-thumb bg-light" style="font-size: 10px; line-height: 1.2;">
                            Chưa có hình ảnh
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <h6 class="fw-bold mb-0">${g.title}</h6>
                      <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Slug: ${g.slug}</span>
                    </td>
                    <td>
                      <span class="fw-bold text-dark">${g.publisher.companyName}</span>
                      <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Email: ${g.publisher.supportEmail}</span>
                    </td>
                    <td class="fw-bold text-primary">
                      <c:choose>
                        <c:when test="${g.price == 0}">Miễn phí</c:when>
                        <c:otherwise>
                          <fmt:formatNumber value="${g.price}" type="number" maxFractionDigits="0" />đ
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:forEach var="c" items="${g.categories}">
                        <span class="badge border border-2 border-black bg-white text-dark small fw-bold px-2 py-1" style="font-size: 11px; border-radius: 6px;">${c.name}</span>
                      </c:forEach>
                    </td>
                    <td>
                      <div class="d-flex justify-content-center gap-2">
                        <form action="${pageContext.request.contextPath}/admin/games/approve" method="POST" class="d-inline">
                          <input type="hidden" name="gameId" value="${g.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-dark fw-bold py-1.5 px-3" style="background:#94FFB4; border-radius: 8px;">
                            <i data-lucide="check" width="14" height="14" class="me-1"></i> Phê duyệt
                          </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin/games/reject" method="POST" class="d-inline">
                          <input type="hidden" name="gameId" value="${g.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-white fw-bold py-1.5 px-3" style="background:var(--gf-pink); border-radius: 8px;">
                            <i data-lucide="x" width="14" height="14" class="me-1"></i> Từ chối
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:forEach>

                <c:if test="${empty pendingGames}">
                  <tr>
                    <td colspan="6" class="text-center py-5">
                      <div class="py-4">
                        <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:64px;height:64px;">
                          <i data-lucide="gamepad-2" width="30" height="30" class="text-secondary"></i>
                        </div>
                        <h5 class="fw-black fw-bold mb-1 text-dark">Không có game mới cần duyệt</h5>
                        <p class="small text-secondary gf-muted mb-0">Tất cả yêu cầu đăng game từ Nhà phát triển đã được xử lý xong.</p>
                      </div>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tab 2: Yêu cầu xóa & hoàn tiền -->
      <div class="tab-pane fade" id="delete-pane" role="tabpanel" aria-labelledby="delete-tab">
        <div class="table-container">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 120px;">Ảnh bìa</th>
                  <th scope="col">Tựa game</th>
                  <th scope="col">Nhà phát triển (Publisher)</th>
                  <th scope="col" style="width: 140px;">Giá bán</th>
                  <th scope="col">Trạng thái hiện tại</th>
                  <th scope="col" class="text-center" style="width: 320px;">Quyết định</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="g" items="${pendingDeleteGames}">
                  <tr>
                    <td>
                      <c:choose>
                        <c:when test="${not empty g.mediaList && not fn:startsWith(g.mediaList[0].mediaUrl, 'http')}">
                          <img src="${pageContext.request.contextPath}${g.mediaList[0].mediaUrl}" alt="${fn:escapeXml(g.title)}" class="game-thumb">
                        </c:when>
                        <c:otherwise>
                          <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black game-thumb bg-light" style="font-size: 10px; line-height: 1.2;">
                            Chưa có hình ảnh
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <h6 class="fw-bold mb-0">${g.title}</h6>
                      <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Slug: ${g.slug}</span>
                    </td>
                    <td>
                      <span class="fw-bold text-dark">${g.publisher.companyName}</span>
                      <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Email: ${g.publisher.supportEmail}</span>
                    </td>
                    <td class="fw-bold text-primary">
                      <c:choose>
                        <c:when test="${g.price == 0}">Miễn phí</c:when>
                        <c:otherwise>
                          <fmt:formatNumber value="${g.price}" type="number" maxFractionDigits="0" />đ
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <span class="badge border border-2 border-black fw-bold px-2 py-1 text-white bg-danger" style="border-radius: 6px; font-size: 11px;">CHỜ DUYỆT XÓA</span>
                    </td>
                    <td>
                      <div class="d-flex justify-content-center gap-2">
                        <form action="${pageContext.request.contextPath}/admin/games/approve" method="POST" class="d-inline">
                          <input type="hidden" name="gameId" value="${g.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-white fw-bold py-1.5 px-3 bg-danger" style="border-radius: 8px;">
                            <i data-lucide="trash-2" width="14" height="14" class="me-1"></i> Duyệt Xóa & Hoàn Tiền
                          </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin/games/reject" method="POST" class="d-inline">
                          <input type="hidden" name="gameId" value="${g.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-dark fw-bold py-1.5 px-3 bg-white" style="border-radius: 8px;">
                            <i data-lucide="rotate-ccw" width="14" height="14" class="me-1"></i> Từ chối (Khôi phục)
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:forEach>

                <c:if test="${empty pendingDeleteGames}">
                  <tr>
                    <td colspan="6" class="text-center py-5">
                      <div class="py-4">
                        <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:64px;height:64px;">
                          <i data-lucide="trash-2" width="30" height="30" class="text-secondary"></i>
                        </div>
                        <h5 class="fw-black fw-bold mb-1 text-dark">Không có yêu cầu xóa game</h5>
                        <p class="small text-secondary gf-muted mb-0">Tất cả yêu cầu gỡ/xóa game của Nhà phát triển đã được xử lý xong.</p>
                      </div>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tab 3: Bản vá chờ duyệt -->
      <div class="tab-pane fade" id="patchnotes-pane" role="tabpanel" aria-labelledby="patchnotes-tab">
        <div class="table-container">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 150px;">Game</th>
                  <th scope="col" style="width: 100px;">Phiên bản</th>
                  <th scope="col">Nội dung cập nhật (Patch notes)</th>
                  <th scope="col" style="width: 140px;">Ngày gửi</th>
                  <th scope="col" class="text-center" style="width: 250px;">Quyết định</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="pn" items="${pendingPatchNotes}">
                  <tr>
                    <td class="fw-bold">${pn.game.title}</td>
                    <td>
                      <span class="badge border border-2 border-black bg-white text-dark small fw-bold px-2 py-1" style="font-size: 11px; border-radius: 6px;">${pn.version}</span>
                    </td>
                    <td>
                      <div style="max-height: 80px; overflow-y: auto; white-space: pre-wrap; font-size:13px; color:#555;">${fn:escapeXml(pn.content)}</div>
                    </td>
                    <td style="font-size:12px;">
                      <fmt:parseDate value="${pn.publishedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedPnDate" type="both" /><fmt:formatDate value="${parsedPnDate}" pattern="dd/MM/yyyy HH:mm" />
                    </td>
                    <td>
                      <div class="d-flex justify-content-center gap-2">
                        <form action="${pageContext.request.contextPath}/admin/patchnotes/approve" method="POST" class="d-inline">
                          <input type="hidden" name="patchNoteId" value="${pn.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-dark fw-bold py-1.5 px-3" style="background:#94FFB4; border-radius: 8px;">
                            <i data-lucide="check" width="14" height="14" class="me-1"></i> Phê duyệt
                          </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin/patchnotes/reject" method="POST" class="d-inline">
                          <input type="hidden" name="patchNoteId" value="${pn.id}">
                          <button type="submit" class="btn btn-sm gf-border gf-shadow-sm gf-press text-white fw-bold py-1.5 px-3" style="background:var(--gf-pink); border-radius: 8px;">
                            <i data-lucide="x" width="14" height="14" class="me-1"></i> Từ chối
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:forEach>

                <c:if test="${empty pendingPatchNotes}">
                  <tr>
                    <td colspan="5" class="text-center py-5">
                      <div class="py-4">
                        <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:64px;height:64px;">
                          <i data-lucide="scroll" width="30" height="30" class="text-secondary"></i>
                        </div>
                        <h5 class="fw-black fw-bold mb-1 text-dark">Không có bản vá cần duyệt</h5>
                        <p class="small text-secondary gf-muted mb-0">Tất cả ghi chú cập nhật bản vá từ Nhà phát triển đã được xử lý xong.</p>
                      </div>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tab 4: Tất cả game -->
      <div class="tab-pane fade" id="all-pane" role="tabpanel" aria-labelledby="all-tab">
        <div class="mb-3 d-flex gap-2 px-1">
          <input type="text" id="searchGameInput" class="form-control gf-border-2" placeholder="Tìm kiếm game theo tên..." style="border-radius: 8px; max-width: 300px; border: 2px solid #000;">
          <button class="btn btn-dark gf-border gf-shadow-sm fw-bold px-3 d-flex align-items-center gap-1" onclick="searchGames()" style="border-radius: 8px;">
            <i data-lucide="search" width="14" height="14"></i> Tìm kiếm
          </button>
        </div>
        <div class="table-container">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 120px;">Ảnh bìa</th>
                  <th scope="col">Tựa game</th>
                  <th scope="col">Nhà phát hành (Publisher)</th>
                  <th scope="col" style="width: 120px;">Giá bán</th>
                  <th scope="col" style="width: 120px;">Giá gốc</th>
                  <th scope="col" style="width: 110px;">Ngày đăng</th>
                  <th scope="col" style="width: 110px;">Ngày duyệt</th>
                  <th scope="col" style="width: 120px;">Người duyệt</th>
                  <th scope="col" style="width: 100px;">Lượt bán</th>
                  <th scope="col" style="width: 140px;">Trạng thái</th>
                </tr>
              </thead>
              <tbody id="all-games-table-body">
                <c:forEach var="g" items="${allGames}">
                  <tr>
                    <td>
                      <c:choose>
                        <c:when test="${not empty g.mediaList && not fn:startsWith(g.mediaList[0].mediaUrl, 'http')}">
                          <img src="${pageContext.request.contextPath}${g.mediaList[0].mediaUrl}" alt="${fn:escapeXml(g.title)}" class="game-thumb">
                        </c:when>
                        <c:otherwise>
                          <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black game-thumb bg-light" style="font-size: 10px; line-height: 1.2;">
                            Chưa có hình ảnh
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <h6 class="fw-bold mb-0 game-title-cell">${g.title}</h6>
                      <span class="text-secondary small d-block gf-muted" style="font-size: 11px;">Slug: ${g.slug}</span>
                    </td>
                    <td>
                      <span class="fw-bold text-dark">${g.publisher.companyName}</span>
                    </td>
                    <td class="fw-bold text-primary">
                      <c:choose>
                        <c:when test="${g.price == 0}">Miễn phí</c:when>
                        <c:otherwise>
                          <fmt:formatNumber value="${g.price}" type="number" maxFractionDigits="0" />đ
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-secondary small gf-muted">
                      <c:choose>
                        <c:when test="${not empty g.originalPrice && g.originalPrice != 0}">
                          <fmt:formatNumber value="${g.originalPrice}" type="number" maxFractionDigits="0" />đ
                        </c:when>
                        <c:otherwise>
                          -
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td style="font-size:12px;">
                      <c:if test="${not empty g.createdAt}">
                        <fmt:parseDate value="${g.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedCreateDate" type="both" /><fmt:formatDate value="${parsedCreateDate}" pattern="dd/MM/yyyy" />
                      </c:if>
                    </td>
                    <td style="font-size:12px;">
                      <c:choose>
                        <c:when test="${not empty g.approvedAt}">
                          <fmt:parseDate value="${g.approvedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedApproveDate" type="both" /><fmt:formatDate value="${parsedApproveDate}" pattern="dd/MM/yyyy" />
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                      </c:choose>
                    </td>
                    <td style="font-size:12px;">
                      <c:choose>
                        <c:when test="${not empty g.approvedBy}">${fn:escapeXml(g.approvedBy)}</c:when>
                        <c:otherwise>-</c:otherwise>
                      </c:choose>
                    </td>
                    <td class="fw-bold text-center">
                      <c:choose>
                        <c:when test="${not empty salesCountMap[g.id]}">
                          <span class="badge bg-dark text-white" style="font-size: 12px; border-radius: 6px;">${salesCountMap[g.id]}</span>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">0</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${g.status == 'ACTIVE'}">
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-black bg-success" style="background:#94FFB4 !important; border-radius: 6px; font-size: 11px;">ĐANG HOẠT ĐỘNG</span>
                        </c:when>
                        <c:when test="${g.status == 'PENDING'}">
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-dark bg-warning" style="background:var(--gf-yellow) !important; border-radius: 6px; font-size: 11px;">CHỜ DUYỆT ĐĂNG</span>
                        </c:when>
                        <c:when test="${g.status == 'PENDING_DELETE'}">
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-white bg-danger" style="border-radius: 6px; font-size: 11px;">YÊU CẦU XÓA</span>
                        </c:when>
                        <c:when test="${g.status == 'REJECTED'}">
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-white bg-secondary" style="border-radius: 6px; font-size: 11px;">BỊ TỪ CHỐI</span>
                        </c:when>
                        <c:when test="${g.status == 'DELETED'}">
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-white bg-dark" style="border-radius: 6px; font-size: 11px;">ĐÃ XÓA</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge border border-2 border-black fw-bold px-2 py-1 text-dark bg-light" style="border-radius: 6px; font-size: 11px;">${g.status}</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tab 5: Giao dịch ví -->
      <div class="tab-pane fade" id="transactions-pane" role="tabpanel" aria-labelledby="transactions-tab">
        <div class="table-container">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 80px;">ID</th>
                  <th scope="col">Tài khoản</th>
                  <th scope="col">Loại giao dịch</th>
                  <th scope="col">Số tiền</th>
                  <th scope="col">Trạng thái</th>
                  <th scope="col">Mã tham chiếu</th>
                  <th scope="col">Thời gian</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="tx" items="${walletTransactions}">
                  <tr>
                    <td class="fw-bold">#${tx.id}</td>
                    <td>
                      <span class="fw-bold">${tx.wallet.user.username}</span>
                      <small class="text-muted d-block" style="font-size:11px;">${tx.wallet.user.fullName}</small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${tx.type == 'DEPOSIT'}"><span class="badge bg-success text-white">Nạp tiền</span></c:when>
                        <c:when test="${tx.type == 'WITHDRAW'}"><span class="badge bg-warning text-dark">Rút tiền</span></c:when>
                        <c:when test="${tx.type == 'PURCHASE'}"><span class="badge bg-info text-dark">Mua game</span></c:when>
                        <c:when test="${tx.type == 'REFUND'}"><span class="badge bg-primary text-white">Hoàn tiền</span></c:when>
                        <c:when test="${tx.type == 'ADJUSTMENT'}"><span class="badge bg-secondary text-white">Doanh thu Publisher</span></c:when>
                        <c:when test="${tx.type == 'PAYOUT'}"><span class="badge bg-danger text-white">Rút tiền Publisher</span></c:when>
                        <c:otherwise><span class="badge bg-light text-dark">${tx.type}</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="fw-bold">
                      <c:choose>
                        <c:when test="${tx.type == 'DEPOSIT' || tx.type == 'REFUND' || tx.type == 'ADJUSTMENT'}">
                          <span class="text-success">+<fmt:formatNumber value="${tx.amount}" type="number" maxFractionDigits="0" />đ</span>
                        </c:when>
                        <c:otherwise>
                          <span class="text-danger">-<fmt:formatNumber value="${tx.amount}" type="number" maxFractionDigits="0" />đ</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${tx.status == 'SUCCESS'}"><span class="badge bg-success text-white">Thành công</span></c:when>
                        <c:when test="${tx.status == 'FAILED'}"><span class="badge bg-danger text-white">Thất bại</span></c:when>
                        <c:otherwise><span class="badge bg-warning text-dark">${tx.status}</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-monospace" style="font-size: 12px;">${tx.referenceId}</td>
                    <td style="font-size:12px;">
                      <fmt:parseDate value="${tx.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedTxDate" type="both" /><fmt:formatDate value="${parsedTxDate}" pattern="dd/MM/yyyy HH:mm" />
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty walletTransactions}">
                  <tr>
                    <td colspan="7" class="text-center py-5">
                      <div class="py-4">
                        <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:64px;height:64px;">
                          <i data-lucide="banknote" width="30" height="30" class="text-secondary"></i>
                        </div>
                        <h5 class="fw-black fw-bold mb-1 text-dark">Không có giao dịch nào</h5>
                        <p class="small text-secondary gf-muted mb-0">Hệ thống chưa ghi nhận bất kỳ giao dịch ví nào.</p>
                      </div>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForce Admin Dashboard
    </div>
  </footer>

  <script>
    lucide.createIcons();

    function searchGames() {
      let input = document.getElementById('searchGameInput').value.toLowerCase();
      let rows = document.querySelectorAll('#all-games-table-body tr');
      rows.forEach(row => {
        let titleCell = row.querySelector('.game-title-cell');
        if (titleCell) {
          let text = titleCell.textContent.toLowerCase();
          if (text.includes(input)) {
            row.style.display = '';
          } else {
            row.style.display = 'none';
          }
        }
      });
    }

    document.getElementById('searchGameInput')?.addEventListener('keyup', function(e) {
      if (e.key === 'Enter') {
        searchGames();
      }
    });
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
