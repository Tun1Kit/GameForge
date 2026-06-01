package com.gamestore.service;

import com.gamestore.dao.PayoutRequestDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.PublisherProfile;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class PayoutService {

    @Autowired
    private PayoutRequestDAO payoutRequestDAO;

    @Autowired
    private PublisherProfileDAO publisherProfileDAO;

    @Autowired
    private WalletService walletService;

    public List<PayoutRequest> getAllRequests() {
        return payoutRequestDAO.findAllOrderByNewest();
    }

    public List<PayoutRequest> getRequestsByPublisherUser(Long userId) {
        PublisherProfile profile = publisherProfileDAO.findByUserId(userId);
        if (profile == null) {
            throw new IllegalArgumentException("Không tìm thấy hồ sơ Publisher.");
        }
        return payoutRequestDAO.findByPublisherId(profile.getId());
    }

    public void createPayoutRequest(User publisherUser, BigDecimal amount, String bankAccountInfo) {
        validateAmount(amount);
        if (publisherUser == null || !publisherUser.hasRole("ROLE_PUBLISHER")) {
            throw new IllegalArgumentException("Chỉ Publisher mới được tạo yêu cầu payout.");
        }
        PublisherProfile profile = publisherProfileDAO.findByUserId(publisherUser.getId());
        if (profile == null) {
            throw new IllegalArgumentException("Tài khoản chưa có Publisher Profile.");
        }
        Wallet wallet = walletService.getOrCreateWallet(publisherUser);
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("Số dư ví không đủ để tạo yêu cầu rút tiền.");
        }

        PayoutRequest request = new PayoutRequest();
        request.setPublisher(profile);
        request.setAmount(amount);
        request.setBankAccountInfo(bankAccountInfo);
        request.setStatus("PENDING");

        payoutRequestDAO.save(request);
    }

    public void approvePayout(Long requestId) {
        PayoutRequest request = payoutRequestDAO.findById(requestId);
        if (request == null) throw new IllegalArgumentException("Không tìm thấy yêu cầu payout.");
        if (!"PENDING".equals(request.getStatus())) throw new IllegalArgumentException("Yêu cầu payout này đã được xử lý.");

        User publisherUser = request.getPublisher().getUser();
        walletService.payoutToPublisher(publisherUser, request.getAmount(), "PAYOUT_" + request.getId());

        request.setStatus("PAID");
        request.setProcessedAt(LocalDateTime.now());
        payoutRequestDAO.update(request);
    }

    public void rejectPayout(Long requestId) {
        PayoutRequest request = payoutRequestDAO.findById(requestId);
        if (request == null) throw new IllegalArgumentException("Không tìm thấy yêu cầu payout.");
        if (!"PENDING".equals(request.getStatus())) throw new IllegalArgumentException("Yêu cầu payout này đã được xử lý.");

        request.setStatus("REJECTED");
        request.setProcessedAt(LocalDateTime.now());
        payoutRequestDAO.update(request);
    }

    private void validateAmount(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền payout phải lớn hơn 0.");
        }
    }
}
