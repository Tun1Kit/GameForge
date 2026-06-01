package com.gamestore.service;

import com.gamestore.dao.KycRequestDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.dao.RoleDAO;
import com.gamestore.dao.UserDAO;
import com.gamestore.entity.KycRequest;
import com.gamestore.entity.PublisherProfile;
import com.gamestore.entity.Role;
import com.gamestore.entity.User;
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

    public KycRequest getLatestRequestByUser(Long userId) {
        return kycRequestDAO.findLatestByUserId(userId);
    }

    public List<KycRequest> getAllRequests() {
        return kycRequestDAO.findAllOrderByNewest();
    }

    public void submitRequest(User user, String taxId, String documentUrl) {
        KycRequest latest = kycRequestDAO.findLatestByUserId(user.getId());
        if (latest != null && "PENDING".equals(latest.getStatus())) {
            throw new IllegalArgumentException("Bạn đã có một yêu cầu KYC đang chờ duyệt.");
        }
        if (user.hasRole("ROLE_PUBLISHER")) {
            throw new IllegalArgumentException("Tài khoản của bạn đã là Publisher.");
        }

        KycRequest request = new KycRequest();
        request.setUser(user);
        request.setTaxId(taxId);
        request.setDocumentUrl(documentUrl);
        request.setStatus("PENDING");

        kycRequestDAO.save(request);
    }

    public void approveRequest(Long requestId) {
        KycRequest request = kycRequestDAO.findById(requestId);
        if (request == null) throw new IllegalArgumentException("Không tìm thấy yêu cầu KYC.");
        if (!"PENDING".equals(request.getStatus())) throw new IllegalArgumentException("Yêu cầu này đã được xử lý.");

        User user = userDAO.findById(request.getUser().getId());
        Role publisherRole = roleDAO.findByCode("ROLE_PUBLISHER");
        if (publisherRole == null) throw new IllegalArgumentException("Database chưa có ROLE_PUBLISHER.");

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
    }

    public void rejectRequest(Long requestId) {
        KycRequest request = kycRequestDAO.findById(requestId);
        if (request == null) throw new IllegalArgumentException("Không tìm thấy yêu cầu KYC.");
        if (!"PENDING".equals(request.getStatus())) throw new IllegalArgumentException("Yêu cầu này đã được xử lý.");

        request.setStatus("REJECTED");
        request.setProcessedAt(LocalDateTime.now());
        kycRequestDAO.update(request);
    }
}
