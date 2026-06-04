package com.gamestore.service;

import com.gamestore.dao.KycRequestDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.dao.RoleDAO;
import com.gamestore.dao.UserDAO;
import com.gamestore.entity.KycRequest;
import com.gamestore.entity.Notification;
import com.gamestore.entity.PublisherProfile;
import com.gamestore.entity.Role;
import com.gamestore.entity.User;
import com.gamestore.dao.NotificationDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class KycService {

    @Autowired
    private KycRequestDAO kycRequestDAO;

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private RoleDAO roleDAO;

    @Autowired
    private PublisherProfileDAO publisherProfileDAO;

    @Autowired
    private NotificationDAO notificationDAO;

    @Transactional(readOnly = true)
    public KycRequest getLatestRequestByUser(Long userId) {
        return kycRequestDAO.findLatestByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<KycRequest> getAllRequests() {
        return kycRequestDAO.findAllOrderByNewest();
    }

    @Transactional(readOnly = true)
    public List<KycRequest> getPendingRequests() {
        return kycRequestDAO.findPendingRequests();
    }

    @Transactional(readOnly = true)
    public List<KycRequest> getRequestsByStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return kycRequestDAO.findAllOrderByNewest();
        }

        return kycRequestDAO.findByStatusOrderByNewest(status.trim());
    }

    public void submitRequest(User user, String taxId, String documentUrl) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("Không tìm thấy người dùng hiện tại.");
        }

        if (taxId == null || taxId.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập số giấy tờ.");
        }

        if (documentUrl == null || documentUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng upload giấy tờ KYC.");
        }

        KycRequest latestRequest = getLatestRequestByUser(user.getId());

        if (latestRequest != null && "PENDING".equalsIgnoreCase(latestRequest.getStatus())) {
            throw new IllegalStateException("Bạn đã có một yêu cầu KYC đang chờ duyệt.");
        }

        if (latestRequest != null && "APPROVED".equalsIgnoreCase(latestRequest.getStatus())) {
            throw new IllegalStateException("Tài khoản của bạn đã được duyệt KYC.");
        }

        KycRequest request = new KycRequest();
        request.setUser(user);
        request.setTaxId(taxId.trim());
        request.setDocumentUrl(documentUrl);
        request.setStatus("PENDING");
        request.setSubmittedAt(LocalDateTime.now());

        kycRequestDAO.save(request);

        // Notify Admins
        Notification notif = new Notification();
        notif.setTitle("Yêu cầu KYC mới");
        notif.setContent("Người dùng @" + user.getUsername() + " (" + user.getFullName() + ") đã nộp hồ sơ KYC.");
        notif.setType("KYC");
        notif.setTargetUrl("/admin/kyc");
        notif.setUser(null); // Admin wide
        notificationDAO.save(notif);
    }

    public void approveRequest(Long requestId) {
        KycRequest request = kycRequestDAO.findById(requestId);

        if (request == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu KYC.");
        }

        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new IllegalArgumentException("Yêu cầu này đã được xử lý.");
        }

        User user = userDAO.findById(request.getUser().getId());

        if (user == null) {
            throw new IllegalArgumentException("Không tìm thấy tài khoản gửi KYC.");
        }

        Role publisherRole = roleDAO.findByCode("ROLE_PUBLISHER");

        if (publisherRole == null) {
            throw new IllegalArgumentException("Database chưa có ROLE_PUBLISHER.");
        }

        if (!user.hasRole("ROLE_PUBLISHER")) {
            user.getRoles().add(publisherRole);
            userDAO.update(user);
        }

        PublisherProfile profile = publisherProfileDAO.findByUserId(user.getId());

        if (profile == null) {
            profile = new PublisherProfile();
            profile.setUser(user);
            profile.setCompanyName(user.getFullName());
            profile.setSupportEmail(user.getEmail());
            publisherProfileDAO.save(profile);
        }

        request.setStatus("APPROVED");
        request.setProcessedAt(LocalDateTime.now());

        kycRequestDAO.update(request);

        // Notify User
        Notification notif = new Notification();
        notif.setTitle("Hồ sơ KYC được phê duyệt");
        notif.setContent("Chúc mừng! Hồ sơ KYC của bạn đã được phê duyệt thành công. Bạn hiện là Nhà phát hành.");
        notif.setType("KYC");
        notif.setTargetUrl("/publisher/dashboard");
        notif.setUser(user);
        notificationDAO.save(notif);
    }

    public void rejectRequest(Long requestId) {
        KycRequest request = kycRequestDAO.findById(requestId);

        if (request == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu KYC.");
        }

        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new IllegalArgumentException("Yêu cầu này đã được xử lý.");
        }

        request.setStatus("REJECTED");
        request.setProcessedAt(LocalDateTime.now());

        kycRequestDAO.update(request);

        // Notify User
        Notification notif = new Notification();
        notif.setTitle("Hồ sơ KYC bị từ chối");
        notif.setContent("Hồ sơ KYC của bạn đã bị từ chối. Vui lòng kiểm tra lại thông tin và gửi lại yêu cầu mới.");
        notif.setType("KYC");
        notif.setTargetUrl("/kyc");
        notif.setUser(request.getUser());
        notificationDAO.save(notif);
    }
}