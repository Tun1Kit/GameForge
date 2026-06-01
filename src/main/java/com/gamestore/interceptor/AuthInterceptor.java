package com.gamestore.interceptor;

import com.gamestore.entity.User;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();

        User currentUser = (User) request.getSession().getAttribute("currentUser");

        if (isLoginRequired(uri, contextPath)) {
            if (currentUser == null) {
                response.sendRedirect(contextPath + "/login");
                return false;
            }
        }

        if (uri.startsWith(contextPath + "/admin")) {
            if (currentUser == null) {
                response.sendRedirect(contextPath + "/login");
                return false;
            }
            if (!currentUser.hasRole("ROLE_ADMIN")) {
                response.sendRedirect(contextPath + "/access-denied");
                return false;
            }
        }

        if (uri.startsWith(contextPath + "/publisher")) {
            if (currentUser == null) {
                response.sendRedirect(contextPath + "/login");
                return false;
            }
            boolean isPublisher = currentUser.hasRole("ROLE_PUBLISHER");
            boolean isAdmin = currentUser.hasRole("ROLE_ADMIN");
            if (!isPublisher && !isAdmin) {
                response.sendRedirect(contextPath + "/access-denied");
                return false;
            }
        }

        return true;
    }

    private boolean isLoginRequired(String uri, String contextPath) {
        return uri.startsWith(contextPath + "/wallet")
                || uri.startsWith(contextPath + "/kyc")
                || uri.startsWith(contextPath + "/cart")
                || uri.startsWith(contextPath + "/checkout")
                || uri.startsWith(contextPath + "/library")
                || uri.startsWith(contextPath + "/orders");
    }
}
