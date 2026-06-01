package com.gamestore.controller;

import com.gamestore.entity.KycRequest;
import com.gamestore.entity.User;
import com.gamestore.service.KycService;
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

    @Autowired
    private KycService kycService;

    @GetMapping("/kyc")
    public String kycPage(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";
        KycRequest latestRequest = kycService.getLatestRequestByUser(currentUser.getId());
        model.addAttribute("latestRequest", latestRequest);
        return "kyc/index";
    }

    @PostMapping("/kyc/submit")
    public String submitKyc(@RequestParam("taxId") String taxId,
                            @RequestParam("documentFile") MultipartFile documentFile,
                            HttpSession session,
                            Model model) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        try {
            if (documentFile == null || documentFile.isEmpty()) {
                throw new IllegalArgumentException("Vui lòng upload giấy tờ KYC.");
            }
            String documentUrl = saveDocumentFile(documentFile, session);
            kycService.submitRequest(currentUser, taxId, documentUrl);
            return "redirect:/kyc?success=submitted";
        } catch (Exception e) {
            KycRequest latestRequest = kycService.getLatestRequestByUser(currentUser.getId());
            model.addAttribute("latestRequest", latestRequest);
            model.addAttribute("error", e.getMessage());
            return "kyc/index";
        }
    }

    private String saveDocumentFile(MultipartFile file, HttpSession session) throws Exception {
        String uploadDirPath = session.getServletContext().getRealPath("/uploads/kyc");
        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

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
