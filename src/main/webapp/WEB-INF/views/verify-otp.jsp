<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Xác thực OTP</title>

  <!-- CSRF: not used by this project -->
  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">
  <style> body { font-family: 'Inter', sans-serif !important; } </style>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

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

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">

  <style>
    body {
      background: var(--gf-bg, #FFFDF8);
      min-height: 100vh;
    }
  </style>
</head>

<body class="position-relative" style="overflow-x: hidden;">

  <!-- Decorative pills -->
  <div class="gf-decor-pill" style="top: 15%; left: 4%; background: var(--gf-yellow); transform: rotate(15deg);"></div>
  <div class="gf-decor-pill" style="top: 70%; left: 2%; background: var(--gf-pink); transform: rotate(-20deg); width: 30px; height: 30px;"></div>
  <div class="gf-decor-pill" style="top: 20%; right: 5%; background: var(--gf-blue); transform: rotate(45deg); width: 28px; height: 28px; border-radius: 50%;"></div>
  <div class="gf-decor-pill" style="top: 65%; right: 3%; background: #94FFB4; transform: rotate(-10deg);"></div>

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
        <a href="${pageContext.request.contextPath}/" class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
          <i data-lucide="arrow-left" width="16" height="16"></i> Trang chủ
        </a>
      </div>
    </div>
  </nav>

  <!-- OTP VERIFICATION CARD -->
  <main class="container-xl py-5 d-flex align-items-center justify-content-center" style="min-height: calc(100vh - 76px);">
    <div class="bg-white gf-border gf-shadow p-0 mx-3" style="border-radius: 22px; max-width: 480px; width: 100%; overflow: hidden;">

      <!-- Header -->
      <div class="p-4 text-center gf-border-bottom" style="background: var(--gf-lavender); border-bottom: 3px solid #000;">
        <div class="mx-auto mb-3 d-grid gf-border-2 rounded-4" style="width:72px;height:72px;place-items:center;background:#E8D5FF;">
          <i data-lucide="mail-check" width="36" height="36" class="text-dark"></i>
        </div>
        <h1 class="fw-black fw-bold mb-1">Xác thực OTP</h1>
        <p class="small text-secondary gf-muted mb-0">Nhập mã OTP đã gửi đến:</p>
        <p class="fw-bold text-dark mb-0" style="font-size: 15px;">${fn:escapeXml(email)}</p>
      </div>

      <!-- Messages -->
      <div class="p-4">
        <c:if test="${not empty success}">
          <div class="alert alert-success gf-border border-2 border-dark fw-semibold mb-3" style="border-radius: 12px;">
            ${fn:escapeXml(success)}
          </div>
        </c:if>

        <c:if test="${not empty error}">
          <div class="alert alert-danger gf-border border-2 border-dark fw-semibold mb-3" style="border-radius: 12px;">
            ${fn:escapeXml(error)}
          </div>
        </c:if>

        <!-- OTP Form -->
        <form action="${pageContext.request.contextPath}/verify-otp" method="post">
          <div class="mb-4">
            <label class="form-label fw-bold text-dark" style="font-size: 13px;">Mã OTP (6 chữ số)</label>
            <input type="text"
                   name="otp"
                   maxlength="6"
                   required
                   autocomplete="one-time-code"
                   inputmode="numeric"
                   pattern="[0-9]{6}"
                   class="form-control gf-border-2 fw-bold text-center"
                   style="font-size: 28px; letter-spacing: 10px; font-weight: 900; padding: 12px; border-radius: 12px;"
                   placeholder="000000">
            <div class="form-text small gf-muted">Mã có hiệu lực trong 5 phút</div>
          </div>

          <button type="submit" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-3 d-flex align-items-center justify-content-center gap-2" style="background: var(--gf-green); border-radius: 14px; font-size: 15px;">
            <i data-lucide="shield-check" width="18" height="18"></i> Xác thực tài khoản
          </button>
        </form>

        <!-- Resend / Back -->
        <div class="text-center mt-4 pt-3 gf-border-top" style="border-top: 2px solid #e5e5e5;">
          <p class="small text-secondary gf-muted mb-2">Chưa nhận được mã?</p>
          <button id="resendBtn"
                  type="button"
                  onclick="resendOtp()"
                  class="btn btn-sm gf-border gf-shadow-sm gf-press fw-bold"
                  style="background: var(--gf-yellow); border-radius: 8px; font-size: 12px; min-width: 130px;">
            <i data-lucide="refresh-cw" width="14" height="14"></i> <span id="resendText">Gửi lại mã OTP</span>
          </button>
        </div>

        <div class="text-center mt-3">
          <a href="${pageContext.request.contextPath}/login" class="small fw-bold text-secondary gf-muted text-decoration-none d-inline-flex align-items-center gap-1">
            <i data-lucide="arrow-left" width="12" height="12"></i> Quay lại đăng nhập
          </a>
        </div>
      </div>
    </div>
  </main>

  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    lucide.createIcons();

    function resendOtp() {
      var btn = document.getElementById('resendBtn');
      var text = document.getElementById('resendText');
      if (btn.disabled) return;

      var xhr = new XMLHttpRequest();
      xhr.open('POST', window.GAMEFORGE_CONTEXT_PATH + '/resend-otp', true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

      xhr.onload = function () {
        if (xhr.status === 200) {
          startCountdown(60);
        } else {
          var parser = new DOMParser();
          var doc = parser.parseFromString(xhr.responseText, 'text/html');
          var errorEl = doc.querySelector('.alert-danger');
          if (errorEl) {
            showInlineError(errorEl.textContent.trim());
          }
          // Nếu là cooldown, hiển thị countdown
          var errorText = xhr.responseText;
          var m = errorText.match(/đợi (\d+)s/);
          if (m) startCountdown(parseInt(m[1]));
        }
      };

      xhr.onerror = function () {
        showInlineError('Không thể gửi yêu cầu. Vui lòng thử lại.');
      };

      xhr.send();
    }

    function startCountdown(seconds) {
      var btn = document.getElementById('resendBtn');
      var text = document.getElementById('resendText');
      var remaining = seconds;
      btn.disabled = true;
      btn.style.cursor = 'not-allowed';
      btn.style.opacity = '0.6';

      var timer = setInterval(function () {
        remaining--;
        text.textContent = 'Đợi ' + remaining + 's';
        if (remaining <= 0) {
          clearInterval(timer);
          btn.disabled = false;
          btn.style.cursor = 'pointer';
          btn.style.opacity = '1';
          text.textContent = 'Gửi lại mã OTP';
        }
      }, 1000);

      text.textContent = 'Đợi ' + remaining + 's';
    }

    function showInlineError(msg) {
      var existing = document.querySelector('.otp-inline-error');
      if (existing) existing.remove();
      var div = document.createElement('div');
      div.className = 'alert alert-danger gf-border border-2 border-dark fw-semibold mt-3 otp-inline-error';
      div.style.borderRadius = '12px';
      div.textContent = msg;
      var form = document.querySelector('form');
      form.parentNode.insertBefore(div, form.nextSibling);
    }
  </script>
</body>
</html>
