<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Thanh toán thành công - GameForge</title>

  <script>
    (function () {
      try {
        if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
          document.documentElement.classList.add('gf-dark-mode');
        }
      } catch (e) {}
    })();
  </script>

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
          <span class="fs-5 fw-black fw-bold d-none d-sm-inline">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

        <div class="d-flex align-items-center gap-2 gap-sm-3">
          <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
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

  <!-- SUCCESS CONTENT -->
  <main class="container-xl py-5">
    <div class="row justify-content-center">
      <div class="col-lg-8">

        <!-- SUCCESS BANNER -->
        <div class="text-center mb-5">
          <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
               style="width: 80px; height: 80px; background: var(--gf-green); border: 4px solid #000;">
            <i data-lucide="check" width="40" height="40" style="color:#000;"></i>
          </div>
          <h1 class="display-6 fw-black fw-bold mb-2">Thanh toán thành công!</h1>
          <p class="text-secondary">Cảm ơn bạn đã mua sắm tại GameForge</p>
        </div>

        <!-- ORDER INFO CARD -->
        <div class="gf-checkout-card mb-4">
          <h2 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
            <i data-lucide="receceipt" width="20" height="20"></i> Thông tin đơn hàng
          </h2>

          <div class="row g-3">
            <div class="col-sm-6">
              <div class="small text-secondary">Mã đơn hàng</div>
              <div class="fw-black fw-bold fs-5">${order.orderCode}</div>
            </div>
            <div class="col-sm-6">
              <div class="small text-secondary">Ngày mua</div>
              <div class="fw-bold"><fmt:formatDate value="${order.paidAt}" pattern="HH:mm - dd/MM/yyyy" /></div>
            </div>
            <div class="col-sm-6">
              <div class="small text-secondary">Phương thức thanh toán</div>
              <div class="fw-bold">
                <c:choose>
                  <c:when test="${shippingInfo.paymentMethod == 'WALLET'}">Ví GameForge</c:when>
                  <c:when test="${shippingInfo.paymentMethod == 'CARD'}">Thẻ Visa/Master</c:when>
                  <c:when test="${shippingInfo.paymentMethod == 'BANK'}">Chuyển khoản ngân hàng</c:when>
                  <c:otherwise>${shippingInfo.paymentMethod}</c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="col-sm-6">
              <div class="small text-secondary">Trạng thái</div>
              <div class="fw-bold text-success">Đã thanh toán</div>
            </div>

            <div class="col-12">
              <hr class="border-2 border-dark">
            </div>

            <div class="col-12">
              <div class="small text-secondary mb-1">Địa chỉ giao hàng</div>
              <div class="fw-semibold">
                ${shippingInfo.fullName} | ${shippingInfo.phone}<br>
                ${shippingInfo.address}, ${shippingInfo.ward}, ${shippingInfo.district}, ${shippingInfo.province}
              </div>
            </div>

            <c:if test="${not empty shippingInfo.notes}">
              <div class="col-12">
                <div class="small text-secondary mb-1">Ghi chú</div>
                <div class="fw-semibold">${shippingInfo.notes}</div>
              </div>
            </c:if>

            <div class="col-12">
              <hr class="border-2 border-dark">
            </div>

            <div class="col-6">
              <div class="small text-secondary">Tạm tính</div>
              <div class="fw-bold"><fmt:formatNumber value="${order.subtotalAmount}" type="number" maxFractionDigits="0" />₫</div>
            </div>
            <div class="col-6">
              <div class="small text-secondary">Giảm giá</div>
              <div class="fw-bold text-danger">-<fmt:formatNumber value="${order.discountAmount}" type="number" maxFractionDigits="0" />₫</div>
            </div>
            <div class="col-12">
              <div class="d-flex justify-content-between align-items-center border-top border-3 border-dark pt-3">
                <span class="fs-5 fw-black fw-bold">Tổng thanh toán</span>
                <span class="fs-3 fw-black fw-bold" style="color: var(--gf-green);">
                  <fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0" />₫
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- LICENSE KEYS CARD -->
        <c:if test="${not empty keys}">
          <div class="gf-checkout-card mb-4">
            <h2 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
              <i data-lucide="key" width="20" height="20"></i> License Key của bạn
            </h2>

            <div class="d-flex flex-column gap-3">
              <c:forEach var="keyEntry" items="${keys}">
                <div class="p-3 border border-2 border-dark rounded-3 bg-white">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div>
                      <div class="fw-bold mb-1">${keyEntry.gameTitle}</div>
                      <div class="d-flex align-items-center gap-2">
                        <i data-lucide="key" width="16" height="16" class="text-success"></i>
                        <code class="fw-black fw-bold fs-6 px-3 py-1 bg-dark text-white rounded-2"
                              style="letter-spacing: 1px;">${keyEntry.keyString}</code>
                      </div>
                    </div>
                    <c:choose>
                      <c:when test="${keyEntry.hasKey}">
                        <div class="badge bg-success border border-2 border-dark rounded-pill fw-black px-3">
                          <i data-lucide="check-circle" width="14" height="14" class="me-1"></i> Đã kích hoạt
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="badge bg-warning border border-2 border-dark rounded-pill fw-black px-3 text-dark">
                          <i data-lucide="clock" width="14" height="14" class="me-1"></i> Đang chờ cấp phát
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </c:forEach>
            </div>

            <div class="mt-3 p-3 bg-light border border-2 border-dark rounded-3">
              <div class="d-flex align-items-start gap-2">
                <i data-lucide="info" width="18" height="18" class="text-primary flex-shrink-0 mt-1"></i>
                <div class="small fw-semibold text-secondary">
                  Key của bạn đã được kích hoạt và thêm vào <strong>Thư viện Game</strong>.
                  Truy cập trang chủ để tải và chơi ngay!
                </div>
              </div>
            </div>
          </div>
        </c:if>

        <!-- ACTION BUTTONS -->
        <div class="d-flex flex-wrap gap-3 justify-content-center">
          <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-3 px-4">
            <i data-lucide="home" width="18" height="18"></i> Quay về trang chủ
          </a>
        </div>

      </div>
    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Bootstrap 5 Neo Brutalism Order Success Page.
    </div>
  </footer>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
    lucide.createIcons();
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/index.js?v=20260528"></script>
</body>
</html>
