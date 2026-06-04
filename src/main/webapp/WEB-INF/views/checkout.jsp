<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Giỏ hàng & Thanh toán - GameForge</title>

  <!-- CSRF Meta Tags (Spring Security) -->
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />

  <script>
    (function () {
      try {
        if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
          document.documentElement.classList.add('gf-dark-mode');
        }
      } catch (e) {}
    })();
  </script>

  <!-- Bootstrap 5 + Lucide + CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css">
</head>

<body>
  <!-- NAVBAR -->
  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold d-none d-sm-inline text-dark">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

        <div class="d-flex align-items-center gap-2 gap-sm-3">
          <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-press fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3" style="background: var(--gf-card-bg); color: var(--gf-text-main);">
            <i data-lucide="home" width="16" height="16"></i> <span class="d-none d-sm-inline">Trang chủ</span>
          </a>

          <button id="themeButton" class="btn gf-border-2 gf-shadow-sm gf-press bg-dark text-white fw-bold rounded-3 d-flex align-items-center gap-2" type="button">
            <span id="icon-light"><i data-lucide="sun" width="16" height="16"></i></span>
            <span id="icon-dark" class="d-none"><i data-lucide="moon" width="16" height="16" style="color:#fde047"></i></span>
            <span id="theme-text" class="d-none d-sm-inline">Light</span>
          </button>
        </div>
      </div>
    </div>
  </nav>

  <c:if test="${not empty param.error}">
    <div class="container-xl mt-3">
      <div class="alert alert-danger d-flex align-items-center gap-2 fw-bold" role="alert">
        <i data-lucide="alert-circle" width="18" height="18"></i>
        <c:choose>
          <c:when test="${param.error == 'wallet_not_found'}">Bạn chưa có ví GameForge. Vui lòng nạp tiền trước.</c:when>
          <c:when test="${param.error == 'insufficient_balance'}">Số dư ví không đủ. Vui lòng nạp thêm tiền.</c:when>
          <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại.</c:otherwise>
        </c:choose>
      </div>
    </div>
  </c:if>

  <!-- MAIN CHECKOUT SECTION -->
  <main class="gf-checkout-container container-xl">
    <form action="${pageContext.request.contextPath}/checkout/process" method="post" id="checkoutForm">
      <div class="row g-4">
        
        <!-- CỘT TRÁI: DANH SÁCH SẢN PHẨM & TỔNG TIỀN -->
        <div class="col-lg-7">
          <div class="gf-checkout-card d-flex flex-column gap-4">
            
            <!-- Tiêu đề giỏ hàng -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
              <div class="d-flex align-items-center gap-2">
                <div class="bg-success border border-3 rounded-3 d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; background: var(--gf-green); border-color: var(--gf-ink) !important;">
                  <i data-lucide="shopping-bag" width="22" height="22"></i>
                </div>
                <div>
                  <h1 class="fs-4 fw-black fw-bold mb-0">Giỏ hàng</h1>
                  <span class="small fw-bold" style="color: var(--gf-muted);" id="cartItemCount">${fn:length(cartItems)} sản phẩm</span>
                </div>
              </div>

              <!-- Nút quay lại -->
              <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-shadow-sm gf-press rounded-3 d-flex align-items-center gap-1 py-1 px-3 small" style="background: var(--gf-card-bg); color: var(--gf-text-main);">
                <i data-lucide="arrow-left" width="14" height="14"></i> Tiếp tục mua sắm
              </a>
            </div>

            <!-- Loop danh sách sản phẩm (render bằng JS) -->
            <div id="gfCartItemsWrapper"></div>

            <!-- Tóm tắt dòng tiền -->
            <div class="border-top border-2 pt-4 mt-4" style="border-color: var(--gf-ink) !important;">
              <div class="d-flex justify-content-between align-items-center mb-2 fw-semibold">
                <span class="text-secondary">Giá gốc</span>
                <span id="subtotalPrice" class="fw-bold"><fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0" />₫</span>
              </div>
              <div class="d-flex justify-content-between align-items-center mb-3 fw-semibold">
                <span class="text-secondary">Giảm giá</span>
                <span id="discountPrice" class="text-danger fw-bold">-<fmt:formatNumber value="${discount}" type="number" maxFractionDigits="0" />₫</span>
              </div>
              <div class="d-flex justify-content-between align-items-center border-top border-2 pt-3 mb-4" style="border-color: var(--gf-ink) !important;">
                <div>
                  <span class="fs-5 fw-black fw-bold block">Tổng tiền</span>
                  <div class="small text-secondary" style="font-size:11px;">Đã bao gồm VAT (nếu có)</div>
                </div>
                <span id="totalPrice" class="display-6 fw-black fw-bold" style="color:var(--gf-green);"><fmt:formatNumber value="${total}" type="number" maxFractionDigits="0" />₫</span>
              </div>

              <!-- Nút thanh toán & Quyền lợi cam kết -->
              <div class="row align-items-center g-3">
                <div class="col-sm-6">
                  <button type="button" onclick="handleCheckoutPay()" class="gf-pay-btn gf-press" ${empty cartItems ? 'disabled' : ''}>
                    <i data-lucide="lock" width="18" height="18"></i> Thanh toán an toàn
                  </button>
                </div>
                <div class="col-sm-6">
                  <div class="d-flex flex-column gap-1 small fw-bold text-secondary">
                    <span class="d-flex align-items-center gap-1"><i data-lucide="shield-check" class="text-success" width="16" height="16"></i> Thanh toán bảo mật</span>
                    <span class="d-flex align-items-center gap-1"><i data-lucide="headphones" class="text-success" width="16" height="16"></i> Hỗ trợ kỹ thuật 24/7</span>
                    <span class="d-flex align-items-center gap-1"><i data-lucide="refresh-cw" class="text-success" width="16" height="16"></i> Hoàn tiền 100% nếu key lỗi</span>
                  </div>
                </div>
              </div>

            </div>

          </div>
        </div>

        <!-- CỘT PHẢI: PHƯƠNG THỨC & THÔNG TIN THANH TOÁN -->
        <div class="col-lg-5 mt-4 mt-lg-0">
          <div class="gf-checkout-card d-flex flex-column gap-4">
            
            <!-- BƯỚC 1: PHƯƠNG THỨC THANH TOÁN -->
            <div class="gf-checkout-step-card p-4 gf-border rounded-4 gf-shadow-sm mb-4">
              <h2 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
                <span class="bg-warning border border-3 rounded-circle d-inline-grid place-items-center fw-black" style="width:28px; height:28px; font-size:13px; border-color: var(--gf-ink) !important; color: var(--gf-ink);">1</span>
                Thông tin thanh toán
              </h2>

              <div class="row g-2 mb-3">
                <div class="col-4">
                  <div class="gf-payment-option active" data-method="WALLET">
                    <i data-lucide="wallet" class="mb-1" width="22" height="22"></i>
                    <div class="small fw-black" style="font-size:11px;">Ví điện tử</div>
                    <div class="text-secondary" style="font-size:9px;">ZaloPay, MoMo</div>
                  </div>
                </div>
                <div class="col-4">
                  <div class="gf-payment-option" data-method="CARD">
                    <i data-lucide="credit-card" class="mb-1" width="22" height="22"></i>
                    <div class="small fw-black" style="font-size:11px;">Thẻ Visa</div>
                    <div class="text-secondary" style="font-size:9px;">Visa, Master</div>
                  </div>
                </div>
                <div class="col-4">
                  <div class="gf-payment-option" data-method="BANK">
                    <i data-lucide="landmark" class="mb-1" width="22" height="22"></i>
                    <div class="small fw-black" style="font-size:11px;">Chuyển khoản</div>
                    <div class="text-secondary" style="font-size:9px;">Internet Banking / QR</div>
                  </div>
                </div>
              </div>

              <!-- Input ẩn chứa phương thức được chọn -->
              <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="WALLET">

              <!-- Form trường động tùy biến theo Payment Method -->
              <div id="paymentFields" class="p-3 border border-2 rounded-3" style="background: var(--gf-card-bg); border-color: var(--gf-ink) !important;">
                <!-- WALLET FIELDS -->
                <div class="payment-group" id="fields-WALLET">
                  <label class="form-label fw-bold small mb-1">Chọn Ví Điện Tử *</label>
                  <select class="gf-checkout-select mb-2" name="walletProvider" id="walletProviderSelect">
                    <option value="">-- Chọn ví điện tử --</option>
                    <option value="MOMO">Ví MoMo</option>
                    <option value="ZALOPAY">Ví ZaloPay</option>
                    <option value="GAMEFORGE" data-balance="${walletBalance}">Ví GameForge (Số dư: <fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />₫)</option>
                  </select>
                  <!-- Hiển thị số dư ví GameForge khi được chọn -->
                  <div id="gameforgeWalletInfo" class="d-none mb-2 p-2 border border-2 rounded-3 d-flex align-items-center justify-content-between" style="background: #F0FDF4; border-color: var(--gf-green) !important;">
                    <span class="small fw-bold text-secondary">Số dư ví GameForge:</span>
                    <span class="fw-black text-success" id="checkoutWalletBalanceDisplay" style="font-weight: 900 !important;"><fmt:formatNumber value="${walletBalance}" type="number" maxFractionDigits="0" />₫</span>
                  </div>
                  <label class="form-label fw-bold small mb-1">Số điện thoại đăng ký ví *</label>
                  <input type="text" class="gf-checkout-input" name="paymentPhone" placeholder="Nhập số điện thoại liên kết ví" required maxlength="11" pattern="\d{10,11}" title="Số điện thoại 10-11 chữ số">
                </div>

                <!-- CARD FIELDS (visa...) -->
                <div class="payment-group d-none" id="fields-CARD">
                  <label class="form-label fw-bold small mb-1">Số thẻ tín dụng *</label>
                  <input type="text" class="gf-checkout-input mb-3" name="cardNumber" placeholder="xxxx xxxx xxxx xxxx" maxlength="19" pattern="\d{13,19}" title="Số thẻ 13-19 chữ số">
                  <div class="row g-2">
                    <div class="col-6">
                      <label class="form-label fw-bold small mb-1">Ngày hết hạn *</label>
                      <input type="text" class="gf-checkout-input" name="cardExpiry" placeholder="MM/YY" maxlength="5" pattern="(0[1-9]|1[0-2])\/\d{2}" title="Định dạng MM/YY (VD: 12/28)">
                    </div>
                    <div class="col-6">
                      <label class="form-label fw-bold small mb-1">Mã bí mật CVV *</label>
                      <input type="password" class="gf-checkout-input" name="cardCvv" placeholder="***" maxlength="4" pattern="\d{3,4}" title="Mã CVV 3-4 chữ số">
                    </div>
                  </div>
                </div>

                <!-- BANK FIELDS -->
                <div class="payment-group d-none" id="fields-BANK">
                  <label class="form-label fw-bold small mb-1">Ngân hàng thụ hưởng *</label>
                  <select class="gf-checkout-select mb-2" name="bankCode">
                    <option value="VCB">Vietcombank</option>
                    <option value="TCB">Techcombank</option>
                    <option value="MB">MB Bank</option>
                  </select>
                  <div class="small fw-semibold text-secondary p-2 border rounded" style="background: var(--gf-card-bg);">
                    Sau khi nhấn Thanh toán, hệ thống sẽ tự động hiển thị mã QR và cú pháp chuyển khoản tương ứng.
                  </div>
                </div>
              </div>
            </div>

            <!-- BƯỚC 2: ĐỊA CHỈ NHẬN HÀNG -->
            <div class="gf-checkout-step-card p-4 gf-border rounded-4 gf-shadow-sm mb-4">
              <h2 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
                <span class="bg-warning border border-3 rounded-circle d-inline-grid place-items-center fw-black" style="width:28px; height:28px; font-size:13px; border-color: var(--gf-ink) !important; color: var(--gf-ink);">2</span>
                Địa chỉ nhận hàng
              </h2>

              <div class="d-flex flex-column gap-3">
                <div>
                  <label class="form-label fw-bold small mb-1">Họ và tên *</label>
                  <input type="text" class="gf-checkout-input" name="fullName" placeholder="Nhập họ và tên đầy đủ" required maxlength="100">
                </div>

                <div>
                  <label class="form-label fw-bold small mb-1">Số điện thoại *</label>
                  <input type="tel" class="gf-checkout-input" name="phone"
                         placeholder="Nhập số điện thoại liên lạc"
                         required minlength="10" maxlength="11"
                         pattern="\d{10,11}"
                         title="Số điện thoại phải là 10-11 chữ số, bắt đầu bằng 0">
                </div>

                <div>
                  <label class="form-label fw-bold small mb-1">Địa chỉ (Số nhà, Tên đường) *</label>
                  <input type="text" class="gf-checkout-input" name="address" placeholder="Nhập địa chỉ nhà cụ thể" required maxlength="300">
                </div>

                <div class="row g-2">
                  <div class="col-6">
                    <label class="form-label fw-bold small mb-1">Tỉnh/Thành phố *</label>
                    <select class="gf-checkout-select" id="provinceSelect" name="province" required>
                      <option value="">-- Chọn Tỉnh/Thành phố --</option>
                    </select>
                  </div>
                  <div class="col-6">
                    <label class="form-label fw-bold small mb-1">Phường/Xã *</label>
                    <select class="gf-checkout-select" id="wardSelect" name="ward" required disabled>
                      <option value="">-- Chọn Phường/Xã --</option>
                    </select>
                  </div>
                </div>

                <div class="d-none">
                  <select id="districtSelect" name="district">
                    <option value=""></option>
                  </select>
                </div>

                <div>
                  <label class="form-label fw-bold small mb-1">Ghi chú thêm (Không bắt buộc)</label>
                  <textarea class="gf-checkout-input" name="notes" placeholder="Ghi chú đơn hàng nếu cần..." rows="2" style="height:auto;" maxlength="500"></textarea>
                </div>
              </div>
            </div>

            <!-- Footer bảo mật chân dung -->
            <div class="gf-security-alert p-3 d-flex align-items-start gap-2 text-secondary">
              <i data-lucide="shield-alert" class="flex-shrink-0 text-success" width="18" height="18"></i>
              <div class="small fw-semibold">
                Thông tin cá nhân và dữ liệu thanh toán của bạn luôn được mã hóa và bảo mật chuẩn tối cao SSL/TLS.
              </div>
            </div>

            <!-- Nút thanh toán trùng đã xóa - chỉ giữ nút bên trái cột giỏ hàng -->

          </div>
        </div>

      </div>
    </form>
  </main>

  <!-- QR PAYMENT MODAL (cho WALLET & BANK) -->
  <div class="modal fade" id="checkoutQrModal" data-bs-backdrop="static" data-bs-config='{"backdrop":"static"}' tabindex="-1" aria-hidden="true" style="z-index: 9999;">
    <div class="modal-dialog modal-dialog-centered" style="z-index: 10000;">
      <div class="modal-content gf-border rounded-4 gf-shadow" style="background: #FFFDF8; position: relative; overflow: hidden;">
        <div class="modal-header border-bottom border-2 border-dark" style="background: var(--gf-lavender);">
          <h5 class="modal-title fw-black fw-bold text-dark d-flex align-items-center gap-2">
            <i data-lucide="qr-code" width="20" height="20"></i> Thanh toán bằng mã QR
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="cancelCheckoutQr()"></button>
        </div>
        <div class="modal-body p-4 text-center">
          <p class="fw-semibold mb-2" id="checkoutQrSubtitle">Quét mã bên dưới để thanh toán:</p>
          <p class="small text-secondary mb-3" id="checkoutQrAmountDisplay" style="font-size:13px;"></p>

          <!-- QR Code -->
          <div class="mx-auto gf-border p-3 bg-white mb-3" style="width: 250px; height: 250px; border-radius: 12px; display: grid; place-items: center;">
            <img id="checkoutQrImage" src="" alt="QR Code" style="width: 220px; height: 220px;">
          </div>

          <!-- Payment details -->
          <div class="p-3 bg-light gf-border rounded-3 text-start mb-4" style="border-radius: 8px; font-size: 13px;">
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary">Ngân hàng:</span>
              <strong class="text-dark">MBBank (Ngân hàng Quân đội)</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary">Số tài khoản:</span>
              <strong class="text-dark">1902848123984</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary">Tên thụ hưởng:</span>
              <strong class="text-dark">GAMEFORGE STORE</strong>
            </div>
            <div class="d-flex justify-content-between mb-1.5">
              <span class="text-secondary">Số tiền:</span>
              <strong class="text-success" id="checkoutQrAmountDetail" style="font-weight:900;">0đ</strong>
            </div>
            <div class="d-flex justify-content-between">
              <span class="text-secondary">Nội dung CK:</span>
              <strong class="text-primary" id="checkoutQrMessage" style="font-size:11px;">GF_CHECKOUT</strong>
            </div>
          </div>

          <!-- Timer -->
          <div class="mb-4 d-flex align-items-center justify-content-center gap-2">
            <span class="pulsate-dot"></span>
            <span class="small fw-bold text-secondary" id="checkoutQrTimer">Đang chờ thanh toán... (05:00)</span>
          </div>

          <!-- Confirm button -->
          <button type="button" id="checkoutQrConfirmBtn" onclick="confirmCheckoutQr()" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2.5 d-flex align-items-center justify-content-center gap-2" style="background: var(--gf-green); border-radius: 10px;">
            <i data-lucide="check-circle" width="18" height="18"></i> Tôi đã thanh toán thành công
          </button>

          <!-- SUCCESS OVERLAY (ẩn mặc định, hiện lên đè QR khi thanh toán thành công) -->
          <div id="checkoutSuccessOverlay" class="d-none" style="position:absolute; top:0; left:0; right:0; bottom:0; background:#FFFDF8; z-index:10; border-radius: inherit; overflow-y:auto;">
            <div class="p-4 text-center">
              <!-- Checkmark Icon -->
              <div class="mx-auto mb-3" style="width:80px; height:80px; background: #E8FDF0; border: 3px solid var(--gf-green); border-radius: 50%; display:grid; place-items:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#2ECC71" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
              </div>
              
              <h3 class="fw-black fw-bold mb-2" style="color: var(--gf-green); text-shadow: 1px 1px 0 #000;">Thanh toán thành công!</h3>
              <p class="fw-bold mb-1"><span id="successAmount" class="text-success"></span> đã được thanh toán.</p>
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
                  <strong class="text-success" id="successAmountDetail" style="font-weight:900;"></strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Nội dung CK:</span>
                  <strong class="text-primary" id="successMessage" style="font-size:11px;"></strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                  <span class="text-secondary">Mã giao dịch:</span>
                  <strong class="text-dark" id="successTxnId"></strong>
                </div>
                <div class="d-flex justify-content-between">
                  <span class="text-secondary">Thời gian xác nhận:</span>
                  <strong class="text-dark" id="successTimestamp"></strong>
                </div>
              </div>
              
              <!-- Status -->
              <div class="mb-3 d-flex align-items-center justify-content-center gap-2">
                <span style="width:10px;height:10px;background:var(--gf-green);border-radius:50%;display:inline-block;"></span>
                <span class="small fw-bold text-success">Đã xác nhận chuyển khoản</span>
              </div>
              
              <!-- Action Buttons -->
              <button type="button" onclick="closeSuccessAndRedirect()" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2 d-flex align-items-center justify-content-center gap-2 mb-2" style="background: var(--gf-green); border-radius: 10px;">
                <i data-lucide="library" width="18" height="18"></i> Về thư viện game
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

  <footer class="bg-dark text-white border-top border-3 border-black py-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Bootstrap 5 Neo Brutalism Checkout Page.
    </div>
  </footer>

  <!-- Thư viện canvas-confetti -->
  <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.GAMEFORGE_WALLET_BALANCE = ${not empty walletBalance ? walletBalance : 0};
    window.GAMEFORGE_CSRF_TOKEN = (function() {
      var m = document.querySelector('meta[name="_csrf"]');
      return m ? m.content : '';
    })();
    window.GAMEFORGE_CSRF_HEADER = (function() {
      var m = document.querySelector('meta[name="_csrf_header"]');
      return m ? m.content : '_csrf';
    })();
    window.GAMEFORGE_CURRENT_USER_ID = '${not empty currentUser.id ? currentUser.id : ""}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/index.js?v=20260528"></script>
  <script>
    window.cartItemsData = [
    <c:forEach var="item" items="${cartItems}" varStatus="vs">
      {
        id: "${item.id}",
        gameId: ${item.game.id},
        price: ${item.game.price},
        title: "${fn:escapeXml(item.game.title)}",
        image: "<c:choose><c:when test='${not empty item.game.mediaList}'>${fn:startsWith(item.game.mediaList[0].mediaUrl, 'http') ? item.game.mediaList[0].mediaUrl : pageContext.request.contextPath.concat(item.game.mediaList[0].mediaUrl)}</c:when><c:otherwise>https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg</c:otherwise></c:choose>",
        originalPrice: ${item.game.originalPrice}
      }<c:if test="${not vs.last}">,</c:if>
    </c:forEach>
    ];
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/checkout.js?v=20250529b"></script>
</body>
</html>