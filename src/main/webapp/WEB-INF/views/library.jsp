<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="com.gamestore.entity.User" %>
<%
  Long currentUserId = null;
  Object cu = request.getSession().getAttribute("currentUser");
  if (cu instanceof User) currentUserId = ((User) cu).getId();
%>
<script>
  window.GAMEFORGE_CURRENT_USER_ID = <%= currentUserId != null ? currentUserId : "null" %>;
</script>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Thư Viện Game & Cá Nhân</title>

  <!-- CSRF Meta Tags (Spring Security) -->
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

  <script>
    window.GAMEFORGE_CSRF_TOKEN = (function() {
      var m = document.querySelector('meta[name="_csrf"]');
      return m ? m.content : '';
    })();
    window.GAMEFORGE_CSRF_HEADER = (function() {
      var m = document.querySelector('meta[name="_csrf_header"]');
      return m ? m.content : '_csrf';
    })();
  </script>

  <script>
    (function () {
      try {
        if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
          document.documentElement.classList.add('gf-dark-mode');
        } else {
          document.documentElement.classList.remove('gf-dark-mode');
        }
      } catch (e) {}
    })();
  </script>

  <!-- Bootstrap 5 + Lucide -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/library.css">
</head>

<body class="position-relative" style="min-height: 100vh; overflow-x: hidden;">
  <!-- Trang trí nổi trôi phong cách Neo-brutalism -->
  <div class="gf-decor-pill" style="top: 15%; left: 3%; background: var(--gf-pink); transform: rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top: 75%; left: 2%; background: var(--gf-yellow); transform: rotate(-20deg); width: 30px; height: 30px;"></div>
  <div class="gf-decor-pill" style="top: 25%; right: 4%; background: var(--gf-blue); transform: rotate(45deg); width: 28px; height: 28px; border-radius: 50%;"></div>
  <div class="gf-decor-pill" style="top: 68%; right: 3%; background: #94FFB4; transform: rotate(-10deg);"></div>

  <!-- NAVBAR -->
  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <c:if test="${currentUser.hasRole('ROLE_ADMIN')}">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
              <i data-lucide="shield-check" width="14" height="14"></i> Quản Trị Viên
            </a>
          </c:if>
          <c:if test="${currentUser.hasRole('ROLE_PUBLISHER')}">
            <a href="${pageContext.request.contextPath}/publisher/dashboard" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
              <i data-lucide="layout-dashboard" width="14" height="14"></i> Nhà Phát Hành
            </a>
          </c:if>
          
          <a href="${pageContext.request.contextPath}/" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="arrow-left" width="14" height="14"></i> Cửa hàng
          </a>

          <!-- DROPDOWN USER -->
          <div class="dropdown" style="flex-shrink: 0;">
            <button class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown" style="height:38px;border-color:#000;padding:4px 12px 4px 6px;flex-shrink:0;line-height:1;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Vinh'}" 
                   alt="Avatar" 
                   style="width: 24px; height: 24px; border-radius: 50%; object-fit: cover; border: 1.5px solid #000;">
              <span class="d-none d-sm-inline fw-black text-dark" style="font-size:12px; max-width: 100px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${fn:escapeXml(currentUser.fullName)}</span>
              <i data-lucide="chevron-down" width="14" height="14" class="text-dark"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius: 12px; min-width: 210px;">
              <c:if test="${currentUser.hasRole('ROLE_ADMIN')}">
                <li>
                  <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="shield-check" width="14" height="14"></i> Quản Trị Viên
                  </a>
                </li>
              </c:if>
              <c:if test="${currentUser.hasRole('ROLE_PUBLISHER')}">
                <li>
                  <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/publisher/dashboard">
                    <i data-lucide="layout-dashboard" width="14" height="14"></i> Nhà Phát Hành
                  </a>
                </li>
              </c:if>
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/library">
                  <i data-lucide="library" width="14" height="14"></i> Thư viện game
                </a>
              </li>
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/transactions">
                  <i data-lucide="history" width="14" height="14"></i> Lịch sử giao dịch
                </a>
              </li>
              <li class="dropdown-divider my-2" style="border-top: 2px solid #000;"></li>
              <li>
                <div class="px-3 py-1.5 d-flex align-items-center justify-content-between gap-2 bg-light rounded-3 gf-border">
                  <span class="small fw-black text-secondary" style="font-size: 11px;">Số dư ví:</span>
                  <span class="fw-black text-success" style="font-size: 14px; font-weight: 900 !important;">
                    <fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />đ
                  </span>
                </div>
              </li>
              <li class="px-2 mt-2">
                <a class="btn btn-sm w-100 gf-border gf-shadow-sm gf-press fw-bold text-dark py-1.5" href="${pageContext.request.contextPath}/recharge" style="background:var(--gf-yellow); border-radius: 8px; font-size: 13px; display: inline-flex; align-items: center; justify-content: center; gap: 4px;">
                  <i data-lucide="wallet" width="14" height="14"></i> Nạp tiền
                </a>
              </li>
              <li class="dropdown-divider my-2" style="border-top: 2px solid #000;"></li>
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2 text-danger"
                   href="${pageContext.request.contextPath}/logout"
                   onclick="localStorage.removeItem('gameforge_favorite_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_user_id');">
                  <i data-lucide="log-out" width="14" height="14"></i> Đăng xuất
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- MAIN CONTAINER -->
  <main class="container-xl py-5">
    <div class="row align-items-start g-5">
      
      <!-- PHẦN 1: THƯ VIỆN GAME BÊN TRÁI -->
      <div class="col-lg-8">
        <h1 class="fw-black fw-bold mb-1">Thư viện game của <span class="text-success" id="libraryTitleName">${fn:escapeXml(currentUser.fullName)}</span></h1>
        <p class="fw-semibold text-secondary gf-muted mb-4">Quản lý game đã sở hữu và thông tin tài khoản của bạn.</p>
        
        <!-- THANH CÔNG CỤ LỌC & SẮP XẾP -->
        <div class="d-flex flex-column flex-md-row gap-3 align-items-md-center justify-content-between p-3 bg-white gf-border rounded-4 gf-shadow-sm mb-4">
          <div class="d-flex flex-wrap align-items-center gap-2" id="filterBtnGroup">
            <button class="btn btn-sm gf-border-2 fw-bold px-3 py-1.5 active" data-filter="all" style="border-radius: 8px; font-size: 13px; background: var(--gf-green);">Tất cả</button>
            <button class="btn btn-sm gf-border-2 fw-bold px-3 py-1.5 bg-light" data-filter="installed" style="border-radius: 8px; font-size: 13px;">Đã cài</button>
            <button class="btn btn-sm gf-border-2 fw-bold px-3 py-1.5 bg-light" data-filter="uninstalled" style="border-radius: 8px; font-size: 13px;">Chưa cài</button>
            <button class="btn btn-sm gf-border-2 fw-bold px-3 py-1.5 bg-light" data-filter="favorite" style="border-radius: 8px; font-size: 13px; display: inline-flex; align-items: center; gap: 4px;">
              <i data-lucide="heart" width="14" height="14" style="fill: #f87171; color: #f87171;"></i> Yêu thích
            </button>
          </div>
          
          <div class="d-flex align-items-center gap-2">
            <select class="form-select gf-border-2 fw-bold" id="sortSelect" style="width: 150px; border-radius: 8px; font-size: 13px; height: 38px;">
              <option value="newest">Mới nhất</option>
              <option value="oldest">Cũ nhất</option>
            </select>
            
            <div class="d-flex align-items-center bg-white gf-border-2 rounded-3 px-3 py-1.5" style="border-radius: 8px;">
              <i data-lucide="search" width="16" height="16" class="text-secondary"></i>
              <input id="librarySearchInput" type="text" placeholder="Tìm trong thư viện..." class="border-0 bg-transparent ms-2 fw-semibold" style="outline:none; width:150px; font-size: 13px;">
            </div>
          </div>
        </div>
        
        <!-- LƯỚI CARD GAME THƯ VIỆN -->
        <div id="libraryGrid" class="row row-cols-1 row-cols-md-3 g-4">
          <c:forEach var="item" items="${libraryItems}">
            <c:set var="primaryCategory" value="Game" />
            <c:forEach var="cat" items="${item.game.categories}" varStatus="catStatus">
              <c:if test="${catStatus.first}">
                <c:set var="primaryCategory" value="${cat.name}" />
              </c:if>
            </c:forEach>
            
            <c:set var="isFavorite" value="false" />
            <c:if test="${fn:contains(fn:toLowerCase(item.game.title), 'elden') || fn:contains(fn:toLowerCase(item.game.title), 'cyberpunk')}">
              <c:set var="isFavorite" value="true" />
            </c:if>
            
            <c:set var="isInstalled" value="false" />
            
            <div class="col library-card-col" 
                 data-title="${fn:escapeXml(fn:toLowerCase(item.game.title))}" 
                 data-installed="${isInstalled ? 'true' : 'false'}" 
                 data-favorite="${isFavorite ? 'true' : 'false'}"
                 data-acquired="${item.acquiredAt}"
                 data-item-id="${item.id}"
                 data-game-id="${item.game.id}"
                 data-status="${item.status}">
              <article class="gf-game-card gf-press">
                <div class="game-cover-container">
                  <c:choose>
                    <c:when test="${not empty item.game.mediaList && not fn:startsWith(item.game.mediaList[0].mediaUrl, 'http')}">
                      <img src="${pageContext.request.contextPath}${item.game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(item.game.title)}" loading="lazy" style="width:100%; height:140px; object-fit:cover;">
                    </c:when>
                    <c:otherwise>
                      <div class="d-flex align-items-center justify-content-center fw-bold text-center w-100 bg-light text-dark gf-muted" style="height:140px; font-size: 12px;">
                        Chưa có hình ảnh
                      </div>
                    </c:otherwise>
                  </c:choose>
                  
                  <span class="gf-tag" style="background: var(--gf-yellow); border: 2px solid #000; font-weight: bold;">
                    ${primaryCategory}
                  </span>
                  
                  <button type="button" class="gf-favorite-btn" style="background: #ffffff; border: 2px solid #000; border-radius: 50%; width: 36px; height: 36px;" title="Yêu thích">
                    <i data-lucide="heart" width="16" height="16" style="color:#000;"></i>
                  </button>
                </div>
                
                <div class="p-4 d-flex flex-column flex-grow-1">
                  <div class="d-flex align-items-center justify-content-between mb-3">
                    <c:choose>
                      <c:when test="${item.status == 'REFUNDED'}">
                        <span class="badge border border-2 border-black fw-bold py-1 px-2 text-white bg-danger" 
                              id="statusBadge-${item.id}" 
                              style="border-radius: 999px; font-size: 11px;">
                          Đã hoàn tiền (Game bị xóa)
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge border border-2 border-black fw-bold py-1 px-2 text-dark" 
                              id="statusBadge-${item.id}" 
                              style="background: #e9ecef; border-radius: 999px; font-size: 11px;">
                          Chưa cài đặt
                        </span>
                      </c:otherwise>
                    </c:choose>
                    <span class="small text-secondary gf-muted" style="font-size: 12px;">
                      Mua: ${item.formattedAcquiredAt}
                    </span>
                  </div>
                  
                  <h3 class="fs-5 fw-black fw-bold mb-3 text-truncate" title="${fn:escapeXml(item.game.title)}">${item.game.title}</h3>
                  
                  <!-- Cấu hình Progress Bar nạp giả lập ẩn ban đầu -->
                  <div class="mb-3 d-none" id="downloadProgressContainer-${item.id}">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                      <span class="small fw-bold text-primary">Đang tải xuống...</span>
                      <span class="small fw-black text-primary" id="downloadProgressPercent-${item.id}">0%</span>
                    </div>
                    <div class="progress-bar-container">
                      <div class="progress-bar-fill" id="downloadProgressBarFill-${item.id}"></div>
                    </div>
                  </div>
 
                  <div class="d-flex gap-2 align-items-center" id="actionContainer-${item.id}">
                    <c:choose>
                      <c:when test="${item.status == 'REFUNDED'}">
                        <button type="button" disabled class="btn w-100 gf-border gf-shadow-sm fw-bold py-2 bg-secondary text-white opacity-50" style="border-radius: 10px; cursor: not-allowed;">
                          <i data-lucide="slash" width="16" height="16" class="me-1"></i> Không khả dụng
                        </button>
                      </c:when>
                      <c:otherwise>
                        <button type="button" onclick="startDownloadSimulation('${item.id}', '${fn:escapeXml(item.game.title)}')" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2" style="background: var(--gf-blue); border-radius: 10px;">
                          <i data-lucide="download" width="16" height="16" class="me-1"></i> Tải về
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </article>
            </div>
          </c:forEach>

          <c:forEach var="pItem" items="${pendingItems}">
            <c:set var="primaryCategory" value="Game" />
            <c:forEach var="cat" items="${pItem.game.categories}" varStatus="catStatus">
              <c:if test="${catStatus.first}">
                <c:set var="primaryCategory" value="${cat.name}" />
              </c:if>
            </c:forEach>
            
            <div class="col library-card-col" 
                 data-title="${fn:escapeXml(fn:toLowerCase(pItem.game.title))}" 
                 data-installed="false" 
                 data-favorite="false"
                 data-acquired="${pItem.order.paidAt}"
                 data-item-id="pending-${pItem.id}"
                 data-game-id="${pItem.game.id}">
              <article class="gf-game-card gf-press">
                <div class="game-cover-container">
                  <c:choose>
                    <c:when test="${not empty pItem.game.mediaList}">
                      <img src="${pItem.game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(pItem.game.title)}" loading="lazy">
                    </c:when>
                    <c:otherwise>
                      <img src="https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg" alt="Cover" loading="lazy">
                    </c:otherwise>
                  </c:choose>
                  
                  <span class="gf-tag" style="background: var(--gf-yellow); border: 2px solid #000; font-weight: bold;">
                    ${primaryCategory}
                  </span>
                </div>
                
                <div class="p-4 d-flex flex-column flex-grow-1">
                  <div class="d-flex align-items-center justify-content-between mb-3">
                    <span class="badge border border-2 border-black fw-bold py-1 px-2 text-dark bg-warning" 
                          style="border-radius: 999px; font-size: 11px;">
                      Đang chờ cấp key
                    </span>
                    <span class="small text-secondary gf-muted" style="font-size: 12px;">
                      Mua: ${pItem.formattedPaidAt}
                    </span>
                  </div>
                  
                  <h3 class="fs-5 fw-black fw-bold mb-3 text-truncate" title="${fn:escapeXml(pItem.game.title)}">${pItem.game.title}</h3>
                  
                  <div class="d-flex gap-2 align-items-center">
                    <button type="button" class="btn w-100 gf-border gf-shadow-sm fw-bold py-2" style="background: #e9ecef; color: #6c757d; border-radius: 10px; cursor: not-allowed;" disabled>
                      <i data-lucide="clock" width="16" height="16" class="me-1"></i> Chờ cấp key
                    </button>
                  </div>
                </div>
              </article>
            </div>
          </c:forEach>
          
          <c:if test="${empty libraryItems && empty pendingItems}">
            <div class="col-12">
              <div class="bg-white gf-border rounded-4 p-5 text-center gf-shadow">
                <div class="mx-auto mb-4 gf-border rounded-4 gf-shadow-sm d-grid place-items-center" style="width:64px;height:64px;background:var(--gf-pink);color:#000;">
                  <i data-lucide="library" width="32" height="32"></i>
                </div>
                <h3 class="fw-black fw-bold">Thư viện trống</h3>
                <p class="fw-semibold text-secondary mb-0">Bạn chưa sở hữu tựa game nào trong tài khoản.</p>
              </div>
            </div>
          </c:if>
        </div>
      </div>
      
      <!-- PHẦN 2: SIDEBAR THÀNH VIÊN BÊN PHẢI -->
      <div class="col-lg-4">
        <div class="d-flex flex-column gap-5">
          
          <!-- BIỂU TƯỢNG HỒ SƠ TÀI KHOẢN -->
          <div class="bg-white gf-border rounded-4 gf-shadow p-4 text-center position-relative">
            <div class="p-3" style="background: #94FFB4; border: 3px solid #000; border-radius: 20px; box-shadow: 4px 4px 0 #000; margin-bottom: 20px;">
              <h5 class="fw-black fw-bold mb-0 d-flex align-items-center justify-content-center gap-2">
                <i data-lucide="user-check" width="18" height="18"></i> Thông tin tài khoản
              </h5>
            </div>
            
            <div class="position-relative mx-auto mb-3" style="width: 100px; height: 100px;">
              <img id="avatarImagePreview" src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Vinh'}" 
                   class="gf-border-3 rounded-circle shadow-sm" style="width: 100%; height: 100%; object-fit: cover;">
              <div class="position-absolute bottom-0 end-0 bg-success text-white gf-border rounded-circle d-grid place-items-center" style="width: 28px; height: 28px; border: 2px solid #000;">
                <i data-lucide="check" width="14" height="14"></i>
              </div>
            </div>
            
            <h4 class="fw-black fw-bold mb-1" id="profileNameDisplay">${fn:escapeXml(currentUser.fullName)}</h4>
            <p class="small text-secondary gf-muted mb-3" id="profileEmailDisplay">${fn:escapeXml(currentUser.email)}</p>
            
            <div class="d-flex align-items-center justify-content-center gap-2">
              <span class="badge bg-black text-white border border-2 border-white px-3 py-1.5 fw-bold" style="border-radius: 999px; font-size: 11px;">Thành viên</span>
              <span class="badge border border-2 border-black text-dark px-3 py-1.5 fw-bold" style="background: var(--gf-yellow); border-radius: 999px; font-size: 11px;">Hoạt động</span>
            </div>
          </div>
          
          <!-- WIDGET VÍ TIỀN GAMEFORGE -->
          <div class="bg-white gf-border rounded-4 gf-shadow p-4">
            <div class="d-flex align-items-center gap-3">
              <div class="gf-border-3 rounded-3 d-grid place-items-center text-dark" style="width: 48px; height: 48px; background: var(--gf-yellow); box-shadow: 3px 3px 0 #000;">
                <i data-lucide="wallet" width="24" height="24"></i>
              </div>
              <div>
                <span class="small fw-black text-secondary gf-muted" style="font-size: 12px; display: block; margin-bottom: 2px;">Số dư ví GameForge</span>
                <span class="fs-4 fw-black text-success" id="libraryWalletBalanceText" style="font-weight: 900 !important;">
                  <fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />đ
                </span>
              </div>
              <a href="${pageContext.request.contextPath}/recharge" class="btn btn-sm gf-border gf-shadow-sm gf-press fw-bold text-dark py-2 px-3 ms-auto" style="background: var(--gf-yellow); border-radius: 8px;">
                Nạp tiền
              </a>
            </div>
          </div>

          <!-- FORM CẬP NHẬT THÔNG TIN -->
          <div class="bg-white gf-border rounded-4 gf-shadow p-4">
            <h5 class="fw-black fw-bold mb-4 d-flex align-items-center gap-2">
              <i data-lucide="settings" width="18" height="18"></i> Cập nhật thông tin
            </h5>
            
            <form id="profileUpdateForm" onsubmit="submitProfileUpdate(event)">
              <div class="mb-3">
                <label class="form-label fw-bold text-dark" style="font-size: 13px;">Tên hiển thị</label>
                <input type="text" name="fullName" value="${fn:escapeXml(currentUser.fullName)}" required class="form-control gf-border-2 fw-semibold px-3 py-2" style="border-radius: 8px; font-size: 14px;" maxlength="100">
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold text-dark" style="font-size: 13px;">Địa chỉ Email</label>
                <input type="email" name="email" value="${fn:escapeXml(currentUser.email)}" readonly class="form-control gf-border-2 fw-semibold px-3 py-2 bg-light text-secondary" style="border-radius: 8px; font-size: 14px; cursor: not-allowed;" title="Email không thể thay đổi">
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold text-dark" style="font-size: 13px;">Mật khẩu mới</label>
                <input type="password" name="password" placeholder="••••••••" class="form-control gf-border-2 fw-semibold px-3 py-2" style="border-radius: 8px; font-size: 14px;" maxlength="128">
              </div>
              <div class="mb-4">
                <input type="hidden" name="avatar" value="${fn:escapeXml(currentUser.avatar)}">
                
                <label class="form-label fw-bold text-dark" style="font-size: 13px; display: block;">Chọn ảnh đại diện có sẵn:</label>
                <div class="d-flex flex-wrap gap-2 p-2 bg-light gf-border rounded-3 mb-2" style="max-height: 150px; overflow-y: auto;">
                  <c:forEach var="seed" items="${fn:split('Aiden,Buster,Coco,Duke,Ella,Felix,Ginger,Harley,Izzy,Jax,Kiki,Loki,Milo,Nala,Oscar,Penny,Rusty,Shadow', ',')}">
                    <c:set var="avatarUrl" value="https://api.dicebear.com/7.x/pixel-art/svg?seed=${seed}" />
                    <img src="${avatarUrl}" 
                         alt="${seed}" 
                         class="preset-avatar-option gf-border-2 gf-press cursor-pointer rounded-circle" 
                         style="width: 40px; height: 40px; object-fit: cover; background: #fff; cursor: pointer; border-color: ${currentUser.avatar == avatarUrl ? 'var(--gf-green)' : '#000'};"
                         onclick="selectPresetAvatar('${avatarUrl}', this)">
                  </c:forEach>
                </div>
              </div>
              
              <button type="submit" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5" style="background: var(--gf-green); border-radius: 10px;">
                Lưu thay đổi
              </button>
            </form>
          </div>

          <!-- DANH SÁCH TIỆN ÍCH NHANH -->
          <div class="bg-white gf-border rounded-4 gf-shadow" style="overflow: hidden;">
            <div class="p-3 fw-black fw-bold d-flex align-items-center gap-2 text-dark" style="background: var(--gf-yellow); border-bottom: 3px solid #000;">
              <i data-lucide="list-collapse" width="18" height="18"></i> Tiện ích nhanh
            </div>
            <div class="list-group list-group-flush">
              <a href="${pageContext.request.contextPath}/transactions" class="list-group-item list-group-item-action d-flex align-items-center justify-content-between fw-bold py-3 px-4 border-bottom border-dark border-1">
                <span><i data-lucide="history" width="16" height="16" class="me-2 text-secondary"></i> Lịch sử giao dịch ví</span>
                <i data-lucide="chevron-right" width="16" height="16"></i>
              </a>
              <a href="#" onclick="alert('Cài đặt bảo mật 2 lớp đang được bảo trì an toàn')" class="list-group-item list-group-item-action d-flex align-items-center justify-content-between fw-bold py-3 px-4">
                <span><i data-lucide="shield-alert" width="16" height="16" class="me-2 text-secondary"></i> Bảo mật tài khoản</span>
                <i data-lucide="chevron-right" width="16" height="16"></i>
              </a>
            </div>
          </div>
          
        </div>
      </div>

    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Thư viện game & Cá nhân Neo-brutalism.
    </div>
  </footer>

  <!-- GAME LAUNCHER MODAL (Mock Neo-brutalism) -->
  <div class="modal fade" id="gameLauncherModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
      <div class="modal-content gf-border rounded-4 gf-shadow" style="background: #FFFDF8; border: 3px solid #000 !important; box-shadow: 6px 6px 0 #000;">
        <div class="modal-header bg-warning text-dark border-bottom border-3 border-black p-3">
          <h5 class="modal-title fw-black fw-bold d-flex align-items-center gap-2 mb-0" style="font-size:16px;">
            <i data-lucide="play-circle" width="18" height="18"></i> Trình Khởi Chạy GameForge
          </h5>
          <button type="button" class="btn-close d-none" id="launcherHeaderCloseBtn" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body text-center p-4">
          <div class="mx-auto mb-4 gf-border rounded-circle d-grid place-items-center bg-white" style="width: 72px; height: 72px; border: 3px solid #000 !important; box-shadow: 4px 4px 0 #000; place-items:center;">
            <i data-lucide="gamepad-2" width="36" height="36" style="color: var(--gf-green);"></i>
          </div>
          
          <h4 class="fw-black fw-bold mb-2 text-dark" id="launcherGameTitle">Cyberpunk 2077</h4>
          <p class="small text-secondary fw-semibold mb-4" id="launcherStatusText">🚀 Đang chuẩn bị khởi động trò chơi...</p>
          
          <!-- Progress loader bar -->
          <div class="progress-bar-container mb-4" style="height: 18px; border: 3px solid #000; background: #fff; box-shadow: 2px 2px 0 #000; border-radius: 999px; overflow: hidden;">
            <div id="launcherProgressBarFill" class="progress-bar-fill" style="width: 0%; height: 100%; background: var(--gf-green); transition: width 0.05s linear;"></div>
          </div>
          
          <div id="launcherFinishedText" class="d-none text-success fw-black fw-bold mb-3" style="font-size: 15px; text-shadow: 0.5px 0.5px 0 #fff;">
            🎯 Trò chơi đã được khởi chạy thành công!
          </div>
          
          <button type="button" class="btn gf-border gf-shadow-sm gf-press fw-bold w-100 py-2.5 d-none" id="launcherCloseBtn" data-bs-dismiss="modal" style="background: var(--gf-green); border-radius: 10px; font-size:14px;">
            Đóng Trình Khởi Chạy
          </button>
        </div>
      </div>
    </div>
  </div>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/library.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
