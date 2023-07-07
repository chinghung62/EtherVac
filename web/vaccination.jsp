<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionClinic.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register Vaccination</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript" src="js/util.js"></script>
<script type="text/javascript" src="js/html5-qrcode.min.js"></script>
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

	function openQRPopup() {
		$e("div-qr").style.display = "unset";
		scanQR();
	}

	async function closeQRPopup() {
		await stopQR();
		$e("div-qr").style.display = "none";
	}

	let html5QrcodeScanner;

	function scanQR() {
		$e("span-message").innerHTML = null;

		html5QrcodeScanner = new Html5QrcodeScanner("qr-scanner", {
			fps : 10,
			qrbox : 250
		});

		html5QrcodeScanner.render(onScanSuccess);
	}

	async function stopQR() {
		await html5QrcodeScanner.clear();
	}

	async function onScanSuccess(decodedText) {
		await closeQRPopup();
		let pattern = /0x[0-9A-Fa-f]{40}/;
		let address = decodedText.match(pattern);
		$e("input-patient-address").value = address;
		checkPatient();
	}

	function checkPatient(rc = null) {
		if (rc == null) {
			$e("input-patient-address").style.borderColor = null;
			$e("button-search-patient").disabled = true;

			let d = {};
			d["address"] = $e("input-patient-address").value;

			if (d["address"] == "") {
				$e("span-message").innerHTML = "Please enter patient address.";
				$e("input-patient-address").style.borderColor = "#ff0000";
				$e("input-patient-address").focus();
			} else {
				let pattern = /^(0x)?[0-9A-Fa-f]{40}$/;

				if (!pattern.test(d["address"])) {
					$e("span-message").innerHTML = "Incorrect address format.";
					$e("input-patient-address").style.borderColor = "#ff0000";
					$e("input-patient-address").focus();
				} else {
					$e("span-message").innerHTML = "Searching...";
					XHRequest("checkPatient", JSON.stringify(d), {callback: "checkPatient"});
					return;
				}
			}
		} else {
			if ($e("span-message").innerHTML == "Searching...") $e("span-message").innerHTML = null;

			if (rc["ok"] === true) {
				$e("input-patient-name").value = rc["name"];
				$e("input-patient-ic-no").value = rc["ic_no"];
				$e("input-patient-gender").value = rc["gender"];
				$e("input-patient-nationality").value = rc["nationality"];
			} else {
				$e("input-patient-name").value = null;
				$e("input-patient-ic-no").value = null;
				$e("input-patient-gender").value = null;
				$e("input-patient-nationality").value = null;
			}
		}

		$e("button-search-patient").disabled = false;
	}

	function checkVaccine(rc = null) {
		if (rc == null) {
			$e("input-vaccine-barcode").style.borderColor = null;
			$e("button-search-vaccine").disabled = true;

			let d = {};
			d["barcode"] = $e("input-vaccine-barcode").value;

			if (d["barcode"] == "") {
				$e("span-message").innerHTML = "Please enter vaccine barcode.";
				$e("input-vaccine-barcode").style.borderColor = "#ff0000";
				$e("input-vaccine-barcode").focus();
			} else {
				$e("span-message").innerHTML = "Searching...";
				XHRequest("checkVaccine", JSON.stringify(d), {callback: "checkVaccine"});
				return;
			}
		} else {
			if ($e("span-message").innerHTML == "Searching...") $e("span-message").innerHTML = null;

			if (rc["ok"] === true) {
				$e("input-vaccine-name").value = rc["name"];
				$e("input-vaccine-manufacturer").value = rc["manufacturer"];
			} else {
				$e("input-vaccine-name").value = null;
				$e("input-vaccine-manufacturer").value = null;
			}
		}

		$e("button-search-vaccine").disabled = false;
	}

	async function addVaccination() {
		$e("input-patient-address").style.borderColor = null;
		$e("input-patient-ic-no").style.borderColor = null;
		$e("input-patient-name").style.borderColor = null;
		$e("input-patient-gender").style.borderColor = null;
		$e("input-patient-nationality").style.borderColor = null;
		$e("input-vaccine-barcode").style.borderColor = null;
		$e("input-vaccine-name").style.borderColor = null;
		$e("input-vaccine-manufacturer").style.borderColor = null;
		$e("input-date").style.borderColor = null;
		$e("input-batch-no").style.borderColor = null;
		$e("button-search-patient").disabled = true;
		$e("button-search-vaccine").disabled = true;
		$e("button-register").disabled = true;
		$e("button-cancel").disabled = true;

		let d = {};
		d["patient_address"] = $e("input-patient-address").value;
		d["ic_no"] = $e("input-patient-ic-no").value;
		d["patient_name"] = $e("input-patient-name").value;
		d["gender"] = $e("input-patient-gender").value;
		d["nationality"] = $e("input-patient-nationality").value;
		d["barcode"] = $e("input-vaccine-barcode").value;
		d["vaccine_name"] = $e("input-vaccine-name").value;
		d["manufacturer"] = $e("input-vaccine-manufacturer").value;
		d["date"] = $e("input-date").value;
		d["batch_no"] = $e("input-batch-no").value;
		d["signature"] = null;

		if (d["patient_address"] == "") {
			$e("span-message").innerHTML = "Please enter address.";
			$e("input-patient-address").style.borderColor = "#ff0000";
			$e("input-patient-address").focus();
		} else {
			let pattern = /^(0x)?[0-9A-Fa-f]{40}$/;

			if (!pattern.test(d["patient_address"])) {
				$e("span-message").innerHTML = "Incorrect address format.";
				$e("input-patient-address").style.borderColor = "#ff0000";
				$e("input-patient-address").focus();
			} else if (d["ic_no"] == "") {
				$e("span-message").innerHTML = "Please enter IC no.";
				$e("input-patient-ic-no").style.borderColor = "#ff0000";
				$e("input-patient-ic-no").focus();
			} else if (d["patient_name"] == "") {
				$e("span-message").innerHTML = "Please enter patient name.";
				$e("input-patient-name").style.borderColor = "#ff0000";
				$e("input-patient-name").focus();
			} else if (d["gender"] == "") {
				$e("span-message").innerHTML = "Please enter gender.";
				$e("input-patient-gender").style.borderColor = "#ff0000";
				$e("input-patient-gender").focus();
			} else if (d["nationality"] == "") {
				$e("span-message").innerHTML = "Please enter nationality.";
				$e("input-patient-nationality").style.borderColor = "#ff0000";
				$e("input-patient-nationality").focus();
			} else if (d["barcode"] == "") {
				$e("span-message").innerHTML = "Please enter barcode.";
				$e("input-vaccine-barcode").style.borderColor = "#ff0000";
				$e("input-vaccine-barcode").focus();
			} else if (d["vaccine_name"] == "") {
				$e("span-message").innerHTML = "Please enter vaccine name.";
				$e("input-vaccine-name").style.borderColor = "#ff0000";
				$e("input-vaccine-name").focus();
			} else if (d["manufacturer"] == "") {
				$e("span-message").innerHTML = "Please enter manufacturer.";
				$e("input-vaccine-manufacturer").style.borderColor = "#ff0000";
				$e("input-vaccine-manufacturer").focus();
			} else if (d["date"] == "") {
				$e("span-message").innerHTML = "Please enter date correctly.";
				$e("input-date").style.borderColor = "#ff0000";
				$e("input-date").focus();
			} else if (d["batch_no"] == "") {
				$e("span-message").innerHTML = "Please enter batch no.";
				$e("input-batch-no").style.borderColor = "#ff0000";
				$e("input-batch-no").focus();
			} else {
				$e("span-message").innerHTML = "Connecting wallet...";

				await connectWallet().then(async (address) => {
					getNonce();
					let message = "Welcome to EtherVac!\n\nYou're about to add a new vaccination.\n\nWallet address:\n"
							+ address
							+ "\n\nNonce:\n"
							+ nonce;

					$e("span-message").innerHTML = "Signing action message...";

					await signMessage(message, address).then((signature) => {
						d["signature"] = signature;
					}).catch((error) => {
						$e("span-message").innerHTML = error;
					});
				}).catch((error) => {
					$e("span-message").innerHTML = error;
				});

				if (d["signature"] != null) {
					$e("span-message").innerHTML = "Please wait...";
					XHRequest("addVaccination", JSON.stringify(d), {callback: "afterAddVaccination"});
					return;
				}
			}
		}

		afterAddVaccination();
	}

	function afterAddVaccination(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "A new vaccination has been added.";
				location.href = "issue-certificate.jsp";
			}
		}

		$e("button-search-patient").disabled = false;
		$e("button-search-vaccine").disabled = false;
		$e("button-register").disabled = false;
		$e("button-cancel").disabled = false;
	}
