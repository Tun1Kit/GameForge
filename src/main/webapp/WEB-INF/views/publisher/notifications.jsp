<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Publisher Notifications</title>
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
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
          <a href="${pageContext.request.contextPath}/publisher/notifications" class="btn btn-sm gf-border-2 gf-press text-white rounded-3 d-flex align-items-center justify-content-center p-0 position-relative" style="width:38px; height:38px; border-color:#000; background:var(--gf-green); flex-shrink:0; color:#fff !important;">
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
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-5">
      <div>
        <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-pink);box-shadow:3px 3px 0 #000;">
          <i data-lucide="bell" width="16" height="16"></i> Trung tâm thông báo
        </div>
        <h1 class="fw-black fw-bold mb-2" style="font-size:clamp(2rem,5vw,3rem);line-height:1.1;letter-spacing:-0.03em;">
          Thông báo <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Nhà phát hành</span>
        </h1>
        <p class="fs-5 fw-semibold text-secondary gf-muted mb-0">Theo dõi các đánh giá từ người chơi, trạng thái phê duyệt game, KYC và payout.</p>
      </div>

      <c:if test="${not empty notifications}">
        <form action="${pageContext.request.contextPath}/publisher/notifications/mark-read" method="POST" class="flex-shrink-0">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
          <button type="submit" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 py-2 px-3 d-flex align-items-center gap-2">
            <i data-lucide="check-check" width="16" height="16"></i> Đánh dấu tất cả đã đọc
          </button>
        </form>
      </c:if>
    </div>

    <c:choose>
      <c:when test="${empty notifications}">
        <div class="bg-white gf-border rounded-4 gf-shadow p-5 text-center my-4">
          <div class="gf-border-2 rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width:64px;height:64px;background:var(--gf-blue);">
            <i data-lucide="bell-off" width="28" height="28" class="text-black"></i>
          </div>
          <h3 class="fw-black text-black mb-2">Không có thông báo</h3>
          <p class="text-secondary fw-semibold gf-muted mb-0">Tuyệt vời! Bạn không có thông báo chưa đọc nào.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="d-flex flex-column gap-3">
          <c:forEach var="notif" items="${notifications}">
            <div class="bg-white gf-border rounded-4 gf-shadow p-4 position-relative overflow-hidden transition-all hover-translate-y" 
                 style="border-left: 8px solid ${notif.read ? '#e4e4e7' : 'var(--gf-green)'} !important;">
              
              <div class="d-flex justify-content-between align-items-start gap-3">
                <div class="d-flex align-items-start gap-3">
                  <div class="gf-border-2 rounded-3 d-flex align-items-center justify-content-center flex-shrink-0" 
                       style="width: 44px; height: 44px; background: ${notif.type == 'REVIEW' ? 'var(--gf-yellow)' : notif.type == 'PAYOUT' ? 'var(--gf-pink)' : notif.type == 'GAME_APPROVAL' ? 'var(--gf-blue)' : 'var(--gf-lavender)'};">
                    <c:choose>
                      <c:when test="${notif.type == 'REVIEW'}">
                        <i data-lucide="message-square" width="20" height="20"></i>
                      </c:when>
                      <c:when test="${notif.type == 'PAYOUT'}">
                        <i data-lucide="banknote" width="20" height="20"></i>
                      </c:when>
                      <c:when test="${notif.type == 'GAME_APPROVAL'}">
                        <i data-lucide="gamepad-2" width="20" height="20"></i>
                      </c:when>
                      <c:otherwise>
                        <i data-lucide="bell" width="20" height="20"></i>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div>
                    <h5 class="fw-black mb-1 d-flex align-items-center gap-2">
                      ${fn:escapeXml(notif.title)}
                      <c:if test="${!notif.read}">
                        <span class="badge bg-danger rounded-pill fw-bold" style="font-size:9px; padding: 2px 6px;">Mới</span>
                      </c:if>
                    </h5>
                    <p class="text-dark fw-medium mb-2" style="font-size:15px;">${fn:escapeXml(notif.content)}</p>
                    <div class="text-secondary small fw-bold d-flex align-items-center gap-1 gf-muted">
                      <i data-lucide="calendar" width="12" height="12"></i>
                      <fmt:parseDate value="${notif.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDateTime" type="both" />
                      <fmt:formatDate value="${parsedDateTime}" pattern="dd/MM/yyyy HH:mm" />
                    </div>
                  </div>
                </div>
                
                <c:if test="${not empty notif.targetUrl}">
                  <a href="${pageContext.request.contextPath}${notif.targetUrl}" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 px-3 py-2 d-flex align-items-center gap-2 flex-shrink-0 align-self-center">
                    <i data-lucide="external-link" width="14" height="14"></i> Xem chi tiết
                  </a>
                </c:if>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForce Publisher Center
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    lucide.createIcons();
  </script>
</body>
</html>
