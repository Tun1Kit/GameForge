<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Đăng nhập / Đăng ký</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">
  <style> body { font-family: 'Inter', sans-serif !important; } </style>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  
<script>
  (function () {
    try {
      // Ép trạng thái ban đầu của Bootstrap luôn theo hệ thống màu của ta
      if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
        document.documentElement.classList.add('gf-dark-mode');
      } else {
        document.documentElement.classList.remove('gf-dark-mode');
      }
    } catch (e) {}
  })();
</script>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css">
</head>

<body>

  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black tracking-tight d-none d-sm-inline">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

		<div class="d-flex align-items-center gap-2 gap-sm-3">
		  <a href="${pageContext.request.contextPath}/"
		     class="gf-icon-btn gf-press"
		     title="Trang chủ">
		    <i data-lucide="home" width="20" height="20"></i>
		  </a>
		
		  <button id="themeButton"
		    class="btn gf-border-2 gf-shadow-sm gf-press bg-dark text-white fw-bold rounded-3 d-flex align-items-center gap-2"
		    type="button">
		    <span id="icon-light">
		      <i data-lucide="sun" width="16" height="16"></i>
		    </span>
		    <span id="icon-dark" class="d-none">
		      <i data-lucide="moon" width="16" height="16" style="color:#fde047"></i>
		    </span>
		    <span id="theme-text" class="d-none d-sm-inline">Light</span>
		  </button>
		</div>
      </div>
    </div>
  </nav>

  <main class="d-flex align-items-center justify-content-center min-vh-100 position-relative overflow-hidden" style="padding-top: 76px;">
    
    <div class="gf-floating-shape rounded-4" style="width: 90px; height: 90px; background: var(--gf-yellow); left: 3%; top: 22%; --rot: -6deg;"></div>
    <div class="gf-floating-shape rounded-circle" style="width: 70px; height: 70px; background: var(--gf-pink); right: 6%; top: 25%; animation-delay: 1s;"></div>
    <div class="gf-floating-shape rounded-3" style="width: 60px; height: 60px; background: var(--gf-lavender); left: 7%; bottom: 15%; --rot: 12deg; animation-delay: 2s;"></div>
    <div class="gf-floating-shape rounded-4" style="width: 50px; height: 50px; background: #9AF0B7; right: 10%; bottom: 18%; --rot: -12deg; animation-delay: 1.5s;"></div>

    <div class="gf-login-container gf-border gf-shadow d-flex mx-3 mx-lg-4">
      
      <div class="gf-login-banner d-none d-md-flex flex-column justify-content-between p-5">
        <div class="position-absolute border border-2 border-dark rounded-4" style="inset: 18px; border-style: dashed !important; opacity: 0.3; pointer-events: none;"></div>
        
        <div class="position-relative z-1">
          <div class="bg-white border border-3 border-dark rounded-4 p-2 d-inline-flex align-items-center gap-3 gf-shadow-sm mb-5">
            <div class="bg-success border border-3 border-dark rounded-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
              <i data-lucide="shopping-cart" class="text-dark" width="20" height="20"></i>
            </div>
            <div class="pe-2">
              <div class="fw-black fw-bold text-dark" style="font-size: 13px;">Login để mua game</div>
              <div class="fw-bold text-secondary" style="font-size: 11px;">Cart • Checkout • Library</div>
            </div>
          </div>

          <h1 class="fw-black fw-bold text-dark" style="font-size: 42px; line-height: 1.1; letter-spacing: -0.5px;">Mở khóa kho<br>game của bạn.</h1>
          <p class="mt-3 fw-bold text-dark" style="font-size: 15px; opacity: 0.8; max-width: 280px;">Đăng nhập để thêm game vào giỏ hàng, thanh toán và lưu vào thư viện cá nhân.</p>
        </div>

        <div class="position-relative z-1 bg-white border border-3 border-dark rounded-4 gf-shadow-sm overflow-hidden mt-4">
          <div class="bg-dark text-white px-3 py-2 d-flex justify-content-between align-items-center fw-black small">
            <span style="font-size: 11px;">GAMEFORGE STATUS</span>
            <span class="bg-success text-dark border border-2 border-dark rounded-2 px-2 py-1" style="font-size: 10px;">ONLINE</span>
          </div>
          <div class="p-3 text-dark">
            <div class="d-flex align-items-center gap-2 pb-2 border-bottom fw-bold small text-secondary">
              <span class="rounded-circle bg-success" style="width:8px; height:8px;"></span> Hệ thống hoạt động tốt.
            </div>
            <div class="row text-center pt-2 g-0">
              <div class="col border-end"><div class="fw-black fs-6">12.4K</div><div class="fw-bold text-secondary" style="font-size: 10px;">Người chơi</div></div>
              <div class="col border-end"><div class="fw-black fs-6">8.7K</div><div class="fw-bold text-secondary" style="font-size: 10px;">Đã bán</div></div>
              <div class="col"><div class="fw-black fs-6">99%</div><div class="fw-bold text-secondary" style="font-size: 10px;">Uptime</div></div>
            </div>
          </div>
        </div>
      </div>

      <div class="flex-grow-1 p-4 p-md-5 d-flex flex-column align-items-center overflow-auto hide-scrollbar">
        <div class="w-100 d-flex flex-column justify-content-center h-100" style="max-width: 420px;">
          
          <div class="d-flex p-1 bg-light border border-3 border-dark rounded-4 mb-4 gf-shadow-sm flex-shrink-0" style="gap: 4px;">
            <button id="loginTab" onclick="switchAuth('login')" class="btn flex-grow-1 border-3 border-dark rounded-3 fw-black shadow-none text-dark" style="background-color: var(--gf-green); height: 42px;">Đăng nhập</button>
            <button id="registerTab" onclick="switchAuth('register')" class="btn flex-grow-1 border-0 rounded-3 fw-black text-secondary bg-transparent" style="height: 42px;">Đăng ký</button>
          </div>

          <c:if test="${not empty error}">
            <div class="alert alert-danger fw-bold border border-3 border-dark rounded-3 gf-shadow-sm p-2 mb-4 d-flex align-items-center gap-2" style="background-color: #FECACA; color: #000;">
              <i data-lucide="alert-triangle" width="18" height="18"></i>
              <span style="font-size: 13px;">${error}</span>
            </div>
            <c:if test="${fn:contains(error, 'khớp') or fn:contains(error, 'sử dụng')}">
              <script>document.addEventListener('DOMContentLoaded', () => switchAuth('register'));</script>
            </c:if>
          </c:if>
          
          <c:if test="${not empty success}">
            <div class="alert alert-success fw-bold border border-3 border-dark rounded-3 gf-shadow-sm p-2 mb-4 d-flex align-items-center gap-2" style="background-color: #A7F3D0; color: #000;">
              <i data-lucide="check-circle" width="18" height="18"></i>
              <span style="font-size: 13px;">${success}</span>
            </div>
          </c:if>

          <div class="gf-form-window flex-shrink-0">
            <div id="formTrack" class="gf-form-track">
              
              <div class="gf-form-panel d-flex flex-column">
                <h2 class="fs-4 fw-black fw-bold mb-1">Chào mừng trở lại</h2>
                <p class="small fw-bold text-secondary mb-4">Đăng nhập để xem giỏ hàng và thanh toán.</p>

                <form action="${pageContext.request.contextPath}/login" method="post" class="d-flex flex-column gap-3">
                  <div>
                    <label class="form-label fw-black small mb-1">Email hoặc tên đăng nhập</label>
                    <div class="gf-input-wrapper">
                      <i data-lucide="mail" class="gf-input-icon" width="18" height="18"></i>
                      <input name="emailOrUsername" type="text" class="gf-input" placeholder="vd: vinhnguyen123 hoặc email@example.com" required>
                    </div>
                  </div>

                  <div>
                    <label class="form-label fw-black small mb-1">Mật khẩu</label>
                    <div class="gf-input-wrapper">
                      <i data-lucide="lock-keyhole" class="gf-input-icon" width="18" height="18"></i>
                      <input id="loginPassword" name="password" type="password" class="gf-input" placeholder="Nhập mật khẩu" required>
                      <button type="button" onclick="togglePassword('loginPassword', this)" class="gf-eye-btn">
                        <i data-lucide="eye" width="18" height="18"></i>
                      </button>
                    </div>
                  </div>

                  <div class="d-flex align-items-center justify-content-between small fw-bold mt-1">
                    <label class="d-flex align-items-center gap-2 cursor-pointer mb-0">
                      <input type="checkbox" name="rememberMe" style="accent-color: var(--gf-green); width: 16px; height: 16px;">
                      <span>Ghi nhớ tôi</span>
                    </label>
                    <a href="#" class="text-dark text-decoration-underline">Quên mật khẩu?</a>
                  </div>

                  <button type="submit" class="btn w-100 py-2 border-3 border-dark rounded-3 fw-black fw-bold gf-shadow-sm gf-press d-flex align-items-center justify-content-center gap-2 mt-2" style="background-color: var(--gf-green); color: #000;">
                    <i data-lucide="log-in" width="20" height="20"></i> Đăng nhập
                  </button>
                </form>

                <div class="d-flex align-items-center gap-3 my-4 small fw-black text-secondary text-uppercase" style="letter-spacing: 2px;">
                  <div class="flex-grow-1 bg-dark" style="height: 2px;"></div> HOẶC <div class="flex-grow-1 bg-dark" style="height: 2px;"></div>
                </div>

                <button type="button" onclick="switchAuth('register')" class="btn w-100 py-2 bg-white border-3 border-dark rounded-3 fw-black fw-bold gf-shadow-sm gf-press d-flex align-items-center justify-content-center gap-2">
                  <i data-lucide="user-plus" width="20" height="20"></i> Tạo tài khoản mới
                </button>
              </div>
			  
              <div class="gf-form-panel d-flex flex-column">
                <h2 class="fs-4 fw-black fw-bold mb-1">Tạo tài khoản</h2>
                <p class="small fw-bold text-secondary mb-4">Điền thông tin để tạo ID GameForge.</p>

                <form action="${pageContext.request.contextPath}/register" method="post" class="d-flex flex-column gap-3">
                  <div>
                    <label class="form-label fw-black small mb-1">Tên đăng nhập</label>
                    <div class="gf-input-wrapper">
                      <i data-lucide="at-sign" class="gf-input-icon" width="18" height="18"></i>
                      <input name="username" type="text" class="gf-input" placeholder="vd: vinhnguyen123" required>
                    </div>
                  </div>

                  <div>
                    <label class="form-label fw-black small mb-1">Tên hiển thị</label>
                    <div class="gf-input-wrapper">
                      <i data-lucide="user" class="gf-input-icon" width="18" height="18"></i>
                      <input name="fullName" type="text" class="gf-input" placeholder="vd: Nguyễn Văn A">
                    </div>
                  </div>

                  <div>
                    <label class="form-label fw-black small mb-1">Email</label>
                    <div class="gf-input-wrapper">
                      <i data-lucide="mail" class="gf-input-icon" width="18" height="18"></i>
                      <input name="email" type="email" class="gf-input" placeholder="Nhập email" required>
                    </div>
                  </div>

                  <div class="row g-2">
                    <div class="col-6">
                      <label class="form-label fw-black small mb-1">Mật khẩu</label>
                      <div class="gf-input-wrapper">
                        <i data-lucide="lock-keyhole" class="gf-input-icon" width="16" height="16"></i>
                        <input id="regPassword" name="password" type="password" class="gf-input" style="padding-left: 36px; padding-right: 32px;" required>
                        <button type="button" onclick="togglePassword('regPassword', this)" class="gf-eye-btn">
                          <i data-lucide="eye" width="16" height="16"></i>
                        </button>
                      </div>
                    </div>
                    <div class="col-6">
                      <label class="form-label fw-black small mb-1">Nhập lại</label>
                      <div class="gf-input-wrapper">
                        <i data-lucide="shield-check" class="gf-input-icon" width="16" height="16"></i>
                        <input id="regConfirm" name="confirmPassword" type="password" class="gf-input" style="padding-left: 36px; padding-right: 32px;" required>
                        <button type="button" onclick="togglePassword('regConfirm', this)" class="gf-eye-btn">
                          <i data-lucide="eye" width="16" height="16"></i>
                        </button>
                      </div>
                    </div>
                  </div>
					<div id="password-rules" class="bg-white border-2 border-dark rounded-3 p-2 mb-2 mt-1 gf-shadow-sm d-none transition-all">
					  <div class="small fw-black mb-1">Quy chuẩn bảo mật:</div>
					  <div class="d-flex flex-column gap-1" style="font-size: 11px;">
					    <div id="rule-length" class="fw-bold text-danger d-flex align-items-center gap-1"><i data-lucide="x-circle" width="14" height="14"></i> Tối thiểu 8 ký tự</div>
					    <div id="rule-upper" class="fw-bold text-danger d-flex align-items-center gap-1"><i data-lucide="x-circle" width="14" height="14"></i> Ít nhất 1 chữ IN HOA</div>
					    <div id="rule-lower" class="fw-bold text-danger d-flex align-items-center gap-1"><i data-lucide="x-circle" width="14" height="14"></i> Ít nhất 1 chữ thường</div>
					    <div id="rule-number" class="fw-bold text-danger d-flex align-items-center gap-1"><i data-lucide="x-circle" width="14" height="14"></i> Ít nhất 1 chữ số</div>
					    <div id="rule-special" class="fw-bold text-danger d-flex align-items-center gap-1"><i data-lucide="x-circle" width="14" height="14"></i> Ký tự đặc biệt (!@#$...)</div>
					  </div>
					</div>
				  <div class="small fw-bold mt-1">
				    <label class="d-flex align-items-center gap-2 cursor-pointer mb-0">
				      <input type="checkbox" required style="accent-color: var(--gf-green); width: 16px; height: 16px; margin-top:-2px;">
				      <span>Tôi đồng ý với <a href="#" class="gf-link-green">Điều khoản</a> & <a href="#" class="gf-link-green">Bảo mật</a></span>
				    </label>
				  </div>

                  <button type="submit" class="btn w-100 py-2 border-3 border-dark rounded-3 fw-black fw-bold gf-shadow-sm gf-press d-flex align-items-center justify-content-center gap-2 mt-2" style="background-color: var(--gf-green); color: #000;">
                    <i data-lucide="user-plus" width="20" height="20"></i> Đăng ký ngay
                  </button>
                </form>

                <div class="d-flex align-items-center gap-3 my-3 small fw-black text-secondary text-uppercase" style="letter-spacing: 2px;">
                  <div class="flex-grow-1 bg-dark" style="height: 2px;"></div> HOẶC <div class="flex-grow-1 bg-dark" style="height: 2px;"></div>
                </div>

                <button type="button" class="btn w-100 py-2 bg-white border-3 border-dark rounded-3 fw-black fw-bold gf-shadow-sm gf-press d-flex align-items-center justify-content-center gap-2">
                  <span style="color: #4285F4; font-size: 18px;">G</span> Đăng ký với Google
                </button>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <script src="${pageContext.request.contextPath}/assets/js/login.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>