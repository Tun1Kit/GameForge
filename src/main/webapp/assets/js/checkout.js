// Checkout JS - GameForge
// Handles: payment tabs, Vietnam address API (2025 model), cart AJAX, form validation
// NOTE: cartItemsData is injected by JSP via window.cartItemsData

(function () {
  "use strict";

  // ─────────────────────────────────────────
  // CONFIG
  // ─────────────────────────────────────────
  var ADDRESS_API = {
    provinces: "https://raw.githubusercontent.com/AnhKhoaCNTT/DonViHanhChinhVietNam/main/json-raw/Tinh.ThanhPho.json",
    wardBase: "https://raw.githubusercontent.com/AnhKhoaCNTT/DonViHanhChinhVietNam/main/json-raw/"
  };
  var provincesCache = null;
  var selectedPaymentMethod = "WALLET";

  // QR checkout state
  var checkoutQrTimerInterval = null;
  var pendingCheckoutData = null;

  // ─────────────────────────────────────────
  // DOM READY
  // ─────────────────────────────────────────
  document.addEventListener("DOMContentLoaded", function () {
    initCartItemsRender();
    initPaymentOptionSwitch();
    initWalletProviderListener();
    initLocationDropdowns();
    initFormValidation();
    if (window.lucide) {
      lucide.createIcons();
    }
  });

  // ─────────────────────────────────────────
  // RENDER CART ITEMS FROM window.cartItemsData
  // ─────────────────────────────────────────
  function recalculateCartTotals() {
    var items = window.cartItemsData || [];
    var subtotal = 0;   // tổng giá gốc
    var discount = 0;   // tổng tiền được giảm
    items.forEach(function (item) {
      var original = parseFloat(item.originalPrice) || 0;
      var sale = parseFloat(item.price) || 0;
      subtotal += original;
      discount += (original - sale);
    });
    var total = subtotal - discount;
    var formatMoney = function (val) {
      return new Intl.NumberFormat("vi-VN").format(Math.max(0, val)) + " VND";
    };
    var el;
    el = document.getElementById("cartItemCount");
    if (el) el.textContent = items.length + " san pham";
    el = document.getElementById("subtotalPrice");
    if (el) el.textContent = formatMoney(subtotal);
    el = document.getElementById("discountPrice");
    if (el) el.textContent = "-" + formatMoney(discount);
    el = document.getElementById("totalPrice");
    if (el) el.textContent = formatMoney(total);
    var payBtn = document.querySelector(".gf-pay-btn");
    if (payBtn) payBtn.disabled = (items.length === 0);
    return { subtotal: subtotal, discount: discount, total: total };
  }
  function renderCartItems() {
    var wrapper = document.getElementById("gfCartItemsWrapper");
    if (!wrapper) return;
    var items = window.cartItemsData || [];
    if (items.length === 0) {
      wrapper.innerHTML = '<div class="text-center py-5">' +
        '<i data-lucide="shopping-cart" width="48" height="48" class="text-secondary mb-3"></i>' +
        '<h4 class="fw-black">Gio hang cua ban dang trong</h4>' +
        '<p class="text-secondary small">Hay quay lai trang chu va chon tua game yeu thich cua ban!</p>' +
        '</div>';
      if (window.lucide) lucide.createIcons();
      return;
    }
    var html = '<div class="d-flex flex-column gap-3">';
    items.forEach(function (item) {
      var formattedPrice = new Intl.NumberFormat("vi-VN").format(item.price);
      var formattedOriginal = new Intl.NumberFormat("vi-VN").format(item.originalPrice);
      html += '<div class="gf-cart-item" data-item-id="' + item.id + '" data-price="' + item.price + '">' +
        '<div class="d-flex align-items-center justify-content-between flex-wrap gap-3 w-100">' +
        '<div class="d-flex align-items-center gap-3 flex-grow-1">' +
        '<div class="gf-cart-img-wrapper flex-shrink-0">' +
        '<img src="' + item.image + '" alt="' + item.title + '">' +
        '</div>' +
        '<div>' +
        '<h3 class="fs-6 fw-black fw-bold mb-1">' + item.title + '</h3>' +
        '<div class="d-flex flex-wrap gap-1 align-items-center">' +
        '<span class="gf-item-badge gf-badge-rpg">Hanh dong RPG</span>' +
        '</div>' +
        '<div class="small fw-bold mt-1 d-flex align-items-center gap-1" style="color: var(--gf-pink);">' +
        '<span class="gf-item-badge gf-badge-promo"><i data-lucide="gift" width="12" height="12"></i> Dang co khuyen mai</span>' +
        '</div>' +
        '</div>' +
        '</div>' +
        '<div class="d-flex align-items-center gap-3 flex-shrink-0">' +
        '<div class="text-end">' +
        '<div class="small" style="text-decoration: line-through; color: var(--gf-muted);">' + formattedOriginal + ' VND</div>' +
        '<div class="fw-black fw-bold" style="color: var(--gf-green); font-size: 18px;">' + formattedPrice + ' VND</div>' +
        '<span class="badge bg-danger border-2 rounded-pill fw-black text-white" style="font-size:10px;">-25%</span>' +
        '</div>' +
        '<div class="d-flex align-items-center">' +
        '<div class="gf-qty-box">' +
        '<button type="button" class="gf-qty-btn" onclick="onDecrease(this, ' + item.id + ')">-</button>' +
        '<input type="text" class="gf-qty-input" value="1" readonly>' +
        '<button type="button" class="gf-qty-btn" disabled>+</button>' +
        '</div>' +
        '</div>' +
        '</div>' +
        '</div>' +
        '</div>';
    });
    html += '</div>';
    wrapper.innerHTML = html;
    if (window.lucide) lucide.createIcons();
    recalculateCartTotals();
  }

  function initCartItemsRender() {
    renderCartItems();
  }

  // ─────────────────────────────────────────
  // PAYMENT TAB SWITCHER
  // ─────────────────────────────────────────
  function initPaymentOptionSwitch() {
    var options = document.querySelectorAll(".gf-payment-option");
    var methodInput = document.getElementById("paymentMethodInput");
    options.forEach(function (opt) {
      opt.addEventListener("click", function () {
        options.forEach(function (o) { o.classList.remove("active"); });
        opt.classList.add("active");
        selectedPaymentMethod = opt.dataset.method;
        methodInput.value = selectedPaymentMethod;
        document.querySelectorAll(".payment-group").forEach(function (group) {
          group.classList.add("d-none");
          var fields = group.querySelectorAll("input, select");
          fields.forEach(function (el) { el.removeAttribute("required"); });
        });
        var targetGroup = document.getElementById("fields-" + selectedPaymentMethod);
        if (targetGroup) {
          targetGroup.classList.remove("d-none");
          var fields = targetGroup.querySelectorAll("input, select");
          fields.forEach(function (el) {
            if (el.name.indexOf("notes") === -1 && el.name.indexOf("card") === -1) {
              el.setAttribute("required", "required");
            }
          });
        }
      });
    });
  }

  // ─────────────────────────────────────────
  // WALLET PROVIDER LISTENER (Show/Hide GameForge balance)
  // ─────────────────────────────────────────
  function initWalletProviderListener() {
    var walletSelect = document.getElementById('walletProviderSelect');
    if (!walletSelect) return;
    walletSelect.addEventListener('change', function() {
      var infoDiv = document.getElementById('gameforgeWalletInfo');
      if (!infoDiv) return;
      if (this.value === 'GAMEFORGE') {
        infoDiv.classList.remove('d-none');
      } else {
        infoDiv.classList.add('d-none');
      }
    });
  }

  // ─────────────────────────────────────────
  // ADDRESS API - LOAD PROVINCES
  // ─────────────────────────────────────────
  function loadProvinces(callback) {
    if (provincesCache) {
      callback(provincesCache);
      return;
    }
    var xhr = new XMLHttpRequest();
    xhr.open("GET", ADDRESS_API.provinces, true);
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          try {
            var data = JSON.parse(xhr.responseText);
            provincesCache = data.filter(function (p) { return p.id !== -1; });
            callback(provincesCache);
          } catch (e) {
            console.error("Loi parse provinces:", e);
            callback([]);
          }
        } else {
          console.error("Loi tai provinces, status:", xhr.status);
          callback([]);
        }
      }
    };
    xhr.send();
  }

  // ─────────────────────────────────────────
  // ADDRESS API - LOAD WARDS BY PROVINCE ID + NAME
  // Format: {id}.{Name}.json  e.g. 12370.HaNoi.json
  // ─────────────────────────────────────────
  // Bo diacritics (dau) tieng Viet = tach thanh base char + combining mark, roi bo combining mark
  // VD: "à" (U+00E0) = "a" (U+0061) + combining grave (U+0300)  →  strip U+0300 → "a"
  function stripDiacritics(text) {
    // NFD: decomposed form (base char + combining diacritical mark)
    return text.normalize("NFD").replace(/[\u0300-\u036F]/g, "");
  }

  function slugifyVietnamese(text) {
    // GitHub file: {id}.{Name}.json  vd: 12397.HoChiMinh.json
    // Bo "Thanh pho" / "Tinh", tach theo khoang trang,
    // moi tu: bo dau → viet HOA dau → noi
    var cleaned = text
      .replace(/^Thành phố\s*/i, "")
      .replace(/^Tỉnh\s*/i, "")
      .replace(/Thành phố\s*/gi, "")
      .replace(/Tỉnh\s*/gi, "")
      .trim();

    // Replace cac ky tu dac biet khong bi NFD decompose
    // Ă→A, Đ→D, Ô→O, Ư→U, ơ→o, ư→u (chi chu cai dau moi thay doi)
    var replacements = {
      "\u0102": "A", "\u0103": "a", // Ă ă
      "\u0110": "D", "\u0111": "d", // Đ đ  <-- quan trong! NFD khong decompose
      "\u01A0": "O", "\u01A1": "o", // Ô (ngoai BMP nhung can du khi)
      "\u01AF": "U", "\u01B0": "u", // Ư (ngoai BMP)
      "\u00D4": "O", "\u00F4": "o", // Ô ô (trong BMP, NFD decompose duoc nhung thu tu)
      "\u00C2": "A", "\u00E2": "a", // Â â
      "\u00D0": "D", "\u00F0": "d", // Đ (Latin-1 Supplement)
      "\u1EA0": "A", "\u1EA1": "a", // Vietnamese A with hook (below)
      "\u1EB0": "A", "\u1EB1": "a",
      "\u1EB4": "A", "\u1EB5": "a",
      "\u1EB6": "A", "\u1EB7": "a",
      "\u1EB2": "A", "\u1EB3": "a",
      "\u1EB8": "E", "\u1EB9": "e",
      "\u1EBB": "E", "\u1EBC": "E", "\u1EBD": "e",
      "\u1EC0": "E", "\u1EC1": "e",
      "\u1EC2": "E", "\u1EC3": "e",
      "\u1EC4": "E", "\u1EC5": "e",
      "\u1EC6": "E", "\u1EC7": "e",
      "\u1EC8": "I", "\u1EC9": "i",
      "\u1ECA": "I", "\u1ECB": "i",
      "\u1ECC": "O", "\u1ECD": "o",
      "\u1ECE": "O", "\u1ECF": "o",
      "\u1ED0": "O", "\u1ED1": "o",
      "\u1ED2": "O", "\u1ED3": "o",
      "\u1ED4": "O", "\u1ED5": "o",
      "\u1ED6": "O", "\u1ED7": "o",
      "\u1ED8": "O", "\u1ED9": "o",
      "\u1EDA": "O", "\u1EDB": "o",
      "\u1EDC": "O", "\u1EDD": "o",
      "\u1EDE": "O", "\u1EDF": "o",
      "\u1EE0": "O", "\u1EE1": "o",
      "\u1EE2": "O", "\u1EE3": "o",
      "\u1EE4": "U", "\u1EE5": "u",
      "\u1EE6": "U", "\u1EE7": "u",
      "\u1EE8": "U", "\u1EE9": "u",
      "\u1EEA": "U", "\u1EEB": "u",
      "\u1EEC": "U", "\u1EED": "u",
      "\u1EEE": "U", "\u1EEF": "u",
      "\u1EF0": "U", "\u1EF1": "u",
      "\u1EF2": "Y", "\u1EF3": "y",
      "\u1EF4": "Y", "\u1EF5": "y",
      "\u1EF6": "Y", "\u1EF7": "y",
      "\u1EF8": "Y", "\u1EF9": "y"
    };

    var parts = cleaned.split(/\s+/);
    var result = "";
    var i, part, plain, j, ch;
    for (i = 0; i < parts.length; i++) {
      if (parts[i].length > 0) {
        // Step 1: NFD decompose + strip combining marks
        plain = parts[i].normalize("NFD").replace(/[\u0300-\u036F]/g, "");
        // Step 2: Apply manual replacements cho nhung ky tu NFD khong decompose
        // Step 2: Manual replacements (Đ→D, etc. — NFD khong decompose cac nay)
        plain = plain.split("").map(function (c) { return replacements[c] || c; }).join("");
        result += plain.charAt(0).toUpperCase() + plain.slice(1).toLowerCase();
      }
    }
    return result;
  }

  function loadWards(provinceId, provinceName, callback) {
    var slug = slugifyVietnamese(provinceName);
    var url = ADDRESS_API.wardBase + provinceId + "." + slug + ".json";
    console.log("[Ward API] Fetching: " + url);

    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          try {
            var data = JSON.parse(xhr.responseText);
            var wards = data.filter(function (w) { return w.id !== -1; });
            console.log("[Ward API] OK: " + wards.length + " wards for " + slug);
            callback(wards);
          } catch (e) {
            console.error("[Ward API] Loi parse wards:", e);
            callback([]);
          }
        } else {
          console.error("[Ward API] Loi tai wards, status:", xhr.status, "url:", url);
          callback([]);
        }
      }
    };
    xhr.onerror = function () {
      console.error("[Ward API] Network error for url:", url);
      callback([]);
    };
    xhr.send();
  }

  // ─────────────────────────────────────────
  // LOCATION DROPDOWNS (Province → Ward, 2025 model)
  // ─────────────────────────────────────────
  function initLocationDropdowns() {
    var provinceSelect = document.getElementById("provinceSelect");
    var districtSelect = document.getElementById("districtSelect");
    var wardSelect = document.getElementById("wardSelect");
    if (!provinceSelect) return;

    loadProvinces(function (provinces) {
      provinceSelect.innerHTML = '<option value="">-- Chon Tinh/Thanh pho --</option>';
      provinces.forEach(function (p) {
        var opt = document.createElement("option");
        opt.value = p.id + "|" + p.name;
        opt.textContent = p.name;
        provinceSelect.appendChild(opt);
      });
    });

    provinceSelect.addEventListener("change", function (e) {
      wardSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
      wardSelect.disabled = true;

      if (!e.target.value) {
        districtSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
        districtSelect.disabled = true;
        return;
      }

      var parts = e.target.value.split("|");
      var provinceId = parts[0];
      var provinceName = parts[1] || "";
      wardSelect.disabled = true;
      wardSelect.innerHTML = '<option value="">Dang tai...</option>';

      loadWards(provinceId, provinceName, function (wards) {
        wardSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
        if (wards.length === 0) {
          wardSelect.innerHTML = '<option value="">Khong co du lieu (mo DevTools xem console)</option>';
          console.warn("[Ward API] 0 wards for provinceId=" + provinceId + " name=" + provinceName);
        } else {
          wards.forEach(function (w) {
            var opt = document.createElement("option");
            opt.value = w.name;
            opt.textContent = w.name;
            wardSelect.appendChild(opt);
          });
          wardSelect.disabled = false;
        }
        districtSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
        districtSelect.disabled = false;
      });
    });

    provinceSelect.addEventListener("input", function () {
      if (!provinceSelect.value) {
        districtSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
        districtSelect.disabled = true;
        wardSelect.innerHTML = '<option value="">-- Chon Phuong/Xa --</option>';
        wardSelect.disabled = true;
      }
    });
  }

  // ─────────────────────────────────────────
  // QTY BUTTONS - Decrease / Increase
  // ─────────────────────────────────────────
  window.onDecrease = function (btn, itemId) {
    var box = btn.closest(".gf-qty-box");
    var input = box.querySelector(".gf-qty-input");
    var currentQty = parseInt(input.value, 10);

    if (currentQty <= 1) {
      if (confirm("Ban co chan chan muon xoa game nay khoi gio hang?")) {
        removeCartItem(itemId); // splice array + re-render + recalculate
      }
    }
    // Khong cho giam them neu da = 1
  };

  window.onIncrease = function (btn) {
    // Khong cho tang so luong
  };

  // ─────────────────────────────────────────
  // REMOVE CART ITEM (AJAX + localStorage sync)
  // ─────────────────────────────────────────
  window.removeCartItem = function (itemId) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", window.GAMEFORGE_CONTEXT_PATH + "/api/cart/remove?itemId=" + itemId, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 && xhr.status === 200) {
        var text = xhr.responseText || "";
        var isOk = text.indexOf("OK=") === 0;

        if (isOk) {
          // Parse COUNT from response: "OK=message&COUNT=3"
          var parts = text.split("&");
          var newCount = 0;
          for (var i = 0; i < parts.length; i++) {
            if (parts[i].indexOf("COUNT=") === 0) {
              newCount = parseInt(parts[i].split("=")[1], 10) || 0;
            }
          }

          // Sync localStorage cart key
          var localCart = JSON.parse(localStorage.getItem("gameforge_cart_games_bootstrap_jsp") || "[]");
          var gameId = String(itemId);
          var idx = localCart.indexOf(gameId);
          if (idx > -1) localCart.splice(idx, 1);
          localStorage.setItem("gameforge_cart_games_bootstrap_jsp", JSON.stringify(localCart));

          // Update header badge
          var badge = document.getElementById("cartCount");
          if (badge) badge.textContent = newCount;

          // Remove item from local array
          var items = window.cartItemsData || [];
          for (var j = 0; j < items.length; j++) {
            if (String(items[j].id) === String(itemId)) {
              items.splice(j, 1);
              break;
            }
          }

          renderCartItems();
          recalculateCartTotals();
        } else {
          var msg = text.replace("ERROR=", "").replace(/\+/g, " ");
          alert("Khong the xoa san pham. Loi: " + decodeURIComponent(msg));
        }
      }
    };
    xhr.send();
  };

  // ─────────────────────────────────────────
  // FORM VALIDATION
  // ─────────────────────────────────────────
  function initFormValidation() {
    var form = document.getElementById("checkoutForm");
    if (!form) return;

    // ---- Real-time: Phone - chi so ----
    var phoneInput = form.querySelector('[name="phone"]');
    if (phoneInput) {
      phoneInput.addEventListener("input", function () {
        this.value = this.value.replace(/\D/g, "").slice(0, 11);
      });
    }

    // ---- Real-time: Card Number - dinh dang 4 so 1 khoang ----
    var cardNumberInput = form.querySelector('[name="cardNumber"]');
    if (cardNumberInput) {
      cardNumberInput.addEventListener("input", function () {
        var digits = this.value.replace(/\D/g, "").slice(0, 16);
        var formatted = digits.replace(/(.{4})/g, "$1 ").trim();
        this.value = formatted;
      });
      cardNumberInput.addEventListener("keypress", function (e) {
        if (!/[0-9]/.test(String.fromCharCode(e.which))) e.preventDefault();
      });
    }

    // ---- Real-time: Card Expiry MM/YY ----
    var cardExpiryInput = form.querySelector('[name="cardExpiry"]');
    if (cardExpiryInput) {
      cardExpiryInput.addEventListener("input", function () {
        var digits = this.value.replace(/\D/g, "").slice(0, 4);
        if (digits.length >= 2) {
          digits = digits.slice(0, 2) + "/" + digits.slice(2);
        }
        this.value = digits;
      });
      cardExpiryInput.addEventListener("keypress", function (e) {
        if (!/[0-9]/.test(String.fromCharCode(e.which))) e.preventDefault();
      });
    }

    // ---- Real-time: CVV - chi so ----
    var cardCvvInput = form.querySelector('[name="cardCvv"]');
    if (cardCvvInput) {
      cardCvvInput.addEventListener("input", function () {
        this.value = this.value.replace(/\D/g, "").slice(0, 4);
      });
      cardCvvInput.addEventListener("keypress", function (e) {
        if (!/[0-9]/.test(String.fromCharCode(e.which))) e.preventDefault();
      });
    }

    // ---- Submit Validation ----
    form.addEventListener("submit", function (e) {
      var phone = form.querySelector('[name="phone"]');
      if (phone && phone.value) {
        var phoneVal = phone.value.trim();
        if (!/^0\d{9,10}$/.test(phoneVal)) {
          e.preventDefault();
          alert("So dien thoai khong hop le!\nVui long nhap 10-11 chu so, bat dau bang so 0.\nVi du: 0912345678");
          phone.focus();
          return;
        }
      }

      var fullName = form.querySelector('[name="fullName"]');
      if (fullName && fullName.value.trim().length < 2) {
        e.preventDefault();
        alert("Vui long nhap ho va ten day du.");
        fullName.focus();
        return;
      }

      var address = form.querySelector('[name="address"]');
      if (address && address.value.trim().length < 5) {
        e.preventDefault();
        alert("Vui long nhap dia chi cu the (so nha, ten duong).");
        address.focus();
        return;
      }

      if (selectedPaymentMethod === "WALLET") {
        var walletSelect = form.querySelector('[name="walletProvider"]');
        if (!walletSelect || !walletSelect.value) {
          e.preventDefault();
          alert("Vui long chon loai vi dien tu.");
          walletSelect.focus();
          return;
        }
      }

      if (selectedPaymentMethod === "CARD") {
        var cardNumber = form.querySelector('[name="cardNumber"]');
        var cardExpiry = form.querySelector('[name="cardExpiry"]');
        var cardCvv = form.querySelector('[name="cardCvv"]');

        // Card number: 16 chu so (sau khi bo khoang trang)
        if (!cardNumber || !cardNumber.value) {
          e.preventDefault();
          alert("Vui long nhap so the Visa.");
          cardNumber.focus();
          return;
        }
        var rawCard = cardNumber.value.replace(/\s/g, "");
        if (!/^\d{16}$/.test(rawCard)) {
          e.preventDefault();
          alert("So the Visa phai la 16 chu so.\nVi du: 4111 1111 1111 1111");
          cardNumber.focus();
          return;
        }

        // Expiry: MM/YY
        if (!cardExpiry || !cardExpiry.value) {
          e.preventDefault();
          alert("Vui long nhap ngay het han (MM/YY).");
          cardExpiry.focus();
          return;
        }
        if (!/^\d{2}\/\d{2}$/.test(cardExpiry.value)) {
          e.preventDefault();
          alert("Ngay het han phai dung dinh dang MM/YY.\nVi du: 12/28");
          cardExpiry.focus();
          return;
        }
        var expiryParts = cardExpiry.value.split("/");
        var expMonth = parseInt(expiryParts[0], 10);
        var expYear = parseInt("20" + expiryParts[1], 10);
        var now = new Date();
        if (expMonth < 1 || expMonth > 12) {
          e.preventDefault();
          alert("Thang het han khong hop le (01-12).");
          cardExpiry.focus();
          return;
        }
        if (expYear < now.getFullYear() || (expYear === now.getFullYear() && expMonth < now.getMonth() + 1)) {
          e.preventDefault();
          alert("The da het han. Vui long nhap the moi.");
          cardExpiry.focus();
          return;
        }

        // CVV: 3-4 chu so
        if (!cardCvv || !cardCvv.value) {
          e.preventDefault();
          alert("Vui long nhap ma CVV (3-4 chu so o mat sau the).");
          cardCvv.focus();
          return;
        }
        if (!/^\d{3,4}$/.test(cardCvv.value)) {
          e.preventDefault();
          alert("Ma CVV phai la 3-4 chu so.\nVi du: 123");
          cardCvv.focus();
          return;
        }
      }

      var province = form.querySelector('[name="province"]');
      if (province && !province.value) {
        e.preventDefault();
        alert("Vui long chon Tinh/Thanh pho.");
        province.focus();
        return;
      }

      var ward = form.querySelector('[name="ward"]');
      if (ward && !ward.value) {
        e.preventDefault();
        alert("Vui long chon Phuong/Xa.");
        ward.focus();
        return;
      }
    });
  }

  // ─────────────────────────────────────────
  // QR CHECKOUT FLOW
  // ─────────────────────────────────────────
  function getCsrfParams() {
    var token = window.GAMEFORGE_CSRF_TOKEN;
    var header = window.GAMEFORGE_CSRF_HEADER || "_csrf";
    if (!token) return "";
    return encodeURIComponent(header) + "=" + encodeURIComponent(token);
  }

  function getCurrentTotal() {
    var items = window.cartItemsData || [];
    var subtotal = 0;
    var discount = 0;
    items.forEach(function (item) {
      var original = parseFloat(item.originalPrice) || 0;
      var sale = parseFloat(item.price) || 0;
      subtotal += original;
      discount += (original - sale);
    });
    return subtotal - discount;
  }

  function formatVND(val) {
    return new Intl.NumberFormat("vi-VN").format(val) + " VND";
  }

  window.handleCheckoutPay = function () {
    var form = document.getElementById("checkoutForm");
    if (!form) return;

    // Validate shipping info
    var phone = form.querySelector('[name="phone"]');
    if (phone && phone.value) {
      var phoneVal = phone.value.trim();
      if (!/^0\d{9,10}$/.test(phoneVal)) {
        alert("Số điện thoại không hợp lệ!\nVui lòng nhập 10-11 chữ số, bắt đầu bằng số 0.\nVí dụ: 0912345678");
        phone.focus();
        return;
      }
    }

    var fullName = form.querySelector('[name="fullName"]');
    if (fullName && fullName.value.trim().length < 2) {
      alert("Vui lòng nhập họ và tên đầy đủ.");
      fullName.focus();
      return;
    }

    var address = form.querySelector('[name="address"]');
    if (address && address.value.trim().length < 5) {
      alert("Vui lòng nhập địa chỉ cụ thể (số nhà, tên đường).");
      address.focus();
      return;
    }

    var province = form.querySelector('[name="province"]');
    if (province && !province.value) {
      alert("Vui lòng chọn Tỉnh/Thành phố.");
      province.focus();
      return;
    }

    var ward = form.querySelector('[name="ward"]');
    if (ward && !ward.value) {
      alert("Vui lòng chọn Phường/Xã.");
      ward.focus();
      return;
    }

    // WALLET: kiểm tra ví trước khi hiện QR
    if (selectedPaymentMethod === "WALLET") {
      var walletSelect = form.querySelector('[name="walletProvider"]');
      if (!walletSelect || !walletSelect.value) {
        alert("Vui lòng chọn loại ví điện tử.");
        walletSelect.focus();
        return;
      }
      // Chỉ kiểm tra số dư khi chọn ví GameForge
      if (walletSelect.value === "GAMEFORGE") {
        var total = getCurrentTotal();
        var balance = parseFloat(window.GAMEFORGE_WALLET_BALANCE) || 0;
        if (balance < total) {
          alert("Số dư ví GameForge không đủ!\nSố dư hiện tại: " + formatVND(balance) + "\nCần thanh toán: " + formatVND(total) + "\nVui lòng nạp thêm tiền hoặc chọn phương thức khác.");
          return;
        }
        // Ví GameForge đủ tiền -> thanh toán luôn không qua QR
        var csrfParams = getCsrfParams();
        var fd = new FormData(form);
        pendingCheckoutData = {
          csrfParams: csrfParams,
          params: fd,
          total: total
        };
        var timestamp = Date.now();
        var userId = window.GAMEFORGE_CURRENT_USER_ID || "";
        var message = "GF_CHECKOUT_U" + userId + "_T" + timestamp;
        var qrMsgEl = document.getElementById("checkoutQrMessage");
        if (qrMsgEl) qrMsgEl.innerText = message;
        processDirectCheckout();
        return;
      }
    }

    // CARD: thanh toán trực tiếp không qua QR
    if (selectedPaymentMethod === "CARD") {
      var cardNumber = form.querySelector('[name="cardNumber"]');
      var cardExpiry = form.querySelector('[name="cardExpiry"]');
      var cardCvv = form.querySelector('[name="cardCvv"]');

      if (!cardNumber || !cardNumber.value) {
        alert("Vui lòng nhập số thẻ Visa.");
        cardNumber && cardNumber.focus();
        return;
      }
      var rawCard = cardNumber.value.replace(/\s/g, "");
      if (!/^\d{16}$/.test(rawCard)) {
        alert("Số thẻ Visa phải là 16 chữ số.\nVí dụ: 4111 1111 1111 1111");
        cardNumber.focus();
        return;
      }
      if (!cardExpiry || !cardExpiry.value) {
        alert("Vui lòng nhập ngày hết hạn (MM/YY).");
        cardExpiry && cardExpiry.focus();
        return;
      }
      if (!/^\d{2}\/\d{2}$/.test(cardExpiry.value)) {
        alert("Ngày hết hạn phải đúng định dạng MM/YY.\nVí dụ: 12/28");
        cardExpiry.focus();
        return;
      }
      var expiryParts = cardExpiry.value.split("/");
      var expMonth = parseInt(expiryParts[0], 10);
      var expYear = parseInt("20" + expiryParts[1], 10);
      var now = new Date();
      if (expMonth < 1 || expMonth > 12) {
        alert("Tháng hết hạn không hợp lệ (01-12).");
        cardExpiry.focus();
        return;
      }
      if (expYear < now.getFullYear() || (expYear === now.getFullYear() && expMonth < now.getMonth() + 1)) {
        alert("Thẻ đã hết hạn. Vui lòng nhập thẻ mới.");
        cardExpiry.focus();
        return;
      }
      if (!cardCvv || !cardCvv.value) {
        alert("Vui lòng nhập mã CVV (3-4 chữ số ở mặt sau thẻ).");
        cardCvv && cardCvv.focus();
        return;
      }
      if (!/^\d{3,4}$/.test(cardCvv.value)) {
        alert("Mã CVV phải là 3-4 chữ số.\nVí dụ: 123");
        cardCvv.focus();
        return;
      }

      // Visa: gọi API trực tiếp (không qua QR)
      var csrfParams = getCsrfParams();
      var fd = new FormData(form);
      pendingCheckoutData = {
        csrfParams: csrfParams,
        params: fd,
        total: getCurrentTotal()
      };
      // Generate checkout message for success display
      var cardTimestamp = Date.now();
      var cardUserId = window.GAMEFORGE_CURRENT_USER_ID || '';
      var cardMessage = 'GF_CHECKOUT_U' + cardUserId + '_T' + cardTimestamp;
      var qrMsgEl = document.getElementById('checkoutQrMessage');
      if (qrMsgEl) qrMsgEl.innerText = cardMessage;
      processDirectCheckout();
      return;
    }

    // Build form data for QR modal
    var csrfParams = getCsrfParams();
    var fd = new FormData(form);
    pendingCheckoutData = {
      csrfParams: csrfParams,
      params: fd,
      total: getCurrentTotal()
    };

    triggerCheckoutQrModal();
  };

  function triggerCheckoutQrModal() {
    var modal = document.getElementById("checkoutQrModal");
    if (!modal) return;

    var total = pendingCheckoutData.total;
    var method = selectedPaymentMethod;
    var methodLabel = method === "WALLET" ? "Ví điện tử" : "Chuyển khoản";

    document.getElementById("checkoutQrSubtitle").innerText =
      "Quét mã QR bằng ứng dụng " + methodLabel + " để thanh toán:";
    document.getElementById("checkoutQrAmountDisplay").innerText =
      "Số tiền cần thanh toán: " + formatVND(total);
    document.getElementById("checkoutQrAmountDetail").innerText = formatVND(total);

    var timestamp = Date.now();
    var userId = window.GAMEFORGE_CURRENT_USER_ID || "";
    var message = "GF_CHECKOUT_U" + userId + "_T" + timestamp;
    document.getElementById("checkoutQrMessage").innerText = message;

    // Build QR data: MBBank format
    var qrData = "MBBANK|1902848123984|" + total + "|" + message;
    var qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + encodeURIComponent(qrData);
    document.getElementById("checkoutQrImage").src = qrUrl;

    // 5-minute countdown
    var secondsLeft = 300;
    var timerEl = document.getElementById("checkoutQrTimer");
    if (checkoutQrTimerInterval) clearInterval(checkoutQrTimerInterval);
    checkoutQrTimerInterval = setInterval(function () {
      secondsLeft--;
      var mins = Math.floor(secondsLeft / 60).toString().padStart(2, "0");
      var secs = (secondsLeft % 60).toString().padStart(2, "0");
      timerEl.innerText = "Đang chờ thanh toán... (" + mins + ":" + secs + ")";
      if (secondsLeft <= 0) {
        clearInterval(checkoutQrTimerInterval);
        timerEl.innerText = "Mã QR đã hết hạn! Vui lòng tạo lại giao dịch.";
        document.getElementById("checkoutQrConfirmBtn").disabled = true;
      }
    }, 1000);

    document.getElementById("checkoutQrConfirmBtn").disabled = false;
    if (window.lucide) lucide.createIcons();

    var bsModal = new bootstrap.Modal(modal);
    bsModal.show();
  }

  window.cancelCheckoutQr = function () {
    if (checkoutQrTimerInterval) {
      clearInterval(checkoutQrTimerInterval);
      checkoutQrTimerInterval = null;
    }
    pendingCheckoutData = null;
  };

  // Dùng chung cho Visa (direct) và QR confirm
  function doCheckoutApiCall(btn, btnOriginalHtml) {
    var csrfParams = pendingCheckoutData.csrfParams;
    var params = pendingCheckoutData.params;
    var bodyParts = [];
    if (csrfParams) bodyParts.push(csrfParams);
    params.forEach(function (val, key) {
      bodyParts.push(encodeURIComponent(key) + "=" + encodeURIComponent(val));
    });
    var body = bodyParts.join("&");

    var csrfToken = window.GAMEFORGE_CSRF_TOKEN;
    var csrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";
    var headers = { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" };
    if (csrfToken) headers[csrfHeader] = csrfToken;

    btn.disabled = true;
    fetch(window.GAMEFORGE_CONTEXT_PATH + "/api/checkout/process", {
      method: "POST",
      headers: headers,
      body: body
    })
      .then(function (res) {
        if (!res.ok) {
          return res.text().then(function(text) {
            try { return JSON.parse(text); }
            catch (e) { return { success: false, message: "Lỗi " + res.status + ": " + (text || "Không có phản hồi từ máy chủ") }; }
          });
        }
        return res.json();
      })
      .then(function (data) {
        if (data.success) {
          if (window.confetti) {
            window.confetti({ particleCount: 150, spread: 80, origin: { y: 0.6 } });
          }
          if (checkoutQrTimerInterval) {
            clearInterval(checkoutQrTimerInterval);
            checkoutQrTimerInterval = null;
          }
          pendingCheckoutData = null;
          
          // Clear cart local storage and reset header cart badge
          try {
            localStorage.removeItem('gameforge_cart_games_bootstrap_jsp');
          } catch (e) {
            console.error("Error clearing cart localStorage:", e);
          }
          var headerCartCount = document.getElementById('cartCount');
          if (headerCartCount) {
            headerCartCount.textContent = '0';
          }
          
          // Hiển thị success overlay trong modal thay vì alert
          var totalAmount = formatVND(getCurrentTotal());
          var overlay = document.getElementById('checkoutSuccessOverlay');
          if (overlay) {
            // Nếu modal chưa mở (CARD direct), mở modal trước
            var modalEl = document.getElementById('checkoutQrModal');
            var existingModal = bootstrap.Modal.getInstance(modalEl);
            if (!existingModal) {
              existingModal = new bootstrap.Modal(modalEl);
              existingModal.show();
            }
            
            // Điền thông tin thành công
            var successAmountEl = document.getElementById('successAmount');
            if (successAmountEl) successAmountEl.textContent = totalAmount;
            var successAmountDetail = document.getElementById('successAmountDetail');
            if (successAmountDetail) successAmountDetail.textContent = totalAmount;
            var successMsg = document.getElementById('successMessage');
            var qrMsg = document.getElementById('checkoutQrMessage');
            if (successMsg) successMsg.textContent = qrMsg ? qrMsg.textContent : 'GF_CHECKOUT';
            var successTxn = document.getElementById('successTxnId');
            if (successTxn) successTxn.textContent = 'TXN' + new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14);
            var successTime = document.getElementById('successTimestamp');
            if (successTime) {
              var now = new Date();
              successTime.textContent = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN');
            }
            
            overlay.classList.remove('d-none');
            if (window.lucide) lucide.createIcons();
          } else {
            alert("Thanh toán thành công! Cảm ơn bạn đã mua sắm tại GameForge.");
            setTimeout(function () {
              window.location.href = window.GAMEFORGE_CONTEXT_PATH + "/library";
            }, 1800);
          }
        } else {
          alert("Thanh toán thất bại: " + (data.message || "Vui lòng thử lại."));
          btn.innerHTML = btnOriginalHtml;
          btn.disabled = false;
          if (window.lucide) lucide.createIcons();
        }
      })
      .catch(function (err) {
        console.error("Checkout error:", err);
        alert("Lỗi máy chủ khi hoàn thành thanh toán. Vui lòng thử lại.");
        btn.innerHTML = btnOriginalHtml;
        btn.disabled = false;
        if (window.lucide) lucide.createIcons();
      });
  }

  // Visa: xử lý trực tiếp không qua QR
  window.processDirectCheckout = function () {
    if (!pendingCheckoutData) return;
    var form = document.getElementById("checkoutForm");
    var btn = form ? form.querySelector(".gf-pay-btn") : null;
    var originalHtml = btn ? btn.innerHTML : "";
    if (btn) {
      btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Đang xử lý...';
      btn.disabled = true;
    }
    doCheckoutApiCall(btn || { innerHTML: "", disabled: false }, originalHtml);
  };

  // QR confirm: cho WALLET và BANK
  window.confirmCheckoutQr = function () {
    if (!pendingCheckoutData) return;
    var confirmBtn = document.getElementById("checkoutQrConfirmBtn");
    var originalHtml = confirmBtn.innerHTML;
    confirmBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Đang xử lý...';
    doCheckoutApiCall(confirmBtn, originalHtml);
  };

  // ─────────────────────────────────────────
  // CLOSE SUCCESS OVERLAY & REDIRECT
  // ─────────────────────────────────────────
  window.closeSuccessAndRedirect = function() {
    var modalEl = document.getElementById('checkoutQrModal');
    if (modalEl) {
      var modalInstance = bootstrap.Modal.getInstance(modalEl);
      if (modalInstance) modalInstance.hide();
    }
    window.location.href = window.GAMEFORGE_CONTEXT_PATH + '/library';
  };

})();
