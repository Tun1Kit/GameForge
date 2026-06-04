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
  <title>GameForge - Lịch Sử Giao Dịch</title>

  <!-- CSRF Meta Tags -->
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/transactions.css">
</head>

<body class="position-relative" style="min-height: 100vh; overflow-x: hidden;">
  <!-- Neo-brutalism Floating Decorative Background Elements -->
  <div class="gf-decor-pill" style="top: 12%; left: 4%; background: var(--gf-pink); transform: rotate(-10deg);"></div>
  <div class="gf-decor-pill" style="top: 80%; left: 3%; background: var(--gf-yellow); transform: rotate(15deg); width: 32px; height: 32px; border-radius: 50%;"></div>
  <div class="gf-decor-pill" style="top: 20%; right: 5%; background: var(--gf-blue); transform: rotate(30deg); width: 25px; height: 25px;"></div>
  <div class="gf-decor-pill" style="top: 72%; right: 4%; background: #94FFB4; transform: rotate(-25deg);"></div>

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
  </nav>

  <!-- MAIN CONTAINER -->
  <main class="container-xl py-5">
    
    <!-- HEADER -->
    <div class="mb-5 text-center text-sm-start d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
      <div>
        <h1 class="fw-black fw-bold mb-1">Lịch sử giao dịch</h1>
        <p class="fw-semibold text-secondary gf-muted mb-0">Xem và đối chiếu chi tiết các khoản nạp tiền cũng như mua sắm game của bạn.</p>
      </div>
      
      <a href="${pageContext.request.contextPath}/recharge" class="btn gf-border gf-shadow-sm gf-press fw-bold py-2.5 px-4 d-inline-flex align-items-center justify-content-center gap-2 align-self-sm-center" style="background: var(--gf-yellow); border-radius: 12px; font-size: 15px;">
        <i data-lucide="wallet-cards" width="18" height="18"></i> Nạp tiền vào ví
      </a>
    </div>

    <!-- STAT CARDS (Neo-brutalism) -->
    <div class="row g-4 mb-5">
      <!-- Card 1: Số dư hiện tại -->
      <div class="col-sm-6 col-lg-3">
        <div class="gf-stat-card p-4 rounded-4 gf-border gf-shadow d-flex flex-column justify-content-between h-100" style="background: #94FFB4;">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="fw-black text-dark" style="font-size: 13px;">SỐ DƯ VÍ</span>
            <div class="gf-stat-icon-wrapper bg-white rounded-circle d-grid place-items-center border border-2 border-black" style="width:32px; height:32px; place-items:center;">
              <i data-lucide="wallet" width="16" height="16" class="text-dark"></i>
            </div>
          </div>
          <h3 class="fw-black fw-bold text-dark mb-0 mt-3" style="font-size: 26px; font-weight:900 !important; text-shadow: 1px 1px 0 #fff;">
            <fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />đ
          </h3>
          <span class="small fw-bold text-dark-50 mt-1" style="font-size: 11px;">Khả dụng cho mọi tựa game</span>
        </div>
      </div>

      <!-- Card 2: Chi tiêu trong tháng -->
      <div class="col-sm-6 col-lg-3">
        <div class="gf-stat-card p-4 rounded-4 gf-border gf-shadow d-flex flex-column justify-content-between h-100" style="background: #fb7185;">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="fw-black text-white" style="font-size: 13px;">CHI TIÊU THÁNG NÀY</span>
            <div class="gf-stat-icon-wrapper bg-white rounded-circle d-grid place-items-center border border-2 border-black" style="width:32px; height:32px; place-items:center;">
              <i data-lucide="shopping-bag" width="16" height="16" class="text-dark"></i>
            </div>
          </div>
          <h3 class="fw-black fw-bold text-white mb-0 mt-3" style="font-size: 26px; font-weight:900 !important; text-shadow: 1.5px 1.5px 0 #000;">
            <fmt:formatNumber value="${totalSpentThisMonth}" type="number" maxFractionDigits="0" />đ
          </h3>
          <span class="small fw-bold text-white-50 mt-1" style="font-size: 11px; color: #ffe4e6 !important;">Khoản chi mua game/phần mềm</span>
        </div>
      </div>

      <!-- Card 3: Số lượng giao dịch -->
      <div class="col-sm-6 col-lg-3">
        <div class="gf-stat-card p-4 rounded-4 gf-border gf-shadow d-flex flex-column justify-content-between h-100" style="background: var(--gf-lavender);">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="fw-black text-dark" style="font-size: 13px;">TỔNG GIAO DỊCH THÁNG NÀY</span>
            <div class="gf-stat-icon-wrapper bg-white rounded-circle d-grid place-items-center border border-2 border-black" style="width:32px; height:32px; place-items:center;">
              <i data-lucide="arrow-left-right" width="16" height="16" class="text-dark"></i>
            </div>
          </div>
          <h3 class="fw-black fw-bold text-dark mb-0 mt-3" style="font-size: 26px; font-weight:900 !important; text-shadow: 1px 1px 0 #fff;">
            ${transactionCountThisMonth} giao dịch
          </h3>
          <span class="small fw-bold text-dark-50 mt-1" style="font-size: 11px;">Bao gồm nạp tiền và mua game</span>
        </div>
      </div>

      <!-- Card 4: Chu kỳ thống kê -->
      <div class="col-sm-6 col-lg-3">
        <div class="gf-stat-card p-4 rounded-4 gf-border gf-shadow d-flex flex-column justify-content-between h-100" style="background: var(--gf-blue);">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="fw-black text-dark" style="font-size: 13px;">CHU KỲ THỐNG KÊ</span>
            <div class="gf-stat-icon-wrapper bg-white rounded-circle d-grid place-items-center border border-2 border-black" style="width:32px; height:32px; place-items:center;">
              <i data-lucide="calendar" width="16" height="16" class="text-dark"></i>
            </div>
          </div>
          <h3 class="fw-black fw-bold text-dark mb-0 mt-3" style="font-size: 26px; font-weight:900 !important; text-shadow: 1px 1px 0 #fff;">
            ${currentMonthYear}
          </h3>
        </div>
      </div>
    </div>

    <!-- MAIN CARD TABLE CONTENT -->
    <div class="bg-white gf-border rounded-4 gf-shadow-sm p-4">
        
        <!-- TOOLBAR -->
        <div class="row g-3 align-items-center justify-content-between mb-4 pb-3 border-bottom border-2 border-black">
          <!-- Filter Tabs -->
          <div class="col-12 col-md-auto">
            <div class="d-flex flex-wrap align-items-center gap-2" id="txnFilterBtnGroup">
              <button class="btn btn-sm gf-border-2 fw-bold px-3 py-2 active" data-filter="all" style="border-radius: 8px; font-size: 13px; background: var(--gf-green);">Tất cả</button>
              <button class="btn btn-sm gf-border-2 fw-bold px-3 py-2 bg-light text-dark" data-filter="PURCHASE" style="border-radius: 8px; font-size: 13px;">Mua Game</button>
              <button class="btn btn-sm gf-border-2 fw-bold px-3 py-2 bg-light text-dark" data-filter="RECHARGE" style="border-radius: 8px; font-size: 13px;">Nạp Tiền</button>
            </div>
          </div>
          
          <!-- Search and Date Filter -->
          <div class="col-12 col-md-auto d-flex flex-wrap align-items-center gap-3">
            <!-- Refresh button -->
            <button type="button" onclick="window.location.reload();" class="btn btn-light gf-border-2 fw-bold py-1.5 px-3 d-inline-flex align-items-center gap-2" style="border-radius: 8px; font-size: 13px; height:38px;">
              <i data-lucide="refresh-cw" width="14" height="14"></i> Làm mới
            </button>
            
            <!-- Search input -->
            <div class="d-flex align-items-center bg-white gf-border-2 rounded-3 px-3 py-1.5" style="border-radius: 8px; height: 38px;">
              <i data-lucide="search" width="16" height="16" class="text-secondary"></i>
              <input id="txnSearchInput" type="text" placeholder="Tìm kiếm giao dịch..." class="border-0 bg-transparent ms-2 fw-semibold" style="outline:none; width:180px; font-size: 13px;">
            </div>
          </div>
        </div>

        <!-- TRANSACTION TABLE WRAPPED IN SLIDER SHELL -->
        <div class="gf-table-slider-shell">
          <button id="txnPrevPageBtn" class="gf-side-nav-btn gf-side-left" type="button" aria-label="Trang trước">
            <i data-lucide="chevron-left" width="24" height="24"></i>
          </button>

          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 gf-txn-table" style="border-collapse: separate; border-spacing: 0 8px;">
              <thead>
                <tr class="text-secondary" style="font-size: 12px; border-bottom: 2px solid #000 !important;">
                  <th scope="col" class="fw-bold px-3" style="width: 15%;">NGÀY GIAO DỊCH</th>
                  <th scope="col" class="fw-bold" style="width: 35%;">MÔ TẢ GIAO DỊCH</th>
                <th scope="col" class="fw-bold" style="width: 15%;">MÃ GIAO DỊCH</th>
                <th scope="col" class="fw-bold text-center" style="width: 10%;">LOẠI</th>
                <th scope="col" class="fw-bold text-end" style="width: 13%;">SỐ TIỀN THAY ĐỔI</th>
                <th scope="col" class="fw-bold text-end px-3" style="width: 12%;">SỐ DƯ SAU GD</th>
              </tr>
            </thead>
            <tbody id="txnTableBody">
              <c:forEach var="tx" items="${transactions}">
                <tr class="txn-row-item" 
                    data-id="${tx.id}" 
                    data-type="${tx.type}" 
                    data-code="${fn:toLowerCase(tx.code)}" 
                    data-desc="${fn:escapeXml(fn:toLowerCase(tx.description))}">
                  
                  <!-- Ngày giao dịch -->
                  <td class="px-3 fw-bold small text-secondary">
                    ${tx.dateFormatted}
                  </td>
                  
                  <!-- Mô tả chi tiết -->
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <c:choose>
                        <c:when test="${tx.type == 'RECHARGE'}">
                          <div class="d-grid place-items-center rounded-circle border border-2 border-black" style="width: 30px; height: 30px; background: #94FFB4; place-items:center;">
                            <i data-lucide="arrow-down-left" width="14" height="14" class="text-dark"></i>
                          </div>
                          <div>
                            <strong class="text-dark" style="font-size: 14px;">Nạp tiền vào ví GameForge</strong>
                            <span class="d-block small text-secondary" style="font-size: 11px;">Cổng thanh toán tự động</span>
                          </div>
                        </c:when>
                        <c:otherwise>
                          <div class="d-grid place-items-center rounded-circle border border-2 border-black" style="width: 30px; height: 30px; background: #fb7185; place-items:center;">
                            <i data-lucide="shopping-cart" width="14" height="14" class="text-dark"></i>
                          </div>
                          <div style="min-width: 0;">
                            <strong class="text-dark text-truncate d-block" style="font-size: 14px; max-width: 300px;" title="${fn:escapeXml(tx.description)}">
                              ${tx.description}
                            </strong>
                            <span class="d-block small text-secondary" style="font-size: 11px;">
                              <c:choose>
                                <c:when test="${tx.paymentMethod == 'GAMEFORGE' || tx.paymentMethod == 'WALLET'}">Thanh toán bằng ví GameForge</c:when>
                                <c:when test="${tx.paymentMethod == 'CARD'}">Thanh toán bằng thẻ Visa/Mastercard</c:when>
                                <c:when test="${tx.paymentMethod == 'BANK'}">Thanh toán bằng chuyển khoản ngân hàng</c:when>
                                <c:when test="${tx.paymentMethod == 'MOMO'}">Thanh toán bằng ví MoMo</c:when>
                                <c:when test="${tx.paymentMethod == 'ZALOPAY'}">Thanh toán bằng ví ZaloPay</c:when>
                                <c:otherwise>Thanh toán qua ${tx.paymentMethod}</c:otherwise>
                              </c:choose>
                            </span>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </td>
                  
                  <!-- Mã tham chiếu/mã giao dịch -->
                  <td class="fw-bold font-monospace" style="font-size: 12px;">
                    ${tx.code}
                  </td>
                  
                  <!-- Loại giao dịch badge -->
                  <td class="text-center">
                    <c:choose>
                      <c:when test="${tx.type == 'RECHARGE'}">
                        <span class="badge border border-2 border-black fw-bold py-1 px-2.5 text-dark" style="background: #E8FDF0; border-radius: 6px; font-size:10px;">
                          NẠP TIỀN
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge border border-2 border-black fw-bold py-1 px-2.5 text-dark" style="background: #FFF1F2; border-radius: 6px; font-size:10px;">
                          MUA GAME
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  
                  <!-- Biến động số tiền -->
                  <td class="text-end fw-black fw-bold" style="font-size: 14px;">
                    <c:choose>
                      <c:when test="${tx.type == 'RECHARGE'}">
                        <span class="text-success" style="font-weight: 900;">
                          +<fmt:formatNumber value="${tx.amount}" type="number" maxFractionDigits="0" />đ
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="text-danger" style="font-weight: 900;">
                          -<fmt:formatNumber value="${tx.amount}" type="number" maxFractionDigits="0" />đ
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  
                  <!-- Số dư ví sau giao dịch -->
                  <td class="px-3 text-end fw-bold text-dark" style="font-size: 14px;">
                    <fmt:formatNumber value="${tx.runningBalance}" type="number" maxFractionDigits="0" />đ
                  </td>
                </tr>
              </c:forEach>

              <c:if test="${empty transactions}">
                <tr id="emptyTxnRow">
                  <td colspan="6" class="text-center py-5">
                    <div class="mx-auto mb-3 d-grid place-items-center rounded-4 gf-border text-dark" style="width: 54px; height: 54px; background: var(--gf-pink); place-items:center;">
                      <i data-lucide="receipt-text" width="24" height="24"></i>
                    </div>
                    <h5 class="fw-black">Không có lịch sử giao dịch</h5>
                    <p class="text-secondary small mb-0">Bạn chưa thực hiện bất cứ giao dịch nạp ví hoặc mua sắm nào.</p>
                  </td>
                </tr>
              </c:if>
            </tbody>
          </table>
        </div>

        <button id="txnNextPageBtn" class="gf-side-nav-btn gf-side-right" type="button" aria-label="Trang tiếp theo">
          <i data-lucide="chevron-right" width="24" height="24"></i>
        </button>
      </div>

      <!-- PAGINATION CONTROLS (Neo-brutalism) -->
      <div id="txnPaginationContainer" class="d-flex align-items-center justify-content-center gap-3 mt-4 pt-3 border-top border-1 border-light">
        <div id="txnPageNumbers" class="d-flex align-items-center gap-2">
          <!-- Page numbers dynamically injected here -->
        </div>
      </div>

    </div>

  </main>

  <!-- FOOTER -->
  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Lịch sử giao dịch ví Neo-brutalism.
    </div>
  </footer>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/transactions.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
