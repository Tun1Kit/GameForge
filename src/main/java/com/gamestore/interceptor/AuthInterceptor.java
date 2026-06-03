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

        boolean adminPath = isAdminPath(uri, contextPath);
        boolean publisherPath = isPublisherPath(uri, contextPath);
        boolean userOnlyPath = isUserOnlyPath(uri, contextPath);

        if (currentUser == null && (adminPath || publisherPath || userOnlyPath)) {
            response.sendRedirect(contextPath + "/login");
            return false;
        }

        if (currentUser == null) {
            return true;
        }

        boolean isAdmin = currentUser.hasRole("ROLE_ADMIN");
        boolean isPublisher = currentUser.hasRole("ROLE_PUBLISHER");
        boolean isUser = currentUser.hasRole("ROLE_USER");

        if (adminPath && !isAdmin) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        if (publisherPath && !isPublisher) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        if (userOnlyPath && (isAdmin || isPublisher || !isUser)) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        return true;
    }

    private boolean isAdminPath(String uri, String contextPath) {
        return uri.startsWith(contextPath + "/admin");
    }

    private boolean isPublisherPath(String uri, String contextPath) {
        return uri.startsWith(contextPath + "/publisher");
    }

    private boolean isUserOnlyPath(String uri, String contextPath) {
        return uri.equals(contextPath + "/dashboard")
                || uri.startsWith(contextPath + "/dashboard/")
                || uri.equals(contextPath + "/kyc")
                || uri.startsWith(contextPath + "/kyc/")
                || uri.equals(contextPath + "/cart")
                || uri.startsWith(contextPath + "/cart/")
                || uri.equals(contextPath + "/checkout")
                || uri.startsWith(contextPath + "/checkout/")
                || uri.equals(contextPath + "/library")
                || uri.startsWith(contextPath + "/library/")
                || uri.equals(contextPath + "/orders")
                || uri.startsWith(contextPath + "/orders/")
                || uri.equals(contextPath + "/wishlist")
                || uri.startsWith(contextPath + "/wishlist/")
                || uri.equals(contextPath + "/recharge")
                || uri.startsWith(contextPath + "/recharge/")
                || uri.equals(contextPath + "/transactions")
                || uri.startsWith(contextPath + "/transactions/");
    }
}