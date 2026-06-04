<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge Publisher - ${isEdit ? 'Cập Nhật Game' : 'Đăng Game Mới'}</title>

  <script>
    document.documentElement.classList.remove('gf-dark-mode');
  </script>

  <!-- Bootstrap 5 + Lucide -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">

  <style>
    body {
      background-color: #f4f4f5;
    }
    .form-container {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 8px 8px 0 0 #000;
      border-radius: 16px;
      padding: 32px;
    }
    .form-control, .form-select {
      border: 2px solid #000;
      font-weight: 600;
      padding: 12px;
      border-radius: 8px;
    }
    .form-control:focus, .form-select:focus {
      border-color: #000;
      box-shadow: 3px 3px 0 0 #000;
      outline: none;
    }
    .form-label {
      font-weight: 900;
      text-transform: uppercase;
      font-size: 13px;
      margin-bottom: 6px;
    }
    .section-title {
      background: var(--gf-yellow);
      border: 2px solid #000;
      box-shadow: 3px 3px 0 0 #000;
      padding: 10px 20px;
      display: inline-block;
      font-weight: 900;
      border-radius: 8px;
      margin-bottom: 24px;
      text-transform: uppercase;
      font-size: 14px;
    }
    .media-preview-box {
      border: 2px dashed #000;
      border-radius: 8px;
      padding: 16px;
      background: #fbfbfb;
      min-height: 120px;
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
    }
    .media-preview-img {
      width: 120px;
      height: 68px;
      object-fit: cover;
      border: 2px solid #000;
      border-radius: 4px;
      box-shadow: 2px 2px 0 0 #000;
    }
  </style>
</head>

