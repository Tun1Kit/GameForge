document.addEventListener("DOMContentLoaded", function() {
  
  // 1. Khởi tạo Lucide Icons
  if (window.lucide) {
    window.lucide.createIcons();
  }

  // 2. Cache các phần tử DOM
  const searchInput = document.getElementById("txnSearchInput");
  const filterButtons = document.querySelectorAll("#txnFilterBtnGroup button");
  const tableRows = document.querySelectorAll(".txn-row-item");
  const tableBody = document.getElementById("txnTableBody");
  
  let activeFilter = "all";
  let searchQuery = "";

  // Cấu hình Phân trang
  const itemsPerPage = 10;
  let currentPage = 1;

  // Tạo dòng thông báo trống nếu chưa có sẵn
  let emptyRow = document.getElementById("emptyTxnRow");
  if (!emptyRow && tableBody) {
    emptyRow = document.createElement("tr");
    emptyRow.id = "emptyTxnRow";
    emptyRow.classList.add("d-none");
    emptyRow.innerHTML = `
      <td colspan="6" class="text-center py-5">
        <div class="mx-auto mb-3 d-grid place-items-center rounded-4 gf-border text-dark" style="width: 54px; height: 54px; background: var(--gf-pink); place-items:center;">
          <i data-lucide="receipt-text" width="24" height="24"></i>
        </div>
        <h5 class="fw-black">Không tìm thấy kết quả phù hợp</h5>
        <p class="text-secondary small mb-0">Hãy thử nhập từ khóa khác hoặc thay đổi bộ lọc.</p>
      </td>
    `;
    tableBody.appendChild(emptyRow);
    if (window.lucide) window.lucide.createIcons();
  }

  // 3. Xử lý tìm kiếm bằng ô Input
  if (searchInput) {
    searchInput.addEventListener("input", function() {
      searchQuery = this.value.toLowerCase().trim()
        .normalize('NFD').replace(/[\u0300-\u036f]/g, ''); // Loại bỏ dấu tiếng Việt để tìm kiếm chính xác
      currentPage = 1; // Quay về trang 1 khi lọc mới
      applyFilters();
    });
  }

  // 4. Xử lý chuyển tab Lọc giao dịch
  filterButtons.forEach(btn => {
    btn.addEventListener("click", function() {
      // Bỏ active của các nút khác
      filterButtons.forEach(b => {
        b.classList.remove("active");
        b.classList.add("bg-light");
        b.style.backgroundColor = "";
      });
      // Thiết lập active cho nút hiện tại
      this.classList.add("active");
      this.classList.remove("bg-light");
      this.style.backgroundColor = "var(--gf-green)";
      
      activeFilter = this.getAttribute("data-filter");
      currentPage = 1; // Quay về trang 1 khi lọc mới
      applyFilters();
    });
  });

  // 5. Hàm áp dụng bộ lọc, tìm kiếm và phân trang
  function applyFilters() {
    let filteredRows = [];
    
    tableRows.forEach(row => {
      const type = row.getAttribute("data-type");
      const code = row.getAttribute("data-code") || "";
      const desc = row.getAttribute("data-desc") || "";
      
      // Chuẩn hóa chuỗi mô tả để tìm kiếm không dấu
      const normalizedDesc = desc.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
      const normalizedCode = code.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
      
      // Kiểm tra bộ lọc loại giao dịch
      let matchFilter = false;
      if (activeFilter === "all") {
        matchFilter = true;
      } else {
        matchFilter = (type === activeFilter);
      }
      
      // Kiểm tra từ khóa tìm kiếm
      const matchSearch = normalizedDesc.includes(searchQuery) || normalizedCode.includes(searchQuery);
      
      if (matchFilter && matchSearch) {
        filteredRows.push(row);
      } else {
        row.style.display = "none";
      }
    });

    const totalItems = filteredRows.length;
    const totalPages = Math.ceil(totalItems / itemsPerPage);

    // Đảm bảo số trang hiện tại hợp lệ
    if (currentPage > totalPages) currentPage = 1;
    if (currentPage < 1) currentPage = 1;

    // Hiển thị 10 dòng của trang hiện tại, ẩn các dòng khác
    filteredRows.forEach((row, index) => {
      const start = (currentPage - 1) * itemsPerPage;
      const end = start + itemsPerPage;
      if (index >= start && index < end) {
        row.style.display = "table-row";
      } else {
        row.style.display = "none";
      }
    });

    // Hiện/Ẩn dòng trống khi không có kết quả
    const paginationContainer = document.getElementById("txnPaginationContainer");
    if (emptyRow) {
      if (totalItems === 0) {
        emptyRow.classList.remove("d-none");
        emptyRow.style.display = "table-row";
        if (paginationContainer) paginationContainer.classList.add("d-none");
      } else {
        emptyRow.classList.add("d-none");
        emptyRow.style.display = "none";
        if (paginationContainer) paginationContainer.classList.remove("d-none");
      }
    }

    // Render bộ điều khiển phân trang
    renderPaginationControls(totalPages);
  }

  // 6. Hàm hiển thị nút phân trang 1, 2, 3 và Nút Tiến / Lùi
  function renderPaginationControls(totalPages) {
    const pageNumContainer = document.getElementById("txnPageNumbers");
    const prevPageBtn = document.getElementById("txnPrevPageBtn");
    const nextPageBtn = document.getElementById("txnNextPageBtn");
    const paginationContainer = document.getElementById("txnPaginationContainer");

    if (!pageNumContainer || !paginationContainer) return;

    pageNumContainer.innerHTML = "";

    // Nếu chỉ có 1 trang hoặc ít hơn, ẩn hoàn toàn khối phân trang và nút bên
    if (totalPages <= 1) {
      paginationContainer.classList.add("d-none");
      if (prevPageBtn) prevPageBtn.classList.add("d-none");
      if (nextPageBtn) nextPageBtn.classList.add("d-none");
      return;
    } else {
      paginationContainer.classList.remove("d-none");
      if (prevPageBtn) prevPageBtn.classList.remove("d-none");
      if (nextPageBtn) nextPageBtn.classList.remove("d-none");
    }

    // Tạo các nút số trang 1, 2, 3...
    for (let i = 1; i <= totalPages; i++) {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "btn page-num-btn " + (i === currentPage ? "active" : "");
      btn.innerText = i;
      btn.addEventListener("click", function() {
        currentPage = i;
        applyFilters();
        // Cuộn nhẹ lên đầu bảng để có trải nghiệm tốt
        const tableCard = document.querySelector(".table-responsive");
        if (tableCard) tableCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      });
      pageNumContainer.appendChild(btn);
    }

    // Cấu hình nút Lùi trang (Prev)
    if (prevPageBtn) {
      if (currentPage === 1) {
        prevPageBtn.disabled = true;
        prevPageBtn.style.opacity = "0.5";
        prevPageBtn.style.cursor = "not-allowed";
      } else {
        prevPageBtn.disabled = false;
        prevPageBtn.style.opacity = "1";
        prevPageBtn.style.cursor = "pointer";
      }
      prevPageBtn.onclick = function() {
        if (currentPage > 1) {
          currentPage--;
          applyFilters();
        }
      };
    }

    // Cấu hình nút Tiến trang (Next)
    if (nextPageBtn) {
      if (currentPage === totalPages) {
        nextPageBtn.disabled = true;
        nextPageBtn.style.opacity = "0.5";
        nextPageBtn.style.cursor = "not-allowed";
      } else {
        nextPageBtn.disabled = false;
        nextPageBtn.style.opacity = "1";
        nextPageBtn.style.cursor = "pointer";
      }
      nextPageBtn.onclick = function() {
        if (currentPage < totalPages) {
          currentPage++;
          applyFilters();
        }
      };
    }

    // Cập nhật lại Lucide icons cho các nút tiến/lùi
    if (window.lucide) {
      window.lucide.createIcons();
    }
  }

  // Khởi động render phân trang ban đầu
  applyFilters();

});
