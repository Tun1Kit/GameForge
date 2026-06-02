<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge - ${game.title}</title>

  <script>
    (function () {
      try {
        if (localStorage.getItem('gameforge_theme_bootstrap') === 'dark') {
          document.documentElement.classList.add('gf-dark-mode');
        }
      } catch (e) {}
    })();
  </script>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght=400;600;700;800;900&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  
  <style>
    body { 
      font-family: 'Inter', sans-serif !important; 
    }
    .gf-video-shell {
      background: #000;
      border: 3px solid #000;
      box-shadow: 6px 6px 0px #000;
      border-radius: 16px;
      overflow: hidden;
    }
    .gf-gallery-thumb {
      border: 3px solid #000;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.1s ease;
    }
    .gf-gallery-thumb:hover, .gf-gallery-thumb.active {
      transform: translate(-2px, -2px);
      box-shadow: 3px 3px 0px #000;
      border-color: var(--gf-green) !important;
    }
    .gf-sticky-sidebar {
      position: sticky;
      top: 30px;
    }
    .description-text {
      line-height: 1.8;
      font-size: 15px;
    }
    .media-placeholder {
      background: #e9ecef;
      border: 3px dashed #ced4da;
      border-radius: 16px;
      min-height: 350px;
    }
    .modal-close-brutal {
      background: var(--gf-pink) !important;
      border: 2px solid #000 !important;
      box-shadow: 2px 2px 0px #000;
      opacity: 1 !important;
    }
    .spec-list li {
      margin-bottom: 8px;
      font-size: 14px;
    }
    /* Hiệu ứng chuyển cảnh Fade cực mượt */
    #gfMainProductBanner {
      transition: opacity 0.15s ease-in-out;
    }
  </style>
</head>

