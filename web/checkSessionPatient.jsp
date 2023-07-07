<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<%
String userType = session.getAttribute("user_type") != null ? (String) session.getAttribute("user_type") : null;
String address = session.getAttribute("address") != null ? (String) session.getAttribute("address") : null;

if (userType == null || !userType.equals("patient") || address == null) {
	response.sendRedirect(request.getContextPath() + "/index.jsp");
} else {
	if (request.getServletPath().equals("/checkSessionAdmin.jsp")) {
		response.sendRedirect(request.getContextPath() + "/index.jsp");
	}
}
%>