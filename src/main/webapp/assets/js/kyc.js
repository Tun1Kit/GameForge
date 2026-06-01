/**
 * GameForge KYC — JS (Neo-Brutalism)
 * Handles KYC form: image preview, validation, submission
 */

(function () {
  'use strict';

  // -------------------------------------------------------
  // Image Preview
  // -------------------------------------------------------
  window.previewImage = function (input, previewId) {
    var preview = document.getElementById(previewId);
    if (!preview || !input.files || !input.files[0]) return;

    var file = input.files[0];
    var maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      alert('File quá lớn! Dung lượng tối đa là 5MB.');
      input.value = '';
      return;
    }

    var reader = new FileReader();
    reader.onload = function (e) {
      var wrapper = preview.parentElement;
      wrapper.innerHTML =
        '<img src="' + e.target.result + '" alt="Preview" style="max-height:120px;border-radius:8px;margin:0 auto;display:block;">' +
        '<div class="text-center mt-2"><span class="small fw-bold text-success">' + file.name + '</span><br>' +
        '<span class="small text-secondary">' + (file.size / 1024 / 1024).toFixed(2) + ' MB</span></div>';
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
      if (parentCard) parentCard.classList.add('active');
    });
  });

  // -------------------------------------------------------
  // Form Validation & Submit
  // -------------------------------------------------------
  var kycForm = document.getElementById('kycForm');
  if (kycForm) {
    kycForm.addEventListener('submit', function (e) {
      var idType = document.querySelector('input[name="idType"]:checked');
      var idNumber = document.getElementById('idNumber') || document.querySelector('[name="idNumber"]');
      var fullName = document.querySelector('[name="fullName"]');

      if (!idType) {
        e.preventDefault();
        alert('Vui lòng chọn loại giấy tờ!');
        return;
      }

      if (idNumber && idNumber.value.trim().length < 6) {
        e.preventDefault();
        alert('Số giấy tờ phải có ít nhất 6 ký tự!');
        idNumber.focus();
        return;
      }

      if (fullName && fullName.value.trim().length < 3) {
        e.preventDefault();
        alert('Họ và tên phải có ít nhất 3 ký tự!');
        fullName.focus();
        return;
      }

      var submitBtn = document.getElementById('kycSubmitBtn');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang gửi...';
      }
    });
  }

  // -------------------------------------------------------
  // INIT: Lucide icons
  // -------------------------------------------------------
  if (window.lucide) lucide.createIcons();

})();
