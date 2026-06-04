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

    function loadWishlistFromDb() {
      if (currentUserId == null) {
        favorites.clear();
        updateCounts();
        updateButtonStates();
        return;
      }
      fetch(contextPath + '/api/wishlist/items')
        .then(function(res) { return res.text(); })
        .then(function(text) {
          var params = parseQuery(text);
          favorites.clear();
          if (params.IDS && params.IDS.length > 0) {
            params.IDS.split(',').forEach(function(id) {
              favorites.add(String(id.trim()));
            });
          }
          localStorage.setItem(favKey, JSON.stringify(Array.from(favorites)));
          updateButtonStates();
          updateCounts();
        })
        .catch(function() {});
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
	  if (event) {
	    event.preventDefault();
	    event.stopPropagation();
	  }

	  if (currentUserId == null) {
	    window.location.href = contextPath + '/login';
	    return;
	  }

	  const gameId = String(id);
	  var csrfToken = window.GAMEFORGE_CSRF_TOKEN || "";
	  var csrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";

	  // Optimistic UI update
	  const wasFavorite = favorites.has(gameId);
	  if (wasFavorite) {
	    favorites.delete(gameId);
	  } else {
	    favorites.add(gameId);
	  }
	  saveState();

	  var body = "gameId=" + encodeURIComponent(gameId);
	  if (csrfToken) body += "&" + encodeURIComponent(csrfHeader) + "=" + encodeURIComponent(csrfToken);

	  fetch(contextPath + '/api/wishlist/toggle', {
	    method: 'POST',
	    headers: (function() {
	      var h = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
	      if (csrfToken) h[csrfHeader] = csrfToken;
	      return h;
	    })(),
	    body: body
	  })
	  .then(function(res) { return res.text(); })
	  .then(function(text) {
	    var params = parseQuery(text);
	    if (params.ERROR) {
	      // Rollback optimistic update
	      if (wasFavorite) {
	        favorites.add(gameId);
	      } else {
	        favorites.delete(gameId);
	      }
	      saveState();
	      alert(params.ERROR);
	    } else {
	      // Server state confirmation
	      if (params.STATUS === 'ADDED') {
	        favorites.add(gameId);
	      } else if (params.STATUS === 'REMOVED') {
	        favorites.delete(gameId);
	      }
	      saveState();
	    }
	  })
	  .catch(function() {
	    // Rollback on network failure
	    if (wasFavorite) {
	      favorites.add(gameId);
	    } else {
	      favorites.delete(gameId);
	    }
	    saveState();
	  });

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
            alert(params.ERROR);
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

    function parseRam(reqString) {
      if (!reqString) return 0;
      const match = reqString.match(/(\d+)\s*gb/i);
      if (match) {
        return parseInt(match[1], 10);
      }
      const numMatch = reqString.match(/(\d+)/);
      if (numMatch) {
        return parseInt(numMatch[1], 10);
      }
      return 0;
    }

    function matchesFilters(item) {
      // 1. Search text filter
      const title = norm(item.dataset.title);
      const allCategories = item.dataset.categories || '';
      const matchesSearch = !searchText || title.includes(norm(searchText)) || allCategories.includes(norm(searchText));
      if (!matchesSearch) return false;

      // 2. Category select filter
      const filterCat = document.getElementById('filterCategory');
      const catVal = filterCat ? filterCat.value : 'all';
      if (catVal !== 'all') {
        const categoriesStr = allCategories.trim().split(/\s+/); // Split by spaces into array
        const searchCat = catVal.toLowerCase();
        if (!categoriesStr.includes(searchCat)) {
          return false;
        }
      }

      // 3. Price select filter
      const filterPrice = document.getElementById('filterPrice');
      const priceVal = filterPrice ? filterPrice.value : 'all';
      if (priceVal !== 'all') {
        const price = parseFloat(item.dataset.price || '0');
        if (priceVal === 'under-100k' && price >= 100000) return false;
        if (priceVal === '100k-500k' && (price < 100000 || price > 500000)) return false;
        if (priceVal === 'over-500k' && price <= 500000) return false;
      }

      // 4. RAM requirement filter
      const filterRam = document.getElementById('filterRam');
      const ramVal = filterRam ? filterRam.value : 'all';
      if (ramVal !== 'all') {
        const minReq = item.dataset.minReq || '';
        const parsedRam = parseRam(minReq);
        if (ramVal === 'ram-8' && parsedRam > 8) return false;
        if (ramVal === 'ram-16' && parsedRam > 16) return false;
      }

      return true;
    }

    function getHotItems() {
      if (!els.hotTrack) return [];

      return Array.from(els.hotTrack.querySelectorAll('.gf-hot-slide-card')).filter(function(item) {
        const id = String(item.dataset.id || '');
        const matchesFavorite = !favoriteOnlyHot || favorites.has(id);
        const matchesFilt = matchesFilters(item);
        item.style.display = matchesFilt && matchesFavorite ? '' : 'none';
        return matchesFilt && matchesFavorite;
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
        const id = String(item.dataset.id || '');
        const matchesFavorite = !favoriteOnlySale || favorites.has(id);
        const matchesFilt = matchesFilters(item);
        return matchesFilt && matchesFavorite;
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
          if (!document.getElementById('hot-games')) {
            window.location.href = contextPath + '/wishlist';
            return;
          }
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

      // Autocomplete search suggestions
      let allGamesCached = [];
      function cacheAllGames() {
        const items = document.querySelectorAll('.game-item');
        const seen = new Set();
        allGamesCached = [];
        items.forEach(function(item) {
          const id = item.dataset.id;
          if (!id || seen.has(id)) return;
          seen.add(id);

          const title = item.querySelector('h3') ? item.querySelector('h3').textContent.trim() : (item.dataset.title || '');
          const slug = item.querySelector('a') ? item.querySelector('a').getAttribute('href').split('/').pop() : '';
          const priceElement = item.querySelector('.gf-price-regular, .gf-price-discounted');
          const priceText = priceElement ? priceElement.textContent.trim() : '';
          const imgEl = item.querySelector('img');
          const imgUrl = imgEl ? imgEl.getAttribute('src') : null;
          
          allGamesCached.push({
            id: id,
            title: title,
            slug: slug,
            priceText: priceText,
            imgUrl: imgUrl,
            normTitle: norm(title),
            normCategory: norm(item.dataset.category || '')
          });
        });
      }

      function updateSearchSuggestions(query) {
        const wrapper = document.getElementById('searchSuggestions');
        if (!wrapper) return;

        const val = norm(query);
        if (!val) {
          wrapper.classList.add('d-none');
          return;
        }

        if (allGamesCached.length === 0) {
          cacheAllGames();
        }

        const matches = allGamesCached.filter(function(g) {
          return g.normTitle.includes(val) || g.normCategory.includes(val);
        });

        if (matches.length === 0) {
          wrapper.innerHTML = '<div class="text-center py-2 fw-semibold text-secondary small">Không tìm thấy game nào</div>';
          wrapper.classList.remove('d-none');
          return;
        }

        let html = '<div class="d-flex flex-column gap-1">';
        matches.forEach(function(g) {
          html += '<a href="' + contextPath + '/game/' + g.slug + '" class="d-flex align-items-center gap-2 p-2 rounded-2 text-decoration-none text-dark" style="border: 2px solid transparent; transition: border-color 0.15s, background 0.15s;" onmouseover="this.style.borderColor=\'#000\';this.style.background=\'#fafafa\'" onmouseout="this.style.borderColor=\'transparent\';this.style.background=\'transparent\'">';
          if (g.imgUrl) {
            html += '<img src="' + g.imgUrl + '" alt="' + g.title + '" style="width: 48px; height: 28px; object-fit: cover; border-radius: 4px; border: 1.5px solid #000;">';
          } else {
            html += '<div class="d-flex align-items-center justify-content-center bg-zinc-200 text-zinc-500 font-bold" style="width: 48px; height: 28px; border-radius: 4px; border: 1.5px solid #000; font-size: 8px;">No image</div>';
          }
          html += '<div class="flex-grow-1 min-width-0">';
          html += '<div class="small fw-bold text-truncate">' + g.title + '</div>';
          html += '<div class="text-success fw-black small" style="font-size: 11px;">' + g.priceText + '</div>';
          html += '</div>';
          html += '</a>';
        });
        html += '</div>';

        wrapper.innerHTML = html;
        wrapper.classList.remove('d-none');
      }

      if (els.searchInput) {
        els.searchInput.addEventListener('input', function(event) {
          searchText = event.target.value;
          updateSearchSuggestions(searchText);
        });
      }

      // Hide suggestions when clicking outside
      document.addEventListener('click', function(event) {
        const searchInput = document.getElementById('searchInput');
        const searchContainer = searchInput ? searchInput.parentElement : null;
        const suggestions = document.getElementById('searchSuggestions');
        if (suggestions && searchContainer && !searchContainer.contains(event.target)) {
          suggestions.classList.add('d-none');
        }
      });

      // Bind filter events
      const filterCat = document.getElementById('filterCategory');
      if (filterCat) {
        filterCat.addEventListener('change', function() {
          hotIndex = 0;
          salePage = 0;
          applyFilters();
        });
      }
      const filterPrice = document.getElementById('filterPrice');
      if (filterPrice) {
        filterPrice.addEventListener('change', function() {
          hotIndex = 0;
          salePage = 0;
          applyFilters();
        });
      }
      const filterRam = document.getElementById('filterRam');
      if (filterRam) {
        filterRam.addEventListener('change', function() {
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
      loadWishlistFromDb();
    });