const contextPath = window.GAMEFORGE_CONTEXT_PATH || '';
    const favKey = 'gameforge_favorite_games_bootstrap_jsp';
    const cartKey = 'gameforge_cart_games_bootstrap_jsp';
    const userIdKey = 'gameforge_cart_user_id';
    const salePerPage = 8;

    // Nếu userId trong localStorage khác user hiện tại → xóa hết cart + favorites cũ
    const savedUserId = localStorage.getItem(userIdKey);
    const currentUserId = window.GAMEFORGE_CURRENT_USER_ID;
    if (savedUserId !== String(currentUserId)) {
      localStorage.removeItem(favKey);
      localStorage.removeItem(cartKey);
      localStorage.removeItem(userIdKey);
    }

    // Lưu userId hiện tại
    if (currentUserId != null) {
      localStorage.setItem(userIdKey, String(currentUserId));
    }

    let favorites = new Set(JSON.parse(localStorage.getItem(favKey) || '[]'));
    let cart = new Set(JSON.parse(localStorage.getItem(cartKey) || '[]'));
    let cartDbCount = 0; // Số lượng cart thực từ DB

    let hotIndex = 0;
    let salePage = 0;
    let saleDirection = 'next';
    let favoriteOnlyHot = false;
    let favoriteOnlySale = false;
    let searchText = '';

    const els = {};

    function cacheElements() {
      [
        'searchInput','favoriteTopBtn','cartTopBtn',
        'favoriteCount','cartCount',
        'hotTrack','hotDots','hotCurrentPage','hotTotalPages',
        'saleGrid','saleDots','saleCurrentPage','saleTotalPages',
        'hotPrev','hotNext','salePrev','saleNext',
        'toggleFavoriteOnlyHot','toggleFavoriteOnlySale',
        'themeButton','theme-text','icon-light','icon-dark'
      ].forEach(function(id) {
        els[id] = document.getElementById(id);
      });
    }

    function createIcons() {
      if (window.lucide && typeof window.lucide.createIcons === 'function') {
        window.lucide.createIcons();
      }
    }

    function norm(value) {
      return String(value || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function saveState() {
      localStorage.setItem(favKey, JSON.stringify(Array.from(favorites)));
      localStorage.setItem(cartKey, JSON.stringify(Array.from(cart)));
      updateCounts();
      updateButtonStates();
    }

    function updateCounts() {
      if (els.favoriteCount) els.favoriteCount.textContent = favorites.size;
      // Badge hiển thị số từ DB, localStorage chỉ dùng cho nút "In Cart"
      if (els.cartCount) els.cartCount.textContent = cartDbCount;
    }

    /**
     * Load cart items từ database khi trang load
     * Gọi API /api/cart/items để lấy số lượng + danh sách game IDs
     * Dùng để sync localStorage với DB (fix: user logout → login lại, nút "In Cart" sáng đúng)
     */
    function loadCartCountFromDb() {
      if (currentUserId == null) {
        cartDbCount = 0;
        cart.clear();
        updateCounts();
        return;
      }
      fetch(contextPath + '/api/cart/items')
        .then(function(res) { return res.text(); })
        .then(function(text) {
          var params = parseQuery(text);
          cartDbCount = parseInt(params.COUNT || '0', 10);
          // Sync localStorage với DB: xóa cũ, thêm lại từ DB
          cart.clear();
          if (params.IDS && params.IDS.length > 0) {
            params.IDS.split(',').forEach(function(id) {
              cart.add(String(id.trim()));
            });
          }
          localStorage.setItem(cartKey, JSON.stringify(Array.from(cart)));
          updateButtonStates();
          updateCounts();
        })
        .catch(function() {
          cartDbCount = 0;
          updateCounts();
        });
    }

    function updateButtonStates() {
      document.querySelectorAll('.favorite-button').forEach(function(button) {
        const id = String(button.dataset.gameId || '');
        button.classList.toggle('is-favorite', favorites.has(id));
      });

      document.querySelectorAll('.cart-button').forEach(function(button) {
        const id = String(button.dataset.gameId || '');
        button.classList.toggle('is-in-cart', cart.has(id));
      });
    }

	function toggleFavorite(event, id) {
	  // 1. Phải nhận đủ 2 tham số (event, id) và chặn click lan ra ngoài
	  if (event) {
	    event.preventDefault();
	    event.stopPropagation();
	  }

	  // Chưa đăng nhập → chuyển đến trang login
	  if (currentUserId == null) {
	    window.location.href = contextPath + '/login';
	    return;
	  }

	  // 2. Thêm/xóa ID game chuẩn
	  const gameId = String(id);
	  if (favorites.has(gameId)) {
	    favorites.delete(gameId);
	  } else {
	    favorites.add(gameId);
	  }

	  // 3. Lưu dữ liệu (Hàm saveState đã tự động lo việc đổi màu tim và tăng số lượng)
	  saveState(); 

	  // 4. Chỉ render lại lưới khi đang bật chế độ "Chỉ yêu thích", và TẮT hiệu ứng trượt ở Sale Hot (false)
	  if (favoriteOnlyHot) {
	    updateHot();
	  }
	  if (favoriteOnlySale) {
	    renderSale(false); 
	  }
	}
	
   function quickAddToCart(event, id) {
      if (event) {
        event.preventDefault();
        event.stopPropagation();
      }

      // Chưa đăng nhập → chuyển đến trang login
      if (currentUserId == null) {
        window.location.href = contextPath + '/login';
        return;
      }

      const gameId = String(id);
      var cartCsrfToken = window.GAMEFORGE_CSRF_TOKEN || "";
      var cartCsrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";

      if (cart.has(gameId)) {
        cart.delete(gameId);
        saveState();
        var cartBody = "gameId=" + encodeURIComponent(gameId);
        if (cartCsrfToken) cartBody += "&" + encodeURIComponent(cartCsrfHeader) + "=" + encodeURIComponent(cartCsrfToken);
        fetch(contextPath + '/api/cart/remove-by-game', {
          method: 'POST',
          headers: (function() {
            var h = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
            if (cartCsrfToken) h[cartCsrfHeader] = cartCsrfToken;
            return h;
          })(),
          body: cartBody
        }).then(function(res) { return res.text(); }).then(function(text) {
          var params = parseQuery(text);
          if (params.COUNT !== undefined) {
            cartDbCount = parseInt(params.COUNT, 10);
          }
          updateCounts();
        }).catch(function() {});
      } else {
        cart.add(gameId);
        saveState();
        var cartBody2 = "gameId=" + encodeURIComponent(gameId);
        if (cartCsrfToken) cartBody2 += "&" + encodeURIComponent(cartCsrfHeader) + "=" + encodeURIComponent(cartCsrfToken);
        fetch(contextPath + '/api/cart/add', {
          method: 'POST',
          headers: (function() {
            var h = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
            if (cartCsrfToken) h[cartCsrfHeader] = cartCsrfToken;
            return h;
          })(),
          body: cartBody2
        }).then(function(res) { return res.text(); }).then(function(text) {
          var params = parseQuery(text);
          if (params.COUNT !== undefined) {
            cartDbCount = parseInt(params.COUNT, 10);
          }
          if (params.ERROR) {
            cart.delete(gameId);
            saveState();
          }
          updateCounts();
        }).catch(function() {});
      }
    }

    function parseQuery(text) {
      var result = {};
      text.split('&').forEach(function(pair) {
        var parts = pair.split('=');
        if (parts.length === 2) {
          result[parts[0]] = decodeURIComponent(parts[1].replace(/\+/g, ' '));
        }
      });
      return result;
    }

    window.toggleFavorite = toggleFavorite;
    window.quickAddToCart = quickAddToCart;
    window.goHot = goHot;
    window.goSale = goSale;

    function visibleHot() {
      if (window.innerWidth < 640) return 1;
      if (window.innerWidth < 1024) return 2;
      return 4;
    }

    function getHotItems() {
      if (!els.hotTrack) return [];

      return Array.from(els.hotTrack.querySelectorAll('.gf-hot-slide-card')).filter(function(item) {
        const title = norm(item.dataset.title);
        const category = norm(item.dataset.category);
        const id = String(item.dataset.id || '');
        const matchesSearch = !searchText || title.includes(norm(searchText)) || category.includes(norm(searchText));
        const matchesFavorite = !favoriteOnlyHot || favorites.has(id);
        item.style.display = matchesSearch && matchesFavorite ? '' : 'none';
        return matchesSearch && matchesFavorite;
      });
    }

    function updateHot() {
      const visibleItems = getHotItems();
      const visibleCount = visibleHot();
      const max = Math.max(0, visibleItems.length - visibleCount);

      hotIndex = Math.max(0, Math.min(hotIndex, max));

      if (!els.hotTrack) return;

      if (visibleItems.length === 0) {
        els.hotTrack.style.transform = 'translateX(0px)';
        if (els.hotCurrentPage) els.hotCurrentPage.textContent = '00';
        if (els.hotTotalPages) els.hotTotalPages.textContent = '00';
        if (els.hotDots) els.hotDots.innerHTML = '';
        return;
      }

      const firstCard = visibleItems[0];
      const gap = parseFloat(getComputedStyle(els.hotTrack).gap) || 24;
      const width = firstCard.getBoundingClientRect().width;
      els.hotTrack.style.transform = 'translateX(-' + (hotIndex * (width + gap)) + 'px)';

      if (els.hotCurrentPage) els.hotCurrentPage.textContent = String(hotIndex + 1).padStart(2, '0');
      if (els.hotTotalPages) els.hotTotalPages.textContent = String(max + 1).padStart(2, '0');

      if (els.hotDots) {
        els.hotDots.innerHTML = Array.from({ length: max + 1 }, function(_, index) {
          return '<button class="gf-page-dot ' + (index === hotIndex ? 'active' : '') + '" onclick="goHot(' + index + ')" aria-label="Chuyển đến game hot ' + (index + 1) + '"></button>';
        }).join('');
      }
    }

    function changeHot(step) {
      const visibleItems = getHotItems();
      const visibleCount = visibleHot();
      const max = Math.max(0, visibleItems.length - visibleCount);

      if (max > 0) {
        hotIndex = (hotIndex + step + max + 1) % (max + 1);
      } else {
        hotIndex = 0;
      }
      updateHot();
    }

    function goHot(index) {
      hotIndex = index;
      updateHot();
    }

    function getSaleItems() {
      if (!els.saleGrid) return [];

      return Array.from(els.saleGrid.querySelectorAll('.sale-card-wrapper')).filter(function(item) {
        const title = norm(item.dataset.title);
        const category = norm(item.dataset.category);
        const id = String(item.dataset.id || '');
        const matchesSearch = !searchText || title.includes(norm(searchText)) || category.includes(norm(searchText));
        const matchesFavorite = !favoriteOnlySale || favorites.has(id);
        return matchesSearch && matchesFavorite;
      });
    }

    function renderSale(animate) {
      if (!els.saleGrid) return;

      const allItems = Array.from(els.saleGrid.querySelectorAll('.sale-card-wrapper'));
      const visibleItems = getSaleItems();
      const total = Math.max(1, Math.ceil(visibleItems.length / salePerPage));

      if (salePage >= total) salePage = 0;

      const start = salePage * salePerPage;
      const end = start + salePerPage;

      allItems.forEach(function(item) {
        item.style.display = 'none';
      });

      visibleItems.slice(start, end).forEach(function(item) {
        item.style.display = '';
      });

      els.saleGrid.classList.remove('sale-smooth-next', 'sale-smooth-prev');
      void els.saleGrid.offsetWidth;

      if (animate) {
        els.saleGrid.classList.add(saleDirection === 'next' ? 'sale-smooth-next' : 'sale-smooth-prev');
      }

      if (els.saleCurrentPage) els.saleCurrentPage.textContent = visibleItems.length ? String(salePage + 1).padStart(2, '0') : '00';
      if (els.saleTotalPages) els.saleTotalPages.textContent = visibleItems.length ? String(total).padStart(2, '0') : '00';

      if (els.saleDots) {
        els.saleDots.innerHTML = visibleItems.length
          ? Array.from({ length: total }, function(_, index) {
              return '<button class="gf-page-dot ' + (index === salePage ? 'active' : '') + '" onclick="goSale(' + index + ')" aria-label="Chuyển đến trang sale ' + (index + 1) + '"></button>';
            }).join('')
          : '';
      }

      createIcons();
    }

    function changeSale(step) {
      const visibleItems = getSaleItems();
      const total = Math.max(1, Math.ceil(visibleItems.length / salePerPage));

      saleDirection = step > 0 ? 'next' : 'prev';
      salePage = (salePage + step + total) % total;
      renderSale(true);
    }

    function goSale(index) {
      saleDirection = index > salePage ? 'next' : 'prev';
      salePage = index;
      renderSale(true);
    }

    function applyFilters() {
      updateHot();
      renderSale(true);
      updateButtonStates();
      createIcons();
    }

	function toggleTheme() {
	  const isDark = !document.body.classList.contains('gf-dark-mode');

	  document.body.classList.toggle('gf-dark-mode', isDark);
	  document.documentElement.classList.toggle('gf-dark-mode', isDark);

	  localStorage.setItem('gameforge_theme_bootstrap', isDark ? 'dark' : 'light');

	  if (els['theme-text']) els['theme-text'].textContent = isDark ? 'Dark' : 'Light';
	  if (els['icon-light']) els['icon-light'].classList.toggle('d-none', isDark);
	  if (els['icon-dark']) els['icon-dark'].classList.toggle('d-none', !isDark);
	}
	
	function initTheme() {
	  const isDark =
	    localStorage.getItem('gameforge_theme_bootstrap') === 'dark';

	  document.body.classList.toggle('gf-dark-mode', isDark);
	  document.documentElement.classList.toggle('gf-dark-mode', isDark);

	  if (els['theme-text']) {
	    els['theme-text'].textContent = isDark ? 'Dark' : 'Light';
	  }

	  if (els['icon-light']) {
	    els['icon-light'].classList.toggle('d-none', isDark);
	  }

	  if (els['icon-dark']) {
	    els['icon-dark'].classList.toggle('d-none', !isDark);
	  }
	}
	
    function bindEvents() {
      if (els.hotPrev) els.hotPrev.addEventListener('click', function() { changeHot(-1); });
      if (els.hotNext) els.hotNext.addEventListener('click', function() { changeHot(1); });
      if (els.salePrev) els.salePrev.addEventListener('click', function() { changeSale(-1); });
      if (els.saleNext) els.saleNext.addEventListener('click', function() { changeSale(1); });

      if (els.toggleFavoriteOnlyHot) {
        els.toggleFavoriteOnlyHot.addEventListener('click', function() {
          favoriteOnlyHot = !favoriteOnlyHot;
          hotIndex = 0;
          updateHot();
        });
      }
	  

      if (els.toggleFavoriteOnlySale) {
        els.toggleFavoriteOnlySale.addEventListener('click', function() {
          favoriteOnlySale = !favoriteOnlySale;
          salePage = 0;
          saleDirection = 'next';
          renderSale(true);
        });
      }

      if (els.favoriteTopBtn) {
        els.favoriteTopBtn.addEventListener('click', function() {
          favoriteOnlyHot = !favoriteOnlyHot;
          favoriteOnlySale = favoriteOnlyHot;
          hotIndex = 0;
          salePage = 0;
          applyFilters();
          const hotSection = document.getElementById('hot-games');
          if (hotSection) hotSection.scrollIntoView({ behavior: 'smooth' });
        });
      }

      if (els.cartTopBtn) {
        els.cartTopBtn.addEventListener('click', function() {
          // Dùng cartDbCount (từ DB) để kiểm tra giỏ trống
          if (currentUserId == null) {
            alert('Vui lòng đăng nhập để xem giỏ hàng.');
            return;
          }
          if (cartDbCount === 0) {
            alert('Giỏ hàng của bạn đang trống!');
          } else {
            window.location.href = contextPath + '/checkout';
          }
        });
      }

      if (els.searchInput) {
        els.searchInput.addEventListener('input', function(event) {
          searchText = event.target.value;
          hotIndex = 0;
          salePage = 0;
          applyFilters();
        });
      }

      if (els.themeButton) els.themeButton.addEventListener('click', toggleTheme);

      window.addEventListener('resize', updateHot);

      document.addEventListener('keydown', function(event) {
        const activeTag = document.activeElement && document.activeElement.tagName ? document.activeElement.tagName.toLowerCase() : '';
        if (activeTag === 'input' || activeTag === 'textarea') return;

        if (event.key === 'ArrowLeft') {
          changeHot(-1);
          changeSale(-1);
        }
        if (event.key === 'ArrowRight') {
          changeHot(1);
          changeSale(1);
        }
      });
    }

    document.addEventListener('DOMContentLoaded', function() {
      cacheElements();
      initTheme();
      bindEvents();
      updateCounts();
      updateButtonStates();
      updateHot();
      renderSale(false);
      createIcons();
      // Load cart count từ DB (badge chính xác theo user)
      loadCartCountFromDb();
    });