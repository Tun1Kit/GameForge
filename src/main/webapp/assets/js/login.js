// Khởi tạo icon
if (window.lucide) {
    lucide.createIcons();
}

function switchAuth(type) {
    const isRegister = type === 'register';
    const track = document.getElementById('formTrack');
    const loginTab = document.getElementById('loginTab');
    const registerTab = document.getElementById('registerTab');

    // Các class Bootstrap cho nút đang chọn (Active) và không chọn (Inactive)
    const activeClasses = 'btn flex-grow-1 border-3 border-dark rounded-3 fw-black shadow-none text-dark';
    const inactiveClasses = 'btn flex-grow-1 border-0 rounded-3 fw-black text-secondary bg-transparent';

    if (isRegister) {
        track.style.transform = 'translateX(-50%)';
        registerTab.className = activeClasses;
        registerTab.style.backgroundColor = 'var(--gf-green)';
        loginTab.className = inactiveClasses;
        loginTab.style.backgroundColor = 'transparent';
    } else {
        track.style.transform = 'translateX(0)';
        loginTab.className = activeClasses;
        loginTab.style.backgroundColor = 'var(--gf-green)';
        registerTab.className = inactiveClasses;
        registerTab.style.backgroundColor = 'transparent';
    }
    
    // Đổi URL trên thanh địa chỉ mà không reload trang
    const url = new URL(window.location.href);
    url.searchParams.set('mode', type);
    window.history.replaceState({}, '', url);
}



function toggleTheme() {
  const isDark = !document.body.classList.contains('gf-dark-mode');

  document.body.classList.toggle('gf-dark-mode', isDark);
  document.documentElement.classList.toggle('gf-dark-mode', isDark);

  localStorage.setItem('gameforge_theme_bootstrap', isDark ? 'dark' : 'light');

  const themeText = document.getElementById('theme-text');
  const iconLight = document.getElementById('icon-light');
  const iconDark = document.getElementById('icon-dark');

  if (themeText) themeText.textContent = isDark ? 'Dark' : 'Light';
  if (iconLight) iconLight.classList.toggle('d-none', isDark);
  if (iconDark) iconDark.classList.toggle('d-none', !isDark);
}

// Khởi tạo trạng thái khi load trang
document.addEventListener('DOMContentLoaded', () => {
    // Giữ nguyên logic check tab Register
    const params = new URLSearchParams(window.location.search);
    if (params.get('mode') === 'register') {
        switchAuth('register');
    }

    // CHECK DARK MODE TỪ LOCALSTORAGE
	const isDark = localStorage.getItem('gameforge_theme_bootstrap') === 'dark';

	document.body.classList.toggle('gf-dark-mode', isDark);
	document.documentElement.classList.toggle('gf-dark-mode', isDark);

	const themeText = document.getElementById('theme-text');
	const iconLight = document.getElementById('icon-light');
	const iconDark = document.getElementById('icon-dark');

	if (themeText) themeText.textContent = isDark ? 'Dark' : 'Light';
	if (iconLight) iconLight.classList.toggle('d-none', isDark);
	if (iconDark) iconDark.classList.toggle('d-none', !isDark);
	
	const themeButton = document.getElementById('themeButton');
	if (themeButton) {
	  themeButton.addEventListener('click', toggleTheme);
	}

	if (window.lucide) {
	  lucide.createIcons();
	}
	
});



function togglePassword(id, btn) {
    const input = document.getElementById(id);
    if (input.type === 'password') {
        input.type = 'text';
        btn.innerHTML = '<i data-lucide="eye-off" width="18" height="18"></i>';
    } else {
        input.type = 'password';
        btn.innerHTML = '<i data-lucide="eye" width="18" height="18"></i>';
    }
    if (window.lucide) lucide.createIcons();
}


