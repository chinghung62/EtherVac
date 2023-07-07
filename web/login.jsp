<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSession.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login page</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript" src="js/util.js"></script>
<script type="text/javascript">
	async function login() {
		$e("button-login").disabled = true;
		let inputUserType = $n("user_type");
		let userType = "";

		for (let i = 0; i < inputUserType.length; i++) {
			if (inputUserType[i].checked) {
				userType = inputUserType[i].value;
				break;
			}
		}

		let d = {};
		d["user_type"] = userType;
		d["address"] = null;
		d["signature"] = null;

		if (d["user_type"] == "") {
			$e("span-message").innerHTML = "Please select a user type.";
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				d["address"] = address;
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to log in as '"
						+ d["user_type"].toLowerCase()
						+ "'.\n\nWallet address:\n"
						+ address
						+ "\n\nNonce:\n"
						+ nonce;

				$e("span-message").innerHTML = "Signing login message...";

				await signMessage(message, address).then((signature) => {
					d["signature"] = signature;
				}).catch((error) => {
					$e("span-message").innerHTML = error;
				});
			}).catch((error) => {
				$e("span-message").innerHTML = error;
			});

			if (d["signature"] != null) {
				XHRequest("login", JSON.stringify(d), {async: false});
			}
		}

		$e("button-login").disabled = false;
	}
</script>
</head>
<body>
	<div class="header">
		<div class="logo">
			<a href="index.jsp">EtherVac E-Certificate System</a>
		</div>
	</div>
	<div class="body">
		<div class="login-container">
			<div class="login-title">
				<span class="login-title"><b>Login</b></span>
			</div>
			<div class="login-message">
				<span class="login-message" id="span-message"></span>
			</div>
			<div class="login-field">
				<label class="login-field" for="login-field">Login as:</label>
				<br> <br>
				<input type="radio" id="input-radio-admin" name="user_type" value="admin">
				<label class="login-field-radio" for="input-radio-admin">Admin</label>
				<br>
				<input type="radio" id="input-radio-clinic" name="user_type" value="clinic">
				<label class="login-field-radio" for="input-radio-clinic">Clinic</label>
				<br>
				<input type="radio" id="input-radio-patient" name="user_type" value="patient">
				<label class="login-field-radio" for="input-radio-patient">Patient</label>
			</div>
			<div class="login-button">
				<button id="button-login" onclick="login();">Login with MetaMask</button>
			</div>
			<div class="login-footer">
				To verify a certificate, <a href="verify.jsp"><b>click here</b></a>
			</div>
		</div>
	</div>
</body>
</html>