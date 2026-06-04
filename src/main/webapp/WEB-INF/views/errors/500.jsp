<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>GameForge - Lỗi máy chủ hệ thống</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">

    <style>
        body {
            min-height: 100vh;
            background:
                radial-gradient(circle at 15% 20%, rgba(192, 132, 252, .2), transparent 28%),
                radial-gradient(circle at 85% 70%, rgba(255, 181, 167, .25), transparent 30%),
                var(--gf-paper);
            display: grid;
            place-items: center;
            padding: 24px;
        }

        .error-card {
            max-width: 820px;
            width: 100%;
            background: #fff;
            border: 4px solid #000;
            border-radius: 28px;
            box-shadow: 12px 12px 0 #000;
            padding: 42px;
        }

        .error-code {
            font-size: clamp(5rem, 16vw, 9rem);
            font-weight: 1000;
            line-height: .85;
            letter-spacing: -0.08em;
            color: var(--gf-purple);
            text-shadow: 5px 5px 0 #000;
        }

        .error-title {
            font-size: clamp(2rem, 6vw, 4rem);
            font-weight: 1000;
            letter-spacing: -0.05em;
            line-height: 1;
        }

        .error-icon {
            width: 76px;
            height: 76px;
            border: 4px solid #000;
            border-radius: 22px;
            background: var(--gf-pink);
            display: grid;
            place-items: center;
            box-shadow: 6px 6px 0 #000;
        }
    </style>
</head>

<body>
    <main class="error-card">
        <div class="row align-items-center g-4">
            <div class="col-lg-4 text-center">
                <div class="error-icon mx-auto mb-4">
                    <i data-lucide="server-crash" width="42" height="42"></i>
                </div>
                <div class="error-code">500</div>
            </div>

            <div class="col-lg-8">
                <h1 class="error-title mb-3">
                    Đã xảy ra lỗi<br>
                    <span style="color:var(--gf-pink);text-shadow:3px 3px 0 #000;">máy chủ!</span>
                </h1>

                <p class="fs-5 fw-semibold text-secondary mb-4">
                    Hệ thống đang gặp sự cố kỹ thuật tạm thời. Chúng tôi đang nỗ lực khắc phục. Xin lỗi bạn vì sự bất tiện này.
                </p>

                <div class="d-flex flex-wrap gap-2">
                    <a href="${pageContext.request.contextPath}/"
                       class="btn gf-border-2 gf-shadow-sm gf-press fw-bold rounded-3 px-4 py-2"
                       style="background:var(--gf-green);">
                        <i data-lucide="home" width="16" height="16"></i>
                        Về trang chủ
                    </a>

                    <button onclick="window.history.back()"
                       class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 px-4 py-2">
                        <i data-lucide="arrow-left" width="16" height="16"></i>
                        Quay lại trang trước
                    </button>
                </div>
            </div>
        </div>
    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
