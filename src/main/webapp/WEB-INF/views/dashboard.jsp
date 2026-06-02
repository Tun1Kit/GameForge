<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ java.time.format.DateTimeFormatter %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Bảng Điều Khiển Thành Viên</title>

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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
</head>

<body class="position-relative" style="min-height: 100vh; overflow-x: hidden;">
  <!-- Trang trí nổi trôi phong cách Neo-brutalism -->
  <div class="gf-decor-pill" style="top: 15%; left: 3%; background: var(--gf-yellow); transform: rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top: 65%; left: 2%; background: var(--gf-lavender); transform: rotate(-20deg); width: 30px; height: 30px;"></div>
  <div class="gf-decor-pill" style="top: 20%; right: 4%; background: var(--gf-pink); transform: rotate(45deg); width: 28px; height: 28px; border-radius: 50%;"></div>
  <div class="gf-decor-pill" style="top: 60%; right: 3%; background: #94FFB4; transform: rotate(-10deg);"></div>

  <!-- NAVBAR -->
  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

        <div class="d-flex align-items-center gap-2 gap-sm-3">
          <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="arrow-left" width="16" height="16"></i> Cửa hàng
          </a>

          <!-- DROPDOWN USER -->
          <div class="dropdown">
            <button class="btn dropdown-toggle d-flex align-items-center gap-2 gf-press"
                    data-bs-toggle="dropdown" type="button"
                    style="background: #18181b; border: 3px solid #000; border-radius: 999px; height: 42px; padding: 4px 16px 4px 6px; color: #fff; box-shadow: 3px 3px 0 0 #000;"
                    title="${fn:escapeXml(currentUser.fullName)}">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Vinh'}" 
                   alt="Avatar" 
                   style="width: 30px; height: 30px; border-radius: 50%; object-fit: cover; border: 2px solid #fff;">
              <span class="d-none d-sm-inline fw-black text-white" style="font-size:13px; max-width: 100px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${fn:escapeXml(currentUser.fullName)}</span>
              <i data-lucide="chevron-down" width="16" height="16" class="text-white"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius: 12px; min-width: 210px;">
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/dashboard">
                  <i data-lucide="layout-dashboard" width="16" height="16"></i> Bảng điều khiển
                </a>
              </li>
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/library">
                  <i data-lucide="library" width="16" height="16"></i> Thư viện game
                </a>
              </li>
              <li>
                <a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/transactions">
                  <i data-lucide="history" width="16" height="16"></i> Lịch sử giao dịch
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
  <i data-lucide="log-out" width="16" height="16"></i> Đăng xuất
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
      
      <!-- PHẦN CHÀO MỪNG BÊN TRÁI -->
      <div class="col-lg-6">
        <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-4" style="background: #94FFB4; box-shadow: 3px 3px 0 #000;">
          👋 Thành viên từ <fmt:parseDate value="${currentUser.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" /><fmt:formatDate value="${parsedDate}" pattern="MM/yyyy" />
        </div>

        <h1 class="fw-black fw-bold mb-4" style="font-size: clamp(2.5rem, 6vw, 3.8rem); line-height: 1.1; letter-spacing: -0.03em;">
          Chào mừng trở lại, <br>
          <span class="text-success" style="text-shadow: 2px 2px 0 #000;">${fn:escapeXml(currentUser.fullName)}!</span>
        </h1>

        <p class="fs-5 fw-semibold text-secondary gf-muted mb-5" style="max-width: 460px; line-height: 1.6;">
          Tiếp tục mua sắm, khám phá ưu đãi mới và quản lý thư viện game của bạn một cách dễ dàng.
        </p>

        <div class="d-flex flex-column flex-sm-row gap-3">
          <a href="${pageContext.request.contextPath}/#store" class="btn gf-border gf-shadow gf-press fw-bold fs-5 px-4 py-3 rounded-3 d-inline-flex align-items-center justify-content-center gap-2" style="background: var(--gf-green);">
            <i data-lucide="shopping-bag" width="20" height="20"></i> Tiếp tục mua sắm
          </a>
          <a href="${pageContext.request.contextPath}/library" class="btn gf-border gf-shadow gf-press fw-bold fs-5 px-4 py-3 rounded-3 d-inline-flex align-items-center justify-content-center gap-2" style="background: var(--gf-blue);">
            <i data-lucide="library" width="20" height="20"></i> Vào thư viện game
          </a>
        </div>
      </div>

      <!-- PHẦN SIDEBAR BÊN PHẢI -->
      <div class="col-lg-6">
        <div class="d-flex flex-column gap-5">
          
          <!-- KHỐI 1: GIỎ HÀNG HIỆN TẠI -->
          <div class="bg-white gf-border rounded-4 gf-shadow" style="overflow: hidden;">
            <div class="p-3 fw-black fw-bold d-flex align-items-center gap-2 text-dark" style="background: var(--gf-yellow); border-bottom: 3px solid #000;">
              <i data-lucide="shopping-cart" width="20" height="20"></i> Giỏ hàng hiện tại
              <span class="badge bg-black text-white ms-auto border border-2 border-white" style="border-radius: 50%; width: 26px; height: 26px; display: grid; place-items: center; padding: 0; font-size: 11px;">
                ${fn:length(cartItems)}
              </span>
            </div>
            
            <div class="p-4">
              <c:choose>
                <c:when test="${not empty cartItems}">
                  <div class="d-flex flex-column gap-3 mb-4">
                    <c:forEach var="item" items="${cartItems}">
                      <div class="d-flex align-items-center justify-content-between gap-3 p-3 bg-light gf-border rounded-3">
                        <div class="d-flex align-items-center gap-3" style="min-width: 0;">
                          <div class="gf-border rounded-2 overflow-hidden" style="width: 50px; height: 50px; flex-shrink: 0;">
                            <c:choose>
                              <c:when test="${not empty item.game.mediaList}">
                                <img src="${item.game.mediaList[0].mediaUrl}" alt="${fn:escapeXml(item.game.title)}" style="width: 100%; height: 100%; object-fit: cover;">
                              </c:when>
                              <c:otherwise>
                                <img src="https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg" alt="Cover" style="width: 100%; height: 100%; object-fit: cover;">
                              </c:otherwise>
                            </c:choose>
                          </div>
                          <div style="min-width: 0;">
                            <h4 class="fs-6 fw-bold text-truncate mb-1">${item.game.title}</h4>
                            <span class="text-secondary small gf-muted">Giá gốc</span>
                          </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                          <span class="fw-black text-dark"><fmt:formatNumber value="${item.game.price}" type="number" maxFractionDigits="0" />đ</span>
                          <button type="button" onclick="removeDashboardCart(this, '${item.game.id}')" class="btn btn-outline-danger btn-sm p-1.5 gf-border-2" style="border-radius: 8px;" title="Xóa khỏi giỏ">
                            <i data-lucide="trash-2" width="14" height="14"></i>
                          </button>
                        </div>
                      </div>
                    </c:forEach>
                  </div>
                  
                  <div class="d-flex align-items-center justify-content-between border-top border-2 border-dark pt-3 mb-3">
                    <span class="fs-6 fw-bold">Tạm tính (${fn:length(cartItems)})</span>
                    <span class="fs-5 fw-black text-success" id="cartTotalText"><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0" />đ</span>
                  </div>
                  
                  <a href="${pageContext.request.contextPath}/checkout" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5 d-flex align-items-center justify-content-center gap-2" style="background: var(--gf-yellow); border-radius: 10px;">
                    Xem giỏ hàng <i data-lucide="arrow-right" width="18" height="18"></i>
                  </a>
                </c:when>
                
                <c:otherwise>
                  <div class="text-center py-4">
                    <div class="mx-auto mb-3 gf-border rounded-4 d-grid place-items-center" style="width: 48px; height: 48px; background: var(--gf-pink);">
                      <i data-lucide="shopping-bag" width="22" height="22"></i>
                    </div>
                    <h5 class="fw-bold">Giỏ hàng trống</h5>
                    <p class="small text-secondary gf-muted mb-0">Hãy quay lại trang chủ và chọn tựa game bạn thích nhé.</p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <!-- KHỐI 2: ĐƠN HÀNG GẦN ĐÂY -->
          <div class="bg-white gf-border rounded-4 gf-shadow" style="overflow: hidden;">
            <div class="p-3 fw-black fw-bold d-flex align-items-center gap-2 text-dark" style="background: var(--gf-lavender); border-bottom: 3px solid #000;">
              <i data-lucide="receipt" width="20" height="20"></i> Đơn hàng gần đây
              <a href="${pageContext.request.contextPath}/library" class="small text-decoration-none ms-auto text-dark fw-bold" style="font-size: 12px; display: inline-flex; align-items: center; gap: 2px;">
                Xem tất cả <i data-lucide="arrow-right" width="12" height="12"></i>
              </a>
            </div>
            
            <div class="p-4">
              <c:choose>
                <c:when test="${not empty recentOrders}">
                  <div class="d-flex flex-column gap-3">
                    <c:forEach var="order" items="${recentOrders}">
                      <div class="d-flex align-items-center justify-content-between p-3 bg-light gf-border rounded-3">
                        <div>
                          <div class="fw-black text-dark mb-1">#GF-2026-0${order.id}</div>
                          <div class="small text-secondary gf-muted">
                            <fmt:parseDate value="${order.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedOrderDate" type="both" />
                            <fmt:formatDate value="${parsedOrderDate}" pattern="dd/MM/yyyy" />
                          </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                          <span class="badge text-dark border border-2 border-black fw-bold" style="background: #94FFB4; border-radius: 999px; font-size: 11px;">Đã hoàn thành</span>
                          <span class="fw-black text-dark"><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0" />đ</span>
                        </div>
                      </div>
                    </c:forEach>
                  </div>
                </c:when>
                
                <c:otherwise>
                  <div class="text-center py-4">
                    <div class="mx-auto mb-3 gf-border rounded-4 d-grid place-items-center" style="width: 48px; height: 48px; background: var(--gf-lavender);">
                      <i data-lucide="receipt" width="22" height="22"></i>
                    </div>
                    <h5 class="fw-bold">Chưa có đơn hàng nào</h5>
                    <p class="small text-secondary gf-muted mb-0">Các đơn hàng bạn mua sẽ xuất hiện tại đây.</p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
          
        </div>
      </div>

    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Bảng điều khiển Neo-brutalism + JSP Dynamic.
    </div>
  </footer>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
