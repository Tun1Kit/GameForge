/**
 * GameForge Admin — Shared JS (Neo-Brutalism)
 * Handles lock/unlock user, KYC approve/reject, Payout approve/reject
 */

(function () {
  'use strict';

  var ctx = window.GAMEFORGE_CONTEXT_PATH || '';

  if (ctx === '/' || ctx === 'null' || ctx === 'undefined') {
    ctx = '';
  }

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

      setTimeout(function () {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast);
        }
      }, 300);
    }, 3500);
  }

  function escapeHtml(str) {
    var d = document.createElement('div');
    d.textContent = str == null ? '' : String(str);
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

    if (overlay) {
      overlay.classList.remove('active');
    }
  }

  // -------------------------------------------------------
  // AJAX Helper
  // -------------------------------------------------------
  function ajaxPost(url, data, onSuccess, onError) {
    showLoading();

    var formData = new FormData();

    if (csrfToken && csrfHeader) {
      formData.append(csrfHeader, csrfToken);
    }

    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        formData.append(key, data[key]);
      }
    }

    fetch(url, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: formData
    })
      .then(function (res) {
        if (res.redirected) {
          window.location.href = res.url;
          return null;
        }

        if (!res.ok) {
          throw new Error('HTTP ' + res.status + ' - ' + url);
        }

        var contentType = res.headers.get('content-type') || '';

        if (contentType.indexOf('application/json') !== -1) {
          return res.json();
        }

        return {
          success: true,
          message: 'Thao tác thành công.'
        };
      })
      .then(function (json) {
        hideLoading();

        if (!json) {
          return;
        }

        if (json.success === false) {
          showToast(json.message || 'Có lỗi xảy ra!', 'error');

          if (onError) {
            onError(json);
          }
        } else {
          showToast(json.message || 'Thao tác thành công!', 'success');

          if (onSuccess) {
            onSuccess(json);
          }
        }
      })
      .catch(function (err) {
        hideLoading();
        showToast('Lỗi kết nối: ' + err.message, 'error');

        if (onError) {
          onError(err);
        }
      });
  }

  // -------------------------------------------------------
  // USER: Lock / Unlock
  // -------------------------------------------------------
  function bindLockButton(btn) {
    if (!btn) {
      return;
    }

    btn.addEventListener('click', function () {
      var userId = btn.dataset.userId;
      var username = btn.dataset.username;

      if (!confirm('Khóa tài khoản "' + username + '"?\nNgười dùng sẽ không thể đăng nhập.')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/users/lock',
        { userId: userId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  }

  function bindUnlockButton(btn) {
    if (!btn) {
      return;
    }

    btn.addEventListener('click', function () {
      var userId = btn.dataset.userId;
      var username = btn.dataset.username;

      if (!confirm('Mở khóa tài khoản "' + username + '"?')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/users/unlock',
        { userId: userId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  }

  document.querySelectorAll('.lock-btn').forEach(function (btn) {
    bindLockButton(btn);
  });

  document.querySelectorAll('.unlock-btn').forEach(function (btn) {
    bindUnlockButton(btn);
  });

  // -------------------------------------------------------
  // KYC: Approve / Reject
  // -------------------------------------------------------
  document.querySelectorAll('.approve-kyc-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var kycId = btn.dataset.kycId;
      var username = btn.dataset.user;

      if (!confirm('Phê duyệt KYC của "' + username + '"?\nNgười dùng sẽ được cấp quyền PUBLISHER.')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/kyc/approve',
        { requestId: kycId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  });

  document.querySelectorAll('.reject-kyc-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var kycId = btn.dataset.kycId;

      if (!confirm('Từ chối yêu cầu KYC này?')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/kyc/reject',
        { requestId: kycId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  });

  // -------------------------------------------------------
  // PAYOUT: Approve / Reject
  // -------------------------------------------------------
  document.querySelectorAll('.approve-payout-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var payoutId = btn.dataset.payoutId;
      var amount = btn.dataset.amount;

      if (!confirm('Phê duyệt payout #' + payoutId + ' (' + amount + 'đ)?\nTiền sẽ được chuyển cho nhà phát hành.')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/payouts/approve',
        { requestId: payoutId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  });

  document.querySelectorAll('.reject-payout-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var payoutId = btn.dataset.payoutId;

      if (!confirm('Từ chối payout #' + payoutId + '?')) {
        return;
      }

      ajaxPost(
        ctx + '/admin/payouts/reject',
        { requestId: payoutId },
        function () {
          setTimeout(function () {
            window.location.reload();
          }, 500);
        }
      );
    });
  });

  // -------------------------------------------------------
  // SETTINGS: Commission Form
  // -------------------------------------------------------
  var commissionForm = document.getElementById('commissionForm');

  if (commissionForm) {
    commissionForm.addEventListener('submit', function (e) {
      var rateInput = document.getElementById('commissionRate');
      var rawValue = rateInput ? String(rateInput.value).replace(',', '.') : '';
      var rate = parseFloat(rawValue);

      if (isNaN(rate) || rate < 0 || rate > 100) {
        e.preventDefault();
        showToast('Tỷ lệ phải từ 0 đến 100%!', 'error');
        return;
      }

      var submitBtn = commissionForm.querySelector('button[type="submit"]');

      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang lưu...';
      }
    });
  }

  // -------------------------------------------------------
  // INIT: Lucide icons
  // -------------------------------------------------------
  if (window.lucide) {
    lucide.createIcons();
  }

})();