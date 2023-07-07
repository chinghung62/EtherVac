<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionClinic.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Clinic Profile</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript">
	function loadUserInfo(rc = null) {
		if (rc == null) {
			$e("span-profile-address").innerHTML = "Loading...";
			XHRequest("getUserInfo", JSON.stringify({}), {callback: "loadUserInfo"});
		} else {
			$e("span-profile-address").innerHTML = rc["address"];
			$e("span-profile-address").setAttribute("title", rc["address"]);
		}
	}

	function getClinicInfo(rc = null) {
		if (rc == null) {
			$e("span-message").innerHTML = "Loading...";
			XHRequest("getClinicInfo", JSON.stringify({}), {callback: "getClinicInfo"});
		} else {
			$e("span-message").innerHTML = null;
			$e("input-address").value = rc["address"];
			$e("input-name").value = rc["name"];
			$e("input-phone-no").value = rc["phone_no"];
			$e("input-email").value = rc["email"];
			$e("input-location").value = rc["location"];
		}
	}
</script>
</head>
<body onload="loadUserInfo(); getClinicInfo();">
	<div class="header">
		<div class="logo">
			<a href="index.jsp">EtherVac E-Certificate System</a>
		</div>
		<div class="opt">
			<div>
				<a href="clinic-profile.jsp"><b>Account: </b><span id="span-profile-address" title="N/A">N/A</span></a>
			</div>
			<div>
				<a href="logout.jsp">Logout</a>
			</div>
		</div>
	</div>
	<div class="body">
		<div class="left-sidebar">
			<ul>
				<li><a href="vaccination.jsp">Register Vaccination</a></li>
			</ul>
			<ul>
				<li><a href="issue-certificate.jsp">Issue Certificate</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="profile">
				<div class="profile-title">PROFILE</div>
				<div class="form-message">
					<span class="form-message" id="span-message"></span>
				</div>
				<div class="profile-form">
					<label for="input-address">Account Address: </label>
					<input id="input-address" type="text" disabled>
					<br>
					<label for="input-name">Clinic Name: </label>
					<input id="input-name" type="text" disabled>
					<br>
					<label for="input-phone-no">Phone No: </label>
					<input id="input-phone-no" type="text" disabled>
					<br>
					<label for="input-email">Email: </label>
					<input id="input-email" type="text" disabled>
					<br>
					<label for="input-location">Location: </label>
					<input id="input-location" type="text" disabled>
				</div>
			</div>
		</div>
	</div>
</body>
</html>