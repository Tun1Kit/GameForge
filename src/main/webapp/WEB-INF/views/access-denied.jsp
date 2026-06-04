<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>GameForge - Access Denied</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">

  <style>
    body {
      min-height: 100vh;
      background:
        radial-gradient(circle at 12% 18%, rgba(46, 204, 113, .24), transparent 28%),
        radial-gradient(circle at 86% 72%, rgba(255, 181, 167, .28), transparent 30%),
        var(--gf-paper) !important;
      overflow-x: hidden;
    }

    .denied-shell {
      min-height: 100vh;
      display: grid;
      place-items: center;
      padding: 32px 16px;
    }

    .denied-card {
      max-width: 920px;
      width: 100%;
      background: #fff;
      border: 4px solid #000;
      border-radius: 28px;
      box-shadow: 12px 12px 0 #000;
      overflow: hidden;
    }

    .denied-top {
      background: #18181b;
      color: #fff;
      border-bottom: 4px solid #000;
      padding: 18px 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }

    .denied-code {
      font-size: clamp(4rem, 15vw, 9rem);
      line-height: .85;
      font-weight: 1000;
      letter-spacing: -0.08em;
      color: var(--gf-pink);
      text-shadow: 5px 5px 0 #000;
    }

    .denied-title {
      font-size: clamp(2rem, 6vw, 4rem);
      line-height: 1;
      font-weight: 1000;
      letter-spacing: -0.05em;
    }

    .denied-badge {
      background: var(--gf-yellow);
      color: #000;
      border: 3px solid #000;
      border-radius: 999px;
      padding: 6px 14px;
      font-weight: 900;
      box-shadow: 3px 3px 0 #000;
    }

    .denied-icon {
      width: 76px;
      height: 76px;
      border: 4px solid #000;
      border-radius: 22px;
      background: var(--gf-green);
      display: grid;
      place-items: center;
      box-shadow: 6px 6px 0 #000;
      flex-shrink: 0;
    }
  </style>
</head>

<body>
  <main class="denied-shell">
    <section class="denied-card">
      <div class="denied-top">
        <a href="${pageContext.request.contextPath}${homeUrl}" class="d-flex align-items-center gap-2 text-decoration-none text-white">
          <div class="gf-logo-box" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fw-black fw-bold">
            GAME<span style="color:var(--gf-green);">FORGE</span>
          </span>
        </a>

        <span class="denied-badge">RBAC BLOCKED</span>
      </div>

      <div class="p-4 p-lg-5">
        <div class="row g-4 align-items-center">
          <div class="col-lg-4 text-center">
            <div class="denied-icon mx-auto mb-4">
              <i data-lucide="shield-x" width="42" height="42"></i>
            </div>
            <div class="denied-code">403</div>
          </div>

          <div class="col-lg-8">
            <h1 class="denied-title mb-3">
              Không có quyền<br>
              <span style="color:var(--gf-green);text-shadow:3px 3px 0 #000;">truy cập!</span>
            </h1>

            <p class="fs-5 fw-semibold text-secondary mb-4">
              Tài khoản hiện tại không được phép vào khu vực này. Hệ thống đã chặn truy cập theo phân quyền
              USER / PUBLISHER / ADMIN để bảo vệ dữ liệu và luồng nghiệp vụ.
            </p>

            <div class="gf-border-2 rounded-4 p-3 mb-4" style="background:var(--gf-lavender);">
              <div class="fw-black mb-1">Tài khoản hiện tại</div>
              <div class="text-secondary fw-semibold">
                <c:choose>
                  <c:when test="${not empty currentUser}">
                    ${fn:escapeXml(currentUser.username)} — ${fn:escapeXml(currentUser.email)}
                  </c:when>
                  <c:otherwise>
                    Chưa đăng nhập
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <div class="d-flex flex-wrap gap-2">
              <a href="${pageContext.request.contextPath}${homeUrl}"
                 class="btn gf-border-2 gf-shadow-sm gf-press fw-bold rounded-3 px-4 py-2"
                 style="background:var(--gf-green);">
                <i data-lucide="arrow-left" width="16" height="16"></i>
                ${homeLabel}
              </a>

              <a href="${pageContext.request.contextPath}/logout"
                 class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 px-4 py-2">
                <i data-lucide="log-out" width="16" height="16"></i>
                Đăng xuất
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <script>
    lucide.createIcons();
  </script>
</body>
</html>