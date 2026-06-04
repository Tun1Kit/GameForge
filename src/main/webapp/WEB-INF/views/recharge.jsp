<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Nạp Tiền Vào Ví</title>

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
  <!-- Thêm thư viện canvas-confetti để bắn pháo hoa khi thanh toán thành công -->
  <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/recharge.css">
</head>

<body class="position-relative" style="min-height: 100vh; overflow-x: hidden;">
  <!-- Trang trí nổi trôi phong cách Neo-brutalism -->
  <div class="gf-decor-pill" style="top: 18%; left: 3%; background: var(--gf-yellow); transform: rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top: 72%; left: 2%; background: var(--gf-pink); transform: rotate(-20deg); width: 30px; height: 30px;"></div>
  <div class="gf-decor-pill" style="top: 22%; right: 4%; background: var(--gf-blue); transform: rotate(45deg); width: 28px; height: 28px; border-radius: 50%;"></div>
  <div class="gf-decor-pill" style="top: 65%; right: 3%; background: #94FFB4; transform: rotate(-10deg);"></div>

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
                  <span class="fw-black text-success" style="font-size: 14px; font-weight: 900 !important;" id="headerWalletBalanceText">
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
    <a href="${pageContext.request.contextPath}/library" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-pill d-inline-flex align-items-center gap-2 py-1.5 px-3 mb-4">
      <i data-lucide="arrow-left" width="14" height="14"></i> Quay lại trang cá nhân
    </a>
    
    <div class="row align-items-start g-5">
      
      <!-- PHẦN BÊN TRÁI: CHỌN SỐ TIỀN & PHƯƠNG THỨC -->
      <div class="col-lg-8">
        <h1 class="fw-black fw-bold mb-1">Nạp tiền vào <span class="text-success" style="text-shadow: 1px 1px 0 #000;">ví</span></h1>
        <p class="fw-semibold text-secondary gf-muted mb-4">Nạp tiền để mua game, DLC và nhiều nội dung hấp dẫn khác.</p>
        
        <!-- BƯỚC 1: CHỌN SỐ TIỀN -->
        <h3 class="fs-5 fw-black fw-bold mb-3">Chọn số tiền nạp</h3>
        <div class="row g-3 mb-4">
          <!-- Gói 100k -->
          <div class="col-sm-4">
            <div class="amount-card active gf-border rounded-4 gf-shadow-sm p-3 text-center" data-amount="100000" data-received="100000">
              <span class="badge border border-2 border-black text-dark fw-bold mb-2 px-3 py-1" style="background: var(--gf-green); border-radius: 999px; font-size: 10px;">Phổ biến</span>
              <h4 class="fw-black text-dark mb-1">100.000đ</h4>
              <span class="small text-secondary gf-muted">Nhận 100.000đ</span>
            </div>
          </div>
          <!-- Gói 200k -->
          <div class="col-sm-4">
            <div class="amount-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-amount="200000" data-received="200000">
              <span class="d-block mb-2" style="height: 24px;"></span>
              <h4 class="fw-black text-dark mb-1">200.000đ</h4>
              <span class="small text-secondary gf-muted">Nhận 200.000đ</span>
            </div>
          </div>
          <!-- Gói 500k -->
          <div class="col-sm-4">
            <div class="amount-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-amount="500000" data-bonus="30000" data-received="530000">
              <span class="badge border border-2 border-black text-dark fw-bold mb-2 px-3 py-1" style="background: var(--gf-yellow); border-radius: 999px; font-size: 10px;">Ưu đãi</span>
              <h4 class="fw-black text-dark mb-1">500.000đ</h4>
              <span class="small text-success fw-bold">Nhận 530.000đ <span class="text-danger">(+30K)</span></span>
            </div>
          </div>
          <!-- Gói 1M -->
          <div class="col-sm-4">
            <div class="amount-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-amount="1000000" data-bonus="80000" data-received="1080000">
              <h4 class="fw-black text-dark mb-1">1.000.000đ</h4>
              <span class="small text-success fw-bold">Nhận 1.080.000đ <span class="text-danger">(+80K)</span></span>
            </div>
          </div>
          <!-- Gói 2M -->
          <div class="col-sm-4">
            <div class="amount-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-amount="2000000" data-bonus="220000" data-received="2220000">
              <h4 class="fw-black text-dark mb-1">2.000.000đ</h4>
              <span class="small text-success fw-bold">Nhận 2.220.000đ <span class="text-danger">(+220K)</span></span>
            </div>
          </div>
          <!-- Gói Khác -->
          <div class="col-sm-4">
            <div class="amount-card gf-border rounded-4 gf-shadow-sm p-3 text-center d-flex flex-column justify-content-center align-items-center" id="customAmountBtn" style="height: 105px;">
              <i data-lucide="keyboard" width="24" height="24" class="mb-1 text-secondary"></i>
              <h5 class="fw-bold mb-0" style="font-size: 14px;">Nhập số tiền khác</h5>
              <span class="small text-secondary gf-muted">Tự nhập số tiền nạp</span>
            </div>
          </div>
        </div>
        
        <!-- Ô NHẬP TIỀN KHÁC (ẨN BAN ĐẦU) -->
        <div class="mb-4 d-none" id="customAmountInputContainer">
          <label class="form-label fw-bold text-dark" style="font-size: 13px;">Nhập số tiền nạp (VND)</label>
          <div class="d-flex gap-2">
            <input type="number" id="customAmountInput" placeholder="Ví dụ: 150000" class="form-control gf-border-2 fw-semibold px-3 py-2" style="border-radius: 8px; font-size: 14px; max-width: 300px;">
            <button type="button" onclick="applyCustomAmount()" class="btn gf-border gf-shadow-sm gf-press fw-bold px-4" style="background: var(--gf-green); border-radius: 8px;">Áp dụng</button>
          </div>
        </div>
        
        <!-- BƯỚC 2: CHỌN PHƯƠNG THỨC THANH TOÁN -->
        <h3 class="fs-5 fw-black fw-bold mb-3">Chọn phương thức thanh toán</h3>
        <div class="row g-3">
          <!-- MoMo -->
          <div class="col-sm-3">
            <div class="payment-card active gf-border rounded-4 gf-shadow-sm p-3 text-center" data-method="MOMO" data-label="MoMo">
              <div class="mx-auto bg-white gf-border-2 rounded-3 d-grid place-items-center mb-2" style="width:40px; height:40px; background: #e21c70 !important;">
                <span class="text-white fw-black" style="font-size: 11px;">momo</span>
              </div>
              <h5 class="fw-bold mb-1" style="font-size: 13px;">MoMo</h5>
              <span class="small text-secondary gf-muted" style="font-size: 11px;">Thanh toán qua ví MoMo</span>
            </div>
          </div>
          <!-- ZaloPay -->
          <div class="col-sm-3">
            <div class="payment-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-method="ZALOPAY" data-label="ZaloPay">
              <div class="mx-auto bg-white gf-border-2 rounded-3 d-grid place-items-center mb-2" style="width:40px; height:40px; background: #008fe5 !important;">
                <span class="text-white fw-black" style="font-size: 11px;">Zalo</span>
              </div>
              <h5 class="fw-bold mb-1" style="font-size: 13px;">ZaloPay</h5>
              <span class="small text-secondary gf-muted" style="font-size: 11px;">Thanh toán qua ZaloPay</span>
            </div>
          </div>
          <!-- Bank Transfer -->
          <div class="col-sm-3">
            <div class="payment-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-method="BANK" data-label="Chuyển khoản">
              <div class="mx-auto bg-white gf-border-2 rounded-3 d-grid place-items-center mb-2" style="width:40px; height:40px; background: #ff7634 !important;">
                <i data-lucide="landmark" width="18" height="18" class="text-white"></i>
              </div>
              <h5 class="fw-bold mb-1" style="font-size: 13px;">Chuyển khoản</h5>
              <span class="small text-secondary gf-muted" style="font-size: 11px;">Thanh toán qua ngân hàng</span>
            </div>
          </div>
          <!-- Phone Card -->
          <div class="col-sm-3">
            <div class="payment-card gf-border rounded-4 gf-shadow-sm p-3 text-center" data-method="CARD" data-label="Thẻ cào">
              <div class="mx-auto bg-white gf-border-2 rounded-3 d-grid place-items-center mb-2" style="width:40px; height:40px; background: #b97dff !important;">
                <i data-lucide="credit-card" width="18" height="18" class="text-white"></i>
              </div>
              <h5 class="fw-bold mb-1" style="font-size: 13px;">Thẻ cào</h5>
              <span class="small text-secondary gf-muted" style="font-size: 11px;">Nạp bằng thẻ điện thoại</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- PHẦN BÊN PHẢI: CHI TIẾT GIAO DỊCH -->
      <div class="col-lg-4">
        <!-- BẢNG TỔNG HỢP NẠP -->
        <div class="bg-white gf-border rounded-4 gf-shadow p-0 mb-4" style="overflow: hidden;">
          <div class="p-3 fw-black fw-bold d-flex align-items-center gap-2 text-dark" style="background: var(--gf-yellow); border-bottom: 3px solid #000;">
            <i data-lucide="wallet" width="18" height="18"></i> Thông tin nạp tiền
          </div>
          
          <div class="p-4">
            <div class="d-flex align-items-center justify-content-between mb-3 border-bottom pb-2">
              <span class="fw-bold text-secondary gf-muted">Số tiền nạp</span>
              <span class="fw-black text-dark" id="previewRechargeAmount" style="font-weight: 900 !important;">100.000đ</span>
            </div>
            
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="fw-bold text-secondary gf-muted">Số tiền khuyến mãi</span>
              <span class="fw-black text-dark" id="previewBonusAmount" style="font-weight: 900 !important;">0đ</span>
            </div>
            
            <div class="d-flex align-items-center justify-content-between mb-4 pt-2 border-top border-2 border-dark">
              <span class="fs-6 fw-bold">Tổng nhận được</span>
              <span class="fs-4 fw-black text-success" id="previewTotalReceived" style="font-weight: 900 !important;">100.000đ</span>
            </div>
            
            <!-- THÔNG TIN BẢO MẬT -->
            <div class="p-3 bg-light gf-border rounded-3 mb-4 d-flex align-items-start gap-3" style="border-radius: 8px;">
              <i data-lucide="shield-check" width="22" height="22" class="text-success mt-0.5 flex-shrink-0"></i>
              <div>
                <h5 class="fw-bold mb-1" style="font-size: 13px;">Bảo mật & An toàn</h5>
                <p class="small text-secondary gf-muted mb-0" style="font-size: 11px; line-height: 1.4;">Mọi giao dịch đều được mã hóa và bảo mật tuyệt đối. Thông tin thanh toán của bạn được bảo vệ an toàn.</p>
              </div>
            </div>
            
            <button type="button" onclick="triggerRechargeModal()" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5 d-flex align-items-center justify-content-center gap-2" style="background: var(--gf-green); border-radius: 10px;">
              <i data-lucide="lock" width="16" height="16"></i> Xác nhận nạp tiền
            </button>
          </div>
        </div>
        
        <!-- THÔNG TIN LƯU Ý -->
        <div class="p-4 bg-white gf-border rounded-4 gf-shadow-sm">
          <h5 class="fw-black fw-bold mb-3 d-flex align-items-center gap-2" style="font-size: 14px;">
            <i data-lucide="info" width="16" height="16" class="text-primary"></i> Lưu ý quan trọng
          </h5>
          <ul class="small text-secondary gf-muted ps-3 mb-0" style="line-height: 1.6; font-size: 12px;">
            <li class="mb-2">Tiền sẽ được cộng ngay vào ví sau khi thanh toán thành công.</li>
            <li class="mb-2">Không hỗ trợ hoàn tiền với mọi giao dịch nạp tiền.</li>
            <li>Liên hệ hỗ trợ nếu bạn gặp vấn đề về giao dịch.</li>
          </ul>
        </div>
      </div>
      
    </div>
  </main>

  <!-- MODAL QUÉT MÃ QR THANH TOÁN GIẢ LẬP -->
  <div class="modal fade" id="qrSimulationModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true" style="z-index: 9999;">
    <div class="modal-dialog modal-dialog-centered" style="z-index: 10000;">
      <div class="modal-content gf-border rounded-4 gf-shadow" style="background: #FFFDF8; position: relative; overflow: hidden;">
        <div class="modal-header border-bottom border-2 border-dark" style="background: var(--gf-lavender);">
          <h5 class="modal-title fw-black fw-bold text-dark d-flex align-items-center gap-2">
            <i data-lucide="qr-code" width="20" height="20"></i> Quét mã QR thanh toán giả lập
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        
        <div class="modal-body p-4 text-center">
          <p class="fw-semibold mb-3">Vui lòng quét mã bên dưới để nạp tiền vào ví:</p>
          
          <!-- KHU VỰC HIỂN THỊ MÃ QR ĐỘNG -->
          <div class="mx-auto gf-border p-3 bg-white mb-3" style="width: 250px; height: 250px; border-radius: 12px; display: grid; place-items: center;">
            <img id="simulatedQrImage" src="" alt="Simulated QR Code" style="width: 220px; height: 220px;">
          </div>
          
          <!-- CHI TIẾT GIAO DỊCH GIẢ LẬP -->
          <div class="p-3 bg-light gf-border rounded-3 text-start mb-4" style="border-radius: 8px; font-size: 13px;">
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary gf-muted">Ngân hàng:</span>
              <strong class="text-dark">MBBank (Ngân hàng Quân đội)</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary gf-muted">Số tài khoản:</span>
              <strong class="text-dark">1902848123984</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary gf-muted">Tên thụ hưởng:</span>
              <strong class="text-dark">GAMEFORGE STORE</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary gf-muted">Số tiền nạp:</span>
              <strong class="text-success" id="qrDetailAmount" style="font-weight: 900;">0đ</strong>
            </div>
            <div class="d-flex justify-content-between">
              <span class="text-secondary gf-muted">Nội dung chuyển khoản:</span>
              <strong class="text-primary" id="qrDetailMessage">GAMEFORGE_RECHARGE</strong>
            </div>
          </div>
          
          <!-- HỘP ĐẾM GIỜ VÀ TRẠNG THÁI -->
          <div class="mb-4 d-flex align-items-center justify-content-center">
            <span class="pulsate-dot"></span>
            <span class="small fw-bold text-secondary" id="qrStatusTimer">Đang chờ chuyển khoản... (05:00)</span>
          </div>
          
          <!-- NÚT BẤM HOÀN TẤT GIAO DỊCH -->
          <button type="button" id="confirmRechargeBtn" onclick="confirmSimulatedRecharge()" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5 d-flex align-items-center justify-content-center gap-2" style="background: var(--gf-green); border-radius: 10px;">
            <i data-lucide="check-circle" width="18" height="18"></i> Tôi đã chuyển khoản thành công / Hoàn tất
          </button>

          <!-- SUCCESS OVERLAY (ẩn mặc định, hiện lên đè QR khi nạp tiền thành công) -->
          <div id="rechargeSuccessOverlay" class="d-none" style="position:absolute; top:0; left:0; right:0; bottom:0; background:#FFFDF8; z-index:10; border-radius: inherit; overflow-y:auto; animation: fadeInOverlay 0.4s ease-out;">
            <div class="p-4 text-center">
              <!-- Checkmark Icon -->
              <div class="mx-auto mb-3" style="width:80px; height:80px; background: #E8FDF0; border: 3px solid var(--gf-green); border-radius: 50%; display:grid; place-items:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#2ECC71" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
              </div>
              
              <h3 class="fw-black fw-bold mb-2" style="color: var(--gf-green); text-shadow: 1px 1px 0 #000;">Thanh toán thành công!</h3>
              <p class="fw-bold mb-1"><span id="rechargeSuccessAmount" class="text-success"></span> đã được cộng vào ví của bạn.</p>
              <p class="small text-secondary mb-3">Giao dịch đã được xác nhận tự động.</p>
              
              <!-- Transaction Details -->
              <div class="p-3 gf-border rounded-3 text-start mb-3" style="font-size: 13px; background: #FAFAF9;">
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Ngân hàng:</span>
                  <strong class="text-dark">MBBank (Ngân hàng Quân đội)</strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Số tài khoản:</span>
                  <strong class="text-dark">1902848123984</strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Tên thụ hưởng:</span>
                  <strong class="text-dark">GAMEFORGE STORE</strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Số tiền:</span>
                  <strong class="text-success" id="rechargeSuccessAmountDetail" style="font-weight:900;"></strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Nội dung chuyển khoản:</span>
                  <strong class="text-primary" id="rechargeSuccessMessage" style="font-size:11px;"></strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Mã giao dịch:</span>
                  <strong class="text-dark" id="rechargeSuccessTxnId"></strong>
                </div>
                <div class="d-flex justify-content-between">
                  <span class="text-secondary">Thời gian xác nhận:</span>
                  <strong class="text-dark" id="rechargeSuccessTimestamp"></strong>
                </div>
              </div>
              
              <!-- Status -->
              <div class="mb-3 d-flex align-items-center justify-content-center gap-2">
                <span style="width:10px;height:10px;background:var(--gf-green);border-radius:50%;display:inline-block;"></span>
                <span class="small fw-bold text-success">Đã xác nhận chuyển khoản</span>
              </div>
              
              <!-- Action Buttons -->
              <button type="button" onclick="closeRechargeSuccess()" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2 d-flex align-items-center justify-content-center gap-2 mb-2" style="background: var(--gf-green); border-radius: 10px;">
                <i data-lucide="wallet" width="18" height="18"></i> Về ví của tôi
              </button>
              <button type="button" onclick="window.location.href=window.GAMEFORGE_CONTEXT_PATH+'/transactions'" class="btn w-100 gf-border gf-press fw-bold py-2 d-flex align-items-center justify-content-center gap-2" style="background: #fff; border-radius: 10px;">
                <i data-lucide="file-text" width="18" height="18"></i> Xem lịch sử giao dịch
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Nạp tiền giả lập Neo-brutalism.
    </div>
  </footer>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_WALLET_BALANCE = ${not empty walletBalance ? walletBalance : 0};
    window.GAMEFORGE_USER_ID = '${not empty currentUser.id ? currentUser.id : ""}';
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/recharge.js"></script>
</body>
</html>
