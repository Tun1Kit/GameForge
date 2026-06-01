/**
 * GameForge Publisher — JS (Neo-Brutalism)
 * Handles payout request validation
 */

(function () {
  'use strict';

  var payoutForm = document.getElementById('payoutForm');
  if (payoutForm) {
    payoutForm.addEventListener('submit', function (e) {
      var amountInput = document.getElementById('payoutAmount');
      var amount = parseFloat(amountInput.value);

      if (isNaN(amount) || amount < 10000) {
        e.preventDefault();
        alert('Số tiền rút tối thiểu là 10.000đ!');
        amountInput.focus();
        return;
      }
    });
  }

  if (window.lucide) lucide.createIcons();

})();
