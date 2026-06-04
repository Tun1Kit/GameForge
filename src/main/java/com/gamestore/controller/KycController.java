package com.gamestore.controller;

import com.gamestore.entity.KycRequest;
import com.gamestore.entity.User;
import com.gamestore.service.KycService;
import com.gamestore.service.UserContextService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.util.UUID;

@Controller
public class KycController {

    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    @Autowired
    private KycService kycService;

    @Autowired
    private UserContextService userContextService;

    @GetMapping("/kyc")
    public String kycPage(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        KycRequest latestRequest = kycService.getLatestRequestByUser(currentUser.getId());

        String currentKycStatus = "NONE";
        if (latestRequest != null && latestRequest.getStatus() != null) {
            currentKycStatus = latestRequest.getStatus();
        }

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("latestRequest", latestRequest);
        model.addAttribute("currentKycStatus", currentKycStatus);

        return "kyc/index";
    }

    @PostMapping("/kyc/submit")
    public String submitKyc(@RequestParam(value = "taxId", required = false) String taxId,
                            @RequestParam(value = "documentFile", required = false) MultipartFile documentFile,
                            HttpSession session) {

        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        try {
            KycRequest latestRequest = kycService.getLatestRequestByUser(currentUser.getId());

            if (latestRequest != null && "PENDING".equalsIgnoreCase(latestRequest.getStatus())) {
                session.setAttribute("kycError", "Bạn đã có một yêu cầu KYC đang chờ duyệt.");
                return "redirect:/kyc";
            }

            if (latestRequest != null && "APPROVED".equalsIgnoreCase(latestRequest.getStatus())) {
                session.setAttribute("kycError", "Tài khoản của bạn đã được duyệt KYC.");
                return "redirect:/kyc";
            }

            if (taxId == null || taxId.trim().isEmpty()) {
                session.setAttribute("kycError", "Vui lòng nhập số giấy tờ.");
                return "redirect:/kyc";
            }

            if (taxId.trim().length() < 6) {
                session.setAttribute("kycError", "Số giấy tờ phải có ít nhất 6 ký tự.");
                return "redirect:/kyc";
            }

            if (documentFile == null || documentFile.isEmpty()) {
                session.setAttribute("kycError", "Vui lòng upload ảnh giấy tờ KYC.");
                return "redirect:/kyc";
            }

            validateDocumentFile(documentFile);

            String documentUrl = saveDocumentFile(documentFile, session);

            kycService.submitRequest(currentUser, taxId.trim(), documentUrl);

            session.setAttribute("kycSuccess", "Gửi hồ sơ KYC thành công. Vui lòng chờ Admin duyệt.");
            return "redirect:/kyc";

        } catch (Exception e) {
            session.setAttribute("kycError", e.getMessage());
            return "redirect:/kyc";
        }
    }

    private void validateDocumentFile(MultipartFile file) {
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File quá lớn. Dung lượng tối đa là 5MB.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Chỉ hỗ trợ file ảnh JPG, JPEG hoặc PNG.");
        }

        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên file không hợp lệ.");
        }

        String lowerName = originalName.toLowerCase();

        if (!lowerName.endsWith(".jpg")
                && !lowerName.endsWith(".jpeg")
                && !lowerName.endsWith(".png")) {
            throw new IllegalArgumentException("Chỉ hỗ trợ file .jpg, .jpeg hoặc .png.");
        }
    }

    private String saveDocumentFile(MultipartFile file, HttpSession session) throws Exception {
        String uploadDirPath = session.getServletContext().getRealPath("/uploads/kyc");

        File uploadDir = new File(uploadDirPath);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String originalName = file.getOriginalFilename();
        String extension = "";

        if (originalName != null && originalName.contains(".")) {
            extension = originalName.substring(originalName.lastIndexOf("."));
        }

        String fileName = "kyc_" + UUID.randomUUID().toString() + extension;
        File destination = new File(uploadDir, fileName);

        file.transferTo(destination);

        return "/uploads/kyc/" + fileName;
    }
}