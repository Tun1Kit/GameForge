<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Danh sách Yêu thích của tôi</title>
  
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <script>
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_CURRENT_USER_ID = '${not empty currentUser.id ? currentUser.id : "null"}';
  </script>

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
    .wish-card {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 6px 6px 0px #000;
      border-radius: 16px;
      overflow: hidden;
      transition: transform 0.15s ease, box-shadow 0.15s ease;
    }
    .wish-card:hover {
      transform: translate(-3px, -3px);
      box-shadow: 9px 9px 0px #000;
    }
    .wish-img-wrapper {
      position: relative;
      border-bottom: 3px solid #000;
      height: 180px;
      overflow: hidden;
    }
    .wish-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.3s ease;
    }
    .wish-card:hover .wish-img {
      transform: scale(1.05);
    }
  </style>
</head>

<body>

  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold d-none d-sm-inline">GAME<span style="color:var(--gf-green)">FORGE</span></span>
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

          <div class="dropdown">
            <button class="btn dropdown-toggle gf-press d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown"
                    style="background:#fff;border:3px solid #000;border-radius:999px;height:44px;padding:4px 16px 4px 6px;box-shadow:3px 3px 0 0 #000;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Kiet'}" alt="Avatar" style="width:30px;height:30px;border-radius:50%;object-fit:cover;border:2px solid #000;">
              <span class="d-none d-sm-inline fw-black text-dark" style="font-size:13px;">${fn:escapeXml(currentUser.fullName)}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:180px;">
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/orders"><i data-lucide="shopping-bag" width="14" height="14"></i> Đơn hàng</a></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/library"><i data-lucide="library" width="14" height="14"></i> Thư viện</a></li>
              <c:if test="${currentUser.hasRole('ROLE_PUBLISHER')}">
                <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/publisher/dashboard"><i data-lucide="layout-dashboard" width="14" height="14"></i> Publisher</a></li>
              </c:if>
              <c:if test="${currentUser.hasRole('ROLE_ADMIN')}">
                <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/admin/dashboard"><i data-lucide="shield-check" width="14" height="14"></i> Quản trị</a></li>
              </c:if>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2 text-danger" href="${pageContext.request.contextPath}/logout"><i data-lucide="log-out" width="14" height="14"></i> Đăng xuất</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <main class="container-xl py-5" style="min-height: 80vh;">
    
    <div class="mb-5">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-pink);box-shadow:3px 3px 0 #000;">
        <i data-lucide="heart" width="16" height="16"></i> Yêu Thích Của Tôi
      </div>
      <h1 class="fw-black fw-bold mb-2 display-5 text-dark">
        DANH SÁCH GAME <span style="color:var(--gf-pink);text-shadow:2px 2px 0 #000;">YÊU THÍCH</span>
      </h1>
      <p class="fs-5 fw-semibold text-secondary gf-muted">Quản lý và mua nhanh các tựa game bạn đã lưu giữ.</p>
    </div>

    <c:choose>
      <c:when test="${not empty wishlistItems}">
        <div class="row g-4">
          <c:forEach var="item" items="${wishlistItems}">
            <c:set var="game" value="${item.game}" />
            <div class="col-12 col-sm-6 col-md-4 col-lg-3" id="wish-item-${game.id}">
              <div class="wish-card h-100 d-flex flex-column">
                
                <a href="${pageContext.request.contextPath}/game/${game.slug}" class="text-decoration-none text-reset">
                  <div class="wish-img-wrapper">
                    <c:set var="gameImg" value="" />
                    <c:forEach var="media" items="${game.mediaList}">
                      <c:if test="${empty gameImg && media.mediaType == 'IMAGE'}">
                        <c:set var="gameImg" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                      </c:if>
                    </c:forEach>
                    <c:choose>
                      <c:when test="${not empty gameImg}">
                        <img src="${gameImg}" class="wish-img" alt="${game.title}">
                      </c:when>
                      <c:otherwise>
                        <div class="w-100 h-100 bg-light d-flex align-items-center justify-content-center">
                          <i data-lucide="image" class="text-muted" width="48" height="48"></i>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </a>

                <div class="p-3 d-flex flex-column flex-grow-1 justify-content-between">
                  <div>
                    <h3 class="fs-6 fw-black fw-bold mb-1 text-truncate">
                      <a href="${pageContext.request.contextPath}/game/${game.slug}" class="text-decoration-none text-dark hover-underline">
                        ${game.title}
                      </a>
                    </h3>
                    <p class="small text-secondary fw-bold gf-muted mb-2">
                      Nhà phát triển: ${not empty game.developer ? game.developer : 'Đang cập nhật'}
                    </p>
                  </div>

                  <div class="mt-3">
                    <div class="fs-5 fw-black text-success mb-3" style="text-shadow: 1px 1px 0px #000;">
                      <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />₫
                    </div>

                    <div class="d-flex gap-2">
                      <button type="button" onclick="quickAddToCart(event, '${game.id}')" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-black fw-bold flex-grow-1 py-2 cart-button" style="background:var(--gf-green); color:#000;" data-game-id="${game.id}">
                        <i data-lucide="shopping-cart" class="d-inline mb-0.5 me-1" width="14" height="14"></i> THÊM
                      </button>
                      <button type="button" onclick="removeWishlistItem(event, '${game.id}')" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-danger py-2 px-3 fw-bold" title="Xóa khỏi yêu thích">
                        <i data-lucide="trash-2" width="15" height="15"></i>
                      </button>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="text-center py-5 bg-white gf-border gf-shadow rounded-4 max-w-md mx-auto p-4">
          <div class="gf-border-2 rounded-4 d-grid mx-auto mb-4 place-items-center" style="width:72px;height:72px;background:var(--gf-pink);box-shadow:3px 3px 0 #000;">
            <i data-lucide="heart-off" width="32" height="32" class="text-white"></i>
          </div>
          <h2 class="fw-black fw-bold text-dark mb-2 fs-4">Danh sách yêu thích trống</h2>
          <p class="small text-secondary fw-semibold gf-muted mb-4 max-w-sm mx-auto">Bạn chưa thêm trò chơi nào vào danh sách yêu thích của mình. Hãy dạo quanh cửa hàng để tìm những game cực hot!</p>
          <a href="${pageContext.request.contextPath}/" class="btn gf-border gf-shadow gf-press fw-black fw-bold px-4 py-2.5 rounded-3" style="background:var(--gf-green); color:#000;">
            <i data-lucide="shopping-bag" class="d-inline mb-0.5 me-1" width="16" height="16"></i> KHÁM PHÁ CỬA HÀNG
          </a>
        </div>
      </c:when>
    </c:choose>

  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Hệ thống Cửa hàng tự động hóa hoàn chỉnh bởi Kiệt.
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>

  <script>
    lucide.createIcons();

    // Custom function to remove item dynamically from wishlist view
    function removeWishlistItem(event, gameId) {
      if (confirm("Bạn có chắc chắn muốn xóa game này khỏi danh sách yêu thích?")) {
        toggleFavorite(event, gameId);
        
        // Dynamic fadeout and remove of card element
        const element = document.getElementById("wish-item-" + gameId);
        if (element) {
          element.style.transition = "all 0.3s ease";
          element.style.transform = "scale(0.8)";
          element.style.opacity = "0";
          setTimeout(() => {
            element.remove();
            
            // If wishlist has become empty, refresh page to show empty state container
            const remaining = document.querySelectorAll("[id^='wish-item-']");
            if (remaining.length === 0) {
              window.location.reload();
            }
          }, 300);
        }
      }
    }
  </script>
</body>
</html>