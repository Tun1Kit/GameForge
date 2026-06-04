<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
      <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <%@ page import="com.gamestore.entity.User" %>
          <%
            Long currentUserId = null;
            Object cu = request.getSession().getAttribute("currentUser");
            if (cu instanceof User) {
                currentUserId = ((User) cu).getId();
            }
          %>
            <c:set var="ownedStr" value="," />
            <c:if test="${not empty ownedGameIds}">
              <c:forEach var="oid" items="${ownedGameIds}">
                <c:set var="ownedStr" value="${ownedStr}${oid}," />
              </c:forEach>
            </c:if>
            <script>
              window.GAMEFORGE_CURRENT_USER_ID = <%= currentUserId != null ? currentUserId : "null" %>;
            </script>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>GameForge - Bootstrap 5 Game Store</title>

              <!-- CSRF Meta Tags (Spring Security) -->
              <meta name="_csrf" content="${_csrf.token}" />
              <meta name="_csrf_header" content="${_csrf.headerName}" />

              <script>
                window.GAMEFORGE_CURRENT_USER_ID = <%= currentUserId != null ? currentUserId : "null" %>;
                window.GAMEFORGE_CSRF_TOKEN = (function () {
                  var m = document.querySelector('meta[name="_csrf"]');
                  return m ? m.content : '';
                })();
                window.GAMEFORGE_CSRF_HEADER = (function () {
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
                  } catch (e) { }
                })();
              </script>



              <!-- Bootstrap 5 + Lucide -->
              <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
              <script src="https://unpkg.com/lucide@latest"></script>
              <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
            </head>

            <body>
              <c:if test="${not empty param.error}">
                <div class="container-xl mt-3">
                  <div class="alert alert-danger d-flex align-items-center gap-2 fw-bold" role="alert">
                    <i data-lucide="alert-circle" width="18" height="18"></i>
                    <c:choose>
                      <c:when test="${param.error == 'empty_cart'}">Giỏ hàng trống!</c:when>
                      <c:when test="${param.error == 'invalid_order'}">Đơn hàng không hợp lệ.</c:when>
                      <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại.</c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </c:if>

              <!-- NAVBAR -->
              <nav class="gf-navbar">
                <div class="container-xl py-3">
                  <div class="d-flex align-items-center justify-content-between gap-3">
                    <a href="${pageContext.request.contextPath}/"
                      class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
                      <div class="gf-logo-box gf-press">
                        <i data-lucide="gamepad-2" width="20" height="20"></i>
                      </div>
                      <span class="fs-5 fw-black fw-bold d-none d-sm-inline text-dark">GAME<span
                          style="color:var(--gf-green)">FORGE</span></span>
                    </a>

                    <div class="d-none d-lg-flex align-items-center gap-2">
                      <a href="#store" class="gf-nav-link">Cửa Hàng</a>
                      <a href="#sale-games" class="gf-nav-link">Khuyến Mãi</a>
                      <a href="#community" class="gf-nav-link">Cộng Đồng</a>
                      <a href="#support" class="gf-nav-link">Hỗ Trợ</a>
                    </div>

                    <div class="d-flex align-items-center gap-2 gap-sm-3">
                      <div
                        class="d-none d-md-flex align-items-center bg-white border border-2 border-black rounded-3 px-3 py-2 gf-shadow-sm">
                        <i data-lucide="search" width="16" height="16" class="text-secondary"></i>
                        <input id="searchInput" type="text" placeholder="Tìm game..."
                          class="border-0 bg-transparent ms-2 fw-semibold small" style="outline:none;width:170px;">
                      </div>

                      <button id="favoriteTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-pink)"
                        type="button" title="Game yêu thích">
                        <i data-lucide="heart" width="20" height="20"></i>
                        <span id="favoriteCount" class="gf-count-badge text-white" style="background:#f87171;">0</span>
                      </button>

                      <button id="cartTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-blue)"
                        type="button" title="Giỏ hàng">
                        <i data-lucide="shopping-cart" width="20" height="20"></i>
                        <span id="cartCount" class="gf-count-badge text-black"
                          style="background:var(--gf-yellow);">0</span>
                      </button>

                      <c:choose>
                        <c:when test="${not empty currentUser}">
                          <div class="dropdown">
                            <button class="btn dropdown-toggle d-flex align-items-center gap-2 gf-press"
                              data-bs-toggle="dropdown" type="button"
                              style="background: #18181b; border: 3px solid #000; border-radius: 999px; height: 42px; padding: 4px 16px 4px 6px; color: #fff; box-shadow: 3px 3px 0 0 #000;">
                              <img
                                src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Vinh'}"
                                alt="Avatar"
                                style="width: 30px; height: 30px; border-radius: 50%; object-fit: cover; border: 2px solid #fff;">
                              <span class="d-none d-sm-inline fw-black text-white"
                                style="font-size:13px; max-width: 100px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${fn:escapeXml(currentUser.fullName)}</span>
                              <i data-lucide="chevron-down" width="16" height="16" class="text-white"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2"
                              style="border-radius: 12px; min-width: 210px;">
                              <c:if test="${currentUser.hasRole('ROLE_ADMIN')}">
                                <li>
                                  <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2"
                                    href="${pageContext.request.contextPath}/admin/dashboard">
                                    <i data-lucide="shield-check" width="16" height="16"></i> Quản Trị Viên
                                  </a>
                                </li>
                              </c:if>
                              <c:if test="${currentUser.hasRole('ROLE_PUBLISHER')}">
                                <li>
                                  <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2"
                                    href="${pageContext.request.contextPath}/publisher/dashboard">
                                    <i data-lucide="layout-dashboard" width="16" height="16"></i> Nhà Phát Hành
                                  </a>
                                </li>
                              </c:if>
                              <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2"
                                  href="${pageContext.request.contextPath}/library">
                                  <i data-lucide="library" width="16" height="16"></i> Thư viện game
                                </a>
                              </li>
                              <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2"
                                  href="${pageContext.request.contextPath}/transactions">
                                  <i data-lucide="history" width="16" height="16"></i> Lịch sử giao dịch
                                </a>
                              </li>
                              <li class="dropdown-divider my-2" style="border-top: 2px solid #000;"></li>
                              <li>
                                <div
                                  class="px-3 py-1.5 d-flex align-items-center justify-content-between gap-2 bg-light rounded-3 gf-border">
                                  <span class="small fw-black text-secondary" style="font-size: 11px;">Số dư ví:</span>
                                  <span class="fw-black text-success" id="headerWalletBalance"
                                    style="font-size: 14px; font-weight: 900 !important;">
                                    <c:choose>
                                      <c:when test="${not empty walletBalance}">
                                        <fmt:formatNumber value="${walletBalance}" type="number"
                                          maxFractionDigits="0" />đ
                                      </c:when>
                                      <c:otherwise>0đ</c:otherwise>
                                    </c:choose>
                                  </span>
                                </div>
                              </li>
                              <li class="px-2 mt-2">
                                <a class="btn btn-sm w-100 gf-border gf-shadow-sm gf-press fw-bold text-dark py-1.5"
                                  href="${pageContext.request.contextPath}/recharge"
                                  style="background:var(--gf-yellow); border-radius: 8px; font-size: 13px; display: inline-flex; align-items: center; justify-content: center; gap: 4px;">
                                  <i data-lucide="wallet" width="14" height="14"></i> Nạp tiền
                                </a>
                              </li>
                              <li class="dropdown-divider my-2" style="border-top: 2px solid #000;"></li>
                              <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2 text-danger"
                                  href="${pageContext.request.contextPath}/logout"
                                  onclick="localStorage.removeItem('gameforge_favorite_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_games_bootstrap_jsp');localStorage.removeItem('gameforge_cart_user_id');">
                                  <i data-lucide="log-out" width="16" height="16"></i> Đăng xuất
                                </a>
                              </li>
                            </ul>
                          </div>
                        </c:when>
                        <c:otherwise>
                          <a href="${pageContext.request.contextPath}/login" class="gf-icon-btn gf-press"
                            style="background:#C084FC" title="Đăng nhập">
                            <i data-lucide="circle-user" width="20" height="20"></i>
                          </a>
                        </c:otherwise>
                      </c:choose>

                      <button id="themeButton"
                        class="btn gf-border-2 gf-shadow-sm gf-press bg-dark text-white fw-bold rounded-3 d-flex align-items-center gap-2"
                        type="button">
                        <span id="icon-light"><i data-lucide="sun" width="16" height="16"></i></span>
                        <span id="icon-dark" class="d-none"><i data-lucide="moon" width="16" height="16"
                            style="color:#fde047"></i></span>
                        <span id="theme-text" class="d-none d-sm-inline">Light</span>
                      </button>
                    </div>
                  </div>
                </div>
              </nav>

              <!-- PROMO BAR -->
              <div class="gf-promo-bar">
                <div class="gf-marquee-track">
                  <span>🔥 Flash Sale - Giảm đến 80%</span><span>•</span>
                  <span>🎮 Game hot trượt từng game mượt</span><span>•</span>
                  <span>💎 Sale giữ grid cũ, hiệu ứng không nhấp nháy</span><span>•</span>
                  <span>🏆 Bootstrap 5 Neo Brutalism Store</span><span>•</span>
                  <span>🔥 Flash Sale - Giảm đến 80%</span><span>•</span>
                  <span>🎮 Game hot trượt từng game mượt</span><span>•</span>
                  <span>💎 Sale giữ grid cũ, hiệu ứng không nhấp nháy</span><span>•</span>
                  <span>🏆 Bootstrap 5 Neo Brutalism Store</span><span>•</span>
                </div>
              </div>

              <c:choose>
                <c:when test="${not empty currentUser}">
                  <!-- LOGGED IN USER HERO/DASHBOARD (Image 1) -->
                  <section id="store" class="gf-hero">
                    <div class="container-xl">
                      <div class="row align-items-start g-5">

                        <!-- PHẦN CHÀO MỪNG BÊN TRÁI -->
                        <div class="col-lg-6">
                          <div
                            class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-4"
                            style="background: #94FFB4; box-shadow: 3px 3px 0 #000; transform: rotate(-1deg);">
                            ✨ Thành viên từ
                            <fmt:parseDate value="${currentUser.createdAt}" pattern="yyyy-MM-dd'T'HH:mm"
                              var="parsedDate" type="both" />
                            <fmt:formatDate value="${parsedDate}" pattern="MM/yyyy" />
                          </div>

                          <h1 class="fw-black fw-bold mb-4"
                            style="font-size: clamp(2.5rem, 6vw, 3.8rem); line-height: 1.1; letter-spacing: -0.03em;">
                            Chào mừng trở lại, <br>
                            <span class="text-success"
                              style="text-shadow: 2px 2px 0 #000;">${fn:escapeXml(currentUser.fullName)}!</span>
                          </h1>

                          <p class="fs-5 fw-semibold text-secondary gf-muted mb-5"
                            style="max-width: 460px; line-height: 1.6;">
                            Tiếp tục mua sắm, khám phá ưu đãi mới và quản lý thư viện game của bạn.
                          </p>

                          <div class="d-flex flex-column flex-sm-row gap-3">
                            <a href="#sale-games"
                              class="btn gf-border gf-shadow gf-press fw-bold fs-5 px-4 py-3 rounded-3 d-inline-flex align-items-center justify-content-center gap-2"
                              style="background: var(--gf-green);">
                              <i data-lucide="shopping-cart" width="20" height="20"></i> Tiếp tục mua sắm &rarr;
                            </a>
                            <a href="${pageContext.request.contextPath}/library"
                              class="btn gf-border gf-shadow gf-press fw-bold fs-5 px-4 py-3 rounded-3 d-inline-flex align-items-center justify-content-center gap-2"
                              style="background: var(--gf-blue);">
                              <i data-lucide="gamepad-2" width="20" height="20"></i> Vào thư viện game
                            </a>
                          </div>
                        </div>

                        <!-- HERO GRID (2x2 featured games) -->
                        <div class="col-lg-6">
                          <div class="row row-cols-2 g-4">
                            <c:forEach var="game" items="${games}" varStatus="status">
                              <c:if test="${status.index lt 4}">
                                <c:set var="isSoftware" value="false" />
                                <c:set var="primaryCategory" value="Game" />
                                <c:forEach var="cat" items="${game.categories}" varStatus="catStatus">
                                  <c:if test="${catStatus.first}">
                                    <c:set var="primaryCategory" value="${cat.name}" />
                                  </c:if>
                                  <c:if
                                    test="${fn:toLowerCase(cat.name) == 'software' || fn:toLowerCase(cat.name) == 'phần mềm'}">
                                    <c:set var="isSoftware" value="true" />
                                  </c:if>
                                </c:forEach>

                                <c:set var="tagText" value="${isSoftware ? 'SOFTWARE' : 'GAME'}" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="tagText" value="HOT" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="tagText" value="GOTY" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="tagText" value="RPG" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="tagText" value="New" />
                                  </c:when>
                                </c:choose>

                                <c:set var="devName" value="${primaryCategory}" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="devName" value="CD Projekt Red" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="devName" value="FromSoftware" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="devName" value="Larian Studios" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="devName" value="Game Science" />
                                  </c:when>
                                </c:choose>

                                <c:set var="ratingStars" value="★★★★★ 4.7" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.8" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.9" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.9" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.8" />
                                  </c:when>
                                </c:choose>

                                <c:set var="isDiscounted" value="false" />
                                <c:if
                                  test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk') || fn:contains(fn:toLowerCase(game.title), 'elden') || fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                  <c:set var="isDiscounted" value="true" />
                                </c:if>

                                <div class="col">
                                  <article class="gf-game-card gf-press game-item" data-id="${game.id}"
                                    data-title="${fn:escapeXml(fn:toLowerCase(game.title))}"
                                    data-category="${fn:escapeXml(fn:toLowerCase(primaryCategory))}">
                                    <div class="gf-game-banner">
                                      <a href="${pageContext.request.contextPath}/${game.slug}" class="d-block h-100">
                                        <c:choose>
                                          <c:when test="${not empty game.mediaList && not fn:startsWith(game.mediaList[0].mediaUrl, 'http')}">
                                            <img src="${pageContext.request.contextPath}${game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(game.title)}" loading="lazy" style="width: 100%; height: 180px; object-fit: cover;">
                                          </c:when>
                                          <c:otherwise>
                                            <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black w-100 bg-light text-dark gf-muted" style="height: 180px; font-size: 14px;">
                                              Chưa có hình ảnh
                                            </div>
                                          </c:otherwise>
                                        </c:choose>
                                      </a>
                                      <span class="gf-tag">${tagText}</span>
                                      <button type="button" onclick="toggleFavorite(event, '${game.id}')"
                                        class="gf-favorite-btn favorite-button" data-game-id="${game.id}"
                                        title="Yêu thích">
                                        <i data-lucide="heart" width="18" height="18"></i>
                                      </button>
                                      <div class="gf-rating-badge">${ratingStars}</div>
                                    </div>

                                    <div class="p-3 p-sm-4 d-flex flex-column flex-grow-1">
                                      <div class="d-flex align-items-start justify-content-between gap-2 mb-3">
                                        <div class="flex-grow-1" style="min-width: 0;">
                                          <h3 class="fs-6 fw-black fw-bold text-truncate mb-1"
                                            title="${fn:escapeXml(game.title)}">${game.title}</h3>
                                          <div class="small fw-semibold text-secondary gf-muted text-truncate">
                                            ${devName}</div>
                                        </div>
                                        <c:set var="gameIdStr" value=",${game.id}," />
                                        <c:choose>
                                          <c:when test="${not empty ownedGameIds && fn:contains(ownedStr, gameIdStr)}">
                                            <button type="button"
                                              class="btn btn-sm gf-border-2 fw-bold text-dark px-2 bg-light text-secondary"
                                              style="border-radius: 8px; font-size:11px; cursor:default; height:38px;"
                                              disabled title="Đã có trong thư viện">
                                              <i data-lucide="library" width="14" height="14" class="me-1"></i>Đã sở hữu
                                            </button>
                                          </c:when>
                                          <c:otherwise>
                                            <button type="button" onclick="quickAddToCart(event, '${game.id}')"
                                              class="gf-cart-btn cart-button" data-game-id="${game.id}"
                                              title="Thêm vào giỏ">
                                              <i data-lucide="shopping-cart" width="18" height="18"></i>
                                            </button>
                                          </c:otherwise>
                                        </c:choose>
                                      </div>

                                      <div class="gf-price-container mt-auto">
                                        <c:choose>
                                          <c:when test="${isDiscounted}">
                                            <span class="gf-price-discounted text-success fw-black fw-bold me-2">
                                              <fmt:formatNumber value="${game.price}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                            <span
                                              class="gf-price-original text-muted text-decoration-line-through small">
                                              <fmt:formatNumber value="${game.price * 1.4}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                          </c:when>
                                          <c:otherwise>
                                            <span class="gf-price-regular fw-black fw-bold">
                                              <fmt:formatNumber value="${game.price}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                          </c:otherwise>
                                        </c:choose>
                                      </div>
                                    </div>
                                  </article>
                                </div>
                              </c:if>
                            </c:forEach>
                          </div>
                        </div>

                      </div>
                    </div>
                  </section>
                </c:when>
                <c:otherwise>
                  <!-- HERO -->
                  <section id="store" class="gf-hero">
                    <div class="container-xl">
                      <div class="row align-items-start g-5">
                        <div class="col-lg-6">
                          <div class="gf-badge mb-4">
                            <span class="gf-pulse-dot"></span>
                            Web bán game/ phần mềm bản quyền hiện đại
                          </div>

                          <h1 class="gf-hero-title mb-4">
                            Trải Nghiệm <br class="d-none d-sm-block">
                            Game <span class="gf-green">Đỉnh Cao</span>, <br>
                            Mọi Nơi!
                          </h1>

                          <p class="gf-hero-text mb-5">
                            Game Hot chuyển từng game bằng carousel ngang. Sale Hot vẫn giữ grid cũ 8 game/trang nhưng
                            dùng hiệu ứng trượt nhẹ, không nhấp nháy.
                          </p>

                          <div class="d-flex flex-column flex-sm-row gap-3 mb-5">
                            <a href="#hot-games"
                              class="btn gf-border gf-shadow gf-press fw-black fw-bold fs-5 px-4 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2"
                              style="background:var(--gf-green);">
                              Xem Game Hot <i data-lucide="arrow-right" width="20" height="20"></i>
                            </a>
                            <a href="#sale-games"
                              class="btn gf-border gf-shadow gf-press fw-black fw-bold fs-5 px-4 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2"
                              style="background:var(--gf-blue);">
                              <i data-lucide="percent" width="20" height="20"></i> Sale Đang Hot
                            </a>
                          </div>

                          <div class="gf-stat">
                            <div class="row row-cols-2 row-cols-sm-4 g-4">
                              <div class="col">
                                <div class="display-6 fw-black fw-bold">10K+</div>
                                <div class="fw-bold text-secondary gf-muted">Tựa Game</div>
                              </div>
                              <div class="col">
                                <div class="display-6 fw-black fw-bold">2M+</div>
                                <div class="fw-bold text-secondary gf-muted">Game Thủ</div>
                              </div>
                              <div class="col">
                                <div class="display-6 fw-black fw-bold">500+</div>
                                <div class="fw-bold text-secondary gf-muted">Nhà Phát Hành</div>
                              </div>
                              <div class="col">
                                <div class="display-6 fw-black fw-bold">4.9★</div>
                                <div class="fw-bold text-secondary gf-muted">Đánh Giá</div>
                              </div>
                            </div>
                          </div>
                        </div>

                        <!-- HERO GRID -->
                        <div class="col-lg-6">
                          <div class="row row-cols-2 g-4">
                            <c:forEach var="game" items="${games}" varStatus="status">
                              <c:if test="${status.index lt 4}">
                                <c:set var="isSoftware" value="false" />
                                <c:set var="primaryCategory" value="Game" />
                                <c:forEach var="cat" items="${game.categories}" varStatus="catStatus">
                                  <c:if test="${catStatus.first}">
                                    <c:set var="primaryCategory" value="${cat.name}" />
                                  </c:if>
                                  <c:if
                                    test="${fn:toLowerCase(cat.name) == 'software' || fn:toLowerCase(cat.name) == 'phần mềm'}">
                                    <c:set var="isSoftware" value="true" />
                                  </c:if>
                                </c:forEach>

                                <c:set var="tagText" value="${isSoftware ? 'SOFTWARE' : 'GAME'}" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="tagText" value="HOT" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="tagText" value="GOTY" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="tagText" value="RPG" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="tagText" value="New" />
                                  </c:when>
                                </c:choose>

                                <c:set var="devName" value="${primaryCategory}" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="devName" value="CD Projekt Red" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="devName" value="FromSoftware" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="devName" value="Larian Studios" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="devName" value="Game Science" />
                                  </c:when>
                                </c:choose>

                                <c:set var="ratingStars" value="★★★★★ 4.7" />
                                <c:choose>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.8" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.9" />
                                  </c:when>
                                  <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.9" />
                                  </c:when>
                                  <c:when
                                    test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                    <c:set var="ratingStars" value="★★★★★ 4.8" />
                                  </c:when>
                                </c:choose>

                                <c:set var="isDiscounted" value="false" />
                                <c:if
                                  test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk') || fn:contains(fn:toLowerCase(game.title), 'elden') || fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                  <c:set var="isDiscounted" value="true" />
                                </c:if>

                                <div class="col">
                                  <article class="gf-game-card gf-press game-item" data-id="${game.id}"
                                    data-title="${fn:escapeXml(fn:toLowerCase(game.title))}"
                                    data-category="${fn:escapeXml(fn:toLowerCase(primaryCategory))}">
                                      <div class="gf-game-banner">
                                      <a href="${pageContext.request.contextPath}/${game.slug}"
                                        class="d-block h-100">
                                        <c:choose>
                                          <c:when test="${not empty game.mediaList && not fn:startsWith(game.mediaList[0].mediaUrl, 'http')}">
                                            <img src="${pageContext.request.contextPath}${game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(game.title)}" loading="lazy" style="width: 100%; height: 180px; object-fit: cover;">
                                          </c:when>
                                          <c:otherwise>
                                            <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black w-100 bg-light text-dark gf-muted" style="height: 180px; font-size: 14px;">
                                              Chưa có hình ảnh
                                            </div>
                                          </c:otherwise>
                                        </c:choose>
                                      </a>
                                      <span class="gf-tag">${tagText}</span>
                                      <button type="button" onclick="toggleFavorite(event, '${game.id}')"
                                        class="gf-favorite-btn favorite-button" data-game-id="${game.id}"
                                        title="Yêu thích">
                                        <i data-lucide="heart" width="18" height="18"></i>
                                      </button>
                                      <div class="gf-rating-badge">${ratingStars}</div>
                                    </div>

                                    <div class="p-3 p-sm-4 d-flex flex-column flex-grow-1">
                                      <div class="d-flex align-items-start justify-content-between gap-2 mb-3">
                                        <div class="flex-grow-1" style="min-width: 0;">
                                          <h3 class="fs-6 fw-black fw-bold text-truncate mb-1"
                                            title="${fn:escapeXml(game.title)}">${game.title}</h3>
                                          <div class="small fw-semibold text-secondary gf-muted text-truncate">
                                            ${devName}</div>
                                        </div>
                                        <c:set var="gameIdStr" value=",${game.id}," />
                                        <c:choose>
                                          <c:when test="${not empty ownedGameIds && fn:contains(ownedStr, gameIdStr)}">
                                            <button type="button"
                                              class="btn btn-sm gf-border-2 fw-bold text-dark px-2 bg-light text-secondary"
                                              style="border-radius: 8px; font-size:11px; cursor:default; height:38px;"
                                              disabled title="Đã có trong thư viện">
                                              <i data-lucide="library" width="14" height="14" class="me-1"></i>Đã sở hữu
                                            </button>
                                          </c:when>
                                          <c:otherwise>
                                            <button type="button" onclick="quickAddToCart(event, '${game.id}')"
                                              class="gf-cart-btn cart-button" data-game-id="${game.id}"
                                              title="Thêm vào giỏ">
                                              <i data-lucide="shopping-cart" width="18" height="18"></i>
                                            </button>
                                          </c:otherwise>
                                        </c:choose>
                                      </div>

                                      <div class="gf-price-container mt-auto">
                                        <c:choose>
                                          <c:when test="${isDiscounted}">
                                            <span class="gf-price-discounted text-success fw-black fw-bold me-2">
                                              <fmt:formatNumber value="${game.price}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                            <span
                                              class="gf-price-original text-muted text-decoration-line-through small">
                                              <fmt:formatNumber value="${game.price * 1.4}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                          </c:when>
                                          <c:otherwise>
                                            <span class="gf-price-regular fw-black fw-bold">
                                              <fmt:formatNumber value="${game.price}" type="number"
                                                maxFractionDigits="0" /><u>đ</u>
                                            </span>
                                          </c:otherwise>
                                        </c:choose>
                                      </div>
                                    </div>
                                  </article>
                                </div>
                              </c:if>
                            </c:forEach>
                          </div>
                        </div>
                      </div>
                    </div>
                  </section>
                </c:otherwise>
              </c:choose>

              <!-- CATEGORY -->
              <section class="gf-section-soft py-5">
                <div class="container-xl py-4">
                  <div class="text-center mb-5">
                    <span
                      class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small"
                      style="background:var(--gf-yellow);color:#000;">Danh Mục</span>
                    <h2 class="display-5 fw-black fw-bold mt-3">Khám Phá Theo <span class="gf-green">Thể Loại</span>
                    </h2>
                  </div>

                  <div class="row row-cols-2 row-cols-sm-3 row-cols-lg-6 g-4">
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:var(--gf-pink);"><i data-lucide="swords"
                            width="28" height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Hành Động</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">Action RPG</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:var(--gf-blue);"><i data-lucide="brain"
                            width="28" height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Chiến Thuật</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">Strategy</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:var(--gf-lavender);"><i data-lucide="users"
                            width="28" height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Nhập Vai</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">RPG</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:#94FFB4;"><i data-lucide="car" width="28"
                            height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Đua Xe</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">Racing</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:var(--gf-yellow);"><i data-lucide="package"
                            width="28" height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Software</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">Tools</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-category-card gf-press">
                        <div class="gf-category-icon mb-3" style="background:#fbcfe8;"><i data-lucide="heart" width="28"
                            height="28"></i></div>
                        <h3 class="fs-6 fw-black fw-bold">Giải Trí</h3>
                        <p class="small fw-semibold text-secondary gf-muted mb-0">Casual</p>
                      </div>
                    </div>
                  </div>
                </div>
              </section>

              <!-- GAME HOT -->
              <section id="hot-games" class="py-5">
                <div class="container-xl py-4">
                  <div
                    class="d-flex flex-column flex-lg-row align-items-start align-items-lg-end justify-content-between gap-4 mb-5">
                    <div>
                      <span
                        class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small"
                        style="background:var(--gf-pink);color:#000;">Layout 1</span>
                      <h2 class="display-5 fw-black fw-bold mt-3">Game <span class="gf-green">Hot</span></h2>
                      <p class="fw-semibold text-secondary gf-muted mb-0">Một hàng card, chuyển từng game 1 bằng smooth
                        horizontal carousel, không chớp.</p>
                    </div>

                    <div class="d-flex flex-wrap align-items-center gap-3">
                      <button id="toggleFavoriteOnlyHot"
                        class="btn gf-border gf-shadow-sm gf-press fw-black fw-bold rounded-3 d-flex align-items-center gap-2"
                        type="button">
                        <i data-lucide="heart" width="16" height="16"></i> Chỉ yêu thích
                      </button>
                      <div class="gf-border gf-shadow-sm rounded-3 px-3 py-2 fw-black fw-bold bg-white text-dark">
                        <span id="hotCurrentPage">01</span><span class="text-secondary"> / </span><span
                          id="hotTotalPages">01</span>
                      </div>
                    </div>
                  </div>

                  <div class="gf-slider-shell gf-slider-padding">
                    <button id="hotPrev" class="gf-side-nav-btn gf-side-left" type="button"
                      aria-label="Game hot trước"><i data-lucide="chevron-left" width="28" height="28"></i></button>
                    <div class="gf-hot-viewport">
                      <div id="hotTrack" class="gf-hot-track">
                        <c:forEach var="game" items="${games}" varStatus="status">
                          <c:if test="${status.index lt 12}">
                            <c:set var="isSoftware" value="false" />
                            <c:set var="primaryCategory" value="Game" />
                            <c:forEach var="cat" items="${game.categories}" varStatus="catStatus">
                              <c:if test="${catStatus.first}">
                                <c:set var="primaryCategory" value="${cat.name}" />
                              </c:if>
                              <c:if
                                test="${fn:toLowerCase(cat.name) == 'software' || fn:toLowerCase(cat.name) == 'phần mềm'}">
                                <c:set var="isSoftware" value="true" />
                              </c:if>
                            </c:forEach>

                            <c:set var="tagText" value="${isSoftware ? 'SOFTWARE' : 'GAME'}" />
                            <c:choose>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                <c:set var="tagText" value="HOT" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                <c:set var="tagText" value="GOTY" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                <c:set var="tagText" value="RPG" />
                              </c:when>
                              <c:when
                                test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                <c:set var="tagText" value="New" />
                              </c:when>
                            </c:choose>

                            <c:set var="devName" value="${primaryCategory}" />
                            <c:choose>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                <c:set var="devName" value="CD Projekt Red" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                <c:set var="devName" value="FromSoftware" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                <c:set var="devName" value="Larian Studios" />
                              </c:when>
                              <c:when
                                test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                <c:set var="devName" value="Game Science" />
                              </c:when>
                            </c:choose>

                            <c:set var="ratingStars" value="★★★★★ 4.7" />
                            <c:choose>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                                <c:set var="ratingStars" value="★★★★★ 4.8" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                                <c:set var="ratingStars" value="★★★★★ 4.9" />
                              </c:when>
                              <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                                <c:set var="ratingStars" value="★★★★★ 4.9" />
                              </c:when>
                              <c:when
                                test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                                <c:set var="ratingStars" value="★★★★★ 4.8" />
                              </c:when>
                            </c:choose>

                            <c:set var="isDiscounted" value="false" />
                            <c:if
                              test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk') || fn:contains(fn:toLowerCase(game.title), 'elden') || fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                              <c:set var="isDiscounted" value="true" />
                            </c:if>

                            <div class="gf-hot-slide-card game-item" data-id="${game.id}"
                              data-title="${fn:escapeXml(fn:toLowerCase(game.title))}"
                              data-category="${fn:escapeXml(fn:toLowerCase(primaryCategory))}">
                              <article class="gf-game-card gf-press">
                                <div class="gf-game-banner">
                                  <a href="${pageContext.request.contextPath}/${game.slug}" class="d-block h-100">
                                    <c:choose>
                                          <c:when test="${not empty game.mediaList && not fn:startsWith(game.mediaList[0].mediaUrl, 'http')}">
                                            <img src="${pageContext.request.contextPath}${game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(game.title)}" loading="lazy" style="width: 100%; height: 180px; object-fit: cover;">
                                          </c:when>
                                          <c:otherwise>
                                            <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black w-100 bg-light text-dark gf-muted" style="height: 180px; font-size: 14px;">
                                              Chưa có hình ảnh
                                            </div>
                                          </c:otherwise>
                                        </c:choose>
                                  </a>
                                  <span class="gf-tag">${tagText}</span>
                                  <button type="button" onclick="toggleFavorite(event, '${game.id}')"
                                    class="gf-favorite-btn favorite-button" data-game-id="${game.id}" title="Yêu thích">
                                    <i data-lucide="heart" width="18" height="18"></i>
                                  </button>
                                  <div class="gf-rating-badge">${ratingStars}</div>
                                </div>

                                <div class="p-4 d-flex flex-column flex-grow-1">
                                  <div class="d-flex align-items-start justify-content-between gap-3 mb-3">
                                    <div class="flex-grow-1" style="min-width: 0;">
                                      <h3 class="fs-5 fw-black fw-bold text-truncate mb-1"
                                        title="${fn:escapeXml(game.title)}">${game.title}</h3>
                                      <p class="small fw-semibold text-secondary gf-muted text-truncate mb-0">${devName}
                                      </p>
                                    </div>
                                    <c:set var="gameIdStr" value=",${game.id}," />
                                    <c:choose>
                                      <c:when test="${not empty ownedGameIds && fn:contains(ownedStr, gameIdStr)}">
                                        <button type="button"
                                          class="btn btn-sm gf-border-2 fw-bold text-dark px-2 bg-light text-secondary"
                                          style="border-radius: 8px; font-size:11px; cursor:default; height:38px;"
                                          disabled title="Đã có trong thư viện">
                                          <i data-lucide="library" width="14" height="14" class="me-1"></i>Đã sở hữu
                                        </button>
                                      </c:when>
                                      <c:otherwise>
                                        <button type="button" onclick="quickAddToCart(event, '${game.id}')"
                                          class="gf-cart-btn cart-button" data-game-id="${game.id}"
                                          title="Thêm vào giỏ">
                                          <i data-lucide="shopping-cart" width="18" height="18"></i>
                                        </button>
                                      </c:otherwise>
                                    </c:choose>
                                  </div>

                                  <div class="gf-price-container mb-3">
                                    <c:choose>
                                      <c:when test="${isDiscounted}">
                                        <span class="gf-price-discounted text-success fw-black fw-bold me-2">
                                          <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />
                                          <u>đ</u>
                                        </span>
                                        <span class="gf-price-original text-muted text-decoration-line-through small">
                                          <fmt:formatNumber value="${game.price * 1.4}" type="number"
                                            maxFractionDigits="0" /><u>đ</u>
                                        </span>
                                      </c:when>
                                      <c:otherwise>
                                        <span class="gf-price-regular fw-black fw-bold">
                                          <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />
                                          <u>đ</u>
                                        </span>
                                      </c:otherwise>
                                    </c:choose>
                                  </div>

                                  <a href="${pageContext.request.contextPath}/${game.slug}"
                                    class="gf-detail-btn mt-auto">
                                    Xem chi tiết <i data-lucide="external-link" width="16" height="16"></i>
                                  </a>
                                </div>
                              </article>
                            </div>
                          </c:if>
                        </c:forEach>
                      </div>
                    </div>
                    <button id="hotNext" class="gf-side-nav-btn gf-side-right" type="button"
                      aria-label="Game hot sau"><i data-lucide="chevron-right" width="28" height="28"></i></button>
                  </div>

                  <div id="hotDots" class="mt-4 d-flex align-items-center justify-content-center gap-2"></div>
                </div>
              </section>

              <!-- SALE HOT -->
              <section id="sale-games" class="gf-sale-section py-5">
                <div class="container-xl py-4">
                  <div
                    class="d-flex flex-column flex-lg-row align-items-start align-items-lg-end justify-content-between gap-4 mb-5">
                    <div>
                      <div
                        class="d-inline-flex align-items-center gap-2 gf-border gf-shadow-sm rounded-pill px-4 py-2 fw-black fw-bold text-white mb-3"
                        style="background:#f87171;">
                        <i data-lucide="zap" width="20" height="20"></i> FLASH SALE ĐANG DIỄN RA!
                      </div>
                      <h2 class="display-5 fw-black fw-bold">Sale Hot <span class="text-danger"
                          style="text-shadow:2px 2px 0 #000;">Nhiều Game</span></h2>
                      <p class="fw-semibold text-secondary gf-muted mb-0">Grid động từ dữ liệu game,
                        <strong>${fn:length(games)}</strong> game, 8 game/trang, hiệu ứng trượt mượt không nhấp nháy.
                      </p>
                    </div>

                    <div class="d-flex flex-wrap align-items-center gap-3">
                      <button id="toggleFavoriteOnlySale"
                        class="btn gf-border gf-shadow-sm gf-press fw-black fw-bold rounded-3 d-flex align-items-center gap-2"
                        type="button">
                        <i data-lucide="heart" width="16" height="16"></i> Chỉ yêu thích
                      </button>
                      <div class="gf-border gf-shadow-sm rounded-3 px-3 py-2 fw-black fw-bold bg-white text-dark">
                        <span id="saleCurrentPage">01</span><span class="text-secondary"> / </span><span
                          id="saleTotalPages">01</span>
                      </div>
                    </div>
                  </div>

                  <div class="gf-slider-shell gf-slider-padding">
                    <button id="salePrev" class="gf-side-nav-btn gf-side-left" type="button" aria-label="Sale trước"><i
                        data-lucide="chevron-left" width="28" height="28"></i></button>
                    <div class="gf-sale-grid-shell">
                      <div id="saleGrid"
                        class="gf-sale-grid row row-cols-1 row-cols-sm-2 row-cols-lg-3 row-cols-xl-4 g-4">
                        <c:forEach var="game" items="${games}">
                          <c:set var="isSoftware" value="false" />
                          <c:set var="primaryCategory" value="Game" />
                          <c:forEach var="cat" items="${game.categories}" varStatus="catStatus">
                            <c:if test="${catStatus.first}">
                              <c:set var="primaryCategory" value="${cat.name}" />
                            </c:if>
                            <c:if
                              test="${fn:toLowerCase(cat.name) == 'software' || fn:toLowerCase(cat.name) == 'phần mềm'}">
                              <c:set var="isSoftware" value="true" />
                            </c:if>
                          </c:forEach>

                          <c:set var="tagText" value="${isSoftware ? 'SOFTWARE' : 'GAME'}" />
                          <c:choose>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                              <c:set var="tagText" value="HOT" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                              <c:set var="tagText" value="GOTY" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                              <c:set var="tagText" value="RPG" />
                            </c:when>
                            <c:when
                              test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                              <c:set var="tagText" value="New" />
                            </c:when>
                          </c:choose>

                          <c:set var="devName" value="${primaryCategory}" />
                          <c:choose>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                              <c:set var="devName" value="CD Projekt Red" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                              <c:set var="devName" value="FromSoftware" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                              <c:set var="devName" value="Larian Studios" />
                            </c:when>
                            <c:when
                              test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                              <c:set var="devName" value="Game Science" />
                            </c:when>
                          </c:choose>

                          <c:set var="ratingStars" value="★★★★★ 4.7" />
                          <c:choose>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'cyberpunk 2077')}">
                              <c:set var="ratingStars" value="★★★★★ 4.8" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'elden ring')}">
                              <c:set var="ratingStars" value="★★★★★ 4.9" />
                            </c:when>
                            <c:when test="${fn:contains(fn:toLowerCase(game.title), 'baldur')}">
                              <c:set var="ratingStars" value="★★★★★ 4.9" />
                            </c:when>
                            <c:when
                              test="${fn:contains(fn:toLowerCase(game.title), 'black myth') || fn:contains(fn:toLowerCase(game.title), 'wukong')}">
                              <c:set var="ratingStars" value="★★★★★ 4.8" />
                            </c:when>
                          </c:choose>

                          <c:set var="isDiscounted" value="false" />
                          <c:set var="salePercent" value="0" />
                          <c:forEach var="sale" items="${saleData}">
                            <c:if test="${sale.gameId == game.id}">
                              <c:set var="isDiscounted" value="true" />
                              <c:set var="salePercent" value="${sale.discountPercent}" />
                            </c:if>
                          </c:forEach>

                          <div class="col sale-card-wrapper game-item" data-id="${game.id}"
                            data-title="${fn:escapeXml(fn:toLowerCase(game.title))}"
                            data-category="${fn:escapeXml(fn:toLowerCase(primaryCategory))}">
                            <article class="gf-game-card gf-press">
                              <div class="gf-game-banner">
                                <a href="${pageContext.request.contextPath}/${game.slug}" class="d-block h-100">
                                  <c:choose>
                                          <c:when test="${not empty game.mediaList && not fn:startsWith(game.mediaList[0].mediaUrl, 'http')}">
                                            <img src="${pageContext.request.contextPath}${game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(game.title)}" loading="lazy" style="width: 100%; height: 180px; object-fit: cover;">
                                          </c:when>
                                          <c:otherwise>
                                            <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black w-100 bg-light text-dark gf-muted" style="height: 180px; font-size: 14px;">
                                              Chưa có hình ảnh
                                            </div>
                                          </c:otherwise>
                                        </c:choose>
                                </a>
                                <c:if test="${isDiscounted}">
                                  <span class="gf-tag" style="background:#ef4444;color:#fff;">-${salePercent}%</span>
                                </c:if>
                                <c:if test="${not isDiscounted}">
                                  <span class="gf-tag">${tagText}</span>
                                </c:if>
                                <button type="button" onclick="toggleFavorite(event, '${game.id}')"
                                  class="gf-favorite-btn favorite-button" data-game-id="${game.id}" title="Yêu thích">
                                  <i data-lucide="heart" width="18" height="18"></i>
                                </button>
                                <div class="gf-rating-badge">${ratingStars}</div>
                              </div>

                              <div class="p-4 d-flex flex-column flex-grow-1">
                                <div class="d-flex align-items-start justify-content-between gap-3 mb-3">
                                  <div class="flex-grow-1" style="min-width: 0;">
                                    <h3 class="fs-5 fw-black fw-bold text-truncate mb-1"
                                      title="${fn:escapeXml(game.title)}">${game.title}</h3>
                                    <p class="small fw-semibold text-secondary gf-muted text-truncate mb-0">${devName}
                                    </p>
                                  </div>
                                  <c:set var="gameIdStr" value=",${game.id}," />
                                  <c:choose>
                                    <c:when test="${not empty ownedGameIds && fn:contains(ownedStr, gameIdStr)}">
                                      <button type="button"
                                        class="btn btn-sm gf-border-2 fw-bold text-dark px-2 bg-light text-secondary"
                                        style="border-radius: 8px; font-size:11px; cursor:default; height:38px;"
                                        disabled title="Đã có trong thư viện">
                                        <i data-lucide="library" width="14" height="14" class="me-1"></i>Đã sở hữu
                                      </button>
                                    </c:when>
                                    <c:otherwise>
                                      <button type="button" onclick="quickAddToCart(event, '${game.id}')"
                                        class="gf-cart-btn cart-button" data-game-id="${game.id}" title="Thêm vào giỏ">
                                        <i data-lucide="shopping-cart" width="18" height="18"></i>
                                      </button>
                                    </c:otherwise>
                                  </c:choose>
                                </div>

                                <div class="gf-price-container mb-3">
                                  <c:choose>
                                    <c:when test="${isDiscounted}">
                                      <span class="gf-price-discounted">
                                        <fmt:formatNumber value="${game.price * (100 - salePercent) / 100}"
                                          type="number" maxFractionDigits="0" /><u>đ</u>
                                      </span>
                                      <span class="gf-price-original">
                                        <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />
                                        <u>đ</u>
                                      </span>
                                    </c:when>
                                    <c:otherwise>
                                      <span class="gf-price-regular">
                                        <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />
                                        <u>đ</u>
                                      </span>
                                    </c:otherwise>
                                  </c:choose>
                                </div>

                                <a href="${pageContext.request.contextPath}/${game.slug}"
                                  class="gf-detail-btn mt-auto">
                                  Xem chi tiết <i data-lucide="external-link" width="16" height="16"></i>
                                </a>
                              </div>
                            </article>
                          </div>
                        </c:forEach>

                        <c:if test="${empty games}">
                          <div class="col-12">
                            <div class="bg-white gf-border rounded-4 p-5 text-center gf-shadow">
                              <div class="mx-auto mb-4 gf-border rounded-4 gf-shadow-sm d-grid place-items-center"
                                style="width:64px;height:64px;background:var(--gf-pink);color:#000;place-items:center;">
                                <i data-lucide="heart-crack" width="32" height="32"></i>
                              </div>
                              <h3 class="fw-black fw-bold">Chưa có game</h3>
                              <p class="fw-semibold text-secondary mb-0">Không tìm thấy dữ liệu game.</p>
                            </div>
                          </div>
                        </c:if>
                      </div>
                    </div>
                    <button id="saleNext" class="gf-side-nav-btn gf-side-right text-white" style="background:#f87171;"
                      type="button" aria-label="Sale sau"><i data-lucide="chevron-right" width="28"
                        height="28"></i></button>
                  </div>

                  <div id="saleDots" class="mt-4 d-flex align-items-center justify-content-center gap-2"></div>
                </div>
              </section>

              <!-- COMMUNITY -->
              <section id="community" class="py-5">
                <div class="container-xl py-4">
                  <div class="text-center mb-5">
                    <span
                      class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small"
                      style="background:var(--gf-lavender);color:#000;">Đánh Giá</span>
                    <h2 class="display-5 fw-black fw-bold mt-3">Game Thủ <span class="gf-green">Nói Gì?</span></h2>
                  </div>

                  <div class="row row-cols-1 row-cols-md-3 g-4">
                    <div class="col">
                      <div class="gf-game-card p-4">
                        <div class="text-warning mb-3">★★★★★</div>
                        <p class="fw-semibold text-secondary gf-muted mb-0">"Sale vẫn là grid cũ nên dễ xem, nhưng
                          chuyển trang mượt hơn nhiều."</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-game-card p-4">
                        <div class="text-warning mb-3">★★★★★</div>
                        <p class="fw-semibold text-secondary gf-muted mb-0">"Game Hot trượt từng card không còn chớp
                          tắt."</p>
                      </div>
                    </div>
                    <div class="col">
                      <div class="gf-game-card p-4">
                        <div class="text-warning mb-3">★★★★☆</div>
                        <p class="fw-semibold text-secondary gf-muted mb-0">"Bootstrap 5 nhưng vẫn giữ được chất
                          neo-brutalism."</p>
                      </div>
                    </div>
                  </div>
                </div>
              </section>
              <section id="newsletter" class="py-5"
                style="background: var(--gf-green); border-top:3px solid #000; border-bottom:3px solid #000;">
                <div class="container-xl py-4">
                  <div class="mx-auto bg-white gf-border rounded-4 gf-shadow p-4 p-md-5 text-center"
                    style="max-width: 760px;">
                    <div class="mx-auto mb-4 gf-border rounded-4 gf-shadow-sm d-grid"
                      style="width:72px;height:72px;place-items:center;background:var(--gf-blue);color:#000;">
                      <i data-lucide="mail" width="34" height="34"></i>
                    </div>

                    <h2 class="display-6 fw-black fw-bold mb-3">
                      Nhận Tin Khuyến Mãi Sớm Nhất!
                    </h2>

                    <p class="fw-semibold text-secondary mb-4">
                      Đăng ký email để nhận thông báo game mới, flash sale và ưu đãi độc quyền.
                    </p>

                    <form action="${pageContext.request.contextPath}/newsletter/subscribe" method="post"
                      class="row g-3 justify-content-center">
                      <div class="col-12 col-md-7">
                        <input type="email" name="email" required maxlength="100" placeholder="Email của bạn..."
                          class="form-control gf-border gf-shadow-sm rounded-3 fw-semibold px-3 py-3">
                      </div>

                      <div class="col-12 col-md-auto">
                        <button type="submit"
                          class="btn bg-dark text-white gf-border gf-shadow-sm gf-press rounded-3 fw-black fw-bold px-4 py-3 w-100">
                          Đăng Ký
                        </button>
                      </div>
                    </form>
                  </div>
                </div>
              </section>
              <footer id="support" class="bg-dark text-white border-top border-3 border-black py-5">
                <div class="container-xl text-center small fw-semibold text-secondary">
                  © 2026 GameForge. Bootstrap 5 Neo Brutalism + JSP Dynamic Store.
                </div>
              </footer>

              <!-- Card template include fallback: Nếu không muốn dùng include, xem file partial bên dưới trong gói tải. -->

              <script>
                window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';

                // Hàm AJAX xóa item trực tiếp khỏi giỏ hàng trên Dashboard trang chủ
                function removeDashboardCart(btn, gameId) {
                  if (!confirm("Bạn có chắc chắn muốn xóa game này khỏi giỏ hàng?")) return;

                  const bodyParts = ["itemId=" + encodeURIComponent(gameId)];

                  fetch("${pageContext.request.contextPath}/api/cart/remove", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
                    body: bodyParts.join("&")
                  })
                    .then(res => res.json())
                    .then(data => {
                      if (data.success) {
                        window.location.reload();
                      } else {
                        alert("Lỗi: " + data.message);
                      }
                    })
                    .catch(err => {
                      console.error("Cart remove error:", err);
                      alert("Đã xảy ra lỗi khi kết nối máy chủ.");
                    });
                }
              </script>
              <script src="${pageContext.request.contextPath}/assets/js/index.js?v=20260528b"></script>


              <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>