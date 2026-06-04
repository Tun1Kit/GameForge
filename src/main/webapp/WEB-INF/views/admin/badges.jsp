<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GameForge Admin - Quản lý Huy hiệu</title>
  
  <meta name="_csrf" content="${_csrf.token}" />
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <script>
    window.GAMEFORGE_CSRF_TOKEN = '${_csrf.token}';
    window.GAMEFORGE_CSRF_HEADER = '${_csrf.headerName}';
    window.GAMEFORGE_CONTEXT_PATH = '${pageContext.request.contextPath}';
  </script>

  <!-- Bootstrap 5 + Lucide -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

  <style>
    body {
      background-color: #f4f4f5;
    }
    .panel-box {
      background: #fff;
      border: 3px solid #000;
      box-shadow: 6px 6px 0 0 #000;
      border-radius: 16px;
    }
    .table thead th {
      background: var(--gf-yellow) !important;
      color: #000;
      border-bottom: 3px solid #000 !important;
      font-weight: 900;
      text-transform: uppercase;
      font-size: 13px;
    }
    .table td, .table th {
      padding: 12px 16px;
      vertical-align: middle;
      border-bottom: 2px solid #000;
    }
    .game-thumb-sm {
      width: 60px;
      height: 34px;
      object-fit: cover;
      border: 2px solid #000;
      border-radius: 4px;
      box-shadow: 1.5px 1.5px 0 0 #000;
    }
    .badge-preview {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      border: 2px solid #000;
      border-radius: 6px;
      padding: 3px 8px;
      font-size: 11px;
      font-weight: 800;
      box-shadow: 1.5px 1.5px 0 0 #000;
      color: #000;
    }
    .icon-picker-btn {
      width: 42px;
      height: 42px;
      border-radius: 8px;
      border: 2px solid #000;
      background: #f8fafc;
      color: #64748b;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.15s ease;
    }
    .icon-picker-btn.active {
      background: var(--gf-yellow) !important;
      color: #000 !important;
      box-shadow: 2px 2px 0 #000;
      border-color: #000 !important;
    }
  </style>
</head>