// --- BẮT LỖI MẬT KHẨU REAL-TIME & KIỂM TRA CHUẨN ISO ---
document.addEventListener('DOMContentLoaded', () => {
    const regPassword = document.getElementById('regPassword');
    const regConfirm = document.getElementById('regConfirm');
    const regBtn = document.querySelector('form[action$="/register"] button[type="submit"]');
    const rulesBox = document.getElementById('password-rules');

    // Các thẻ hiển thị từng quy tắc ISO
    const ruleLength = document.getElementById('rule-length');
    const ruleUpper = document.getElementById('rule-upper');
    const ruleLower = document.getElementById('rule-lower');
    const ruleNumber = document.getElementById('rule-number');
    const ruleSpecial = document.getElementById('rule-special');

    let isIsoValid = false;

    // Hàm đổi màu UI khi quy tắc đạt yêu cầu
    function updateRuleUI(element, isValid, text) {
        if (isValid) {
            element.className = 'fw-bold text-success d-flex align-items-center gap-1';
            element.innerHTML = `<i data-lucide="check-circle" width="14" height="14"></i> ${text}`;
        } else {
            element.className = 'fw-bold text-danger d-flex align-items-center gap-1';
            element.innerHTML = `<i data-lucide="x-circle" width="14" height="14"></i> ${text}`;
        }
    }

    if (regPassword && regConfirm && regBtn && rulesBox) {
        
        // 1. Lắng nghe khi gõ ô MẬT KHẨU CHÍNH (Kiểm tra ISO)
        regPassword.addEventListener('input', function() {
            const pass = this.value;

            // Hiện bảng Checklist khi bắt đầu gõ
            if (pass.length > 0) rulesBox.classList.remove('d-none');
            else rulesBox.classList.add('d-none');

            // Kiểm tra 5 tiêu chí bằng Regex
            const hasLength = pass.length >= 8;
            const hasUpper = /[A-Z]/.test(pass);
            const hasLower = /[a-z]/.test(pass);
            const hasNumber = /[0-9]/.test(pass);
            const hasSpecial = /[^A-Za-z0-9]/.test(pass);

            // Cập nhật giao diện Checklist
            updateRuleUI(ruleLength, hasLength, 'Tối thiểu 8 ký tự');
            updateRuleUI(ruleUpper, hasUpper, 'Ít nhất 1 chữ IN HOA');
            updateRuleUI(ruleLower, hasLower, 'Ít nhất 1 chữ thường');
            updateRuleUI(ruleNumber, hasNumber, 'Ít nhất 1 chữ số');
            updateRuleUI(ruleSpecial, hasSpecial, 'Ký tự đặc biệt (!@#$...)');

            if (window.lucide) lucide.createIcons();

            // Lưu trạng thái tổng
            isIsoValid = hasLength && hasUpper && hasLower && hasNumber && hasSpecial;

            // Kích hoạt ô Nhập lại tự kiểm tra chéo
            if(regConfirm.value.length > 0) {
                regConfirm.dispatchEvent(new Event('input')); 
            }
        });

        // 2. Lắng nghe khi gõ ô NHẬP LẠI (Kiểm tra Khớp & Khóa/Mở nút)
        regConfirm.addEventListener('input', function() {
            const passValue = regPassword.value;
            const confirmValue = this.value;

            // Mặc định khóa nút
            regBtn.disabled = true;
            regBtn.style.backgroundColor = '#D1D5DB';
            regBtn.style.cursor = 'not-allowed';

            if (confirmValue.length === 0) {
                // Trống thì trả về bình thường
                this.style.backgroundColor = ''; 
                this.style.borderColor = '#000';
                this.style.boxShadow = '3px 3px 0 0 #000';
                regBtn.innerHTML = '<i data-lucide="user-plus" width="20" height="20"></i> Đăng ký ngay';
                
            } else if (passValue !== confirmValue) {
                // Báo đỏ vì KHÔNG KHỚP
                this.style.backgroundColor = '#FECACA'; 
                this.style.borderColor = '#DC2626';
                this.style.boxShadow = '4px 4px 0 0 #DC2626';
                regBtn.innerHTML = '<i data-lucide="shield-alert" width="20" height="20"></i> Mật khẩu không khớp';
                
            } else if (passValue === confirmValue && !isIsoValid) {
                // Khớp nhưng chưa đạt chuẩn ISO
                this.style.backgroundColor = ''; 
                this.style.borderColor = '#000';
                this.style.boxShadow = '3px 3px 0 0 #000';
                regBtn.innerHTML = '<i data-lucide="shield-alert" width="20" height="20"></i> Cần đạt chuẩn ISO';
                
            } else if (passValue === confirmValue && isIsoValid) {
                // HOÀN HẢO!
                this.style.backgroundColor = '#A7F3D0'; // Xanh lá Neo-Brutalism
                this.style.borderColor = '#000';
                this.style.boxShadow = '3px 3px 0 0 #000';
                
                // Mở khóa nút
                regBtn.disabled = false;
                regBtn.style.backgroundColor = 'var(--gf-green)';
                regBtn.style.cursor = 'pointer';
                regBtn.innerHTML = '<i data-lucide="user-plus" width="20" height="20"></i> Đăng ký ngay';
            }
            
            if (window.lucide) lucide.createIcons();
        });
    }
});

