package com.gamestore.controller;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.nio.file.Files;

@Controller
public class KycFileController {

    @GetMapping("/uploads/kyc/{fileName:.+}")
    public ResponseEntity<Resource> viewKycFile(@PathVariable("fileName") String fileName,
                                                HttpSession session) {
        try {
            String uploadDirPath = session.getServletContext().getRealPath("/uploads/kyc");
            File file = new File(uploadDirPath, fileName);

            if (!file.exists() || !file.isFile()) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(file);

            String contentType = Files.probeContentType(file.toPath());
            if (contentType == null) {
                contentType = "application/octet-stream";
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            ContentDisposition.inline()
                                    .filename(file.getName())
                                    .build()
                                    .toString())
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}