<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionAdmin.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript">
	function loadUserInfo(rc = null) {
		if (rc == null) {
			$e("span-profile-address").innerHTML = "Loading...";
			$e("span-welcome-name").innerHTML = "Loading...";
			XHRequest("getUserInfo", JSON.stringify({}), {callback: "loadUserInfo"});
		} else {
			$e("span-profile-address").innerHTML = rc["address"];
			$e("span-profile-address").setAttribute("title", rc["address"]);
			$e("span-welcome-name").innerHTML = encHTML(rc["name"]);
		}
	}

	function loadClinicStats(rc = null) {
		if (rc == null) {
			$e("span-clinic-count").innerHTML = "Loading...";
			XHRequest("getClinicStats", JSON.stringify({}), {callback: "loadClinicStats"});
		} else {
			$e("span-clinic-count").innerHTML = rc["count"];
		}
	}

	function loadVaccinationStats(rc = null) {
		if (rc == null) {
			$e("span-vaccination-count").innerHTML = "Loading...";
			XHRequest("getVaccinationStats", JSON.stringify({}), {callback: "loadVaccinationStats"});
		} else {
			$e("span-vaccination-count").innerHTML = rc["count"];
		}
	}
</script>
</head>
<body onload="loadUserInfo(); loadClinicStats(); loadVaccinationStats();">
	<div class="header">
		<div class="logo">
			<a href="index.jsp">EtherVac E-Certificate System</a>
		</div>
		<div class="opt">
			<div>
				<a href="admin-profile.jsp"><b>Account: </b><span id="span-profile-address" title="N/A">N/A</span></a>
			</div>
			<div>
				<a href="logout.jsp">Logout</a>
			</div>
		</div>
	</div>
	<div class="body">
		<div class="left-sidebar">
			<ul>
				<li><a href="register-admin.jsp">Admin Registration</a></li>
			</ul>
			<ul>
				<li><a href="register-clinic.jsp">Clinic Registration</a></li>
			</ul>
			<ul>
				<li><a href="register-vaccine.jsp">Vaccine Registration</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="welcome-text">
				Welcome, <span class="welcome-name" id="span-welcome-name">N/A</span> !
			</div>
			<div class="dashboard">
				<div class="stats">
					Total clinics registered:
					<hr>
					<span class="stats-data" id="span-clinic-count">N/A</span>
				</div>
				<br> <br>
				<div class="stats">
					Total successful vaccinations:
					<hr>
					<span class="stats-data" id="span-vaccination-count">N/A</span>
				</div>
			</div>
		</div>
	</div>
</body>
</html>