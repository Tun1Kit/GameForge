package com.gamestore.service;

import com.gamestore.entity.Order;
import com.gamestore.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.internet.MimeMessage;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class EmailService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${email.enabled:false}")
    private boolean emailEnabled;

    // ===== OTP EMAIL =====

    public void sendOtpEmail(String toEmail, String otp) {
        String html = buildOtpEmailHTML(otp);

        if (!emailEnabled || mailSender == null) {
            System.out.println("==================================================");
            System.out.println("=== OTP EMAIL MOCK TO: " + toEmail + " ===");
            System.out.println("Mã OTP của bạn: " + otp);
            System.out.println("==================================================");
            System.out.println("[DEV] Email disabled - OTP printed to console.");
            return;
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(toEmail);
            helper.setSubject("GameForge - Mã xác thực OTP");
            helper.setText(html, true);
            helper.setFrom("noreply@gamestore.com");
            mailSender.send(message);
            System.out.println("[EmailService] OTP sent successfully to: " + toEmail);
        } catch (Exception e) {
            System.err.println("[EmailService] Gửi email OTP thất bại: " + e.getMessage());
            throw new RuntimeException("Không gửi được email OTP", e);
        }
    }

    private String buildOtpEmailHTML(String otp) {
        StringBuilder sb = new StringBuilder();
        sb.append("<div style='font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 3px solid #000000; padding: 30px; box-shadow: 6px 6px 0px #000000; background-color: #FFFDF8;'>");
        sb.append("<div style='background-color: #2ECC71; border-bottom: 3px solid #000000; padding: 15px; text-align: center;'>");
        sb.append("<h1 style='margin: 0; font-size: 24px; color: #000000; font-weight: 900;'>GAMEFORGE</h1>");
        sb.append("</div>");
        sb.append("<div style='padding: 20px 0; text-align: center;'>");
        sb.append("<p style='font-size: 16px;'>Xin chào,</p>");
        sb.append("<p style='font-size: 14px; color: #71717A;'>Mã xác thực OTP của bạn là:</p>");
        sb.append("<div style='background: #FDE047; border: 3px solid #000; padding: 15px 30px; display: inline-block; margin: 15px 0; box-shadow: 3px 3px 0 #000;'>");
        sb.append("<span style='font-size: 32px; font-weight: 900; letter-spacing: 8px; color: #000;'>").append(otp).append("</span>");
        sb.append("</div>");
        sb.append("<p style='font-size: 12px; color: #71717A;'>Mã này có hiệu lực trong <strong>5 phút</strong>.</p>");
        sb.append("<p style='font-size: 12px; color: #71717A;'>Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>");
        sb.append("</div>");
        sb.append("<div style='border-top: 2px solid #000; padding-top: 15px; font-size: 11px; color: #71717A; text-align: center;'>");
        sb.append("© 2026 GameForge. Không chia sẻ mã OTP với bất kỳ ai.");
        sb.append("</div>");
        sb.append("</div>");
        return sb.toString();
    }

    // ===== ORDER CONFIRMATION EMAIL =====

    public void sendOrderConfirmation(User user, Order order, List<Map<String, Object>> keys) {
        String html = buildOrderEmailHTML(user, order, keys);
        
        if (!emailEnabled || mailSender == null) {
            System.out.println("==================================================");
            System.out.println("=== EMAIL MOCK SENT TO: " + user.getEmail() + " ===");
            System.out.println("Subject: [GameForge] Xác nhận đơn hàng #" + order.getId());
            System.out.println("Content:\n" + html);
            System.out.println("==================================================");
            return;
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(user.getEmail());
            helper.setSubject("GameForge - Xác nhận đơn hàng #" + order.getId());
            helper.setText(html, true);
            helper.setFrom("noreply@gamestore.com");
            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("Gửi email thất bại: " + e.getMessage());
        }
    }

    private String buildOrderEmailHTML(User user, Order order, List<Map<String, Object>> keys) {
        NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        
        StringBuilder sb = new StringBuilder();
        sb.append("<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 3px solid #000000; padding: 20px; box-shadow: 6px 6px 0px #000000; background-color: #FFFDF8;'>");
        sb.append("<div style='background-color: #2ECC71; border-bottom: 3px solid #000000; padding: 15px; text-align: center;'>");
        sb.append("<h1 style='margin: 0; font-size: 24px; color: #000000; font-weight: 900; letter-spacing: 1px;'>GAMEFORGE STORE</h1>");
        sb.append("</div>");
        
        sb.append("<div style='padding: 20px 0;'>");
        sb.append("<p style='font-size: 16px; font-weight: bold;'>Chào ").append(user.getFullName()).append(",</p>");
        sb.append("<p>Cảm ơn bạn đã mua hàng tại GameForge! Đơn hàng của bạn đã được thanh toán thành công. Dưới đây là thông tin chi tiết hóa đơn:</p>");
        sb.append("</div>");
        
        sb.append("<div style='border: 2px solid #000000; background-color: #ffffff; padding: 15px; margin-bottom: 20px; box-shadow: 3px 3px 0px #000000;'>");
        sb.append("<p style='margin: 0 0 8px 0;'><strong>Mã đơn hàng:</strong> #").append(order.getId()).append("</p>");
        sb.append("<p style='margin: 0 0 8px 0;'><strong>Thời gian:</strong> ").append(order.getCreatedAt().format(dtf)).append("</p>");
        sb.append("<p style='margin: 0 0 8px 0;'><strong>Phương thức thanh toán:</strong> ").append(order.getPaymentMethod()).append("</p>");
        sb.append("<p style='margin: 0;'><strong>Trạng thái:</strong> <span style='background-color: #2ECC71; color: #000000; padding: 2px 8px; border: 1.5px solid #000000; font-weight: bold; font-size: 12px; border-radius: 4px;'>ĐÃ THANH TOÁN</span></p>");
        sb.append("</div>");
        
        sb.append("<h3 style='border-bottom: 2px solid #000000; padding-bottom: 5px; margin-top: 25px;'>SẢN PHẨM & MÃ KÍCH HOẠT (LICENSE KEY)</h3>");
        sb.append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
        sb.append("<thead>");
        sb.append("<tr style='background-color: #FDE047; border: 2px solid #000000;'>");
        sb.append("<th style='border: 2px solid #000000; padding: 10px; text-align: left;'>Tên Game</th>");
        sb.append("<th style='border: 2px solid #000000; padding: 10px; text-align: center; width: 180px;'>Mã kích hoạt (Key)</th>");
        sb.append("<th style='border: 2px solid #000000; padding: 10px; text-align: right; width: 100px;'>Thành Tiền</th>");
        sb.append("</tr>");
        sb.append("</thead>");
        sb.append("<tbody>");
        
        for (Map<String, Object> key : keys) {
            String title = (String) key.get("gameTitle");
            String keyStr = (String) key.get("keyString");
            sb.append("<tr>");
            sb.append("<td style='border: 2px solid #000000; padding: 10px; font-weight: bold;'>").append(title).append("</td>");
            sb.append("<td style='border: 2px solid #000000; padding: 10px; text-align: center; font-family: monospace; font-size: 14px; background-color: #E5E5FF; font-weight: bold;'>").append(keyStr).append("</td>");
            sb.append("<td style='border: 2px solid #000000; padding: 10px; text-align: right;'>Đã bao gồm</td>");
            sb.append("</tr>");
        }
        
        sb.append("</tbody>");
        sb.append("</table>");
        
        sb.append("<div style='border-top: 3px dashed #000000; padding-top: 15px; text-align: right; font-size: 16px; font-weight: bold;'>");
        sb.append("Tổng thanh toán: <span style='color: #2ECC71; font-size: 20px; font-weight: 900;'>").append(nf.format(order.getTotalAmount())).append("đ</span>");
        sb.append("</div>");
        
        sb.append("<div style='margin-top: 30px; border-top: 2px solid #000000; padding-top: 15px; font-size: 12px; color: #71717A; text-align: center;'>");
        sb.append("<p>Mọi thắc mắc vui lòng liên hệ bộ phận hỗ trợ khách hàng của GameForge.</p>");
        sb.append("<p>© 2026 GameForge. Hóa đơn điện tử tự động.</p>");
        sb.append("</div>");
        sb.append("</div>");
        
        return sb.toString();
    }
}
