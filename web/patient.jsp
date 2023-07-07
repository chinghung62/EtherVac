<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionPatient.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Patient Dashboard</title>
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

	function loadVaccineTable(rc = null) {
		let tBody = $e("vaccine-list").tBodies[0];

		if (rc == null) {
			let row = tBody.insertRow();
			let cell = row.insertCell();
			cell.innerHTML = "Loading...";
			cell.colSpan = 5;
			XHRequest("getRecentVaccines", JSON.stringify({}), {callback: "loadVaccineTable"});
		} else {
			clearTable();

			let r = mapJSON(rc["result"], encHTML);
			let row, cell, span, button;
			let count = 0;

			for (i in r) {
				count++;
				row = tBody.insertRow();

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = count;
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["barcode"];
				span.setAttribute("title", r[i]["barcode"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["name"];
				span.setAttribute("title", r[i]["name"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["manufacturer"];
				span.setAttribute("title", r[i]["manufacturer"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["purpose"];
				span.setAttribute("title", r[i]["purpose"]);
				cell.appendChild(span);
			}

			if (count == 0) {
				row = tBody.insertRow();

				cell = row.insertCell();
				cell.innerHTML = "(None)";
				cell.colSpan = 5;
			}
		}
	}

	function clearTable() {
		let tBody = $e("vaccine-list").tBodies[0];

		for (let i = tBody.rows.length; i > 0; i--) {
			tBody.deleteRow(0);
		}
	}
</script>
</head>
<body onload="loadUserInfo(); loadVaccineTable();">
	<div class="header">
		<div class="logo">
			<a href="index.jsp">EtherVac E-Certificate System</a>
		</div>
		<div class="opt">
			<div>
				<a href="patient-profile.jsp"><b>Account: </b><span id="span-profile-address" title="N/A">N/A</span></a>
			</div>
			<div>
				<a href="logout.jsp">Logout</a>
			</div>
		</div>
	</div>
	<div class="body">
		<div class="left-sidebar">
			<ul>
				<li><a href="certificates.jsp">View Certificates</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="welcome-text">
				Welcome, <span class="welcome-name" id="span-welcome-name">Guest</span> !
			</div>
			<div class="dashboard">
				Recent Vaccines: <br>
				<hr>
				<div class="stats">
					<table id="vaccine-list" style="width: 510px;">
						<colgroup>
							<col style="width: 70px;">
							<col style="width: 170px;">
							<col style="width: 200px;">
							<col style="width: 200px;">
							<col style="width: 250px;">
						</colgroup>
						<thead>
							<tr>
								<th>No</th>
								<th>Barcode</th>
								<th>Name</th>
								<th>Manufacturer</th>
								<th>Purpose</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</body>
</html>