<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - ${game.title}</title>

  <script>
    (function () {
      try {
        if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
          document.documentElement.classList.add('gf-dark-mode');
        }
      } catch (e) {}
    })();
  </script>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght=400;600;700;800;900&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  
  <style>
    body { 
      font-family: 'Inter', sans-serif !important; 
    }
    .gf-video-shell {
      background: #000;
      border: 3px solid #000;
      box-shadow: 6px 6px 0px #000;
      border-radius: 16px;
      overflow: hidden;
    }
    .gf-gallery-thumb {
      border: 3px solid #000;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.1s ease;
    }
    .gf-gallery-thumb:hover, .gf-gallery-thumb.active {
      transform: translate(-2px, -2px);
      box-shadow: 3px 3px 0px #000;
      border-color: var(--gf-green) !important;
    }
    .gf-sticky-sidebar {
      position: sticky;
      top: 30px;
    }
    .description-text {
      line-height: 1.8;
      font-size: 15px;
    }
    .media-placeholder {
      background: #e9ecef;
      border: 3px dashed #ced4da;
      border-radius: 16px;
      min-height: 350px;
    }
    .modal-close-brutal {
      background: var(--gf-pink) !important;
      border: 2px solid #000 !important;
      box-shadow: 2px 2px 0px #000;
      opacity: 1 !important;
    }
    .spec-list li {
      margin-bottom: 8px;
      font-size: 14px;
    }
    #gfMainProductBanner {
      transition: opacity 0.12s ease-in-out;
    }
    
    /* GIAO DIỆN PHÓNG TO SÁNG TẠO */
    .lightbox-blur-bg {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-size: cover;
      background-position: center;
      filter: blur(25px) opacity(0.3);
      transform: scale(1.1);
      z-index: 1;
      pointer-events: none;
    }
    .lightbox-zoom-container {
      position: relative;
      z-index: 2;
      overflow: hidden;
      width: 100%;
      height: 68vh;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: crosshair;
    }
    .lightbox-arrow {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: 48px;
      height: 48px;
      background: var(--gf-yellow) !important;
      border: 3px solid #000 !important;
      box-shadow: 3px 3px 0px #000;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1010;
      cursor: pointer;
      transition: all 0.1s ease;
    }
    .lightbox-arrow:hover {
      transform: translateY(-50%) translate(-2px, -2px);
      box-shadow: 5px 5px 0px #000;
    }
    .lightbox-arrow-left { left: 24px; }
    .lightbox-arrow-right { right: 24px; }
    
    .lightbox-thumbs-container {
      position: relative;
      z-index: 5;
      background: rgba(0, 0, 0, 0.4);
      border-top: 3px solid #000;
      padding: 12px;
      display: flex;
      justify-content: center;
      gap: 10px;
    }
    .lightbox-thumb-item {
      width: 80px;
      height: 48px;
      object-fit: cover;
      border: 2px solid #fff;
      border-radius: 4px;
      cursor: pointer;
      opacity: 0.6;
      transition: all 0.15s ease;
    }
    .lightbox-thumb-item:hover, .lightbox-thumb-item.active {
      opacity: 1;
      border-color: var(--gf-green);
      transform: scale(1.05);
    }
    
    /* NÚT TẮT X LƠ LỬNG */
    .lightbox-close-btn {
      position: absolute;
      top: 15px;
      right: 15px;
      width: 44px;
      height: 44px;
      background: var(--gf-pink) !important;
      border: 3px solid #000 !important;
      box-shadow: 3px 3px 0px #000;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1020;
      cursor: pointer;
      transition: all 0.1s ease;
      color: #000;
    }
    .lightbox-close-btn:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0px #000;
    }

    /* ẢNH PHÓNG TO: ĐẢM BẢO TỰ ĐỘNG TO KHI ẢNH NHỎ */
    #gfLightboxTargetImage {
      max-width: 95vw;
      max-height: 68vh;
      min-width: 60vw;
      min-height: 50vh;
      height: auto;
      width: auto;
      display: block;
      margin: 0 auto;
      z-index: 2;
      border: 3px solid #000;
      box-shadow: 6px 6px 0px rgba(0,0,0,0.6);
    }
    
    /* KÍNH LÚP NEO-BRUTALISM DẠNG Ô VUÔNG Y CŨ */
    .gf-magnifying-lens {
      position: absolute;
      border: 3px solid #000;
      box-shadow: 4px 4px 0px #000;
      width: 160px;
      height: 160px;
      background-repeat: no-repeat;
      display: none;
      pointer-events: none;
      background-color: rgba(0, 0, 0, 0.1);
      z-index: 1000;
      border-radius: 8px;
    }

    /* ĐÁNH GIÁ SAO ĐỘNG */
    .star-rating-selector {
      display: inline-flex;
    }
    .star-rating-selector label {
      color: #ccc;
      transition: color 0.15s ease, transform 0.15s ease;
      font-size: 32px;
      cursor: pointer;
    }
    .star-rating-selector input:checked ~ label,
    .star-rating-selector label:hover,
    .star-rating-selector label:hover ~ label {
      color: #eab308;
      transform: scale(1.1);
    }
  </style>
</head>

