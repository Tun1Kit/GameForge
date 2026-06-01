/**
 * GameForge Admin — Shared JS (Neo-Brutalism)
 * Handles lock/unlock user, KYC approve/reject, Payout approve/reject
 */

(function () {
  'use strict';

  var ctx = window.GAMEFORGE_CONTEXT_PATH || '';
  var csrfToken = window.GAMEFORGE_CSRF_TOKEN || '';
  var csrfHeader = window.GAMEFORGE_CSRF_HEADER || '_csrf';

  // -------------------------------------------------------
  // Toast Notification
  // -------------------------------------------------------
  function showToast(message, type) {
    type = type || 'info';
    var container = document.querySelector('.gf-toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'gf-toast-container';
      document.body.appendChild(container);
    }
    var toast = document.createElement('div');
    toast.className = 'gf-toast ' + type;
    toast.innerHTML = '<span>' + escapeHtml(message) + '</span>';
    container.appendChild(toast);
    setTimeout(function () {
      toast.classList.add('fade-out');
      setTimeout(function () { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 300);
    }, 3500);
  }

  function escapeHtml(str) {
    var d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
  }

  // -------------------------------------------------------
  // Loading Overlay
  // -------------------------------------------------------
  function showLoading() {
    var overlay = document.querySelector('.gf-loading-overlay');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.className = 'gf-loading-overlay';
      overlay.innerHTML = '<div class="gf-spinner"></div>';
      document.body.appendChild(overlay);
    }
    overlay.classList.add('active');
  }

  function hideLoading() {
    var overlay = document.querySelector('.gf-loading-overlay');
    if (overlay) overlay.classList.remove('active');
  }

  // -------------------------------------------------------
  // AJAX Helper
  // -------------------------------------------------------
  function ajaxPost(url, data, onSuccess, onError) {
    showLoading();
    var formData = new FormData();
    formData.append(csrfHeader, csrfToken);
    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        formData.append(key, data[key]);
      }
    }
    fetch(url, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: formData
    })
      .then(function (res) {
        if (res.redirected) {
          window.location.href = res.url;
          return;
        }
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      })
      .then(function (json) {
        hideLoading();
        if (json && json.success === false) {
          showToast(json.message || 'Có lỗi xảy ra!', 'error');
          if (onError) onError(json);
        } else {
          showToast(json && json.message ? json.message : 'Thao tác thành công!', 'success');
          if (onSuccess) onSuccess(json);
        }
      })
      .catch(function (err) {
        hideLoading();
        showToast('Lỗi kết nối: ' + err.message, 'error');
        if (onError) onError(err);
      });
  }

  // -------------------------------------------------------
  // USER: Lock / Unlock
  // -------------------------------------------------------
  document.querySelectorAll('.lock-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var userId = btn.dataset.userId;
      var username = btn.dataset.username;
      if (!confirm('Khóa tài khoản "' + username + '"?\nNgười dùng sẽ không thể đăng nhập.')) return;
      ajaxPost(
        ctx + '/admin/users/lock',
        { userId: userId },
        function () {
          var row = document.querySelector('tr[data-user-id="' + userId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(5) .badge');
            if (badge) { badge.textContent = 'LOCKED'; badge.style.background = 'var(--gf-pink)'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) {
              actionsTd.innerHTML =
                '<button type="button" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 unlock-btn"' +
                ' data-user-id="' + userId + '" data-username="' + escapeHtml(username) + '"' +
                ' style="background:#94FFB4;border-radius:8px;padding:5px 10px;font-size:12px;">' +
                '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>' +
                ' Mở khóa</button>';
              actionsTd.querySelector('.unlock-btn').addEventListener('click', arguments.callee);
            }
          }
        }
      );
    });
  });

  document.querySelectorAll('.unlock-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var userId = btn.dataset.userId;
      var username = btn.dataset.username;
      if (!confirm('Mở khóa tài khoản "' + username + '"?')) return;
      ajaxPost(
        ctx + '/admin/users/unlock',
        { userId: userId },
        function () {
          var row = document.querySelector('tr[data-user-id="' + userId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(5) .badge');
            if (badge) { badge.textContent = 'ACTIVE'; badge.style.background = '#94FFB4'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) {
              actionsTd.innerHTML =
                '<button type="button" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold d-flex align-items-center gap-1 lock-btn"' +
                ' data-user-id="' + userId + '" data-username="' + escapeHtml(username) + '"' +
                ' style="background:var(--gf-pink);border-radius:8px;padding:5px 10px;font-size:12px;">' +
                '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
                ' Khóa</button>';
              var newBtn = actionsTd.querySelector('.lock-btn');
              if (newBtn) newBtn.addEventListener('click', arguments.callee);
            }
          }
        }
      );
    });
  });

  // -------------------------------------------------------
  // KYC: Approve / Reject
  // -------------------------------------------------------
  document.querySelectorAll('.approve-kyc-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var kycId = btn.dataset.kycId;
      var username = btn.dataset.user;
      if (!confirm('Phê duyệt KYC của "' + username + '"?\nNgười dùng sẽ được cấp quyền PUBLISHER.')) return;
      ajaxPost(
        ctx + '/admin/kyc/approve',
        { kycId: kycId },
        function () {
          var row = document.querySelector('tr[data-kyc-id="' + kycId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(4) .badge');
            if (badge) { badge.textContent = 'APPROVED'; badge.style.background = '#94FFB4'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) actionsTd.innerHTML = '<span class="badge fw-bold px-3 py-1.5 rounded-pill" style="background:#94FFB4;border:2px solid #000;font-size:11px;">Đã duyệt</span>';
          }
        }
      );
    });
  });

  document.querySelectorAll('.reject-kyc-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var kycId = btn.dataset.kycId;
      var modal = document.getElementById('rejectKycModal');
      var hiddenInput = modal ? modal.querySelector('#rejectKycId') : null;
      if (hiddenInput) hiddenInput.value = kycId;
      var bsModal = bootstrap.Modal.getOrCreateInstance(modal);
      bsModal.show();
    });
  });

  var confirmRejectBtn = document.getElementById('confirmRejectKyc');
  if (confirmRejectBtn) {
    confirmRejectBtn.addEventListener('click', function () {
      var kycId = document.getElementById('rejectKycId') ? document.getElementById('rejectKycId').value : '';
      var note = document.getElementById('rejectNote') ? document.getElementById('rejectNote').value : '';
      if (!note.trim()) {
        showToast('Vui lòng nhập lý do từ chối!', 'error');
        return;
      }
      ajaxPost(
        ctx + '/admin/kyc/reject',
        { kycId: kycId, note: note },
        function () {
          var modal = document.getElementById('rejectKycModal');
          var bsModal = bootstrap.Modal.getOrCreateInstance(modal);
          bsModal.hide();
          var row = document.querySelector('tr[data-kyc-id="' + kycId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(4) .badge');
            if (badge) { badge.textContent = 'REJECTED'; badge.style.background = 'var(--gf-pink)'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) actionsTd.innerHTML = '<span class="badge fw-bold px-3 py-1.5 rounded-pill" style="background:var(--gf-pink);border:2px solid #000;font-size:11px;">Đã từ chối</span>';
          }
        }
      );
    });
  }

  // -------------------------------------------------------
  // PAYOUT: Approve / Reject
  // -------------------------------------------------------
  document.querySelectorAll('.approve-payout-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var payoutId = btn.dataset.payoutId;
      var amount = btn.dataset.amount;
      if (!confirm('Phê duyệt payout #' + payoutId + ' (' + amount + 'đ)?\nTiền sẽ được chuyển cho nhà phát hành.')) return;
      ajaxPost(
        ctx + '/admin/payouts/approve',
        { payoutId: payoutId },
        function () {
          var row = document.querySelector('tr[data-payout-id="' + payoutId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(4) .badge');
            if (badge) { badge.textContent = 'APPROVED'; badge.style.background = '#94FFB4'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) actionsTd.innerHTML = '<span class="badge fw-bold px-3 py-1.5 rounded-pill" style="background:#94FFB4;border:2px solid #000;font-size:11px;">Đã duyệt</span>';
          }
        }
      );
    });
  });

  document.querySelectorAll('.reject-payout-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var payoutId = btn.dataset.payoutId;
      var modal = document.getElementById('rejectPayoutModal');
      var hiddenInput = modal ? modal.querySelector('#rejectPayoutId') : null;
      if (hiddenInput) hiddenInput.value = payoutId;
      var bsModal = bootstrap.Modal.getOrCreateInstance(modal);
      bsModal.show();
    });
  });

  var confirmRejectPayoutBtn = document.getElementById('confirmRejectPayout');
  if (confirmRejectPayoutBtn) {
    confirmRejectPayoutBtn.addEventListener('click', function () {
      var payoutId = document.getElementById('rejectPayoutId') ? document.getElementById('rejectPayoutId').value : '';
      var note = document.getElementById('rejectPayoutNote') ? document.getElementById('rejectPayoutNote').value : '';
      if (!note.trim()) {
        showToast('Vui lòng nhập lý do từ chối!', 'error');
        return;
      }
      ajaxPost(
        ctx + '/admin/payouts/reject',
        { payoutId: payoutId, note: note },
        function () {
          var modal = document.getElementById('rejectPayoutModal');
          var bsModal = bootstrap.Modal.getOrCreateInstance(modal);
          bsModal.hide();
          var row = document.querySelector('tr[data-payout-id="' + payoutId + '"]');
          if (row) {
            var badge = row.querySelector('td:nth-child(4) .badge');
            if (badge) { badge.textContent = 'REJECTED'; badge.style.background = 'var(--gf-pink)'; }
            var actionsTd = row.querySelector('td:last-child');
            if (actionsTd) actionsTd.innerHTML = '<span class="badge fw-bold px-3 py-1.5 rounded-pill" style="background:var(--gf-pink);border:2px solid #000;font-size:11px;">Đã từ chối</span>';
          }
        }
      );
    });
  }

  // -------------------------------------------------------
  // SETTINGS: Commission Form
  // -------------------------------------------------------
  var commissionForm = document.getElementById('commissionForm');
  if (commissionForm) {
    commissionForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var rate = parseFloat(document.getElementById('commissionRate').value);
      if (isNaN(rate) || rate < 0 || rate > 100) {
        showToast('Tỷ lệ phải từ 0 đến 100%!', 'error');
        return;
      }
      showLoading();
      var formData = new FormData(commissionForm);
      fetch(commissionForm.action, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: formData
      })
        .then(function (res) {
          if (res.redirected) { window.location.href = res.url; return; }
          if (!res.ok) throw new Error('HTTP ' + res.status);
          return res.json();
        })
        .then(function (json) {
          hideLoading();
          showToast('Cập nhật thành công!', 'success');
          setTimeout(function () { window.location.reload(); }, 1200);
        })
        .catch(function (err) {
          hideLoading();
          showToast('Lỗi: ' + err.message, 'error');
        });
    });
  }

  // -------------------------------------------------------
  // INIT: Lucide icons
  // -------------------------------------------------------
  if (window.lucide) lucide.createIcons();

})();