<body class="position-relative" style="min-height:100vh;overflow-x:hidden;">
  <!-- NAVBAR -->
  <!-- NAVBAR -->
  <nav class="gf-navbar" style="background:#fff;border-bottom:3px solid #000;">
    <div class="container-xl py-2">
      <div class="d-flex align-items-center justify-content-between gap-3">
        <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center gap-2 text-decoration-none flex-shrink-0">
          <div class="gf-logo-box gf-press" style="background:var(--gf-green);">
            <i data-lucide="shield-check" width="20" height="20"></i>
          </div>
          <span class="fs-5 fw-black fw-bold text-dark">GAME<span style="color:var(--gf-green)">FORGE</span> <span class="badge bg-danger ms-1" style="font-size:9px;border-radius:999px;padding:2px 6px;">ADMIN</span></span>
        </a>
        
        <div class="d-flex align-items-center gap-2 flex-grow-1 justify-content-end flex-wrap">
          <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="layout-dashboard" width="14" height="14"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="users" width="14" height="14"></i> Người dùng
          </a>
          <a href="${pageContext.request.contextPath}/admin/games" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="gamepad-2" width="14" height="14"></i> Quản lý Game
          </a>
          <a href="${pageContext.request.contextPath}/admin/kyc" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="id-card" width="14" height="14"></i> KYC
          </a>
          <a href="${pageContext.request.contextPath}/admin/payouts" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="banknote" width="14" height="14"></i> Payout
          </a>
          <a href="${pageContext.request.contextPath}/admin/badges" class="btn btn-sm gf-border-2 gf-press text-white fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;background:var(--gf-green);border-color:#000;color:#fff !important;line-height:1;flex-shrink:0;">
            <i data-lucide="award" width="14" height="14"></i> Huy hiệu
          </a>
          <a href="${pageContext.request.contextPath}/admin/settings" class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 px-3" style="height:38px;border-color:#000;line-height:1;flex-shrink:0;">
            <i data-lucide="settings" width="14" height="14"></i> Settings
          </a>
          
          <!-- Notification Bell -->
          <a href="${pageContext.request.contextPath}/admin/notifications" class="btn btn-sm gf-border-2 gf-press bg-white text-dark rounded-3 d-flex align-items-center justify-content-center p-0 position-relative" style="width:38px; height:38px; border-color:#000; flex-shrink:0;">
            <i data-lucide="bell" width="16" height="16"></i>
            <c:if test="${unreadNotificationCount > 0}">
              <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size:9px; padding: 3px 6px;">
                ${unreadNotificationCount}
              </span>
            </c:if>
          </a>

          <!-- Dropdown User -->
          <div class="dropdown" style="flex-shrink: 0;">
            <button class="btn btn-sm gf-border-2 gf-press bg-white text-dark fw-bold rounded-3 d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown" style="height:38px;border-color:#000;padding:4px 12px 4px 6px;flex-shrink:0;line-height:1;">
              <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://api.dicebear.com/7.x/pixel-art/svg?seed=Admin'}" alt="Avatar" style="width:24px;height:24px;border-radius:50%;object-fit:cover;border:1.5px solid #000;">
              <span class="d-none d-sm-inline fw-black text-dark" style="font-size:12px;">${fn:escapeXml(currentUser.username)}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end gf-border-2 gf-shadow-sm p-2" style="border-radius:12px;min-width:180px;">
              <li><a class="dropdown-item d-flex align-items-center gap-2 fw-bold py-2" href="${pageContext.request.contextPath}/logout"><i data-lucide="log-out" width="14" height="14"></i> Đăng xuất</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- MAIN CONTENT -->
  <main class="container-xl py-5">
    <div class="mb-5">
      <div class="d-inline-flex align-items-center gap-2 gf-border-2 rounded-pill px-4 py-2 fw-bold text-black mb-3" style="background:var(--gf-yellow);box-shadow:3px 3px 0 #000;">
        <i data-lucide="award" width="16" height="16"></i> Quản lý Huy hiệu Sản phẩm
      </div>
      <h1 class="fw-black fw-bold mb-2">Trung Tâm Quản Lý Huy Hiệu</h1>
      <p class="fs-5 fw-semibold text-secondary gf-muted">Định nghĩa danh sách các huy hiệu hệ thống và gán chúng cho từng trò chơi trên storefront.</p>
    </div>

    <div class="row g-4">
      <!-- CỘT TRÁI: DANH SÁCH GAME -->
      <div class="col-lg-7">
        <div class="panel-box p-4 bg-white">
          <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
            <h4 class="fw-black m-0 d-flex align-items-center gap-2">
              <i data-lucide="gamepad-2" class="text-primary"></i>
              Danh Sách Trò Chơi
            </h4>
            
            <div class="position-relative" style="width: 250px;">
              <input type="text" id="searchGameInput" class="form-control border border-2 border-dark rounded-3 px-3 py-1.5 fw-bold" 
                     placeholder="Tìm tên game..." onkeyup="filterGames()" style="font-size: 13px;">
              <i data-lucide="search" class="position-absolute text-muted" style="right: 10px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;"></i>
            </div>
          </div>

          <div class="table-responsive" style="max-height: 550px; overflow-y: auto;">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th scope="col" style="width: 80px;">Ảnh</th>
                  <th scope="col">Tên game</th>
                  <th scope="col">Huy hiệu hiện tại</th>
                  <th scope="col" class="text-center" style="width: 130px;">Hành động</th>
                </tr>
              </thead>
              <tbody id="gameTableBody">
                <c:forEach var="game" items="${games}">
                  <tr data-game-id="${game.id}" data-game-title="${game.title}">
                    <td>
                      <c:choose>
                        <c:when test="${not empty game.mediaList}">
                          <c:choose>
                            <c:when test="${not empty game.mediaList && not fn:startsWith(game.mediaList[0].mediaUrl, 'http')}">
                              <img src="${pageContext.request.contextPath}${game.mediaList[0].mediaUrl}" alt="Cover" class="game-thumb-sm">
                            </c:when>
                            <c:otherwise>
                              <div class="d-flex align-items-center justify-content-center fw-bold text-center border border-2 border-black game-thumb-sm bg-light" style="width:40px; height:40px; font-size: 8px; line-height: 1.1;">
                                Chưa có hình ảnh
                              </div>
                            </c:otherwise>
                          </c:choose>
                        </c:when>
                        <c:otherwise>
                          <img src="" alt="Chưa có hình ảnh" alt="Cover" class="game-thumb-sm">
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <span class="fw-black d-block text-dark" style="font-size: 13px;">${game.title}</span>
                      <span class="small text-secondary gf-muted" style="font-size: 11px;">Slug: ${game.slug}</span>
                    </td>
                    <td>
                      <div class="d-flex flex-wrap gap-1">
                        <c:forEach var="bId" items="${fn:split(game.badges, ',')}">
                          <c:forEach var="b" items="${allBadges}">
                            <c:if test="${b.id == bId}">
                              <span class="badge-preview" style="background: ${b.color};">
                                <i data-lucide="${b.icon}" width="11" height="11"></i>
                                ${fn:replace(b.title, '%COUNT%', '')}
                              </span>
                            </c:if>
                          </c:forEach>
                        </c:forEach>
                      </div>
                    </td>
                    <td class="text-center">
                      <button type="button" class="btn btn-sm gf-border gf-shadow-sm gf-press fw-bold" 
                              style="background:var(--gf-pink); font-size:11px; border-radius: 6px; padding: 4px 10px;"
                              onclick="openAssignModal('${game.id}', '${fn:escapeXml(game.title)}', '${game.badges}')">
                        <i data-lucide="check-square" class="d-inline mb-0.5 me-1" width="12" height="12"></i> Gán huy hiệu
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- CỘT PHẢI: QUẢN LÝ HUY HIỆU TOÀN CỤC -->
      <div class="col-lg-5">
        <div class="panel-box p-4 bg-white mb-4">
          <div class="d-flex align-items-center justify-content-between mb-4">
            <h4 class="fw-black m-0 d-flex align-items-center gap-2">
              <i data-lucide="award" class="text-success"></i>
              Huy Hiệu Hệ Thống
            </h4>
            <button type="button" class="btn btn-sm gf-border gf-shadow-sm gf-press fw-black text-dark" 
                    style="background:var(--gf-green); font-size: 11px; border-radius:8px; padding:6px 12px;" onclick="showAddBadgeForm()">
              <i data-lucide="plus" class="d-inline mb-0.5 me-1" width="12" height="12"></i> TẠO HUY HIỆU MỚI
            </button>
          </div>

          <!-- Lịch sử danh sách huy hiệu hệ thống -->
          <div class="d-flex flex-column gap-2" style="max-height: 480px; overflow-y: auto;">
            <c:forEach var="b" items="${allBadges}">
              <div class="p-3 border border-2 border-dark rounded-3 d-flex align-items-center justify-content-between bg-light" style="box-shadow: 2px 2px 0 #000;">
                <div class="d-flex align-items-center gap-3">
                  <div class="gf-border-2 rounded p-2 d-grid place-items-center" style="background: ${b.color}; width: 36px; height: 36px;">
                    <i data-lucide="${b.icon}" width="16" height="16"></i>
                  </div>
                  <div>
                    <span class="fw-black text-dark d-block" style="font-size: 13px;">${b.title}</span>
                    <span class="small text-secondary gf-muted d-block" style="font-size: 10px;">
                      Loại: ${b.type == 'static' ? 'Tĩnh' : 'Động (Lượt tải)'} | ID: ${b.id}
                    </span>
                  </div>
                </div>

                <div class="d-flex gap-1">
                  <button type="button" class="btn btn-xs border border-2 border-dark bg-white gf-press p-1.5" style="border-radius: 6px;"
                          onclick="showEditBadgeForm('${b.id}', '${fn:escapeXml(b.title)}', '${b.icon}', '${b.color}', '${b.type}')" title="Sửa">
                    <i data-lucide="edit" width="12" height="12"></i>
                  </button>
                  <button type="button" class="btn btn-xs border border-2 border-dark bg-danger text-white gf-press p-1.5" style="border-radius: 6px;"
                          onclick="deleteBadge('${b.id}')" title="Xóa">
                    <i data-lucide="trash-2" width="12" height="12"></i>
                  </button>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>

        <!-- FORM THÊM / SỬA HUY HIỆU -->
        <div class="panel-box p-4 bg-white" id="badgeFormPanel" style="display: none;">
          <h4 class="fw-black mb-3 d-flex align-items-center gap-2" id="badgeFormTitle">
            <i data-lucide="plus-circle" class="text-success"></i>
            Định Nghĩa Huy Hiệu Mới
          </h4>
          
          <form id="gfBadgeActionForm" onsubmit="submitBadgeAction(event)">
            <input type="hidden" id="badgeId" name="id">
            <input type="hidden" id="badgeAction" value="add"> <!-- "add" hoặc "edit" -->

            <div class="mb-3">
              <label class="fw-bold text-dark small d-block mb-1">Tên Huy hiệu (Tự động định dạng %COUNT% nếu là động):</label>
              <input type="text" id="badgeTitle" name="title" class="form-control border border-2 border-dark fw-bold text-dark" placeholder="Ví dụ: Đáng Chơi" required>
            </div>

            <div class="row g-3 mb-3">
              <div class="col-sm-6">
                <label class="fw-bold text-dark small d-block mb-1">Tính chất huy hiệu:</label>
                <select id="badgeType" name="type" class="form-select border border-2 border-dark fw-bold text-dark" required>
                  <option value="static">Cố định (Tĩnh)</option>
                  <option value="dynamic_downloads">Động (Lượt mua từ CSDL)</option>
                </select>
              </div>
              <div class="col-sm-6">
                <label class="fw-bold text-dark small d-block mb-1">Màu nền RGB:</label>
                <div class="d-flex align-items-center gap-2">
                  <input type="color" id="badgeColor" name="color" class="form-control border border-2 border-dark" value="#94FFB4" style="height: 42px; width: 64px; padding: 4px; cursor: pointer; border-radius: 8px;">
                  <div class="d-flex gap-1 flex-wrap">
                    <button type="button" class="btn p-0 border border-2 border-dark rounded-circle" style="width:20px; height:20px; background:#94FFB4;" onclick="setPresetColor('#94FFB4')"></button>
                    <button type="button" class="btn p-0 border border-2 border-dark rounded-circle" style="width:20px; height:20px; background:#FFB5A7;" onclick="setPresetColor('#FFB5A7')"></button>
                    <button type="button" class="btn p-0 border border-2 border-dark rounded-circle" style="width:20px; height:20px; background:#FFFEE4;" onclick="setPresetColor('#FFFEE4')"></button>
                    <button type="button" class="btn p-0 border border-2 border-dark rounded-circle" style="width:20px; height:20px; background:#FDE047;" onclick="setPresetColor('#FDE047')"></button>
                    <button type="button" class="btn p-0 border border-2 border-dark rounded-circle" style="width:20px; height:20px; background:#E5E5FF;" onclick="setPresetColor('#E5E5FF')"></button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mb-3">
              <label class="fw-bold text-dark small d-block mb-2">Chọn Icon hiển thị:</label>
              <input type="hidden" id="badgeIcon" name="icon" value="shield-check" required>
              <div class="d-flex flex-wrap gap-2 p-2 border border-2 border-dark bg-white rounded-3" style="max-height: 110px; overflow-y: auto;" id="gfIconGrid">
                <c:forEach var="ic" items="${fn:split('shield-check,flame,download,trophy,award,star,thumbs-up,crown,sparkles,zap,heart,trending-up,gem,gamepad-2,gift,clock,activity,swords,ghost,rocket', ',')}">
                  <button type="button" class="icon-picker-btn ${ic == 'shield-check' ? 'active' : ''}" 
                          onclick="selectIcon('${ic}', this)" title="${ic}">
                    <i data-lucide="${ic}" width="16" height="16"></i>
                  </button>
                </c:forEach>
              </div>
            </div>

            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press text-white fw-bold px-4 py-2" style="background:#000;">
                XÁC NHẬN LƯU
              </button>
              <button type="button" class="btn btn-sm gf-border-2 gf-shadow-sm gf-press bg-white text-dark fw-bold px-4 py-2" onclick="hideBadgeForm()">
                HỦY BỎ
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </main>

  <!-- MODAL GÁN HUY HIỆU CHO GAME -->
  <div class="modal fade" id="assignBadgesModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content gf-border-2" style="border-radius:16px; border:3px solid #000; box-shadow:6px 6px 0 #000;">
        <div class="modal-header" style="background:var(--gf-pink); border-bottom:3px solid #000;">
          <h5 class="modal-title fw-black"><i data-lucide="tag" width="18" height="18" class="me-1"></i> Gán Huy Hiệu: <span id="assignGameTitle" class="text-decoration-underline"></span></h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="assignGameId">
          <p class="fw-bold text-secondary small mb-3">Tích chọn các huy hiệu hiển thị cho trò chơi này trên Store:</p>
          
          <div class="d-flex flex-column gap-2" id="assignBadgesList">
            <c:forEach var="b" items="${allBadges}">
              <div class="form-check border border-2 border-dark rounded px-3 py-2 bg-light d-flex align-items-center gap-2" style="cursor:pointer;">
                <input class="form-check-input border-dark" type="checkbox" name="gameBadgesCheck" value="${b.id}" id="chkModal-${b.id}" style="cursor:pointer; width:18px; height:18px;">
                <label class="form-check-label fw-bold text-dark small mb-0 d-flex align-items-center gap-2" for="chkModal-${b.id}" style="cursor:pointer;">
                  <i data-lucide="${b.icon}" width="14" height="14"></i>
                  ${b.title}
                </label>
              </div>
            </c:forEach>
          </div>
        </div>
        <div class="modal-footer border-top border-2 border-dark">
          <button type="button" class="btn gf-border gf-shadow-sm gf-press fw-bold" data-bs-dismiss="modal" style="border-radius:10px;">HỦY</button>
          <button type="button" class="btn gf-border gf-shadow-sm gf-press fw-bold text-dark" style="background:var(--gf-green); border-radius:10px;" onclick="saveGameBadges()">
            LƯU THAY ĐỔI
          </button>
        </div>
      </div>
    </div>
  </div>

  <footer class="bg-dark text-white border-top border-3 border-black py-4 mt-5">
    <div class="container-xl text-center small fw-semibold text-secondary">
      © 2026 GameForce Admin Dashboard
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    lucide.createIcons();

    // 1. TÌM KIẾM TRÒ CHƠI REAL-TIME
    void function() {
        window.filterGames = function() {
            const q = document.getElementById('searchGameInput').value.toLowerCase().trim();
            const rows = document.querySelectorAll('#gameTableBody tr');
            rows.forEach(row => {
                const title = row.getAttribute('data-game-title').toLowerCase();
                if (title.includes(q)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
    }();

    // Presets colors
    window.setPresetColor = function(color) {
        document.getElementById('badgeColor').value = color;
    }

    // Lucide Icon selector
    window.selectIcon = function(iconName, btn) {
        document.getElementById('badgeIcon').value = iconName;
        document.querySelectorAll('#gfIconGrid .icon-picker-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
    }

    // Show Forms
    window.showAddBadgeForm = function() {
        document.getElementById('badgeAction').value = 'add';
        document.getElementById('badgeFormTitle').innerHTML = '<i data-lucide="plus-circle" class="text-success"></i> Định Nghĩa Huy Hiệu Mới';
        document.getElementById('badgeId').value = '';
        document.getElementById('badgeTitle').value = '';
        document.getElementById('badgeType').value = 'static';
        document.getElementById('badgeColor').value = '#94FFB4';
        document.getElementById('badgeIcon').value = 'shield-check';
        
        document.querySelectorAll('#gfIconGrid .icon-picker-btn').forEach(b => b.classList.remove('active'));
        const defaultBtn = Array.from(document.querySelectorAll('#gfIconGrid .icon-picker-btn')).find(b => b.title === 'shield-check');
        if (defaultBtn) defaultBtn.classList.add('active');
        
        document.getElementById('badgeFormPanel').style.display = 'block';
        document.getElementById('badgeFormPanel').scrollIntoView({ behavior: 'smooth' });
        lucide.createIcons();
    }

    window.showEditBadgeForm = function(id, title, icon, color, type) {
        document.getElementById('badgeAction').value = 'edit';
        document.getElementById('badgeFormTitle').innerHTML = '<i data-lucide="edit" class="text-primary"></i> Sửa Huy Hiệu: ' + id;
        document.getElementById('badgeId').value = id;
        document.getElementById('badgeTitle').value = title;
        document.getElementById('badgeType').value = type;
        document.getElementById('badgeColor').value = color.startsWith('#') ? color : '#94FFB4'; // fallback if variable
        document.getElementById('badgeIcon').value = icon;
        
        document.querySelectorAll('#gfIconGrid .icon-picker-btn').forEach(b => b.classList.remove('active'));
        const activeBtn = Array.from(document.querySelectorAll('#gfIconGrid .icon-picker-btn')).find(b => b.title === icon);
        if (activeBtn) activeBtn.classList.add('active');
        
        document.getElementById('badgeFormPanel').style.display = 'block';
        document.getElementById('badgeFormPanel').scrollIntoView({ behavior: 'smooth' });
        lucide.createIcons();
    }

    window.hideBadgeForm = function() {
        document.getElementById('badgeFormPanel').style.display = 'none';
    }

    // Submit Add/Edit Badge
    window.submitBadgeAction = function(event) {
        event.preventDefault();
        const action = document.getElementById('badgeAction').value;
        const id = document.getElementById('badgeId').value;
        const title = document.getElementById('badgeTitle').value;
        const icon = document.getElementById('badgeIcon').value;
        const color = document.getElementById('badgeColor').value;
        const type = document.getElementById('badgeType').value;

        const csrfToken = window.GAMEFORGE_CSRF_TOKEN || "";
        const csrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";

        let url = window.GAMEFORGE_CONTEXT_PATH + '/api/admin/create-badge';
        let body = "title=" + encodeURIComponent(title) + 
                   "&icon=" + encodeURIComponent(icon) + 
                   "&color=" + encodeURIComponent(color) + 
                   "&type=" + encodeURIComponent(type);

        if (action === 'edit') {
            url = window.GAMEFORGE_CONTEXT_PATH + '/api/admin/edit-badge';
            body += "&id=" + encodeURIComponent(id);
        }
        if (csrfToken) body += "&" + encodeURIComponent(csrfHeader) + "=" + encodeURIComponent(csrfToken);

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8', [csrfHeader]: csrfToken },
            body: body
        })
        .then(res => res.text())
        .then(text => {
            if (text.startsWith("ERROR")) {
                alert(text);
            } else {
                alert(action === 'edit' ? "Cập nhật huy hiệu thành công!" : "Tạo huy hiệu thành công!");
                window.location.reload();
            }
        })
        .catch(err => alert("Lỗi mạng: " + err));
    }

    // Delete Badge
    window.deleteBadge = function(id) {
        if (!confirm("Bạn có chắc chắn muốn xóa huy hiệu '" + id + "' khỏi hệ thống? Việc này không thể hoàn tác!")) {
            return;
        }
        const csrfToken = window.GAMEFORGE_CSRF_TOKEN || "";
        const csrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";

        let body = "id=" + encodeURIComponent(id);
        if (csrfToken) body += "&" + encodeURIComponent(csrfHeader) + "=" + encodeURIComponent(csrfToken);

        fetch(window.GAMEFORGE_CONTEXT_PATH + '/api/admin/delete-badge', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8', [csrfHeader]: csrfToken },
            body: body
        })
        .then(res => res.text())
        .then(text => {
            if (text.startsWith("ERROR")) {
                alert(text);
            } else {
                alert("Đã xóa huy hiệu khỏi hệ thống!");
                window.location.reload();
            }
        })
        .catch(err => alert("Lỗi mạng: " + err));
    }

    // Modal Operations
    let assignModal;
    window.openAssignModal = function(gameId, gameTitle, currentBadgesStr) {
        document.getElementById('assignGameId').value = gameId;
        document.getElementById('assignGameTitle').innerText = gameTitle;
        
        // Reset check boxes
        const checkedList = currentBadgesStr.split(',');
        document.querySelectorAll("input[name='gameBadgesCheck']").forEach(cb => {
            cb.checked = checkedList.includes(cb.value);
        });

        if (!assignModal) {
            assignModal = new bootstrap.Modal(document.getElementById('assignBadgesModal'));
        }
        assignModal.show();
    }

    window.saveGameBadges = function() {
        const gameId = document.getElementById('assignGameId').value;
        const checkedBoxes = document.querySelectorAll("input[name='gameBadgesCheck']:checked");
        const badgeIds = Array.from(checkedBoxes).map(cb => cb.value).join(",");

        const csrfToken = window.GAMEFORGE_CSRF_TOKEN || "";
        const csrfHeader = window.GAMEFORGE_CSRF_HEADER || "_csrf";

        let body = "gameId=" + encodeURIComponent(gameId) + "&badges=" + encodeURIComponent(badgeIds);
        if (csrfToken) body += "&" + encodeURIComponent(csrfHeader) + "=" + encodeURIComponent(csrfToken);

        fetch(window.GAMEFORGE_CONTEXT_PATH + '/api/admin/save-game-badges', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8', [csrfHeader]: csrfToken },
            body: body
        })
        .then(res => res.text())
        .then(text => {
            if (text.startsWith("ERROR")) {
                alert(text);
            } else {
                alert("Đã lưu các tích chọn huy hiệu của game thành công!");
                window.location.reload();
            }
        })
        .catch(err => alert("Lỗi mạng: " + err));
    }
  </script>
</body>
</html>