<body>

  <div id="rawMinRequirementsData" style="display:none;"><c:out value="${game.minimumRequirements}" /></div>
  <div id="rawRecRequirementsData" style="display:none;"><c:out value="${game.recommendedRequirements}" /></div>

  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold d-none d-sm-inline text-dark">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

        <div class="d-none d-lg-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/" class="gf-nav-link">Cửa Hàng</a>
          <a href="${pageContext.request.contextPath}/#sale-games" class="gf-nav-link">Khuyến Mãi</a>
          <a href="${pageContext.request.contextPath}/#community" class="gf-nav-link">Cộng Đồng</a>
          <a href="${pageContext.request.contextPath}/#support" class="gf-nav-link">Hỗ Trợ</a>
        </div>

        <div class="d-flex align-items-center gap-2 gap-sm-3">
          <button id="favoriteTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-pink)" type="button">
            <i data-lucide="heart" width="20" height="20"></i>
            <span id="favoriteCount" class="gf-count-badge text-white" style="background:#f87171;">0</span>
          </button>

          <button id="cartTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-blue)" type="button">
            <i data-lucide="shopping-cart" width="20" height="20"></i>
            <span id="cartCount" class="gf-count-badge text-black" style="background:var(--gf-yellow);">0</span>
          </button>

          <c:choose>
            <c:when test="${not empty currentUser}">
              <div class="dropdown">
                <button class="btn dropdown-toggle gf-press d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown"
                        style="background:#fff;border:3px solid #000;border-radius:999px;height:44px;padding:4px 16px 4px 6px;box-shadow:3px 3px 0 0 #000;">
                  <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Kiet'}" alt="Avatar" style="width:30px;height:30px;border-radius:50%;object-fit:cover;border:2px solid #000;">
                  <span class="d-none d-sm-inline fw-black text-dark" style="font-size:13px;">${fn:escapeXml(currentUser.fullName)}</span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:210px;">
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
                      <span class="fw-black text-success" id="detailWalletBalance" style="font-size: 14px; font-weight: 900 !important;">
                        <c:choose>
                          <c:when test="${not empty walletBalance}">
                            <fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />đ
                          </c:when>
                          <c:otherwise>0đ</c:otherwise>
                        </c:choose>
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
                    <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2 text-danger" href="${pageContext.request.contextPath}/logout" onclick="localStorage.removeItem('gameforge_favorite_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_user_id');">
                      <i data-lucide="log-out" width="14" height="14"></i> Đăng xuất
                    </a>
                  </li>
                </ul>
              </div>
            </c:when>
            <c:otherwise>
              <a href="${pageContext.request.contextPath}/login" class="gf-icon-btn gf-press" style="background:#C084FC" title="Đăng nhập">
                <i data-lucide="circle-user" width="20" height="20"></i>
              </a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </nav>

  <main class="container-xl py-5" style="min-height: 100vh;">
    
    <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-4 d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3">
      <div>
        <c:forEach var="cat" items="${game.categories}" varStatus="status">
          <span class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small mb-2 me-1" style="background:var(--gf-pink); color:#000;">
            ${cat.name}
          </span>
        </c:forEach>
        <c:if test="${empty game.categories}">
          <span class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small mb-2" style="background:var(--gf-pink); color:#000;">
            GAME
          </span>
        </c:if>
        
        <h1 class="display-6 fw-black fw-bold text-dark m-0 mt-1">${game.title}</h1>
        <p class="fw-semibold text-secondary gf-muted m-0 mt-2">Nhà phát triển: <span class="text-dark fw-bold">${not empty game.developer ? game.developer : 'Đang cập nhật'}</span></p>
        <p class="fw-semibold text-secondary gf-muted m-0 mt-1">
          <c:choose>
            <c:when test="${isFutureRelease}">
              Ngày phát hành dự kiến: <span class="text-primary fw-bold">${game.releaseDate}</span>
            </c:when>
            <c:otherwise>
              Ngày phát hành: <span class="text-dark fw-bold">${game.releaseDate}</span>
            </c:otherwise>
          </c:choose>
        </p>
      </div>

      <!-- GRID HUY HIỆU ĐỘNG DO ADMIN QUẢN LÝ -->
      <div class="d-flex flex-column gap-2 flex-shrink-0" style="min-width: 280px;">
        <div class="d-grid gap-2 text-start" style="grid-template-columns: repeat(2, 1fr);">
          <c:forEach var="badge" items="${resolvedBadges}">
            <div class="gf-border rounded-3 p-2 gf-shadow-sm d-flex flex-column align-items-center text-center justify-content-center" style="min-height:75px; background: ${badge.color};">
              <i data-lucide="${badge.icon}" class="text-dark" width="18" height="18"></i>
              <span class="fw-bold text-dark small mt-1" style="font-size: 11px;">${badge.title}</span>
            </div>
          </c:forEach>
        </div>
      </div>
    </div>

    <div class="row g-5">
      <div class="col-lg-8">
        
        <c:set var="hasTrailer" value="false" />
        <c:forEach var="media" items="${game.mediaList}">
          <c:if test="${media.mediaType == 'VIDEO' || media.mediaType == 'VIDEO_TRAILER'}">
            <c:set var="hasTrailer" value="true" />
            <c:set var="trailerUrl" value="${media.mediaUrl}" />
          </c:if>
        </c:forEach>

        <c:choose>
          <c:when test="${hasTrailer}">
            <div class="gf-video-shell mb-4">
              <div class="ratio ratio-16x9">
                <iframe id="gfMainVideoFrame" src="${trailerUrl}" title="Game Trailer" allowfullscreen class="border-0"></iframe>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="media-placeholder d-flex flex-column align-items-center justify-content-center mb-4 p-4 text-center text-muted">
              <i data-lucide="video-off" width="48" height="48" class="mb-3"></i>
              <h5 class="fw-bold m-0">Trailer đang được cập nhật</h5>
              <p class="small fw-semibold mt-1 mb-0">Tính năng phát thử trailer sẽ sớm có mặt cho tựa game này.</p>
            </div>
          </c:otherwise>
        </c:choose>

        <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5">
          <h3 class="fs-5 fw-black fw-bold mb-4 d-flex align-items-center gap-2">
            <i data-lucide="images" width="20" height="20" style="color:var(--gf-blue)"></i> Hình ảnh thực tế (Click để xem phóng to chi tiết)
          </h3>
          <div class="row g-3">
            <c:set var="imgCount" value="0" />
            <c:forEach var="media" items="${game.mediaList}">
              <c:if test="${media.mediaType == 'IMAGE' && not fn:startsWith(media.mediaUrl, 'http')}">
                <div class="col-4">
                  <c:set var="resolvedUrl" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                  <img src="${resolvedUrl}" 
                       class="img-fluid gf-gallery-thumb ${imgCount == 0 ? 'active' : ''}" 
                       alt="Screenshot" 
                       onclick="triggerDoubleAction('${resolvedUrl}', this)">
                </div>
                <c:set var="imgCount" value="${imgCount + 1}" />
              </c:if>
            </c:forEach>
            
            <c:if test="${imgCount == 0}">
              <div class="col-12 text-center py-4 text-muted">
                <i data-lucide="image-off" class="mb-2" width="36" height="36"></i>
                <p class="small fw-semibold m-0">Chưa có hình ảnh chụp màn hình thực tế.</p>
              </div>
            </c:if>
          </div>
        </div>
        
        <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5">
          <h3 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
            <i data-lucide="text-quote" width="20" height="20" style="color:var(--gf-green)"></i> Giới thiệu trò chơi
          </h3>
          <div class="fw-semibold text-secondary description-text">
            <c:choose>
              <c:when test="${not empty game.description}">
                ${game.description}
              </c:when>
              <c:otherwise>Nhà phát hành chưa cập nhật mô tả chi tiết cho trò chơi này.</c:otherwise>
            </c:choose>
          </div>
        </div>

        <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5">
          <h3 class="fs-5 fw-black fw-bold mb-4 d-flex align-items-center gap-2">
            <i data-lucide="terminal" width="22" height="22" style="color:var(--gf-purple)"></i>
            Yêu cầu cấu hình hệ thống
          </h3>
          <div class="row g-4">
            <div class="col-12 col-md-6">
              <div class="p-3 rounded-3 border border-2 border-dark h-100" style="background: #fafafa;">
                <h4 class="fs-6 fw-black fw-bold mb-3 text-uppercase text-secondary">Cấu hình tối thiểu</h4>
                <ul class="list-unstyled spec-list text-dark fw-semibold pm-0" id="minSpecsContainer">
                </ul>
              </div>
            </div>
            
            <div class="col-12 col-md-6">
              <div class="p-3 rounded-3 border border-2 border-dark h-100" style="background: #fafafa;">
                <h4 class="fs-6 fw-black fw-bold mb-3 text-uppercase text-success">Cấu hình đề nghị</h4>
                <ul class="list-unstyled spec-list text-dark fw-semibold pm-0" id="recSpecsContainer">
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- ================= PHẦN ĐÁNH GIÁ THỰC TẾ TỪ NGƯỜI DÙNG ================= -->
        <div class="bg-white gf-border gf-shadow rounded-4 p-4">
          <h3 class="fs-5 fw-black fw-bold mb-4 d-flex align-items-center gap-2">
            <i data-lucide="message-square" width="22" height="22" style="color:var(--gf-pink)"></i>
            Đánh giá từ Cộng đồng (${reviewsCount} Đánh giá)
          </h3>

          <!-- ================= KHUNG HIỂN THỊ ĐÁNH GIÁ CỦA BẠN (NẾU ĐÃ ĐÁNH GIÁ) ================= -->
          <c:if test="${not empty currentUser && hasReviewed}">
            <div class="p-4 rounded-3 border border-3 border-dark mb-4" style="background:#EBF3FF; box-shadow: 4px 4px 0 #000;">
              <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                <h4 class="fs-6 fw-black fw-bold mb-0 text-dark d-flex align-items-center gap-2">
                  <i data-lucide="award" width="16" height="16" style="color:var(--gf-pink)"></i>
                  ĐÁNH GIÁ CỦA BẠN
                </h4>
              </div>

              <!-- Chi tiết đánh giá của tôi -->
              <div class="bg-white border border-2 border-dark rounded-3 p-3 position-relative" style="box-shadow: 2px 2px 0 rgba(0,0,0,0.15);">
                <div class="d-flex align-items-start justify-content-between gap-3 flex-wrap">
                  <div class="d-flex align-items-center gap-2">
                    <img src="https://api.dicebear.com/7.x/pixel-art/svg?seed=${userReview.user.username}" alt="Avatar" class="border border-2 border-dark" style="width:36px; height:36px; border-radius:50%; object-fit:cover;">
                    <div>
                      <h5 class="fs-6 fw-black m-0 text-dark">${fn:escapeXml(userReview.user.fullName)}</h5>
                      <span class="small text-secondary fw-semibold">@${fn:escapeXml(userReview.user.username)}</span>
                    </div>
                  </div>
                  <div class="d-flex flex-column align-items-md-end text-md-end">
                    <div class="text-warning fw-black fs-6">
                      <c:forEach begin="1" end="${userReview.rating}">★</c:forEach>
                      <c:forEach begin="${userReview.rating + 1}" end="5">☆</c:forEach>
                    </div>
                    <span class="small text-secondary fw-bold" style="font-size:10px;">
                      <fmt:parseDate value="${userReview.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedMyRevDate" type="both" />
                      <fmt:formatDate value="${parsedMyRevDate}" pattern="dd/MM/yyyy HH:mm" />
                    </span>
                  </div>
                </div>
                
                <div class="mt-3 text-dark fw-semibold small" style="line-height:1.6;">
                  ${fn:escapeXml(userReview.comment)}
                </div>

                <!-- Nhánh phản hồi của Admin/Publisher cho Review của tôi -->
                <c:if test="${not empty userReview.publisherReply}">
                  <div class="mt-3 p-3 rounded-2 border border-2 border-dark" style="background:#FFFEE4; border-color:var(--gf-yellow) !important; margin-left: 20px;">
                    <div class="d-flex align-items-center gap-2 mb-1">
                      <div class="gf-border-2 rounded-circle bg-dark d-grid place-items-center" style="width:20px; height:20px;">
                        <i data-lucide="reply" class="text-white" width="10" height="10"></i>
                      </div>
                      <span class="fw-black text-dark small" style="font-size:11px;">Phản hồi từ Nhà phát triển / Admin</span>
                      <c:if test="${isAdmin || isGamePublisher}">
                        <form action="${pageContext.request.contextPath}/api/reviews/reply/delete" method="POST" class="ms-auto d-inline mb-0">
                          <input type="hidden" name="reviewId" value="${userReview.id}">
                          <c:if test="${not empty _csrf.token}">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                          </c:if>
                          <button type="submit" class="btn btn-link p-0 text-danger fw-bold text-decoration-none small d-flex align-items-center gap-1" style="font-size: 11px;" onclick="return confirm('Bạn có chắc chắn muốn xóa phản hồi này?')">
                            <i data-lucide="trash-2" width="12" height="12"></i> Xóa
                          </button>
                        </form>
                      </c:if>
                    </div>
                    <p class="m-0 small fw-semibold text-secondary">${fn:escapeXml(userReview.publisherReply)}</p>
                  </div>
                </c:if>

                <!-- Nhánh ý kiến bổ sung (userFollowUp) của tôi -->
                <c:choose>
                  <c:when test="${not empty userReview.userFollowUp}">
                    <div class="mt-3 p-3 rounded-2 border border-2 border-dark" style="background:#F2EAFF; border-color:var(--gf-lavender) !important; margin-left: 40px;">
                      <div class="d-flex align-items-center justify-content-between mb-1">
                        <div class="d-flex align-items-center gap-2">
                          <div class="gf-border-2 rounded-circle bg-dark d-grid place-items-center" style="width:20px; height:20px; background:var(--gf-pink) !important;">
                            <i data-lucide="plus" class="text-white" width="10" height="10"></i>
                          </div>
                          <span class="fw-black text-dark small" style="font-size:11px;">Ý kiến bổ sung của bạn</span>
                        </div>
                        <c:if test="${not empty userReview.userFollowUpRating}">
                          <div class="text-warning fw-black small" style="font-size: 11px;">
                            <c:forEach begin="1" end="${userReview.userFollowUpRating}">★</c:forEach>
                            <c:forEach begin="${userReview.userFollowUpRating + 1}" end="5">☆</c:forEach>
                          </div>
                        </c:if>
                      </div>
                      <p class="m-0 small fw-semibold text-secondary">${fn:escapeXml(userReview.userFollowUp)}</p>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <!-- Nếu đã có phản hồi nhưng chưa có ý kiến bổ sung -> Hiển thị form viết ý kiến bổ sung -->
                    <c:if test="${not empty userReview.publisherReply}">
                      <div class="mt-3 p-3 rounded-2 border border-2 border-dark bg-light" style="margin-left: 40px; box-shadow: 2px 2px 0 #000;">
                        <h6 class="fw-black text-dark mb-2" style="font-size:12px;">Bổ sung đánh giá của bạn (Chỉ được bổ sung 1 lần):</h6>
                        <form action="${pageContext.request.contextPath}/api/reviews/followup" method="POST">
                          <input type="hidden" name="reviewId" value="${userReview.id}">
                          <c:if test="${not empty _csrf.token}">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                          </c:if>
                          
                          <div class="mb-2">
                            <label class="fw-bold text-dark small d-block mb-1" style="font-size:11px;">Chọn số sao bổ sung:</label>
                            <div class="d-flex align-items-center gap-2">
                              <div class="star-rating-selector d-flex flex-row-reverse justify-content-end gap-1">
                                <input type="radio" id="followStar5" name="followUpRating" value="5" class="d-none" required />
                                <label for="followStar5" class="star-label cursor-pointer" title="5 sao" style="font-size:24px;">★</label>
                                
                                <input type="radio" id="followStar4" name="followUpRating" value="4" class="d-none" />
                                <label for="followStar4" class="star-label cursor-pointer" title="4 sao" style="font-size:24px;">★</label>
                                
                                <input type="radio" id="followStar3" name="followUpRating" value="3" class="d-none" />
                                <label for="followStar3" class="star-label cursor-pointer" title="3 sao" style="font-size:24px;">★</label>
                                
                                <input type="radio" id="followStar2" name="followUpRating" value="2" class="d-none" />
                                <label for="followStar2" class="star-label cursor-pointer" title="2 sao" style="font-size:24px;">★</label>
                                
                                <input type="radio" id="followStar1" name="followUpRating" value="1" class="d-none" />
                                <label for="followStar1" class="star-label cursor-pointer" title="1 sao" style="font-size:24px;">★</label>
                              </div>
                            </div>
                          </div>

                          <textarea name="followUpText" rows="2" class="form-control border border-2 border-dark fw-semibold mb-2" placeholder="Nhập ý kiến bổ sung của bạn sau khi nhà phát hành phản hồi..." required maxlength="1000" style="font-size:12px; border-radius: 6px;"></textarea>
                          <button type="submit" class="btn btn-xs gf-border-2 gf-press fw-bold text-dark px-3 py-1" style="background:var(--gf-pink); font-size:11px;">
                            Gửi ý kiến bổ sung
                          </button>
                        </form>
                      </div>
                    </c:if>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </c:if>

          <!-- Form viết Đánh giá (nếu đã đăng nhập và đã sở hữu sản phẩm) -->
          <div id="gfOriginalReviewFormContainer" class="p-4 rounded-3 border border-3 border-dark mb-4" style="background:#fafafa; box-shadow: 4px 4px 0 #000; ${hasReviewed ? 'display: none;' : ''}">
            <c:choose>
              <c:when test="${not empty currentUser}">
                <c:choose>
                  <c:when test="${isOwned}">
                    <h4 class="fs-6 fw-black fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                      <i data-lucide="pen-tool" width="16" height="16"></i>
                      VIẾT ĐÁNH GIÁ THỰC TẾ
                    </h4>
                    
                    <form action="${pageContext.request.contextPath}/api/reviews/add" method="POST">
                      <input type="hidden" name="gameId" value="${game.id}">
                      <c:if test="${not empty _csrf.token}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                      </c:if>
                      
                      <div class="mb-3">
                        <label class="fw-bold text-dark small d-block mb-1">Chọn số sao đánh giá:</label>
                        <div class="d-flex align-items-center gap-2">
                          <div class="star-rating-selector d-flex flex-row-reverse justify-content-end gap-1">
                            <input type="radio" id="star5" name="rating" value="5" class="d-none" required />
                            <label for="star5" class="star-label cursor-pointer" title="5 sao">★</label>
                            
                            <input type="radio" id="star4" name="rating" value="4" class="d-none" />
                            <label for="star4" class="star-label cursor-pointer" title="4 sao">★</label>
                            
                            <input type="radio" id="star3" name="rating" value="3" class="d-none" />
                            <label for="star3" class="star-label cursor-pointer" title="3 sao">★</label>
                            
                            <input type="radio" id="star2" name="rating" value="2" class="d-none" />
                            <label for="star2" class="star-label cursor-pointer" title="2 sao">★</label>
                            
                            <input type="radio" id="star1" name="rating" value="1" class="d-none" />
                            <label for="star1" class="star-label cursor-pointer" title="1 sao">★</label>
                          </div>
                        </div>
                      </div>

                      <div class="mb-3">
                        <label for="commentArea" class="fw-bold text-dark small d-block mb-1">Nội dung bình luận:</label>
                        <textarea id="commentArea" name="comment" rows="3" class="form-control border border-2 border-dark fw-semibold" placeholder="Nhập cảm nhận chân thực của bạn về tựa game này..." required maxlength="2000" style="box-shadow: 2px 2px 0 #000; border-radius: 8px;"></textarea>
                      </div>

                      <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-black fw-bold px-4 py-2" style="background:var(--gf-green); color:#000;">
                          <i data-lucide="send" class="d-inline mb-0.5 me-1" width="14" height="14"></i> GỬI ĐÁNH GIÁ
                        </button>
                      </div>
                    </form>
                  </c:when>
                  <c:otherwise>
                    <div class="text-center py-3 text-muted">
                      <i data-lucide="shopping-bag" class="mb-2" width="32" height="32" style="color:var(--gf-pink) !important;"></i>
                      <h5 class="fw-bold text-dark fs-6">Chưa sở hữu sản phẩm</h5>
                      <p class="small fw-semibold mb-0">Bạn phải mua hoặc sở hữu trò chơi này để có thể gửi đánh giá thực tế.</p>
                    </div>
                  </c:otherwise>
                </c:choose>
              </c:when>
              <c:otherwise>
                <div class="text-center py-2 text-muted">
                  <i data-lucide="lock" class="mb-2" width="28" height="28" style="color:var(--gf-pink)"></i>
                  <h5 class="fw-bold text-dark fs-6">Đăng nhập để viết đánh giá</h5>
                  <p class="small fw-semibold mb-3">Bạn cần có tài khoản để gửi bình luận và đánh giá số sao cho game này.</p>
                  <a href="${pageContext.request.contextPath}/login" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold px-3 py-1.5 bg-white text-dark">
                    ĐĂNG NHẬP NGAY
                  </a>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
          <div class="d-flex flex-column gap-3">
            <c:choose>
              <c:when test="${not empty reviews}">
                <c:set var="isGamePublisher" value="${isGamePublisher}" />
                <c:set var="isAdmin" value="${not empty currentUser && currentUser.hasRole('ROLE_ADMIN')}" />
                
                <c:forEach var="rev" items="${reviews}">
                  <!-- Để tránh trùng lặp hiển thị, không render review của chính mình trong danh sách cộng đồng -->
                  <c:if test="${empty currentUser || rev.user.id != currentUser.id}">
                    <div class="bg-white border border-2 border-dark rounded-3 p-3 position-relative" style="box-shadow: 4px 4px 0 rgba(0,0,0,0.1);">
                      <div class="d-flex align-items-start justify-content-between gap-3 flex-wrap">
                        <div class="d-flex align-items-center gap-2">
                          <img src="https://api.dicebear.com/7.x/pixel-art/svg?seed=${rev.user.username}" alt="Avatar" class="border border-2 border-dark" style="width:36px; height:36px; border-radius:50%; object-fit:cover;">
                          <div>
                            <h5 class="fs-6 fw-black m-0 text-dark">${fn:escapeXml(rev.user.fullName)}</h5>
                            <span class="small text-secondary fw-semibold">@${fn:escapeXml(rev.user.username)}</span>
                          </div>
                        </div>
                        <div class="d-flex flex-column align-items-md-end text-md-end">
                          <div class="text-warning fw-black fs-6">
                            <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                            <c:forEach begin="${rev.rating + 1}" end="5">☆</c:forEach>
                          </div>
                          <span class="small text-secondary fw-bold" style="font-size:10px;">
                            <fmt:parseDate value="${rev.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedRevDate" type="both" />
                            <fmt:formatDate value="${parsedRevDate}" pattern="dd/MM/yyyy HH:mm" />
                          </span>
                        </div>
                      </div>
                      
                      <div class="mt-3 text-dark fw-semibold small pr-md-4" style="line-height:1.6;">
                        ${fn:escapeXml(rev.comment)}
                      </div>

                      <!-- Phản hồi từ Nhà phát triển / Admin -->
                      <c:if test="${not empty rev.publisherReply}">
                        <div class="mt-3 p-3 rounded-2 border border-2 border-dark" style="background:#FFFEE4; border-color:var(--gf-yellow) !important; margin-left: 20px;">
                          <div class="d-flex align-items-center gap-2 mb-1">
                            <div class="gf-border-2 rounded-circle bg-dark d-grid place-items-center" style="width:20px; height:20px;">
                              <i data-lucide="reply" class="text-white" width="10" height="10"></i>
                            </div>
                            <span class="fw-black text-dark small" style="font-size:11px;">Phản hồi từ Nhà phát triển / Admin</span>
                            <c:if test="${isAdmin || isGamePublisher}">
                              <form action="${pageContext.request.contextPath}/api/reviews/reply/delete" method="POST" class="ms-auto d-inline mb-0">
                                <input type="hidden" name="reviewId" value="${rev.id}">
                                <c:if test="${not empty _csrf.token}">
                                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                </c:if>
                                <button type="submit" class="btn btn-link p-0 text-danger fw-bold text-decoration-none small d-flex align-items-center gap-1" style="font-size: 11px;" onclick="return confirm('Bạn có chắc chắn muốn xóa phản hồi này?')">
                                  <i data-lucide="trash-2" width="12" height="12"></i> Xóa
                                </button>
                              </form>
                            </c:if>
                          </div>
                          <p class="m-0 small fw-semibold text-secondary">${fn:escapeXml(rev.publisherReply)}</p>
                        </div>
                      </c:if>

                      <!-- Ý kiến bổ sung từ người dùng -->
                      <c:if test="${not empty rev.userFollowUp}">
                        <div class="mt-3 p-3 rounded-2 border border-2 border-dark" style="background:#F2EAFF; border-color:var(--gf-lavender) !important; margin-left: 40px;">
                          <div class="d-flex align-items-center justify-content-between mb-1">
                            <div class="d-flex align-items-center gap-2">
                              <div class="gf-border-2 rounded-circle bg-dark d-grid place-items-center" style="width:20px; height:20px; background:var(--gf-pink) !important;">
                                <i data-lucide="plus" class="text-white" width="10" height="10"></i>
                              </div>
                              <span class="fw-black text-dark small" style="font-size:11px;">Ý kiến bổ sung từ người dùng</span>
                            </div>
                            <c:if test="${not empty rev.userFollowUpRating}">
                              <div class="text-warning fw-black small" style="font-size: 11px;">
                                <c:forEach begin="1" end="${rev.userFollowUpRating}">★</c:forEach>
                                <c:forEach begin="${rev.userFollowUpRating + 1}" end="5">☆</c:forEach>
                              </div>
                            </c:if>
                          </div>
                          <p class="m-0 small fw-semibold text-secondary">${fn:escapeXml(rev.userFollowUp)}</p>
                        </div>
                      </c:if>

                      <!-- Phản hồi Action (Dành cho Admin/Publisher) -->
                      <c:if test="${isAdmin || isGamePublisher}">
                        <div class="mt-3 text-end">
                          <button class="btn btn-xs btn-outline-dark fw-bold py-1 px-2.5" style="font-size:11px; border-radius:4px; border:2px solid #000; box-shadow:1.5px 1.5px 0 #000; background:#fff;" onclick="toggleReplyForm(${rev.id})">
                            <i data-lucide="message-square" class="d-inline mb-0.5 me-1" width="12" height="12"></i> 
                            ${not empty rev.publisherReply ? 'Cập nhật phản hồi' : 'Viết phản hồi'}
                          </button>
                        </div>

                        <!-- Form Phản hồi (Ẩn theo mặc định) -->
                        <div id="replyForm_${rev.id}" class="mt-3 p-3 rounded-2 border border-2 border-dark bg-light" style="display:none; box-shadow: 2px 2px 0 #000; margin-left: 20px;">
                          <h6 class="fw-black text-dark mb-2" style="font-size:11px;">Nội dung phản hồi của Nhà phát hành / Quản trị viên:</h6>
                          <form action="${pageContext.request.contextPath}/api/reviews/reply" method="POST">
                            <input type="hidden" name="reviewId" value="${rev.id}">
                            <c:if test="${not empty _csrf.token}">
                              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            </c:if>
                            <textarea name="replyText" rows="2" class="form-control border border-2 border-dark fw-semibold mb-2" placeholder="Nhập câu trả lời..." required maxlength="1000" style="font-size:12px; border-radius: 6px;">${rev.publisherReply}</textarea>
                            <div class="d-flex gap-2">
                              <button type="submit" class="btn btn-xs gf-border-2 gf-press fw-bold" style="background:var(--gf-green); color:#000; font-size:11px; padding:2.5px 10px;">
                                Gửi phản hồi
                              </button>
                              <button type="button" class="btn btn-xs btn-outline-dark fw-bold" style="font-size:11px; padding:2.5px 10px;" onclick="toggleReplyForm(${rev.id})">
                                Hủy
                              </button>
                            </div>
                          </form>
                        </div>
                      </c:if>
                    </div>
                  </c:if>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="text-center py-4 text-muted">
                  <i data-lucide="message-square-off" class="mb-2" width="36" height="36"></i>
                  <p class="small fw-semibold m-0">Chưa có đánh giá thực tế nào. Hãy là người đầu tiên chia sẻ cảm nhận!</p>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

      </div>

      <div class="col-lg-4">
        <div class="gf-sticky-sidebar d-flex flex-column gap-4">
          
          <div class="bg-white gf-border gf-shadow rounded-4 p-4 text-center">
            
            <div class="mb-4 gf-border rounded-3 overflow-hidden gf-banner-slideshow-container" style="border-width: 2px !important; cursor: pointer; position: relative;"
                 onclick="openLightboxFromBanner()" id="gfMainBannerContainer">
              <c:set var="mainBanner" value="" />
              <c:catch var="mediaError">
                <c:forEach var="media" items="${game.mediaList}">
                  <c:if test="${(media.isPrimary || (empty mainBanner && media.mediaType == 'IMAGE')) && not fn:startsWith(media.mediaUrl, 'http')}">
                    <c:set var="mainBanner" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                  </c:if>
                </c:forEach>
              </c:catch>
              
              <c:if test="${not empty mediaError || empty mainBanner}">
                <c:forEach var="media" items="${game.mediaList}">
                  <c:if test="${empty mainBanner && media.mediaType == 'IMAGE' && not fn:startsWith(media.mediaUrl, 'http')}">
                    <c:set var="mainBanner" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                  </c:if>
                </c:forEach>
              </c:if>
              
              <c:choose>
                <c:when test="${not empty mainBanner}">
                  <img id="gfMainProductBanner" src="${mainBanner}" class="img-fluid w-100" alt="${game.title}" style="object-fit: cover; max-height: 220px;">
                </c:when>
                <c:otherwise>
                  <div class="d-flex align-items-center justify-content-center fw-bold text-center bg-light text-dark py-5 border-bottom border-dark" style="min-height: 220px; font-size: 16px;">
                    <i data-lucide="image-off" width="24" height="24" class="me-2"></i> Chưa có hình ảnh
                  </div>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="display-6 fw-black fw-bold mb-4" style="color:var(--gf-green); text-shadow: 1px 1px 0px #000;">
              <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />₫
            </div>

            <c:choose>
              <c:when test="${isOwned}">
                <a href="${pageContext.request.contextPath}/library" class="btn w-100 gf-border gf-shadow gf-press fw-black fw-bold fs-5 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2 mb-3" style="background:#e9ecef; color:#6c757d; border: 3px solid #000; cursor: pointer; text-decoration: none;">
                  <i data-lucide="library" width="20" height="20"></i> ĐÃ SỞ HỮU / CHỜ CẤP KEY
                </a>
              </c:when>
              <c:otherwise>
                <button type="button" onclick="quickAddToCart(event, '${game.id}')" class="btn w-100 gf-border gf-shadow gf-press fw-black fw-bold fs-5 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2 mb-3 cart-button" style="background:var(--gf-green); color:#000;" data-game-id="${game.id}">
                  <i data-lucide="shopping-cart" width="20" height="20"></i> THÊM VÀO GIỎ HÀNG
                </button>
              </c:otherwise>
            </c:choose>

            <button type="button" onclick="toggleFavorite(event, '${game.id}')" class="btn w-100 gf-border gf-shadow-sm gf-press fw-black fw-bold py-2.5 rounded-3 d-flex align-items-center justify-content-center gap-2 bg-white text-dark favorite-button mb-3" data-game-id="${game.id}">
              <i data-lucide="heart" width="18" height="18" style="color:var(--gf-pink);"></i> YÊU THÍCH
            </button>

            <button type="button" class="btn w-100 gf-border gf-shadow-sm gf-press fw-black fw-bold py-2.5 rounded-3 d-flex align-items-center justify-content-center gap-2 text-dark" 
                    style="background:var(--gf-lavender); color:#000;" data-bs-toggle="modal" data-bs-target="#gfGamePatchNotesModal">
              <i data-lucide="scroll" width="18" height="18"></i> LỊCH SỬ BẢN VÁ (${fn:length(patchNotes)})
            </button>
          </div>

        </div>
      </div>
    </div>
  </main>

  <!-- Modal Lịch Sử Bản Vá (Patch Notes) -->
  <div class="modal fade" id="gfGamePatchNotesModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
      <div class="modal-content bg-white border border-3 border-dark gf-shadow" style="border-radius: 16px;">
        <div class="modal-header bg-warning border-bottom border-3 border-dark py-3" style="border-radius: 13px 13px 0 0;">
          <h5 class="modal-title fw-black text-dark d-flex align-items-center">
            <i data-lucide="scroll" class="me-2" width="22" height="22"></i> 
            LỊCH SỬ BẢN VÁ & CẬP NHẬT
          </h5>
          <button type="button" class="btn-close modal-close-brutal" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body p-4" style="max-height: 60vh; overflow-y: auto;">
          <c:choose>
            <c:when test="${not empty patchNotes}">
              <div class="d-flex flex-column gap-4">
                <c:forEach var="note" items="${patchNotes}" varStatus="status">
                  <div class="p-3 bg-light border border-2 border-dark rounded-3 position-relative" style="box-shadow: 3px 3px 0px #000;">
                    <div class="d-flex align-items-center justify-content-between mb-2 pb-2 border-bottom border-1 border-dark flex-wrap gap-2">
                      <span class="badge border border-2 border-black text-dark fw-bold px-3 py-1.5" style="background:var(--gf-yellow); border-radius: 8px; font-size: 13px;">
                        Phiên bản ${note.version}
                      </span>
                      <span class="small fw-bold text-secondary gf-muted">
                        Ngày cập nhật: <fmt:parseDate value="${note.publishedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedNoteDate" type="both" /><fmt:formatDate value="${parsedNoteDate}" pattern="dd/MM/yyyy HH:mm" />
                      </span>
                    </div>
                    <div class="fw-semibold text-secondary description-text" style="white-space: pre-wrap; font-size: 14px; color: #333 !important;">
                      ${fn:escapeXml(note.content)}
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="text-center py-5 text-muted">
                <div class="mx-auto mb-3 gf-border rounded-circle d-grid place-items-center bg-light" style="width:64px;height:64px;">
                  <i data-lucide="scroll" width="30" height="30" class="text-secondary"></i>
                </div>
                <h5 class="fw-black fw-bold mb-1 text-dark">Chưa có thông tin cập nhật</h5>
                <p class="small text-secondary gf-muted mb-0">Trò chơi hiện chưa có bản vá hoặc ghi chú cập nhật nào được công bố.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
        <div class="modal-footer border-top border-3 border-dark bg-light py-2" style="border-radius: 0 0 13px 13px;">
          <button type="button" class="btn btn-sm btn-dark gf-border gf-shadow-sm gf-press fw-bold px-3 py-2" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Lightbox Modal Phóng To Sáng Tạo Mở Rộng & Nút Tắt Lơ Lửng -->
  <div class="modal fade" id="gfGlobalImageLightbox" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl" style="max-width: 98vw; width: 98vw; margin: 1vw auto;">
      <div class="modal-content bg-white border border-3 border-dark gf-shadow position-relative">
        
        <!-- NÚT TẮT X LƠ LỬNG GÓC PHẢI -->
        <button type="button" class="lightbox-close-btn" data-bs-dismiss="modal" aria-label="Close">
          <i data-lucide="x" class="text-black" width="22" height="22"></i>
        </button>

        <div class="modal-header bg-light border-bottom border-3 border-dark py-2">
          <h5 class="modal-title fw-black text-dark d-flex align-items-center">
            <i data-lucide="maximize-2" class="me-2" width="18" height="18"></i> 
            CHI TIẾT ẢNH CHỤP 
            <span id="lightboxImageIndexBadge" class="badge text-black ms-2 border border-2 border-dark" style="background:var(--gf-pink); font-size:10px; box-shadow:1.5px 1.5px 0 #000;">1 / 5</span>
          </h5>
          <div class="d-flex align-items-center gap-2 ms-auto" style="margin-right: 70px;">
            <a id="lightboxDownloadBtn" href="" download class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold py-1 px-2.5 small d-flex align-items-center gap-1 text-decoration-none">
              <i data-lucide="download" width="12" height="12"></i> Tải ảnh
            </a>
          </div>
        </div>
        
        <div class="modal-body text-center p-0 bg-dark position-relative d-flex align-items-center justify-content-center" style="overflow: hidden; min-height: 72vh; padding: 0 !important;">
          <!-- Nền mờ sinh động loại bỏ viền đen đơn điệu -->
          <div id="gfLightboxBlurBg" class="lightbox-blur-bg"></div>

          <!-- Mũi tên điều hướng -->
          <button type="button" onclick="lightboxPrevSlide(event)" class="lightbox-arrow lightbox-arrow-left" aria-label="Ảnh trước">
            <i data-lucide="chevron-left" class="text-black" width="24" height="24"></i>
          </button>
          <button type="button" onclick="lightboxNextSlide(event)" class="lightbox-arrow lightbox-arrow-right" aria-label="Ảnh sau">
            <i data-lucide="chevron-right" class="text-black" width="24" height="24"></i>
          </button>

          <div class="lightbox-zoom-container" id="gfLightboxZoomContainer">
            <!-- Thẻ ảnh tự động phóng to tối ưu, viền đen dày wraps sát ảnh -->
            <img id="gfLightboxTargetImage" src="" class="img-fluid rounded-1 position-relative" style="z-index: 2;">
            
            <!-- Kính lúp dạng ô vuông Neo-Brutalism y cũ -->
            <div id="gfLightboxLens" class="gf-magnifying-lens"></div>
          </div>
        </div>
        <!-- Vùng thu nhỏ danh sách ảnh bên dưới -->
        <div class="lightbox-thumbs-container" id="gfLightboxThumbsContainer">
        </div>
      </div>
    </div>
  </div>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Hệ thống Cửa hàng tự động hóa hoàn chỉnh bởi Kiệt.
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  
  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_CURRENT_USER_ID = '${not empty sessionScope.currentUser ? sessionScope.currentUser.id : "null"}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>

  <script>
    lucide.createIcons();

    let lightboxModalInstance = null;

    // GIẢI QUYẾT BẢO VỆ CONTEXT PATH VÀ CDN STEAM TRONG JS
    const screenshotUrls = [];
    <c:forEach var="media" items="${game.mediaList}">
        <c:if test="${media.mediaType == 'IMAGE'}">
            (function() {
                const mediaUrl = '${media.mediaUrl}';
                const isAbsolute = mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://') || mediaUrl.startsWith('//');
                screenshotUrls.push(isAbsolute ? mediaUrl : '${pageContext.request.contextPath}' + mediaUrl);
            })();
        </c:if>
    </c:forEach>

    let currentSlideIndex = 0;
    let slideshowInterval = null;
    let currentLightboxIndex = 0;

    // Auto-cycling slideshow timer logic
    function startSlideshow() {
        if (screenshotUrls.length <= 1) return;
        
        slideshowInterval = setInterval(() => {
            currentSlideIndex = (currentSlideIndex + 1) % screenshotUrls.length;
            const nextUrl = screenshotUrls[currentSlideIndex];
            
            // Smooth fade update
            const mainBanner = document.getElementById('gfMainProductBanner');
            if (mainBanner) {
                mainBanner.style.opacity = '0';
                setTimeout(() => {
                    mainBanner.src = nextUrl;
                    mainBanner.style.opacity = '1';
                }, 120);
            }
            
            // Update the active state of thumbnail list on the left to match the slideshow
            document.querySelectorAll('.gf-gallery-thumb').forEach(thumb => {
                const thumbSrc = thumb.getAttribute('src');
                thumb.classList.toggle('active', thumbSrc && thumbSrc.endsWith(nextUrl));
            });
        }, 5000); 
    }

    // Reset slideshow timer when user manually interacts
    function resetSlideshowTimer(imgSrc) {
        if (screenshotUrls.length <= 1) return;
        const index = screenshotUrls.findIndex(url => imgSrc.endsWith(url) || url.endsWith(imgSrc));
        if (index !== -1) {
            currentSlideIndex = index;
        }
        if (slideshowInterval) {
            clearInterval(slideshowInterval);
            startSlideshow();
        }
    }

    // Chuyển đổi banner
    function changeMainProductView(imgSrc, element) {
        const mainBanner = document.getElementById('gfMainProductBanner');
        if (mainBanner) {
            mainBanner.style.opacity = '0';
            setTimeout(() => {
                mainBanner.src = imgSrc;
                mainBanner.style.opacity = '1';
            }, 120);
        }
        document.querySelectorAll('.gf-gallery-thumb').forEach(thumb => {
            thumb.classList.remove('active');
        });
        if(element) element.classList.add('active');
    }

    // Nhấp ảnh nhỏ: Chuyển banner + Phóng to ảnh tương ứng
    function triggerDoubleAction(imgSrc, element) {
        changeMainProductView(imgSrc, element);
        resetSlideshowTimer(imgSrc);

        const index = screenshotUrls.indexOf(imgSrc);
        openLightboxAt(index !== -1 ? index : 0);
    }

    // Click banner chính
    function openLightboxFromBanner() {
        const mainBanner = document.getElementById('gfMainProductBanner');
        if (mainBanner) {
            const index = screenshotUrls.findIndex(url => mainBanner.src.endsWith(url) || url.endsWith(mainBanner.src));
            openLightboxAt(index !== -1 ? index : 0);
        }
    }

    // Nạp chi tiết ảnh chụp màn hình trong Lightbox Modal
    function openLightboxAt(index) {
        if (screenshotUrls.length === 0) return;
        currentLightboxIndex = (index + screenshotUrls.length) % screenshotUrls.length;
        
        const imgSrc = screenshotUrls[currentLightboxIndex];
        const lightboxImg = document.getElementById('gfLightboxTargetImage');
        const blurBg = document.getElementById('gfLightboxBlurBg');
        const idxBadge = document.getElementById('lightboxImageIndexBadge');
        const downloadBtn = document.getElementById('lightboxDownloadBtn');
        const lens = document.getElementById('gfLightboxLens');

        if (lightboxImg) lightboxImg.src = imgSrc;
        if (blurBg) blurBg.style.backgroundImage = "url('" + imgSrc + "')";
        if (idxBadge) idxBadge.innerText = (currentLightboxIndex + 1) + " / " + screenshotUrls.length;
        if (downloadBtn) {
            downloadBtn.href = imgSrc;
            downloadBtn.setAttribute('download', 'screenshot_' + (currentLightboxIndex + 1) + '.jpg');
        }
        
        if (lens) lens.style.display = 'none';

        // Đồng bộ class active cho hàng thumbnail trong lightbox
        document.querySelectorAll('.lightbox-thumb-item').forEach((thumb, idx) => {
            thumb.classList.toggle('active', idx === currentLightboxIndex);
        });

        if (!lightboxModalInstance) {
            lightboxModalInstance = new bootstrap.Modal(document.getElementById('gfGlobalImageLightbox'));
        }
        
        lightboxModalInstance.show();
    }

    function lightboxPrevSlide(e) {
        if(e) { e.preventDefault(); e.stopPropagation(); }
        openLightboxAt(currentLightboxIndex - 1);
    }

    function lightboxNextSlide(e) {
        if(e) { e.preventDefault(); e.stopPropagation(); }
        openLightboxAt(currentLightboxIndex + 1);
    }

    function buildLightboxThumbnails() {
        const thumbRow = document.getElementById('gfLightboxThumbsContainer');
        if (!thumbRow || screenshotUrls.length <= 1) {
            if (thumbRow) thumbRow.style.display = 'none';
            return;
        }
        thumbRow.innerHTML = screenshotUrls.map((url, idx) => {
            return '<img src="' + url + '" class="lightbox-thumb-item" onclick="openLightboxAt(' + idx + ')" alt="Thumb">';
        }).join('');
    }

    // Khởi tạo cơ chế Phóng To Kính Lúp dạng ô vuông di động y cũ
    function initLightboxLensZoom() {
        const container = document.getElementById('gfLightboxZoomContainer');
        const img = document.getElementById('gfLightboxTargetImage');
        const lens = document.getElementById('gfLightboxLens');
        if (!container || !img || !lens) return;

        container.addEventListener('mousemove', function(e) {
            const rect = img.getBoundingClientRect();
            const containerRect = container.getBoundingClientRect();
            
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            if (x >= 0 && x <= rect.width && y >= 0 && y <= rect.height) {
                lens.style.display = 'block';
                lens.style.backgroundImage = "url('" + img.src + "')";
                
                const zoom = 2.5; 
                lens.style.backgroundSize = (rect.width * zoom) + "px " + (rect.height * zoom) + "px";
                
                const lensWidth = lens.offsetWidth;
                const lensHeight = lens.offsetHeight;
                const posX = x * zoom - lensWidth / 2;
                const posY = y * zoom - lensHeight / 2;
                
                lens.style.backgroundPosition = "-" + posX + "px -" + posY + "px";
                
                const lensX = e.clientX - containerRect.left - lensWidth / 2;
                const lensY = e.clientY - containerRect.top - lensHeight / 2;
                lens.style.left = lensX + "px";
                lens.style.top = lensY + "px";
            } else {
                lens.style.display = 'none';
            }
        });

        container.addEventListener('mouseleave', function() {
            lens.style.display = 'none';
        });
    }

    // ĐỌC CẤU HÌNH JSON VỚI CHỮ SẴN CÓ ĐẦY ĐỦ CHO TẤT CẢ CÁC GAME
    function renderSystemSpecifications() {
        const rawMinJson = document.getElementById('rawMinRequirementsData').innerText;
        const rawRecJson = document.getElementById('rawRecRequirementsData').innerText;
        
        const minContainer = document.getElementById('minSpecsContainer');
        const recContainer = document.getElementById('recSpecsContainer');

        const labelMap = {
            os: "Hệ điều hành (OS)",
            cpu: "Bộ vi xử lý (CPU)",
            ram: "Bộ nhớ RAM",
            gpu: "Card đồ họa (GPU)",
            dx: "Phiên bản DirectX",
            storage: "Lưu trữ (Storage)"
        };

        // CẤU HÌNH THỜI THƯỢNG MẶC ĐỊNH NẾU DỮ LIỆU CỦA GAME TRỐNG
        const defaultMinSpecs = {
            os: "Windows 10 (64-bit)",
            cpu: "Intel Core i5-4460 / AMD FX-6300",
            ram: "8 GB RAM",
            gpu: "NVIDIA GeForce GTX 960 / AMD Radeon R9 280",
            dx: "DirectX 11",
            storage: "5 GB dung lượng khả dụng (Khuyến khích SSD)"
        };
        const defaultRecSpecs = {
            os: "Windows 10/11 (64-bit)",
            cpu: "Intel Core i7-4770 / AMD Ryzen 5 1600",
            ram: "16 GB RAM",
            gpu: "NVIDIA GeForce GTX 1060 / AMD Radeon RX 580",
            dx: "DirectX 12",
            storage: "5 GB dung lượng khả dụng (Khuyến khích SSD)"
        };

        function buildHtml(rawJson, defaultData, isRecommended) {
            try {
                let data = defaultData;
                let parsed = false;
                if (rawJson && rawJson.trim() !== "" && rawJson.trim() !== "false" && rawJson.trim().startsWith('{')) {
                    data = JSON.parse(rawJson);
                    parsed = true;
                }
                
                let htmlResult = "";
                for (const key in labelMap) {
                    if (data[key]) {
                        htmlResult += '<li><strong class="text-secondary">' + labelMap[key] + ':</strong> ' + data[key] + '</li>';
                    }
                }

                if (parsed && data.notes && data.notes.trim() !== "") {
                    htmlResult += '<li><strong class="text-secondary">Ghi chú bổ sung:</strong> ' + data.notes + '</li>';
                }

                if (isRecommended) {
                    htmlResult += '<li class="mt-2" style="color:var(--gf-green); font-size:12px;"><strong style="color:var(--gf-green);">Ghi chú thêm:</strong> Nhắm tới hiệu năng 1080p/60fps ở mức cài đặt High Graphics.</li>';
                } else {
                    htmlResult += '<li class="mt-2 text-muted" style="font-size:12px;"><strong class="text-muted">Ghi chú thêm:</strong> Nhắm tới hiệu năng 1080p/30fps ở mức cài đặt Low Graphics.</li>';
                }

                return htmlResult;
            } catch (e) {
                // Fallback cứu hộ
                let htmlResult = "";
                for (const key in labelMap) {
                    if (defaultData[key]) {
                        htmlResult += '<li><strong class="text-secondary">' + labelMap[key] + ':</strong> ' + defaultData[key] + '</li>';
                    }
                }
                if (isRecommended) {
                    htmlResult += '<li class="mt-2" style="color:var(--gf-green); font-size:12px;"><strong style="color:var(--gf-green);">Ghi chú thêm:</strong> Nhắm tới hiệu năng 1080p/60fps ở mức cài đặt High Graphics.</li>';
                } else {
                    htmlResult += '<li class="mt-2 text-muted" style="font-size:12px;"><strong class="text-muted">Ghi chú thêm:</strong> Nhắm tới hiệu năng 1080p/30fps ở mức cài đặt Low Graphics.</li>';
                }
                return htmlResult;
            }
        }

        minContainer.innerHTML = buildHtml(rawMinJson, defaultMinSpecs, false);
        recContainer.innerHTML = buildHtml(rawRecJson, defaultRecSpecs, true);
    }

    // COMMUNITY REVIEWS JAVASCRIPT LOGIC

    function toggleReplyForm(reviewId) {
        const replyForm = document.getElementById('replyForm_' + reviewId);
        if (replyForm) {
            replyForm.style.display = (replyForm.style.display === 'none') ? 'block' : 'none';
        }
    }

    // ADMIN JAVASCRIPT LOGIC (Badge management has been moved entirely to Admin central panel)

    document.addEventListener("DOMContentLoaded", function() {
        renderSystemSpecifications();
        initLightboxLensZoom();
        buildLightboxThumbnails();
        startSlideshow();

        // Keyboard navigation for screenshot modal
        document.addEventListener('keydown', function(e) {
            const modalEl = document.getElementById('gfGlobalImageLightbox');
            if (modalEl && modalEl.classList.contains('show')) {
                if (e.key === 'ArrowLeft') {
                    lightboxPrevSlide();
                } else if (e.key === 'ArrowRight') {
                    lightboxNextSlide();
                }
            }
        });
    });
  </script>
</body>
</html>