<body>
  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;background:var(--gf-yellow);color:#000;">PUBLISHER</span></span>
        </a>
        
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <a href="${pageContext.request.contextPath}/publisher/dashboard" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/publisher/games" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="package" width="14" height="14"></i> Game đã đăng
          </a>
          <a href="${pageContext.request.contextPath}/publisher/payouts" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/kyc" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <a href="${pageContext.request.contextPath}/publisher/games/add" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
            <i data-lucide="gamepad-2" width="14" height="14"></i> Đăng game
          </a>
          
          <!-- Notification Bell -->
          <a href="${pageContext.request.contextPath}/publisher/notifications" class="btn btn-sm gf-border-2 gf-press bg-white text-dark rounded-3 d-flex align-items-center justify-content-center p-0 position-relative" style="width:38px; height:38px; border-color:#000; flex-shrink:0;">
            <i data-lucide="bell" width="16" height="16"></i>
            <c:if test="${unreadNotificationCount > 0}">
              <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size:9px; padding: 3px 6px;">
                ${unreadNotificationCount}
              </span>
            </c:if>
          </a>

          <!-- Dropdown User -->
          <div class="dropdown" style="flex-shrink: 0;">
            <button class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown" style="height:38px;border-color:#000;padding:4px 12px 4px 6px;flex-shrink:0;line-height:1;">
              <img src="${(not empty currentUser.avatar && currentUser.avatar != 'default-avatar.png') ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Publisher'}" alt="Avatar" style="width:24px;height:24px;border-radius:50%;object-fit:cover;border:1.5px solid #000;">
              <span class="d-none d-sm-inline fw-black text-dark" style="font-size:12px;">${fn:escapeXml(currentUser.username)}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:180px;">
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/logout"><i data-lucide="log-out" width="14" height="14"></i> Đăng xuất</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- MAIN CONTAINER -->
  <main class="container-xl py-5" style="max-width: 900px;">
    <div class="mb-4">
      <h1 class="fw-black fw-bold mb-1">${isEdit ? 'Cập nhật thông tin game' : 'Đăng game mới'}</h1>
      <p class="fw-semibold text-secondary gf-muted">Điền đầy đủ thông tin, thể loại, yêu cầu cấu hình và hình ảnh/video trailer cho sản phẩm.</p>
    </div>

    <!-- Error notice -->
    <c:if test="${not empty error}">
      <div class="alert alert-danger d-flex align-items-center gap-2 border border-3 border-black fw-bold mb-4 shadow" style="border-radius:12px; background:var(--gf-pink); color:#000;">
        <i data-lucide="alert-circle" width="20" height="20"></i>
        <span>${error}</span>
      </div>
    </c:if>

    <div class="form-container">
      <form action="${pageContext.request.contextPath}${actionUrl}" method="POST" enctype="multipart/form-data">
        
        <!-- SECTION 1: THÔNG TIN CHUNG -->
        <h4 class="section-title">1. Thông tin chung</h4>
        
        <div class="row g-3 mb-4">
          <div class="col-md-6">
            <label class="form-label">Tên game *</label>
            <input type="text" name="title" value="${fn:escapeXml(game.title)}" required class="form-control" placeholder="Ví dụ: Cyberpunk 2077" maxlength="150">
          </div>
          <div class="col-md-6">
            <label class="form-label">Đường dẫn tĩnh (Slug) <small class="text-secondary">(Tự tạo nếu trống)</small></label>
            <input type="text" name="slug" value="${fn:escapeXml(game.slug)}" class="form-control" placeholder="Ví dụ: cyberpunk-2077" maxlength="150">
          </div>
        </div>

        <div class="row g-3 mb-4">
          <div class="col-md-12">
            <label class="form-label">Giá bán (VNĐ) *</label>
            <input type="number" name="price" value="${game.price != null ? game.price.longValue() : 0}" required class="form-control" placeholder="Ví dụ: 990000" min="0">
            <div class="form-text small" style="font-size:11px;">Nhập 0 nếu game miễn phí (Free-to-play)</div>
          </div>
        </div>

        <div class="row g-3 mb-4">
          <div class="col-md-6">
            <label class="form-label">Nhà sản xuất / Developer *</label>
            <input type="text" name="developer" value="${fn:escapeXml(game.developer)}" required class="form-control" placeholder="Ví dụ: CD Projekt Red" maxlength="100">
          </div>
          <div class="col-md-6">
            <label class="form-label">Ngày phát hành *</label>
            <input type="date" name="releaseDate" value="${game.releaseDate}" required class="form-control" min="1970-01-01" max="2100-12-31">
          </div>
        </div>

        <div class="mb-4">
          <label class="form-label">Thể loại game *</label>
          <div class="d-flex flex-wrap gap-3 p-3 bg-light border border-2 border-black rounded-3">
            <c:forEach var="c" items="${categories}">
              <div class="form-check form-check-inline">
                <!-- Check xem game hiện tại đã có category này chưa để tích chọn -->
                <c:set var="checked" value="" />
                <c:if test="${isEdit}">
                  <c:forEach var="gc" items="${game.categories}">
                    <c:if test="${gc.id == c.id}">
                      <c:set var="checked" value="checked" />
                    </c:if>
                  </c:forEach>
                </c:if>
                <input class="form-check-input border-2 border-dark" type="checkbox" name="categoryIds" value="${c.id}" id="cat-${c.id}" ${checked}>
                <label class="form-check-label fw-semibold" for="cat-${c.id}">${c.name}</label>
              </div>
            </c:forEach>
          </div>
        </div>

        <div class="mb-4">
          <label class="form-label">Mô tả giới thiệu game *</label>
          <textarea name="description" required rows="5" class="form-control" placeholder="Nhập giới thiệu chi tiết về nội dung cốt truyện, tính năng nổi bật của trò chơi...">${fn:escapeXml(game.description)}</textarea>
        </div>

        <!-- SECTION 2: CẤU HÌNH YÊU CẦU -->
        <h4 class="section-title mt-4">2. Yêu cầu hệ thống</h4>
        
        <input type="hidden" id="minimumRequirements" name="minimumRequirements" value="${fn:escapeXml(game.minimumRequirements)}">
        <input type="hidden" id="recommendedRequirements" name="recommendedRequirements" value="${fn:escapeXml(game.recommendedRequirements)}">

        <div class="row g-4 mb-4">
          <!-- Cột Trái: Tối Thiểu -->
          <div class="col-md-6 border-end border-2 border-dark pe-md-4">
            <h5 class="fw-black mb-3 text-secondary text-uppercase d-flex align-items-center gap-2" style="font-size: 13px;">
              <i data-lucide="terminal" width="16" height="16"></i> Cấu hình tối thiểu
            </h5>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Hệ điều hành (OS)</label>
              <input type="text" id="min_os" class="form-control py-2" placeholder="Ví dụ: Windows 10 64-bit">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Bộ vi xử lý (CPU)</label>
              <input type="text" id="min_cpu" class="form-control py-2" placeholder="Ví dụ: Intel Core i5-4460 / AMD FX-6300">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Bộ nhớ RAM</label>
              <input type="text" id="min_ram" class="form-control py-2" placeholder="Ví dụ: 8 GB RAM">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Card đồ họa (GPU)</label>
              <input type="text" id="min_gpu" class="form-control py-2" placeholder="Ví dụ: NVIDIA GTX 960 / AMD R9 280">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Phiên bản DirectX</label>
              <input type="text" id="min_dx" class="form-control py-2" placeholder="Ví dụ: DirectX 11">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Lưu trữ (Storage)</label>
              <input type="text" id="min_storage" class="form-control py-2" placeholder="Ví dụ: 5 GB dung lượng trống (Khuyến khích SSD)">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">💡 Ghi chú bổ sung (Optional)</label>
              <input type="text" id="min_notes" class="form-control py-2" placeholder="Nhập thêm ghi chú nếu cần thiết (không bắt buộc)">
            </div>
          </div>

          <!-- Cột Phải: Khuyến Nghị -->
          <div class="col-md-6 ps-md-4">
            <h5 class="fw-black mb-3 text-success text-uppercase d-flex align-items-center gap-2" style="font-size: 13px;">
              <i data-lucide="zap" width="16" height="16"></i> Cấu hình đề nghị
            </h5>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Hệ điều hành (OS)</label>
              <input type="text" id="rec_os" class="form-control py-2" placeholder="Ví dụ: Windows 10/11 64-bit">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Bộ vi xử lý (CPU)</label>
              <input type="text" id="rec_cpu" class="form-control py-2" placeholder="Ví dụ: Intel Core i7-4770 / AMD Ryzen 5 1600">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Bộ nhớ RAM</label>
              <input type="text" id="rec_ram" class="form-control py-2" placeholder="Ví dụ: 16 GB RAM">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Card đồ họa (GPU)</label>
              <input type="text" id="rec_gpu" class="form-control py-2" placeholder="Ví dụ: NVIDIA GTX 1060 / AMD RX 580">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Phiên bản DirectX</label>
              <input type="text" id="rec_dx" class="form-control py-2" placeholder="Ví dụ: DirectX 12">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">Lưu trữ (Storage)</label>
              <input type="text" id="rec_storage" class="form-control py-2" placeholder="Ví dụ: 5 GB dung lượng trống (Khuyến khích SSD)">
            </div>
            <div class="mb-3">
              <label class="form-label text-secondary mb-1" style="font-size: 11px;">💡 Ghi chú bổ sung (Optional)</label>
              <input type="text" id="rec_notes" class="form-control py-2" placeholder="Nhập thêm ghi chú nếu cần thiết (không bắt buộc)">
            </div>
          </div>
        </div>

        <!-- SECTION 3: TẢI LÊN MULTIMEDIA -->
        <h4 class="section-title mt-4">3. Tải lên ảnh & video trailer</h4>

        <div class="mb-4">
          <label class="form-label">Ảnh đại diện game (Cover Image) ${isEdit ? '' : '*'}</label>
          <input type="file" name="coverImageFile" ${isEdit ? '' : 'required'} class="form-control" accept="image/*">
          <div class="form-text small" style="font-size:11px;">Đây là ảnh lớn chính hiển thị tại trang chủ storefront.</div>
          
          <c:if test="${isEdit}">
            <div class="mt-2">
              <span class="small fw-bold text-secondary d-block mb-1">Ảnh đại diện hiện tại:</span>
              <c:set var="currCover" value="" />
              <c:forEach var="m" items="${game.mediaList}">
                <c:if test="${m.primary}">
                  <c:set var="currCover" value="${m.mediaUrl}" />
                </c:if>
              </c:forEach>
              <c:if test="${not empty currCover}">
                <img src="${currCover}" class="media-preview-img">
              </c:if>
            </div>
          </c:if>
        </div>

        <div class="mb-4">
          <label class="form-label">Ảnh chụp màn hình bổ sung (Screenshots)</label>
          <input type="file" name="screenshotFiles" class="form-control" accept="image/*" multiple>
          <div class="form-text small" style="font-size:11px;">Hỗ trợ chọn nhiều file ảnh chụp màn hình game cùng lúc (Screenshots Gallery).</div>
          
          <c:if test="${isEdit}">
            <div class="mt-2">
              <span class="small fw-bold text-secondary d-block mb-2">Bộ sưu tập screenshots hiện tại:</span>
              <div class="media-preview-box">
                <c:set var="hasScreenshots" value="false" />
                <c:forEach var="m" items="${game.mediaList}">
                  <c:if test="${m.mediaType == 'IMAGE' && !m.primary}">
                    <c:set var="hasScreenshots" value="true" />
                    <img src="${m.mediaUrl}" class="media-preview-img">
                  </c:if>
                </c:forEach>
                <c:if test="${!hasScreenshots}">
                  <span class="text-secondary small">Chưa có screenshot nào.</span>
                </c:if>
              </div>
            </div>
          </c:if>
        </div>

        <c:set var="currTrailer" value="" />
        <c:if test="${isEdit}">
          <c:forEach var="m" items="${game.mediaList}">
            <c:if test="${m.mediaType == 'VIDEO'}">
              <c:set var="currTrailer" value="${m.mediaUrl}" />
            </c:if>
          </c:forEach>
        </c:if>
        <div class="mb-5">
          <label class="form-label">Đường dẫn Video Trailer game (Link nhúng / Embed URL)</label>
          <input type="text" name="trailerUrl" value="${fn:escapeXml(currTrailer)}" class="form-control" placeholder="Ví dụ: https://www.youtube.com/embed/dQw4w9WgXcQ">
          <div class="form-text small" style="font-size:11px;">Nhập URL video dạng nhúng (Embed URL) để người dùng xem trực tiếp trên cửa hàng.</div>
          
          <c:if test="${isEdit && not empty currTrailer}">
            <div class="mt-2">
              <span class="small fw-bold text-secondary d-block mb-1">Video trailer hiện tại:</span>
              <div class="ratio ratio-16x9 border border-2 border-black rounded shadow-sm" style="max-width: 320px; height: 180px;">
                <iframe src="${currTrailer}" allowfullscreen style="width: 100%; height: 100%; border: 0;"></iframe>
              </div>
            </div>
          </c:if>
        </div>

        <!-- ACTION BUTTONS -->
        <div class="d-flex gap-3 justify-content-end pt-3 border-top border-2 border-black">
          <a href="${pageContext.request.contextPath}/publisher/games" class="btn bg-white text-dark gf-border gf-shadow-sm gf-press fw-bold py-2.5 px-4 rounded-3">
            Hủy bỏ
          </a>
          <button type="submit" class="btn gf-border gf-shadow gf-press fw-bold py-2.5 px-5 rounded-3" style="background: var(--gf-green); color:#000;">
            <i data-lucide="check" width="18" height="18" class="me-1"></i> ${isEdit ? 'Cập nhật game' : 'Đăng game'}
          </button>
        </div>

      </form>
    </div>
  </main>

  <script>
    document.addEventListener("DOMContentLoaded", function() {
        const rawMin = document.getElementById('minimumRequirements').value.trim();
        const rawRec = document.getElementById('recommendedRequirements').value.trim();

        function populateFields(raw, prefix) {
            if (raw && raw.startsWith('{')) {
                try {
                    const data = JSON.parse(raw);
                    document.getElementById(prefix + '_os').value = data.os || '';
                    document.getElementById(prefix + '_cpu').value = data.cpu || '';
                    document.getElementById(prefix + '_ram').value = data.ram || '';
                    document.getElementById(prefix + '_gpu').value = data.gpu || '';
                    document.getElementById(prefix + '_dx').value = data.dx || '';
                    document.getElementById(prefix + '_storage').value = data.storage || '';
                    document.getElementById(prefix + '_notes').value = data.notes || '';
                    return;
                } catch (e) {}
            }
            if (raw) {
                document.getElementById(prefix + '_os').value = raw;
            }
        }
        populateFields(rawMin, 'min');
        populateFields(rawRec, 'rec');

        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            const minData = {
                os: document.getElementById('min_os').value.trim() || "Windows 10 (64-bit)",
                cpu: document.getElementById('min_cpu').value.trim() || "Intel Core i5-4460 / AMD FX-6300",
                ram: document.getElementById('min_ram').value.trim() || "8 GB RAM",
                gpu: document.getElementById('min_gpu').value.trim() || "NVIDIA GeForce GTX 960 / AMD Radeon R9 280",
                dx: document.getElementById('min_dx').value.trim() || "DirectX 11",
                storage: document.getElementById('min_storage').value.trim() || "5 GB dung lượng khả dụng (Khuyến khích SSD)",
                notes: document.getElementById('min_notes').value.trim()
            };
            const recData = {
                os: document.getElementById('rec_os').value.trim() || "Windows 10/11 (64-bit)",
                cpu: document.getElementById('rec_cpu').value.trim() || "Intel Core i7-4770 / AMD Ryzen 5 1600",
                ram: document.getElementById('rec_ram').value.trim() || "16 GB RAM",
                gpu: document.getElementById('rec_gpu').value.trim() || "NVIDIA GeForce GTX 1060 / AMD Radeon RX 580",
                dx: document.getElementById('rec_dx').value.trim() || "DirectX 12",
                storage: document.getElementById('rec_storage').value.trim() || "5 GB dung lượng khả dụng (Khuyến khích SSD)",
                notes: document.getElementById('rec_notes').value.trim()
            };
            document.getElementById('minimumRequirements').value = JSON.stringify(minData);
            document.getElementById('recommendedRequirements').value = JSON.stringify(recData);
        });
    });

    lucide.createIcons();
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