</script>
</head>
<body onload="loadUserInfo();">
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
				<li><a class="selected" href="vaccination.jsp">Register Vaccination</a></li>
			</ul>
			<ul>
				<li><a href="issue-certificate.jsp">Issue Certificate</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="vaccination-form">
				<div class="form-message">
					<span class="form-message" id="span-message" style="text-align: left;"></span>
				</div>
				Patient Information
				<hr>
				<label for="input-patient-address">Patient Account Address: </label>
				<input id="input-patient-address" type="text" autocomplete="off" autofocus>
				<button onclick="openQRPopup();">Scan QR</button>
				<button id="button-search-patient" onclick="checkPatient();">Search</button>
				<br>
				<label for="input-patient-ic-no">Patient IC No: </label>
				<input id="input-patient-ic-no" type="text" autocomplete="off" disabled>
				<br>
				<label for="input-patient-name">Patient Name: </label>
				<input id="input-patient-name" type="text" autocomplete="off" disabled>
				<br>
				<label for="input-patient-gender">Gender: </label>
				<select id="input-patient-gender" disabled>
					<option value=""></option>
					<option value="Male">Male</option>
					<option value="Female">Female</option>
					<option value="Other">Other</option>
				</select> <br>
				<label for="input-patient-nationality">Patient Nationality: </label>
				<input id="input-patient-nationality" type="text" autocomplete="off" disabled>
				<br> <br> <br>Vaccine Information
				<hr>
				<label for="input-vaccine-barcode">Vaccine Barcode: </label>
				<input id="input-vaccine-barcode" type="text" maxlength="13" autocomplete="off">
				<button id="button-search-vaccine" onclick="checkVaccine();">Search</button>
				<br>
				<label for="input-vaccine-name">Vaccine Name: </label>
				<input id="input-vaccine-name" type="text" autocomplete="off" disabled>
				<br>
				<label for="input-vaccine-manufacturer">Vaccine Manufacturer: </label>
				<input id="input-vaccine-manufacturer" type="text" autocomplete="off" disabled>
				<br> <br> Misc
				<hr>
				<label for="input-date">Date: </label>
				<input id="input-date" type="date" autocomplete="off">
				<br>
				<label for="input-batch-no">Batch no: </label>
				<input id="input-batch-no" type="text" maxlength="15" autocomplete="off">
				<br> <br>
				<label></label>
				<button id="button-register" onclick="addVaccination();">Register</button>
				<a href="clinic.jsp"><button id="button-cancel">Cancel</button></a>
			</div>
		</div>
	</div>
	<div class="qr-bgcover" id="div-qr">
		<div class="qr-popup">
			<div class="qr-popup-menu">
				<button onclick="closeQRPopup();">Close</button>
			</div>
			<div class="qr-scan-box" id="qr-scanner"></div>
		</div>
	</div>
</body>
</html>