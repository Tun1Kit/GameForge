document.addEventListener("DOMContentLoaded", function() {
  if (window.lucide) {
    window.lucide.createIcons();
  }

  // Dữ liệu ban đầu
  let currentBalance = window.GAMEFORGE_WALLET_BALANCE || 0;
  let activeAmount = 100000;
  let activeReceived = 100000;
  let activeMethod = "MOMO";
  let activeMethodLabel = "MoMo";
  const contextPath = window.GAMEFORGE_CONTEXT_PATH || '';

  // ==========================================
  // 1. CLICK CHỌN GÓI TIỀN NẠP (PRESET)
  // ==========================================
  const amountCards = document.querySelectorAll(".amount-card");
  const customAmountBtn = document.getElementById("customAmountBtn");
  const customAmountInputContainer = document.getElementById("customAmountInputContainer");
  const customAmountInput = document.getElementById("customAmountInput");

  amountCards.forEach(card => {
    card.addEventListener("click", function() {
      if (this === customAmountBtn) return; // xử lý riêng cho gói tùy chọn
      
      amountCards.forEach(c => c.classList.remove("active"));
      customAmountBtn.classList.remove("active");
      customAmountInputContainer.classList.add("d-none");
      
      this.classList.add("active");
      
      activeAmount = parseInt(this.getAttribute("data-amount"));
      activeReceived = parseInt(this.getAttribute("data-received"));
      updateSidebarDisplay();
    });
  });

  // Mở ô nhập số tiền tùy chọn
  if (customAmountBtn) {
    customAmountBtn.addEventListener("click", function() {
      amountCards.forEach(c => c.classList.remove("active"));
      this.classList.add("active");
      customAmountInputContainer.classList.remove("d-none");
      customAmountInput.focus();
    });
  }

  window.applyCustomAmount = function() {
    const val = parseInt(customAmountInput.value);
    if (isNaN(val) || val <= 0) {
      alert("Vui lòng nhập số tiền nạp hợp lệ.");
      return;
    }
    
    activeAmount = val;
    // Đối với tiền tự nhập, khuyến mãi như sau:
    // 500k -> 530k, 1M -> 1.08M, 2M -> 2.22M, các mức khác nhận đúng số tiền nạp
    let bonus = 0;
    if (val === 500000) bonus = 30000;
    else if (val === 1000000) bonus = 80000;
    else if (val === 2000000) bonus = 220000;
    
    activeReceived = val + bonus;
    updateSidebarDisplay();
    alert(`Đã áp dụng số tiền nạp tùy chọn: ${formatVND(val)}`);
  };

  // ==========================================
  // 2. CLICK CHỌN PHƯƠNG THỨC THANH TOÁN
  // ==========================================
  const paymentCards = document.querySelectorAll(".payment-card");
  paymentCards.forEach(card => {
    card.addEventListener("click", function() {
      paymentCards.forEach(c => c.classList.remove("active"));
      this.classList.add("active");
      
      activeMethod = this.getAttribute("data-method");
      activeMethodLabel = this.getAttribute("data-label");
    });
  });

  // Cập nhật hiển thị số liệu bên Sidebar
  function updateSidebarDisplay() {
    const bonus = activeReceived - activeAmount;
    const previewRechargeAmount = document.getElementById("previewRechargeAmount");
    const previewBonusAmount = document.getElementById("previewBonusAmount");
    const previewTotalReceived = document.getElementById("previewTotalReceived");
    
    if (previewRechargeAmount) previewRechargeAmount.innerText = formatVND(activeAmount);
    if (previewBonusAmount) previewBonusAmount.innerText = formatVND(bonus);
    if (previewTotalReceived) previewTotalReceived.innerText = formatVND(activeReceived);
  }

  function formatVND(val) {
    return new Intl.NumberFormat('vi-VN').format(val) + "đ";
  }

  // ==========================================
  // 3. KÍCH HOẠT HIỂN THỊ MODAL MÃ QR THANH TOÁN
  // ==========================================
  let timerInterval = null;
  window.triggerRechargeModal = function() {
    // 1. Tạo QR động: Sử dụng API sinh mã QR Server
    const userId = window.GAMEFORGE_USER_ID || '';
    const timestamp = Date.now();
    const message = `GF_RECHARGE_U${userId}_T${timestamp}`;
    
    // Tạo URL QR động
    const qrData = `MBBANK|1902848123984|${activeAmount}|${message}`;
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(qrData)}`;
    
    document.getElementById("simulatedQrImage").src = qrUrl;
    document.getElementById("qrDetailAmount").innerText = formatVND(activeAmount);
    document.getElementById("qrDetailMessage").innerText = message;
    
    // 2. Thiết lập bộ đếm giờ giả lập 5 phút
    let secondsLeft = 300;
    const timerElement = document.getElementById("qrStatusTimer");
    timerElement.innerText = `Đang chờ chuyển khoản... (05:00)`;
    
    if (timerInterval) clearInterval(timerInterval);
    timerInterval = setInterval(() => {
      secondsLeft--;
      const mins = Math.floor(secondsLeft / 60).toString().padStart(2, '0');
      const secs = (secondsLeft % 60).toString().padStart(2, '0');
      timerElement.innerText = `Đang chờ chuyển khoản... (${mins}:${secs})`;
      
      if (secondsLeft <= 0) {
        clearInterval(timerInterval);
        timerElement.innerText = "Mã QR đã hết hạn! Vui lòng tạo lại giao dịch.";
        document.getElementById("confirmRechargeBtn").disabled = true;
      }
    }, 1000);
    
    document.getElementById("confirmRechargeBtn").disabled = false;
    
    // Mở modal
    const modal = new bootstrap.Modal(document.getElementById('qrSimulationModal'));
    modal.show();
  };

  // ==========================================
  // 4. AJAX XÁC NHẬN HOÀN TẤT NẠP TIỀN & CHẠY SỐ TĂNG DẦN
  // ==========================================
  window.confirmSimulatedRecharge = function() {
    const confirmBtn = document.getElementById("confirmRechargeBtn");
    confirmBtn.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Đang xử lý trên máy chủ...`;
    confirmBtn.disabled = true;
    
    const formData = new FormData();
    formData.append("amount", activeAmount);
    formData.append("method", activeMethod);
    
    fetch(contextPath + "/api/recharge/process", {
      method: "POST",
      headers: (function() {
        var h = { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" };
        var token = window.GAMEFORGE_CSRF_TOKEN;
        var header = window.GAMEFORGE_CSRF_HEADER || "_csrf";
        if (token) h[header] = token;
        return h;
      })(),
      body: "amount=" + encodeURIComponent(activeAmount) + "&method=" + encodeURIComponent(activeMethod)
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        // Giao dịch thành công! Tắt đếm giờ
        clearInterval(timerInterval);
        
        // Bắn pháo hoa thành công (canvas-confetti)
        if (window.confetti) {
          window.confetti({
            particleCount: 150,
            spread: 80,
            origin: { y: 0.6 }
          });
        }
        
        // Hiệu ứng tăng số ví chạy dần động (Counter Animation) cực chất
        const oldBalance = currentBalance;
        const targetBalance = data.newBalance;
        currentBalance = targetBalance; // Cập nhật lại
        
        let currentRunning = oldBalance;
        const step = Math.ceil((targetBalance - oldBalance) / 25);
        
        const counterInterval = setInterval(() => {
          currentRunning += step;
          if (currentRunning >= targetBalance) {
            currentRunning = targetBalance;
            clearInterval(counterInterval);
          }
          
          // Cập nhật lên UI cả Header và bảng bên phải
          const formatted = new Intl.NumberFormat('vi-VN').format(currentRunning) + "đ";
           const previewCurrentBalance = document.getElementById("previewCurrentBalance");
           if (previewCurrentBalance) {
             previewCurrentBalance.innerText = formatted;
           }
          const headerWalletBalance = document.getElementById("headerWalletBalance");
          if (headerWalletBalance) {
            headerWalletBalance.innerText = formatted;
          }
          const headerWalletBalanceText = document.getElementById("headerWalletBalanceText");
          if (headerWalletBalanceText) {
            headerWalletBalanceText.innerText = formatted;
          }
          const libraryWalletBalanceText = document.getElementById("libraryWalletBalanceText");
          if (libraryWalletBalanceText) {
            libraryWalletBalanceText.innerText = formatted;
          }
        }, 40);
        
        // Hiển thị success overlay đè lên QR modal
        const overlay = document.getElementById('rechargeSuccessOverlay');
        const qrContainer = document.getElementById('qrContainer');
        if (qrContainer) qrContainer.classList.add('d-none');
        
        if (overlay) {
          const totalReceivedFormatted = formatVND(data.totalReceived);
          const amountFormatted = formatVND(activeAmount);
          
          const el1 = document.getElementById('rechargeSuccessAmount');
          if (el1) el1.textContent = totalReceivedFormatted;
          const el2 = document.getElementById('rechargeSuccessAmountDetail');
          if (el2) el2.textContent = amountFormatted;
          const el3 = document.getElementById('rechargeSuccessMessage');
          const qrMsg = document.getElementById('qrDetailMessage');
          if (el3) el3.textContent = qrMsg ? qrMsg.textContent : '';
          const el4 = document.getElementById('rechargeSuccessTxnId');
          if (el4) el4.textContent = 'TXN' + new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14);
          const el5 = document.getElementById('rechargeSuccessTimestamp');
          if (el5) {
            const now = new Date();
            el5.textContent = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN');
          }
          
          overlay.classList.remove('d-none');
          if (window.lucide) window.lucide.createIcons();
        } else {
          alert(`🎉 Nạp tiền thành công! Bạn nhận được ${formatVND(data.totalReceived)}`);
          setTimeout(() => {
            window.location.href = contextPath + "/library";
          }, 1600);
        }
        
      } else {
        alert("Nạp tiền thất bại: " + data.message);
        confirmBtn.innerHTML = `<i data-lucide="check-circle" width="18" height="18"></i> Tôi đã chuyển khoản thành công / Hoàn tất`;
        confirmBtn.disabled = false;
        if (window.lucide) window.lucide.createIcons();
      }
    })
    .catch(err => {
      console.error("Recharge transaction error:", err);
      alert("Lỗi máy chủ khi hoàn thành giao dịch ví.");
      confirmBtn.innerHTML = `<i data-lucide="check-circle" width="18" height="18"></i> Tôi đã chuyển khoản thành công / Hoàn tất`;
      confirmBtn.disabled = false;
      if (window.lucide) window.lucide.createIcons();
    });
  };

  // Đóng success overlay và chuyển trang
  window.closeRechargeSuccess = function() {
    const qrModalElement = document.getElementById('qrSimulationModal');
    if (qrModalElement) {
      const modalInstance = bootstrap.Modal.getInstance(qrModalElement);
      if (modalInstance) modalInstance.hide();
    }
    window.location.href = contextPath + "/recharge";
  };
});
