<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<%
String userType = session.getAttribute("user_type") != null ? (String) session.getAttribute("user_type") : null;
String address = session.getAttribute("address") != null ? (String) session.getAttribute("address") : null;

if (userType != null && address != null) {
	response.sendRedirect(request.getContextPath() + "/" + userType + ".jsp");
} else {
	if (request.getServletPath().equals("/checkSession.jsp")) {
		response.sendRedirect(request.getContextPath() + "/index.jsp");
	}
}
%>