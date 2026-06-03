/**
 * GameForge KYC — JS (Neo-Brutalism)
 * Handles KYC form: image preview, validation, submission
 */

(function () {
  'use strict';

  // -------------------------------------------------------
  // Escape HTML
  // -------------------------------------------------------
  function escapeHtml(text) {
    var div = document.createElement('div');
    div.innerText = text;
    return div.innerHTML;
  }

  // -------------------------------------------------------
  // Image Preview
  // -------------------------------------------------------
  window.previewImage = function (input, previewId) {
    var preview = document.getElementById(previewId);

    if (!preview || !input || !input.files || !input.files[0]) {
      return;
    }

    var file = input.files[0];
    var maxSize = 5 * 1024 * 1024; // 5MB

    if (!file.type || !file.type.startsWith('image/')) {
      alert('Vui lòng chọn file ảnh JPG hoặc PNG.');
      input.value = '';
      return;
    }

    if (file.size > maxSize) {
      alert('File quá lớn! Dung lượng tối đa là 5MB.');
      input.value = '';
      return;
    }

    var reader = new FileReader();

    reader.onload = function (e) {
      // QUAN TRỌNG:
      // Chỉ thay nội dung bên trong div preview.
      // Không được thay preview.parentElement.innerHTML vì sẽ xóa input file khỏi form.
      preview.innerHTML =
        '<img src="' + e.target.result + '" alt="Preview" ' +
        'style="width:100%;max-height:180px;object-fit:cover;border-radius:12px;border:2px solid #000;">' +
        '<div class="text-center mt-2">' +
        '<span class="small fw-bold text-success">' + escapeHtml(file.name) + '</span><br>' +
        '<span class="small text-secondary">' + (file.size / 1024 / 1024).toFixed(2) + ' MB</span><br>' +
        '<span class="small text-secondary">Click để chọn ảnh khác</span>' +
        '</div>';
    };

    reader.readAsDataURL(file);
  };

  // -------------------------------------------------------
  // KYC Type Card Selection
  // -------------------------------------------------------
  document.querySelectorAll('.kyc-type-card input[type="radio"]').forEach(function (radio) {
    radio.addEventListener('change', function () {
      document.querySelectorAll('.kyc-type-card').forEach(function (card) {
        card.classList.remove('active');
      });

      var parentCard = radio.closest('.kyc-type-card');
      if (parentCard) {
        parentCard.classList.add('active');
      }
    });
  });

  // -------------------------------------------------------
  // Form Validation & Submit
  // -------------------------------------------------------
  var kycForm = document.getElementById('kycForm');

  if (kycForm) {
    kycForm.addEventListener('submit', function (e) {
      var idType = document.querySelector('input[name="idType"]:checked');
      var taxId = document.getElementById('taxId') || document.querySelector('[name="taxId"]');
      var fullName = document.querySelector('[name="fullName"]');
      var documentFile = document.getElementById('frontImage') || document.querySelector('[name="documentFile"]');
      var submitBtn = document.getElementById('kycSubmitBtn');

      if (!idType) {
        e.preventDefault();
        alert('Vui lòng chọn loại giấy tờ!');
        return;
      }

      if (!taxId || taxId.value.trim().length < 6) {
        e.preventDefault();
        alert('Số giấy tờ phải có ít nhất 6 ký tự!');
        if (taxId) taxId.focus();
        return;
      }

      if (!fullName || fullName.value.trim().length < 3) {
        e.preventDefault();
        alert('Họ và tên phải có ít nhất 3 ký tự!');
        if (fullName) fullName.focus();
        return;
      }

      if (!documentFile || !documentFile.files || documentFile.files.length === 0) {
        e.preventDefault();
        alert('Vui lòng chọn ảnh mặt trước giấy tờ!');
        return;
      }

      var file = documentFile.files[0];
      var maxSize = 5 * 1024 * 1024;

      if (!file.type || !file.type.startsWith('image/')) {
        e.preventDefault();
        alert('Vui lòng chọn file ảnh JPG hoặc PNG.');
        documentFile.value = '';
        return;
      }

      if (file.size > maxSize) {
        e.preventDefault();
        alert('File quá lớn! Dung lượng tối đa là 5MB.');
        documentFile.value = '';
        return;
      }

      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang gửi...';
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