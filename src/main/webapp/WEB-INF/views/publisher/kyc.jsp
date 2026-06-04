<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>GameForge - Hồ sơ KYC Publisher</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/publisher.css">
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">

  <!-- PUBLISHER NAVBAR -->
  <nav class="gf-navbar" style="background:#18181b;border-bottom:3px solid #000;">
    <div class="container-xl py-3">
      <div class="d-flex align-items-center justify-content-between gap-3">

        <a href="${pageContext.request.contextPath}/publisher/dashboard"
           class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="gamepad-2" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-white">
            GAME<span style="color:var(--gf-green)">FORGE</span>
            <span class="badge ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;background:var(--gf-yellow);color:#000;">
              PUBLISHER
            </span>
          </span>
        </a>

        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/publisher/dashboard"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="layout-dashboard" width="14" height="14"></i>
            Dashboard
          </a>

          <a href="${pageContext.request.contextPath}/publisher/payouts"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3">
            <i data-lucide="banknote" width="14" height="14"></i>
            Payout
          </a>

          <a href="${pageContext.request.contextPath}/logout"
             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-3 d-flex align-items-center gap-2 py-2 px-3"
             style="background:var(--gf-pink);color:#000;">
            <i data-lucide="log-out" width="14" height="14"></i>
            Đăng xuất
          </a>
        </div>

      </div>
    </div>
  </nav>

  <main class="container-xl py-5">

    <section class="bg-white gf-border rounded-4 gf-shadow p-4 p-lg-5">

      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-4"
           style="background:var(--gf-lavender);box-shadow:3px 3px 0 #000;">
        <i data-lucide="id-card" width="16" height="16"></i>
        Hồ sơ KYC Publisher
      </div>

      <h1 class="fw-black fw-bold mb-3" style="font-size:clamp(2rem,5vw,3.5rem);line-height:1.1;letter-spacing:-0.03em;">
        Trạng thái xác minh<br>
        <span style="color:var(--gf-green);text-shadow:2px 2px 0 #000;">Publisher</span>
      </h1>

      <p class="fs-5 fw-semibold text-secondary gf-muted mb-4" style="max-width:820px;">
        Trang này hiển thị dữ liệu KYC thật của Publisher từ bảng
        <code>kyc_requests</code> và thông tin hồ sơ nhà phát hành từ bảng
        <code>publisher_profiles</code>.
      </p>

      <!-- ACCOUNT + PROFILE -->
      <div class="row g-4 mb-4">

        <div class="col-lg-6">
          <div class="gf-border-2 rounded-4 p-4 h-100" style="background:#94FFB4;box-shadow:5px 5px 0 #000;">
            <div class="d-flex align-items-center gap-3 mb-3">
              <div class="gf-border-2 rounded-3 d-grid" style="width:52px;height:52px;place-items:center;background:#fff;">
                <i data-lucide="user-check" width="26" height="26"></i>
              </div>
              <div>
                <div class="fw-black fs-5">Tài khoản Publisher</div>
                <div class="fw-semibold">${fn:escapeXml(currentUser.fullName)}</div>
              </div>
            </div>

            <div class="fw-semibold mb-1">
              Username: ${fn:escapeXml(currentUser.username)}
            </div>

            <div class="fw-semibold">
              Email: ${fn:escapeXml(currentUser.email)}
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="gf-border-2 rounded-4 p-4 h-100" style="background:var(--gf-yellow);box-shadow:5px 5px 0 #000;">
            <div class="d-flex align-items-center gap-3 mb-3">
              <div class="gf-border-2 rounded-3 d-grid" style="width:52px;height:52px;place-items:center;background:#fff;">
                <i data-lucide="building-2" width="26" height="26"></i>
              </div>
              <div>
                <div class="fw-black fs-5">Publisher Profile</div>
                <div class="fw-semibold">
                  <c:choose>
                    <c:when test="${not empty publisherProfile}">
                      Đã tạo hồ sơ nhà phát hành
                    </c:when>
                    <c:otherwise>
                      Chưa có hồ sơ nhà phát hành
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>

            <c:choose>
              <c:when test="${not empty publisherProfile}">
                <div class="fw-semibold mb-1">
                  Công ty:
                  <span class="fw-black">
                    <c:choose>
                      <c:when test="${not empty publisherProfile.companyName}">
                        ${fn:escapeXml(publisherProfile.companyName)}
                      </c:when>
                      <c:otherwise>Chưa cập nhật</c:otherwise>
                    </c:choose>
                  </span>
                </div>

                <div class="fw-semibold mb-1">
                  Website:
                  <c:choose>
                    <c:when test="${not empty publisherProfile.website}">
                      <a href="${fn:escapeXml(publisherProfile.website)}" target="_blank" class="fw-bold text-dark">
                        ${fn:escapeXml(publisherProfile.website)}
                      </a>
                    </c:when>
                    <c:otherwise>Chưa cập nhật</c:otherwise>
                  </c:choose>
                </div>

                <div class="fw-semibold">
                  Email hỗ trợ:
                  <span class="fw-black">
                    <c:choose>
                      <c:when test="${not empty publisherProfile.supportEmail}">
                        ${fn:escapeXml(publisherProfile.supportEmail)}
                      </c:when>
                      <c:otherwise>Chưa cập nhật</c:otherwise>
                    </c:choose>
                  </span>
                </div>
              </c:when>

              <c:otherwise>
                <div class="fw-semibold">
                  Tài khoản này có quyền Publisher nhưng chưa có bản ghi trong bảng
                  <code>publisher_profiles</code>.
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

      </div>

      <!-- KYC DATA -->
      <div class="bg-white gf-border rounded-4 gf-shadow overflow-hidden mb-4">

        <div class="p-3 fw-black d-flex align-items-center gap-2"
             style="background:var(--gf-lavender);border-bottom:3px solid #000;">
          <i data-lucide="shield-check" width="18" height="18"></i>
          Dữ liệu KYC gần nhất
        </div>

        <c:choose>
          <c:when test="${not empty latestKyc}">
            <div class="table-responsive">
              <table class="table mb-0 align-middle">
                <tbody>
                  <tr>
                    <th class="px-4 py-3 fw-black" style="width:260px;">Mã KYC</th>
                    <td class="py-3 fw-semibold">#KYC-${latestKyc.id}</td>
                  </tr>

                  <tr>
                    <th class="px-4 py-3 fw-black">Mã số thuế</th>
                    <td class="py-3 fw-semibold">
                      <c:choose>
                        <c:when test="${not empty latestKyc.taxId}">
                          ${fn:escapeXml(latestKyc.taxId)}
                        </c:when>
                        <c:otherwise>Chưa cập nhật</c:otherwise>
                      </c:choose>
                    </td>
                  </tr>

                  <tr>
                    <th class="px-4 py-3 fw-black">Trạng thái</th>
                    <td class="py-3">
                      <c:choose>
                        <c:when test="${latestKyc.status == 'APPROVED'}">
                          <span class="badge fw-black"
                                style="background:#94FFB4;color:#000;border:2px solid #000;border-radius:999px;padding:8px 14px;">
                            APPROVED
                          </span>
                        </c:when>

                        <c:when test="${latestKyc.status == 'PENDING'}">
                          <span class="badge fw-black"
                                style="background:var(--gf-yellow);color:#000;border:2px solid #000;border-radius:999px;padding:8px 14px;">
                            PENDING
                          </span>
                        </c:when>

                        <c:when test="${latestKyc.status == 'REJECTED'}">
                          <span class="badge fw-black"
                                style="background:var(--gf-pink);color:#000;border:2px solid #000;border-radius:999px;padding:8px 14px;">
                            REJECTED
                          </span>
                        </c:when>

                        <c:otherwise>
                          <span class="badge fw-black"
                                style="background:#e5e7eb;color:#000;border:2px solid #000;border-radius:999px;padding:8px 14px;">
                            ${fn:escapeXml(latestKyc.status)}
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>

                  <tr>
                    <th class="px-4 py-3 fw-black">File giấy tờ đã upload</th>
                    <td class="py-3 fw-semibold">
                      <c:choose>
                        <c:when test="${not empty latestKyc.documentUrl}">
                          <a href="${pageContext.request.contextPath}${latestKyc.documentUrl}"
                             target="_blank"
                             class="btn btn-sm gf-border-2 gf-shadow-sm gf-press fw-bold rounded-3 px-3 py-2"
                             style="background:var(--gf-green);color:#000;">
                            <i data-lucide="file-search" width="14" height="14"></i>
                            Xem giấy tờ
                          </a>

                          <div class="small text-secondary mt-2">
                            ${fn:escapeXml(latestKyc.documentUrl)}
                          </div>
                        </c:when>

                        <c:otherwise>
                          Chưa có file upload
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>

                  <tr>
                    <th class="px-4 py-3 fw-black">Ngày gửi</th>
                    <td class="py-3 fw-semibold">
                      <c:choose>
                        <c:when test="${not empty latestKyc.submittedAt}">
                          ${fn:replace(latestKyc.submittedAt, 'T', ' ')}
                        </c:when>
                        <c:otherwise>Chưa có dữ liệu</c:otherwise>
                      </c:choose>
                    </td>
                  </tr>

                  <tr>
                    <th class="px-4 py-3 fw-black">Ngày duyệt / xử lý</th>
                    <td class="py-3 fw-semibold">
                      <c:choose>
                        <c:when test="${not empty latestKyc.processedAt}">
                          ${fn:replace(latestKyc.processedAt, 'T', ' ')}
                        </c:when>
                        <c:otherwise>Chưa được xử lý</c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </c:when>

          <c:otherwise>
            <div class="text-center p-5">
              <div class="gf-border-2 rounded-4 d-grid mx-auto mb-3"
                   style="width:58px;height:58px;place-items:center;background:var(--gf-yellow);">
                <i data-lucide="file-warning" width="28" height="28"></i>
              </div>

              <h3 class="fw-black mb-2">Chưa có bản ghi KYC</h3>

              <p class="fw-semibold text-secondary mb-0">
                Tài khoản này có thể là Publisher được tạo trực tiếp bằng dữ liệu mẫu,
                nên chưa có dòng dữ liệu trong bảng <code>kyc_requests</code>.
              </p>
            </div>
          </c:otherwise>
        </c:choose>

      </div>

      <!-- ACTIONS -->
      <div class="d-flex flex-wrap gap-2">
        <a href="${pageContext.request.contextPath}/publisher/dashboard"
           class="btn gf-border-2 gf-shadow-sm gf-press fw-bold rounded-3 px-4 py-2"
           style="background:var(--gf-green);">
          <i data-lucide="arrow-left" width="16" height="16"></i>
          Về Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/publisher/payouts"
           class="btn gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold rounded-3 px-4 py-2">
          <i data-lucide="banknote" width="16" height="16"></i>
          Xem Payout
        </a>
      </div>

    </section>

  </main>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForge Publisher — KYC Profile
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    lucide.createIcons();
  </script>
</body>
</html>