document.addEventListener("DOMContentLoaded", function() {
  const contextPath = window.GAMEFORGE_CONTEXT_PATH || '';
  const currentUserId = window.GAMEFORGE_CURRENT_USER_ID;

  // Khóa localStorage theo tài khoản người dùng để tránh lẫn lộn dữ liệu
  const INSTALLED_KEY = `gameforge_installed_u_${currentUserId || 'guest'}`;
  const FAVORITES_KEY = `gameforge_favorites_u_${currentUserId || 'guest'}`;

  // Tải danh sách từ localStorage
  let installedIds = [];
  let favoriteIds = [];
  try {
    installedIds = JSON.parse(localStorage.getItem(INSTALLED_KEY)) || [];
    favoriteIds = JSON.parse(localStorage.getItem(FAVORITES_KEY)) || [];
  } catch (e) {
    console.error("Error reading localStorage:", e);
  }

  // ==========================================
  // 1. KHỞI TẠO TRẠNG THÁI BAN ĐẦU TỪ LOCALSTORAGE
  // ==========================================
  const gridCols = document.querySelectorAll(".library-card-col");

  gridCols.forEach(col => {
    const itemId = col.getAttribute("data-item-id");
    const gameId = col.getAttribute("data-game-id");
    const status = col.getAttribute("data-status");

    if (status === "REFUNDED") {
      const statusBadge = document.getElementById(`statusBadge-${itemId}`);
      if (statusBadge) {
        statusBadge.innerText = "Đã hoàn tiền (Game bị xóa)";
        statusBadge.style.backgroundColor = "var(--gf-pink)";
        statusBadge.style.color = "#fff";
      }
      return; // Bỏ qua logic cài đặt của localstorage
    }

    // 1.1 Khởi tạo trạng thái cài đặt
    const isInstalled = installedIds.includes(itemId);
    col.setAttribute("data-installed", isInstalled ? "true" : "false");

    const statusBadge = document.getElementById(`statusBadge-${itemId}`);
    const actionContainer = document.getElementById(`actionContainer-${itemId}`);

    if (isInstalled && statusBadge && actionContainer) {
      statusBadge.innerText = "Đã cài đặt";
      statusBadge.style.backgroundColor = "#94FFB4";
      actionContainer.innerHTML = `
        <button type="button" onclick="launchGame('${col.getAttribute("data-title")}')" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2" style="background: var(--gf-green); border-radius: 10px;">
          <i data-lucide="play" width="16" height="16" class="me-1"></i> Chơi ngay
        </button>
      `;
    }

    // 1.2 Khởi tạo trạng thái yêu thích
    const isFavorite = favoriteIds.includes(itemId);
    col.setAttribute("data-favorite", isFavorite ? "true" : "false");
    
    const favBtn = col.querySelector(".gf-favorite-btn");
    if (favBtn) {
      if (isFavorite) {
        favBtn.classList.add("active");
        favBtn.classList.add("is-favorite");
      }
      
      // Đăng ký sự kiện click yêu thích
      favBtn.addEventListener("click", function(e) {
        e.stopPropagation();
        toggleFavorite(itemId, favBtn);
      });
    }
  });

  if (window.lucide) {
    window.lucide.createIcons();
  }

  // ==========================================
  // 2. TÌM KIẾM VÀ LỌC GAME TRONG THƯ VIỆN
  // ==========================================
  const searchInput = document.getElementById("librarySearchInput");
  const filterButtons = document.querySelectorAll("#filterBtnGroup button");
  const sortSelect = document.getElementById("sortSelect");
  
  let activeFilter = "all";
  let searchQuery = "";

  // Tìm kiếm game
  if (searchInput) {
    searchInput.addEventListener("input", function() {
      searchQuery = this.value.toLowerCase().trim();
      applyFilters();
    });
  }

  // Lọc game
  filterButtons.forEach(btn => {
    btn.addEventListener("click", function() {
      filterButtons.forEach(b => {
        b.classList.remove("active");
        b.classList.add("bg-light");
        b.style.backgroundColor = "";
      });
      this.classList.add("active");
      this.classList.remove("bg-light");
      this.style.backgroundColor = "var(--gf-green)";
      
      activeFilter = this.getAttribute("data-filter");
      applyFilters();
    });
  });

  // Sắp xếp game
  if (sortSelect) {
    sortSelect.addEventListener("change", function() {
      const sorting = this.value;
      const sortedArray = Array.from(gridCols);
      
      sortedArray.sort((a, b) => {
        const dateA = new Date(a.getAttribute("data-acquired"));
        const dateB = new Date(b.getAttribute("data-acquired"));
        return sorting === "newest" ? dateB - dateA : dateA - dateB;
      });
      
      const grid = document.getElementById("libraryGrid");
      grid.innerHTML = "";
      sortedArray.forEach(col => grid.appendChild(col));
      applyFilters();
    });
  }

  function applyFilters() {
    gridCols.forEach(col => {
      const title = col.getAttribute("data-title");
      const isInstalled = col.getAttribute("data-installed") === "true";
      const isFavorite = col.getAttribute("data-favorite") === "true";
      
      let matchFilter = false;
      if (activeFilter === "all") matchFilter = true;
      else if (activeFilter === "installed") matchFilter = isInstalled;
      else if (activeFilter === "uninstalled") matchFilter = !isInstalled;
      else if (activeFilter === "favorite") matchFilter = isFavorite;
      
      const matchSearch = title.includes(searchQuery);
      
      if (matchFilter && matchSearch) {
        col.style.display = "block";
      } else {
        col.style.display = "none";
      }
    });
  }

  // ==========================================
  // 3. GIẢ LẬP TẢI XUỐNG GAME (MOCK PROGRESS)
  // ==========================================
  window.startDownloadSimulation = function(itemId, gameTitle) {
    const actionContainer = document.getElementById(`actionContainer-${itemId}`);
    const progressContainer = document.getElementById(`downloadProgressContainer-${itemId}`);
    const progressBarFill = document.getElementById(`downloadProgressBarFill-${itemId}`);
    const progressPercent = document.getElementById(`downloadProgressPercent-${itemId}`);
    const statusBadge = document.getElementById(`statusBadge-${itemId}`);
    const cardCol = actionContainer.closest(".library-card-col");
    
    // Ẩn các nút hành động, hiện thanh tiến trình
    actionContainer.classList.add("d-none");
    progressContainer.classList.remove("d-none");
    
    let progress = 0;
    const interval = setInterval(() => {
      progress += 4;
      if (progress > 100) progress = 100;
      
      progressBarFill.style.width = `${progress}%`;
      progressPercent.innerText = `${progress}%`;
      
      if (progress >= 100) {
        clearInterval(interval);
        setTimeout(() => {
          // Tải thành công!
          progressContainer.classList.add("d-none");
          actionContainer.innerHTML = `
            <button type="button" onclick="launchGame('${gameTitle}')" class="btn w-100 gf-border gf-shadow-sm gf-press fw-bold py-2" style="background: var(--gf-green); border-radius: 10px;">
              <i data-lucide="play" width="16" height="16" class="me-1"></i> Chơi ngay
            </button>
          `;
          actionContainer.classList.remove("d-none");
          
          // Cập nhật thẻ trạng thái & data attribute
          statusBadge.innerText = "Đã cài đặt";
          statusBadge.style.backgroundColor = "#94FFB4";
          cardCol.setAttribute("data-installed", "true");
          
          // Lưu trạng thái cài đặt vào localStorage lâu dài
          if (!installedIds.includes(itemId)) {
            installedIds.push(itemId);
            localStorage.setItem(INSTALLED_KEY, JSON.stringify(installedIds));
          }
          
          // Khởi tạo lại Lucide icons cho nút mới
          if (window.lucide) window.lucide.createIcons();
          
          alert(`Tải game "${gameTitle}" hoàn tất thành công!`);
          applyFilters();
        }, 400);
      }
    }, 100);
  };

  // Khởi chạy game giả lập (Trình khởi chạy Neo-brutalism cực xịn sò)
  window.launchGame = function(gameTitle) {
    let displayTitle = gameTitle;
    if (gameTitle.includes("col.get")) displayTitle = "Tựa game sở hữu";

    const modalEl = document.getElementById("gameLauncherModal");
    if (!modalEl) {
      alert(`🚀 Đang khởi chạy tựa game "${displayTitle}"... Vui lòng đợi trong giây lát!`);
      return;
    }

    const titleEl = document.getElementById("launcherGameTitle");
    const statusEl = document.getElementById("launcherStatusText");
    const barEl = document.getElementById("launcherProgressBarFill");
    const finishEl = document.getElementById("launcherFinishedText");
    const closeBtn = document.getElementById("launcherCloseBtn");
    const headerCloseBtn = document.getElementById("launcherHeaderCloseBtn");

    if (titleEl) titleEl.innerText = displayTitle;
    if (statusEl) statusEl.innerText = "🚀 Đang kết nối máy chủ GameForge...";
    if (barEl) barEl.style.width = "0%";
    if (finishEl) finishEl.classList.add("d-none");
    if (closeBtn) closeBtn.classList.add("d-none");
    if (headerCloseBtn) headerCloseBtn.classList.add("d-none");

    const modal = new bootstrap.Modal(modalEl);
    modal.show();

    // Chạy thanh tiến trình tải môi trường
    let percent = 0;
    const interval = setInterval(() => {
      percent += 5;
      if (percent > 100) percent = 100;
      if (barEl) barEl.style.width = percent + "%";

      if (percent === 30 && statusEl) {
        statusEl.innerText = "🔧 Đang giải nén tài nguyên trò chơi...";
      } else if (percent === 60 && statusEl) {
        statusEl.innerText = "🛡️ Đang kiểm tra bản quyền & DRM...";
      } else if (percent === 85 && statusEl) {
        statusEl.innerText = "🔌 Đang khởi động tiến trình đồ họa...";
      }

      if (percent >= 100) {
        clearInterval(interval);
        setTimeout(() => {
          if (statusEl) statusEl.innerText = "🎮 Đang khởi chạy tựa game!";
          if (finishEl) finishEl.classList.remove("d-none");
          if (closeBtn) closeBtn.classList.remove("d-none");
          if (headerCloseBtn) headerCloseBtn.classList.remove("d-none");
          if (window.lucide) window.lucide.createIcons();
        }, 300);
      }
    }, 100);
  };

  // ==========================================
  // 4. XỬ LÝ CLICK YÊU THÍCH (FAVORITE TOGGLE)
  // ==========================================
  function toggleFavorite(itemId, favBtn) {
    const cardCol = favBtn.closest(".library-card-col");
    
    let isFavorite = favoriteIds.includes(itemId);
    
    if (isFavorite) {
      // Hủy yêu thích
      favoriteIds = favoriteIds.filter(id => id !== itemId);
      favBtn.classList.remove("active");
      favBtn.classList.remove("is-favorite");
      cardCol.setAttribute("data-favorite", "false");
    } else {
      // Thêm yêu thích
      favoriteIds.push(itemId);
      favBtn.classList.add("active");
      favBtn.classList.add("is-favorite");
      cardCol.setAttribute("data-favorite", "true");
    }
    
    localStorage.setItem(FAVORITES_KEY, JSON.stringify(favoriteIds));
    applyFilters();
  }

  // ==========================================
  // 5. AJAX CẬP NHẬT THÔNG TIN HỒ SƠ
  // ==========================================
  window.submitProfileUpdate = function(event) {
    event.preventDefault();
    
    const form = document.getElementById("profileUpdateForm");
    const fullName = form.querySelector("[name='fullName']").value.trim();
    const password = form.querySelector("[name='password']").value.trim();
    const avatar = form.querySelector("[name='avatar']").value.trim();
    
    const formData = new FormData();
    formData.append("fullName", fullName);
    formData.append("password", password);
    formData.append("avatar", avatar);

    var libCsrfToken = window.GAMEFORGE_CSRF_TOKEN;
    var libCsrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";
    var libHeaders = {};
    if (libCsrfToken) libHeaders[libCsrfHeader] = libCsrfToken;

    fetch(contextPath + "/api/profile/update", {
      method: "POST",
      headers: libHeaders,
      body: formData
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        // Cập nhật động trên UI mà không cần reload
        document.getElementById("profileNameDisplay").innerText = fullName;
        const libraryTitleName = document.getElementById("libraryTitleName");
        if (libraryTitleName) {
          libraryTitleName.innerText = fullName;
        }
        if (avatar) {
          document.getElementById("avatarImagePreview").src = avatar;
        }
        
        // Reset password input
        form.querySelector("[name='password']").value = "";
        
        alert("Cập nhật thông tin cá nhân thành công!");
      } else {
        alert("Lỗi cập nhật: " + data.message);
      }
    })
    .catch(err => {
      console.error("Profile update error:", err);
      alert("Đã xảy ra lỗi kết nối khi lưu thông tin.");
    });
  };

  window.selectPresetAvatar = function(url, imgEl) {
    const avatarInput = document.querySelector("#profileUpdateForm [name='avatar']");
    if (avatarInput) {
      avatarInput.value = url;
    }
    const previewImg = document.getElementById("avatarImagePreview");
    if (previewImg) {
      previewImg.src = url;
    }
    document.querySelectorAll(".preset-avatar-option").forEach(img => {
      img.style.borderColor = "#000";
    });
    imgEl.style.borderColor = "var(--gf-green)";
  };
});
