package com.gamestore.config;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.NoHandlerFoundException;

import javax.servlet.http.HttpServletRequest;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler({
        Exception.class,
        org.springframework.dao.DataIntegrityViolationException.class,
        org.hibernate.exception.ConstraintViolationException.class,
        org.springframework.transaction.TransactionSystemException.class
    })
    @ResponseBody
    public ResponseEntity<Map<String, Object>> handleApiException(
            Exception ex, HttpServletRequest request) {

        Map<String, Object> response = new HashMap<>();
        response.put("success", false);

        if (ex instanceof org.springframework.dao.DataIntegrityViolationException) {
            response.put("message", "Lỗi dữ liệu: thông tin không hợp lệ hoặc trùng lặp.");
        } else if (ex instanceof org.hibernate.exception.ConstraintViolationException) {
            response.put("message", "Lỗi ràng buộc database.");
        } else {
            response.put("message", "Lỗi máy chủ: " + ex.getMessage());
        }

        StringWriter sw = new StringWriter();
        ex.printStackTrace(new PrintWriter(sw));
        System.err.println("[GlobalExceptionHandler] " + request.getRequestURI() + " -> " + sw);

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> handleNoHandler(NoHandlerFoundException ex) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", "Endpoint không tồn tại.");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
}