<body>

  <div id="rawMinRequirementsData" style="display:none;"><c:out value="${game.minimumRequirements}" /></div>
  <div id="rawRecRequirementsData" style="display:none;"><c:out value="${game.recommendedRequirements}" /></div>

  <nav class="gf-navbar">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none text-reset flex-shrink-0">
          <div class="gf-logo-box gf-press">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold d-none d-sm-inline">GAME<span style="color:var(--gf-green)">FORGE</span></span>
        </a>

        <div class="d-none d-lg-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/#store" class="gf-nav-link">Cửa Hàng</a>
          <a href="${pageContext.request.contextPath}/#sale-games" class="gf-nav-link">Khuyến Mãi</a>
          <a href="${pageContext.request.contextPath}/#community" class="gf-nav-link">Cộng Đồng</a>
          <a href="${pageContext.request.contextPath}/#support" class="gf-nav-link">Hỗ Trợ</a>
        </div>

        <div class="d-flex align-items-center gap-2 gap-sm-3">
          <button id="favoriteTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-pink)" type="button">
            <i data-lucide="heart" width="20" height="20"></i>
            <span id="favoriteCount" class="gf-count-badge text-white" style="background:#f87171;">0</span>
          </button>

          <button id="cartTopBtn" class="gf-icon-btn gf-press" style="background:var(--gf-blue)" type="button">
            <i data-lucide="shopping-cart" width="20" height="20"></i>
            <span id="cartCount" class="gf-count-badge text-black" style="background:var(--gf-yellow);">0</span>
          </button>

          <a href="${pageContext.request.contextPath}/login" class="gf-icon-btn gf-press" style="background:#C084FC">
            <i data-lucide="circle-user" width="20" height="20"></i>
          </a>
        </div>
      </div>
    </div>
  </nav>

  <main class="container-xl py-5" style="min-vh-100">
    
    <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5 d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3">
      <div>
        <c:forEach var="cat" items="${game.categories}" varStatus="status">
          <span class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small mb-2 me-1" style="background:var(--gf-pink); color:#000;">
            ${cat.name}
          </span>
        </c:forEach>
        <c:if test="${empty game.categories}">
          <span class="d-inline-block gf-border-2 gf-shadow-sm rounded-pill px-3 py-1 fw-black fw-bold text-uppercase small mb-2" style="background:var(--gf-pink); color:#000;">
            GAME
          </span>
        </c:if>
        
        <h1 class="display-6 fw-black fw-bold text-dark m-0 mt-1">${game.title}</h1>
        <p class="fw-semibold text-secondary gf-muted m-0 mt-2">Nhà phát triển: <span class="text-dark fw-bold">${not empty game.developer ? game.developer : 'Đang cập nhật'}</span></p>
      </div>
      <div class="d-flex align-items-center gap-2 bg-white gf-border rounded-3 px-3 py-2 gf-shadow-sm">
        <span class="text-warning fw-black fs-5">★★★★★</span>
        <span class="fw-bold text-dark small">(5.0 Đánh giá)</span>
      </div>
    </div>

    <div class="row g-5">
      <div class="col-lg-8">
        
        <c:set var="hasTrailer" value="false" />
        <c:forEach var="media" items="${game.mediaList}">
          <c:if test="${media.mediaType == 'VIDEO' || media.mediaType == 'VIDEO_TRAILER'}">
            <c:set var="hasTrailer" value="true" />
            <c:set var="trailerUrl" value="${media.mediaUrl}" />
          </c:if>
        </c:forEach>

        <c:choose>
          <c:when test="${hasTrailer}">
            <div class="gf-video-shell mb-4">
              <div class="ratio ratio-16x9">
                <iframe id="gfMainVideoFrame" src="${trailerUrl}" title="Game Trailer" allowfullscreen class="border-0"></iframe>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="media-placeholder d-flex flex-column align-items-center justify-content-center mb-4 p-4 text-center text-muted">
              <i data-lucide="video-off" width="48" height="48" class="mb-3"></i>
              <h5 class="fw-bold m-0">Trailer đang được cập nhật</h5>
              <p class="small fw-semibold mt-1 mb-0">Tính năng phát thử trailer sẽ sớm có mặt cho tựa game này.</p>
            </div>
          </c:otherwise>
        </c:choose>

        <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5">
          <h3 class="fs-5 fw-black fw-bold mb-4 d-flex align-items-center gap-2">
            <i data-lucide="images" width="20" height="20" style="color:var(--gf-blue)"></i> Hình ảnh thực tế (Click để xem phóng to chi tiết)
          </h3>
          <div class="row g-3">
            <c:set var="imgCount" value="0" />
            <c:forEach var="media" items="${game.mediaList}">
              <c:if test="${media.mediaType == 'IMAGE'}">
                <div class="col-4">
                  <img src="${pageContext.request.contextPath}${media.mediaUrl}" 
                       class="img-fluid gf-gallery-thumb ${imgCount == 0 ? 'active' : ''}" 
                       alt="Screenshot" 
                       onclick="triggerDoubleAction('${pageContext.request.contextPath}${media.mediaUrl}', this)">
                </div>
                <c:set var="imgCount" value="${imgCount + 1}" />
              </c:if>
            </c:forEach>
            
            <c:if test="${imgCount == 0}">
              <div class="col-12 text-center py-4 text-muted">
                <i data-lucide="image-off" class="mb-2" width="36" height="36"></i>
                <p class="small fw-semibold m-0">Chưa có hình ảnh chụp màn hình thực tế.</p>
              </div>
            </c:if>
          </div>
        </div>
        
        <div class="bg-white gf-border gf-shadow rounded-4 p-4 mb-5">
          <h3 class="fs-5 fw-black fw-bold mb-3 d-flex align-items-center gap-2">
            <i data-lucide="text-quote" width="20" height="20" style="color:var(--gf-green)"></i> Giới thiệu trò chơi
          </h3>
          <div class="fw-semibold text-secondary description-text">
            <c:choose>
              <c:when test="${not empty game.description}">
                ${game.description}
              </c:when>
              <c:otherwise>Nhà phát hành chưa cập nhật mô tả chi tiết cho trò chơi này.</c:otherwise>
            </c:choose>
          </div>
        </div>

        <div class="bg-white gf-border gf-shadow rounded-4 p-4">
          <h3 class="fs-5 fw-black fw-bold mb-4 d-flex align-items-center gap-2">
            <i data-lucide="terminal" width="22" height="22" style="color:var(--gf-purple)"></i>
            Yêu cầu cấu hình hệ thống
          </h3>
          <div class="row g-4">
            <div class="col-12 col-md-6">
              <div class="p-3 rounded-3 border border-2 border-dark h-100" style="background: #fafafa;">
                <h4 class="fs-6 fw-black fw-bold mb-3 text-uppercase text-secondary">Cấu hình tối thiểu</h4>
                <ul class="list-unstyled spec-list text-dark fw-semibold pm-0" id="minSpecsContainer">
                </ul>
              </div>
            </div>
            
            <div class="col-12 col-md-6">
              <div class="p-3 rounded-3 border border-2 border-dark h-100" style="background: #fafafa;">
                <h4 class="fs-6 fw-black fw-bold mb-3 text-uppercase text-success">Cấu hình đề nghị</h4>
                <ul class="list-unstyled spec-list text-dark fw-semibold pm-0" id="recSpecsContainer">
                </ul>
              </div>
            </div>
          </div>
        </div>

      </div>

      <div class="col-lg-4">
        <div class="gf-sticky-sidebar d-flex flex-column gap-4">
          
          <div class="bg-white gf-border gf-shadow rounded-4 p-4 text-center">
            
            <div class="mb-4 gf-border rounded-3 overflow-hidden" style="border-width: 2px !important; cursor: pointer;"
                 onclick="openLightboxFromBanner()">
              <c:set var="mainBanner" value="" />
              <c:catch var="mediaError">
                <c:forEach var="media" items="${game.mediaList}">
                  <c:if test="${media.isPrimary || (empty mainBanner && media.mediaType == 'IMAGE')}">
                    <c:set var="mainBanner" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                  </c:if>
                </c:forEach>
              </c:catch>
              
              <c:if test="${not empty mediaError || empty mainBanner}">
                <c:forEach var="media" items="${game.mediaList}">
                  <c:if test="${empty mainBanner && (fn:contains(media.mediaUrl, 'thumb') || media.mediaType == 'IMAGE')}">
                    <c:set var="mainBanner" value="${pageContext.request.contextPath}${media.mediaUrl}" />
                  </c:if>
                </c:forEach>
              </c:if>
              
              <c:choose>
                <c:when test="${not empty mainBanner}">
                  <img id="gfMainProductBanner" src="${mainBanner}" class="img-fluid w-100" alt="${game.title}" style="object-fit: cover; max-height: 220px;">
                </c:when>
                <c:otherwise>
                  <div class="bg-light py-5 border-bottom border-dark text-muted">
                    <i data-lucide="image" width="36" height="36"></i>
                    <div class="small fw-bold mt-1">No Image Available</div>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="display-6 fw-black fw-bold mb-4" style="color:var(--gf-green); text-shadow: 1px 1px 0px #000;">
              <fmt:formatNumber value="${game.price}" type="number" maxFractionDigits="0" />₫
            </div>

            <button type="button" onclick="quickAddToCart(event, '${game.id}')" class="btn w-100 gf-border gf-shadow gf-press fw-black fw-bold fs-5 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2 mb-3" style="background:var(--gf-green); color:#000;">
              <i data-lucide="shopping-cart" width="20" height="20"></i> THÊM VÀO GIỎ HÀNG
            </button>

            <button type="button" onclick="toggleFavorite(event, '${game.id}')" class="btn w-100 gf-border gf-shadow-sm gf-press fw-black fw-bold py-2.5 rounded-3 d-flex align-items-center justify-content-center gap-2 bg-white text-dark favorite-button" data-game-id="${game.id}">
              <i data-lucide="heart" width="18" height="18" style="color:var(--gf-pink);"></i> YÊU THÍCH
            </button>
          </div>

        </div>
      </div>
    </div>
  </main>

  <div class="modal fade" id="gfGlobalImageLightbox" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl" style="max-width: 96vw;">
      <div class="modal-content bg-white border border-3 border-dark gf-shadow">
        <div class="modal-header bg-light border-bottom border-3 border-dark py-2">
          <h5 class="modal-title fw-black text-dark"><i data-lucide="maximize-2" class="d-inline mb-1 me-1" width="16" height="16"></i> Chế độ xem ảnh phóng to chi tiết</h5>
          <button type="button" class="btn-close modal-close-brutal" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body text-center p-2 bg-dark d-flex align-items-center justify-content-center" style="overflow: auto; min-height: 75vh;">
          <img id="gfLightboxTargetImage" src="" class="img-fluid rounded-1" style="max-height: 84vh; object-fit: contain; cursor: zoom-in;">
        </div>
      </div>
    </div>
  </div>

  <footer class="bg-dark text-white border-top border-3 border-black py-5 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge. Hệ thống Cửa hàng tự động hóa hoàn chỉnh bởi Kiệt.
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  
  <script>
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>
  <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>

  <script>
    lucide.createIcons();

    let lightboxModalInstance = null;

    // HÀM CHUYỂN ĐỔI ẢNH SIDEBAR CÓ HIỆU ỨNG FADE
    function changeMainProductView(imgSrc, element) {
        const mainBanner = document.getElementById('gfMainProductBanner');
        if (mainBanner) {
            mainBanner.style.opacity = '0';
            setTimeout(() => {
                mainBanner.src = imgSrc;
                mainBanner.style.opacity = '1';
            }, 120);
        }
        document.querySelectorAll('.gf-gallery-thumb').forEach(thumb => {
            thumb.classList.remove('active');
        });
        if(element) element.classList.add('active');
    }

    // CLICK ẢNH NHỎ: Chuyển ảnh sidebar + Bung luôn Popup phóng to to đùng
    function triggerDoubleAction(imgSrc, element) {
        changeMainProductView(imgSrc, element);

        const lightboxImg = document.getElementById('gfLightboxTargetImage');
        if (lightboxImg) {
            lightboxImg.src = imgSrc;
            if (!lightboxModalInstance) {
                // Nhờ đảo thư viện lên đầu, câu lệnh khởi tạo này sẽ chạy trơn tru 100%
                lightboxModalInstance = new bootstrap.Modal(document.getElementById('gfGlobalImageLightbox'));
            }
            lightboxModalInstance.show();
        }
    }

    // CLICK BANNER LỚN: Phóng to ảnh đang hiển thị tại khung phải
    function openLightboxFromBanner() {
        const mainBanner = document.getElementById('gfMainProductBanner');
        const lightboxImg = document.getElementById('gfLightboxTargetImage');
        if (mainBanner && lightboxImg) {
            lightboxImg.src = mainBanner.src;
            if (!lightboxModalInstance) {
                lightboxModalInstance = new bootstrap.Modal(document.getElementById('gfGlobalImageLightbox'));
            }
            lightboxModalInstance.show();
        }
    }

    // ENGINE ĐỌC CẤU HÌNH JSON THỜI THƯỢNG (ĐÃ TÍCH HỢP CHỮ DỰ PHÒNG THEO YÊU CẦU)
    function renderSystemSpecifications() {
        const rawMinJson = document.getElementById('rawMinRequirementsData').innerText;
        const rawRecJson = document.getElementById('rawRecRequirementsData').innerText;
        
        const minContainer = document.getElementById('minSpecsContainer');
        const recContainer = document.getElementById('recSpecsContainer');

        const labelMap = {
            os: "Hệ điều hành",
            cpu: "Bộ vi xử lý (CPU)",
            ram: "Bộ nhớ RAM",
            gpu: "Card đồ họa (GPU)",
            storage: "Ổ cứng trống"
        };

        function buildHtml(rawJson, fallbackText) {
            try {
                // KIỆT CONFIG: Nếu dữ liệu trống, mang chữ false hoặc không phải JSON -> hiển thị chữ thông báo chuẩn chỉ
                if (!rawJson || rawJson.trim() === "" || rawJson.trim() === "false" || !rawJson.trim().startsWith('{')) {
                    return `<li><span class="text-secondary">${fallbackText}</span></li>`;
                }
                
                const data = JSON.parse(rawJson);
                let htmlResult = "";
                let hasData = false;
                
                for (const key in labelMap) {
                    if (data[key]) {
                        htmlResult += `<li><strong class="text-secondary">${labelMap[key]}:</strong> ${data[key]}</li>`;
                        hasData = true;
                    }
                }
                return hasData ? htmlResult : `<li><span class="text-secondary">${fallbackText}</span></li>`;
            } catch (e) {
                return `<li><span class="text-secondary">${fallbackText}</span></li>`;
            }
        }

        minContainer.innerHTML = buildHtml(rawMinJson, "Chưa cập nhật. Vui lòng liên hệ nhà phát triển để biết cấu hình tối thiểu.");
        recContainer.innerHTML = buildHtml(rawRecJson, "Chưa cập nhật. Vui lòng liên hệ nhà phát triển để biết cấu hình đề nghị.");
    }

    document.addEventListener("DOMContentLoaded", renderSystemSpecifications);
  </script>
</body>
</html>