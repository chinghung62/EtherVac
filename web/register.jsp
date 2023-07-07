<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionPatient.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Patient Registration</title>
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
			$e("input-address").value = rc["address"];
		}
	}

	async function updatePatientInfo() {
		$e("input-ic-no").style.borderColor = null;
		$e("input-name").style.borderColor = null;
		$e("input-gender").style.borderColor = null;
		$e("input-nationality").style.borderColor = null;
		$e("input-phone-no").style.borderColor = null;
		$e("input-email").style.borderColor = null;
		$e("button-register").disabled = true;

		let d = {};
		d["ic_no"] = $e("input-ic-no").value;
		d["name"] = $e("input-name").value;
		d["gender"] = $e("input-gender").value;
		d["nationality"] = $e("input-nationality").value;
		d["phone_no"] = $e("input-phone-no").value;
		d["email"] = $e("input-email").value;
		d["signature"] = null;

		if (d["ic_no"] == "") {
			$e("span-message").innerHTML = "Please enter IC no.";
			$e("input-ic-no").style.borderColor = "#ff0000";
			$e("input-ic-no").focus();
		} else if (d["name"] == "") {
			$e("span-message").innerHTML = "Please enter name.";
			$e("input-name").style.borderColor = "#ff0000";
			$e("input-name").focus();
		} else if (d["gender"] == "") {
			$e("span-message").innerHTML = "Please enter gender.";
			$e("input-gender").style.borderColor = "#ff0000";
			$e("input-gender").focus();
		} else if (d["nationality"] == "") {
			$e("span-message").innerHTML = "Please enter nationality.";
			$e("input-nationality").style.borderColor = "#ff0000";
			$e("input-nationality").focus();
		} else if (d["phone_no"] == "") {
			$e("span-message").innerHTML = "Please enter phone no.";
			$e("input-phone-no").style.borderColor = "#ff0000";
			$e("input-phone-no").focus();
		} else if (d["email"] == "") {
			$e("span-message").innerHTML = "Please enter email.";
			$e("input-email").style.borderColor = "#ff0000";
			$e("input-email").focus();
		} else {
			let pattern = /^[A-z0-9_-]+(\.[A-z0-9_-]+)*@([A-z0-9-]+\.)+[A-z]{2,7}$/;

			if (!pattern.test(d["email"])) {
				$e("span-message").innerHTML = "Incorrect email format.";
				$e("input-email").style.borderColor = "#ff0000";
				$e("input-email").focus();
			} else {
				$e("span-message").innerHTML = "Connecting wallet...";

				await connectWallet().then(async (address) => {
					getNonce();
					let message = "Welcome to EtherVac!\n\nYou're about to update your info (current patient).\n\nWallet address:\n"
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
					XHRequest("updatePatientInfo", JSON.stringify(d), {callback: "afterUpdatePatientInfo"});
					return;
				}
			}
		}

		afterUpdatePatientInfo();
	}

	function afterUpdatePatientInfo(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "Patient profile has been updated.";
				location.href = "patient.jsp";
			}
		}

		$e("button-register").disabled = false;
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
			<div class="profile">
				<div class="profile-title">REGISTER</div>
				<div class="form-message">
					<span class="form-message" id="span-message"></span>
				</div>
				<div class="profile-form">
					<label for="input-address">Account Address: </label>
					<input id="input-address" type="text" autocomplete="off" disabled>
					<br>
					<label for="input-ic-no">IC No: </label>
					<input id="input-ic-no" type="text" maxlength="20" autocomplete="off" autofocus>
					<br>
					<label for="input-name">Name: </label>
					<input id="input-name" type="text" maxlength="50" autocomplete="off">
					<br>
					<label for="input-gender">Gender: </label>
					<select id="input-gender">
						<option value="Male">Male</option>
						<option value="Female">Female</option>
						<option value="Other">Other</option>
					</select>
					<br>
					<label for="input-nationality">Nationality: </label>
					<input id="input-nationality" type="text" maxlength="20" autocomplete="off">
					<br>
					<label for="input-phone-no">Phone No: </label>
					<input id="input-phone-no" type="text" maxlength="15" autocomplete="off">
					<br>
					<label for="input-email">Email: </label>
					<input id="input-email" type="text" maxlength="50" autocomplete="off">
					<br> <br>
					<label></label>
					<button id="button-register" onclick="updatePatientInfo();">Register</button>
				</div>
			</div>
		</div>
	</div>
</body>
</html>