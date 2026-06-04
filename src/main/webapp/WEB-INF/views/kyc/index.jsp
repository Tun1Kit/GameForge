<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - Xác minh KYC</title>
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <script>
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
  </script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/kyc.css">
</head>
<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <div class="gf-decor-pill" style="top:8%;left:3%;background:var(--gf-lavender);transform:rotate(12deg);"></div>
  <div class="gf-decor-pill" style="top:65%;right:3%;background:var(--gf-green);transform:rotate(-16deg);width:28px;height:28px;"></div>
  <div class="gf-decor-pill" style="top:75%;left:2%;background:var(--gf-yellow);transform:rotate(8deg);"></div>

  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#18181b;border-bottom:3px solid #000;">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-white">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>
        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/publisher" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <div class="dropdown">
            <button class="btn dropdown-toggle gf-press d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown"
                    style="background:#18181b;border:3px solid var(--gf-green);border-radius:999px;height:40px;padding:4px 14px 4px 6px;color:#fff;box-shadow:3px 3px 0 0 #000;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed='.concat(currentUser.username)}" alt="Avatar" style="width:28px;height:28px;border-radius:50%;object-fit:cover;border:2px solid var(--gf-green);">
              <span class="d-none d-sm-inline fw-black text-white" style="font-size:12px;">${fn:escapeXml(currentUser.username)}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:180px;">
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/logout"><i data-lucide="log-out" width="14" height="14"></i> Đăng xuất</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- MAIN CONTENT -->
  <main class="container-xl py-5">
    <div class="mb-4">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-yellow);box-shadow:3px 3px 0 #000;">
        <i data-lucide="shield-check" width="16" height="16"></i> Xác minh danh tính
      </div>
      <h1 class="fw-black fw-bold mb-2" style="font-size:clamp(2rem,5vw,3rem);line-height:1.1;letter-spacing:-0.03em;">
        Xác minh <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">KYC</span>
      </h1>
      <p class="fs-5 fw-semibold text-secondary gf-muted" style="max-width:520px;">Xác minh danh tính để trở thành nhà phát hành và đăng game lên GameForge.</p>
    </div>

    <!-- SUCCESS/ERROR -->
    <c:if test="${not empty sessionScope.kycSuccess}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2" role="alert" style="background:#94FFB4;border:3px solid #000;border-radius:12px;">
        <i data-lucide="check-circle" width="18" height="18"></i> ${fn:escapeXml(sessionScope.kycSuccess)}
        <% session.removeAttribute("kycSuccess"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.kycError}">
      <div class="alert gf-border-2 gf-shadow-sm mb-4 fw-bold d-flex align-items-center gap-2" role="alert" style="background:var(--gf-pink);border:3px solid #000;border-radius:12px;">
        <i data-lucide="alert-circle" width="18" height="18"></i> ${fn:escapeXml(sessionScope.kycError)}
        <% session.removeAttribute("kycError"); %>
      </div>
    </c:if>

    <!-- CURRENT KYC STATUS -->
    <div class="bg-white gf-border rounded-4 gf-shadow p-4 mb-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2 mb-3" style="background:var(--gf-lavender);border-bottom:3px solid #000;">
        <i data-lucide="info" width="18" height="18"></i> Trạng thái KYC hiện tại
      </div>
      <div class="row g-3 align-items-center">
        <div class="col-md-4">
          <div class="gf-border-2 rounded-3 p-3 text-center" style="background:${currentKycStatus == 'APPROVED' ? '#94FFB4' : currentKycStatus == 'PENDING' ? 'var(--gf-yellow)' : 'var(--gf-blue)'};border:2px solid #000;">
            <div class="small fw-bold text-secondary mb-1">Trạng thái</div>
            <div class="fs-5 fw-black text-uppercase">${fn:escapeXml(currentKycStatus)}</div>
          </div>
        </div>
        <div class="col-md-8">
          <div class="d-flex flex-column gap-2">
            <c:choose>
              <c:when test="${currentKycStatus == 'APPROVED'}">
                <div class="d-flex align-items-center gap-2 fw-bold" style="color:var(--gf-green);">
                  <i data-lucide="check-circle" width="18" height="18"></i> Bạn đã được xác minh KYC thành công!
                </div>
                <div class="small text-secondary">Bạn có quyền đăng game lên GameForge. <a href="${pageContext.request.contextPath}/" class="fw-bold text-decoration-none">Đăng game ngay</a>.</div>
              </c:when>
              <c:when test="${currentKycStatus == 'PENDING'}">
                <div class="d-flex align-items-center gap-2 fw-bold" style="color:#d97706;">
                  <i data-lucide="clock" width="18" height="18"></i> KYC của bạn đang chờ duyệt!
                </div>
                <div class="small text-secondary">Đội ngũ GameForge sẽ xem xét trong 1-2 ngày làm việc. Bạn sẽ nhận thông báo khi có kết quả.</div>
              </c:when>
              <c:otherwise>
                <div class="d-flex align-items-center gap-2 fw-bold" style="color:var(--gf-muted);">
                  <i data-lucide="help-circle" width="18" height="18"></i> Bạn chưa nộp KYC
                </div>
                <div class="small text-secondary">Hoàn tất KYC để mở khóa quyền đăng game với tư cách nhà phát hành.</div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>

    <!-- KYC FORM -->
    <c:if test="${currentKycStatus != 'APPROVED'}">
    <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4" id="kycFormCard">
      <div class="p-3 fw-black d-flex align-items-center gap-2" style="background:var(--gf-green);color:#000;border-bottom:3px solid #000;">
        <i data-lucide="upload" width="18" height="18"></i> Nộp hồ sơ KYC
        <c:if test="${currentKycStatus == 'PENDING' || currentKycStatus == 'REJECTED'}">
          <span class="badge ms-auto bg-dark border border-2 border-white" style="border-radius:999px;font-size:10px;">Cập nhật lại</span>
        </c:if>
      </div>
      <div class="p-4">
        <form action="${pageContext.request.contextPath}/kyc/submit" method="post" enctype="multipart/form-data" id="kycForm">
          <input type="hidden" name="_csrf" value="${_csrf.token}" />

          <!-- STEP 1: ID Type -->
          <div class="mb-4">
            <h5 class="fw-black mb-3 d-flex align-items-center gap-2">
              <span class="gf-border-2 rounded-circle d-grid place-items-center" style="width:28px;height:28px;background:var(--gf-yellow);border:2px solid #000;font-size:13px;">1</span>
              Loại giấy tờ
            </h5>
            <div class="row g-3">
              <div class="col-md-4">
                <label class="kyc-type-card ${kycFormData.idType == 'CCCD' ? 'active' : ''}" data-type="CCCD">
                  <input type="radio" name="idType" value="CCCD" ${kycFormData.idType == 'CCCD' ? 'checked' : ''} required>
                  <div class="kyc-type-inner gf-border-2 rounded-3 p-3 text-center">
                    <div class="gf-border-2 rounded-3 d-grid mx-auto mb-2 place-items-center" style="width:44px;height:44px;background:var(--gf-lavender);">
                      <i data-lucide="credit-card" width="20" height="20"></i>
                    </div>
                    <div class="fw-black small">CMND/CCCD</div>
                  </div>
                </label>
              </div>
              <div class="col-md-4">
                <label class="kyc-type-card ${kycFormData.idType == 'PASSPORT' ? 'active' : ''}" data-type="PASSPORT">
                  <input type="radio" name="idType" value="PASSPORT" ${kycFormData.idType == 'PASSPORT' ? 'checked' : ''}>
                  <div class="kyc-type-inner gf-border-2 rounded-3 p-3 text-center">
                    <div class="gf-border-2 rounded-3 d-grid mx-auto mb-2 place-items-center" style="width:44px;height:44px;background:var(--gf-blue);">
                      <i data-lucide="globe" width="20" height="20"></i>
                    </div>
                    <div class="fw-black small">Hộ chiếu</div>
                  </div>
                </label>
              </div>
              <div class="col-md-4">
                <label class="kyc-type-card ${kycFormData.idType == 'DRIVER_LICENSE' ? 'active' : ''}" data-type="DRIVER_LICENSE">
                  <input type="radio" name="idType" value="DRIVER_LICENSE" ${kycFormData.idType == 'DRIVER_LICENSE' ? 'checked' : ''}>
                  <div class="kyc-type-inner gf-border-2 rounded-3 p-3 text-center">
                    <div class="gf-border-2 rounded-3 d-grid mx-auto mb-2 place-items-center" style="width:44px;height:44px;background:var(--gf-pink);">
                      <i data-lucide="car" width="20" height="20"></i>
                    </div>
                    <div class="fw-black small">Bằng lái</div>
                  </div>
                </label>
              </div>
            </div>
          </div>

          <!-- STEP 2: ID Number -->
          <div class="mb-4">
            <h5 class="fw-black mb-3 d-flex align-items-center gap-2">
              <span class="gf-border-2 rounded-circle d-grid place-items-center" style="width:28px;height:28px;background:var(--gf-yellow);border:2px solid #000;font-size:13px;">2</span>
              Số giấy tờ
            </h5>
            <input type="text" name="idNumber" value="${fn:escapeXml(kycFormData.idNumber)}" class="form-control gf-input" placeholder="VD: 001209012345" maxlength="20" required>
          </div>

          <!-- STEP 3: Full Name -->
          <div class="mb-4">
            <h5 class="fw-black mb-3 d-flex align-items-center gap-2">
              <span class="gf-border-2 rounded-circle d-grid place-items-center" style="width:28px;height:28px;background:var(--gf-yellow);border:2px solid #000;font-size:13px;">3</span>
              Họ và tên (đúng theo giấy tờ)
            </h5>
            <input type="text" name="fullName" value="${fn:escapeXml(kycFormData.fullName)}" class="form-control gf-input" placeholder="VD: Nguyễn Văn A" maxlength="100" required>
          </div>

          <!-- STEP 4: Photo Upload -->
          <div class="mb-4">
            <h5 class="fw-black mb-3 d-flex align-items-center gap-2">
              <span class="gf-border-2 rounded-circle d-grid place-items-center" style="width:28px;height:28px;background:var(--gf-yellow);border:2px solid #000;font-size:13px;">4</span>
              Ảnh giấy tờ
              <span class="badge bg-dark ms-1" style="border-radius:999px;font-size:10px;">Tùy chọn</span>
            </h5>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="kyc-upload-box gf-border-2 rounded-3 p-4 text-center gf-border" for="frontImage">
                  <input type="file" name="frontImage" id="frontImage" accept="image/*" class="d-none" onchange="previewImage(this, 'frontPreview')">
                  <div id="frontPreview">
                    <div class="gf-border-2 rounded-3 d-grid mx-auto mb-2 place-items-center" style="width:48px;height:48px;background:var(--gf-lavender);">
                      <i data-lucide="image" width="22" height="22"></i>
                    </div>
                    <div class="fw-bold small">Ảnh mặt trước</div>
                    <div class="text-secondary small mt-1">Click để tải ảnh lên</div>
                  </div>
                </label>
              </div>
              <div class="col-md-6">
                <label class="kyc-upload-box gf-border-2 rounded-3 p-4 text-center gf-border" for="backImage">
                  <input type="file" name="backImage" id="backImage" accept="image/*" class="d-none" onchange="previewImage(this, 'backPreview')">
                  <div id="backPreview">
                    <div class="gf-border-2 rounded-3 d-grid mx-auto mb-2 place-items-center" style="width:48px;height:48px;background:var(--gf-blue);">
                      <i data-lucide="image" width="22" height="22"></i>
                    </div>
                    <div class="fw-bold small">Ảnh mặt sau</div>
                    <div class="text-secondary small mt-1">Click để tải ảnh lên</div>
                  </div>
                </label>
              </div>
            </div>
            <div class="form-text mt-2 small">
              <i data-lucide="info" width="13" height="13" class="d-inline-block align-middle"></i>
              Hỗ trợ JPG, PNG. Dung lượng tối đa 5MB. Có thể bỏ qua bước này.
            </div>
          </div>

          <!-- SUBMIT -->
          <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 pt-3 border-top border-2 border-dark">
            <div class="small text-secondary">
              <i data-lucide="shield" width="14" height="14" class="d-inline-block align-middle"></i>
              Thông tin của bạn được mã hóa và chỉ dùng để xác minh.
            </div>
            <button type="submit" class="btn gf-border gf-shadow gf-press fw-bold d-flex align-items-center gap-2" style="background:var(--gf-green);border-radius:12px;padding:12px 28px;font-size:15px;" id="kycSubmitBtn">
              <i data-lucide="send" width="18" height="18"></i> Gửi hồ sơ KYC
            </button>
          </div>
        </form>
      </div>
    </div>
    </c:if>

    <!-- KYC INFO -->
    <div class="bg-white gf-border rounded-4 gf-shadow p-4">
      <div class="p-3 fw-black d-flex align-items-center gap-2 mb-3" style="background:var(--gf-blue);border-bottom:3px solid #000;">
        <i data-lucide="help-circle" width="18" height="18"></i> Hướng dẫn KYC
      </div>
      <div class="row g-4">
        <div class="col-md-4">
          <div class="d-flex align-items-start gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center flex-shrink-0" style="width:36px;height:36px;background:var(--gf-yellow);">
              <span class="fw-black" style="font-size:16px;">1</span>
            </div>
            <div>
              <div class="fw-bold mb-1">Chọn loại giấy tờ</div>
              <div class="small text-secondary">CMND, CCCD, Hộ chiếu hoặc Bằng lái xe còn hiệu lực.</div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="d-flex align-items-start gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center flex-shrink-0" style="width:36px;height:36px;background:var(--gf-lavender);">
              <span class="fw-black" style="font-size:16px;">2</span>
            </div>
            <div>
              <div class="fw-bold mb-1">Điền thông tin chính xác</div>
              <div class="small text-secondary">Họ tên và số giấy tờ phải khớp chính xác với ảnh.</div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="d-flex align-items-start gap-3">
            <div class="gf-border-2 rounded-3 d-grid place-items-center flex-shrink-0" style="width:36px;height:36px;background:#94FFB4;">
              <span class="fw-black" style="font-size:16px;">3</span>
            </div>
            <div>
              <div class="fw-bold mb-1">Tải ảnh rõ ràng</div>
              <div class="small text-secondary">Ảnh chụp rõ cả mặt trước và sau, không mờ hay che góc.</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge &mdash; Neo-Brutalism Design
    </div>
  </footer>

  <script src="${pageContext.request.contextPath}/assets/js/kyc.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
