package com.gamestore.interceptor;

import com.gamestore.entity.User;
import com.gamestore.dao.NotificationDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AuthInterceptor implements HandlerInterceptor {

    @Autowired
    private NotificationDAO notificationDAO;

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser != null) {
            long unreadCount = 0;
            if (currentUser.hasRole("ROLE_ADMIN")) {
                unreadCount = notificationDAO.countUnreadForAdmins();
            } else if (currentUser.hasRole("ROLE_PUBLISHER")) {
                unreadCount = notificationDAO.countUnreadByUser(currentUser.getId());
            }
            request.setAttribute("unreadNotificationCount", unreadCount);
        }

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
