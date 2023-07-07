<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionPatient.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Certificates</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript" src="js/util.js"></script>
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

	function loadTable(rc = null) {
		if (rc == null) {
			if ($e("span-message").innerHTML == "") $e("span-message").innerHTML = "Loading...";
			XHRequest("getCertificates", JSON.stringify({}), {callback: "loadTable"});
		} else {
			clearTable();

			let r = mapJSON(rc["result"], encHTML);
			let tBody = $e("list").tBodies[0];
			let row, cell, span, button;

			for (i in r) {
				row = tBody.insertRow();

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["clinic_name"];
				span.setAttribute("class", "title");
				span.setAttribute("title", r[i]["clinic_name"]);
				cell.appendChild(span);
				cell.appendChild(document.createElement("br"));
				cell.appendChild(document.createElement("br"));
				span = document.createElement("span");
				span.innerHTML = r[i]["clinic_address"];
				span.setAttribute("class", "detail");
				span.setAttribute("title", "<b>Address: </b>" + r[i]["clinic_address"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["vaccine_name"];
				span.setAttribute("class", "title");
				span.setAttribute("title", r[i]["vaccine_name"]);
				cell.appendChild(span);
				cell.appendChild(document.createElement("br"));
				cell.appendChild(document.createElement("br"));
				span = document.createElement("span");
				span.innerHTML = "<b>Barcode: </b>" + r[i]["barcode"] + "<br><b>Manufacturer: </b>" + r[i]["manufacturer"] + "<br><br><b>Batch No: </b>" + r[i]["batch_no"];
				span.setAttribute("class", "detail");
				span.setAttribute("title", "Barcode: " + r[i]["barcode"] + " | Manufacturer: " + r[i]["manufacturer"] + " | Batch No: " + r[i]["batch_no"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["date"];
				span.setAttribute("class", "title");
				span.setAttribute("title", r[i]["date"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["patient_signed"] ? (r[i]["clinic_signed"] ? "Completed" : "Confirmed") : "Pending";
				span.setAttribute("class", "title");
				span.setAttribute("title", r[i]["patient_signed"] ? (r[i]["clinic_signed"] ? "Completed" : "Confirmed") : "Pending");
				cell.appendChild(span);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = r[i]["patient_signed"] ? "Download" : "Sign & Agree";
				button.setAttribute("onclick", r[i]["patient_signed"] ? (r[i]["clinic_signed"] ? "location.href='download.jsp?id=" + r[i]["id"] + "';" : "alert('Please wait until the clinic signs off on this vaccination.');") : "sign('" + r[i]["id"] + "');");
				cell.appendChild(button);
			}
		}
	}

	function clearTable() {
		let tBody = $e("list").tBodies[0];

		for (let i = tBody.rows.length; i > 0; i--) {
			tBody.deleteRow(0);
		}

		if ($e("span-message").innerHTML == "Loading...") $e("span-message").innerHTML = null;
	}

	let cert = null;

	function loadCertificate(id) {
		let d = {};
		d["id"] = id;

		if (d["id"] != null && d["id"] != "") {
			XHRequest("getCertificate", JSON.stringify(d), {callback: "afterLoadCertificate", async: false});
		}
	}

	function afterLoadCertificate(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				cert = rc;
				return;
			}
		}

		$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		cert = null;
	}

	async function sign(id) {
		toggleDisabledTableButtons(true);

		let d = {};
		d["id"] = id;
		d["patient_signature"] = null;
		d["signature"] = null;

		if (d["id"] == null || d["id"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			loadCertificate(d["id"]);

			if (cert != null) {
				$e("span-message").innerHTML = "Connecting wallet...";

				await connectWallet().then(async (address) => {
					let certificateMessage = "EtherVac Vaccination Certificate\n\n----- Patient Details -----\nAddress: " + cert["patient_address"]
							+ "\nIC: " + cert["ic_no"]
							+ "\nName: " + cert["patient_name"]
							+ "\nGender: " + cert["gender"]
							+ "\nNationality: " + cert["nationality"]
							+ "\n\n----- Clinic Details -----\nAddress: " + cert["clinic_address"]
							+ "\nName: " + cert["clinic_name"]
							+ "\n\n----- Vaccine Details -----\nBarcode: " + cert["barcode"]
							+ "\nName: " + cert["vaccine_name"]
							+ "\nManufacturer: " + cert["manufacturer"]
							+ "\nBatch No: " + cert["batch_no"]
							+ "\n\nDate: " + cert["date"];

					$e("span-message").innerHTML = "Signing certificate... Please make sure all information is correct.";

					await signMessage(certificateMessage, address).then(async (signature) => {
						d["patient_signature"] = signature;
						getNonce();
						let message = "Welcome to EtherVac!\n\nYou're about to sign a vaccination agreement.\n\nWarning:\nSigned agreement cannot be undone.\n\nWallet address:\n" + address
								+ "\n\nNonce:\n" + nonce;

						$e("span-message").innerHTML = "Signing action message...";

						await signMessage(message, address).then((signature) => {
							d["signature"] = signature;
						}).catch((error) => {
							$e("span-message").innerHTML = error;
						});
					}).catch((error) => {
						$e("span-message").innerHTML = error;
					});
				}).catch((error) => {
					$e("span-message").innerHTML = error;
				});

				if (d["signature"] != null) {
					$e("span-message").innerHTML = "Please wait...";
					XHRequest("signAgreement", JSON.stringify(d), {callback: "afterSign"});
					return;
				}
			}
		}

		afterSign();
	}

	function afterSign(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The vaccination has been signed. Waiting clinic to sign...";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	function toggleDisabledTableButtons(bool) {
		let tBody = $e("list").tBodies[0];
		let row, cell;

		for (let i = 0; i < tBody.rows.length; i++) {
			row = tBody.rows[i];
			row.cells[4].childNodes[0].disabled = bool;
		}
	}
</script>
</head>
<body onload="loadUserInfo(); loadTable();">
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
				<li><a class="selected" href="certificates.jsp">View Certificates</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="table-message">
				<span class="table-message" id="span-message"></span>
			</div>
			<table id="list">
				<colgroup>
					<col style="width: 30%;">
					<col style="width: 35%;">
					<col style="width: 10%;">
					<col style="width: 10%;">
					<col style="width: 15%;">
				</colgroup>
				<thead>
					<tr>
						<th>Clinic</th>
						<th>Vaccine</th>
						<th>Date</th>
						<th>Status</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody></tbody>
			</table>
		</div>
	</div>
</body>
</html>