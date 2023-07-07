<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Verify Certificate</title>
<link rel="stylesheet" href="css/main.css">
<script type="text/javascript" src="js/helper.js"></script>
<script type="text/javascript" src="js/util.js"></script>
<script type="text/javascript" src="js/html5-qrcode.min.js"></script>
<script type="text/javascript">
	async function verify(qrData) {
		let d = {};
		d["data"] = qrData;

		if (d["data"] == null || d["data"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			$e("span-message").innerHTML = "Please wait...";
			XHRequest("verifyCertificate", JSON.stringify(d), {callback: "afterVerify"});
			return;
		}

		afterVerify();
	}

	function afterVerify(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = rc["message"];
			}
		}

		let divQRScanner = $e("qr-scanner");
		let button = document.createElement("button");
		button.innerHTML = "Click to scan again";
		button.setAttribute("onclick", "scanQR();");
		divQRScanner.appendChild(button);
	}

	let html5QrcodeScanner;

	async function onScanSuccess(decodedText) {
		await html5QrcodeScanner.clear();
		await verify(decodedText);
	}

	function scanQR() {
		$e("span-message").innerHTML = null;

		html5QrcodeScanner = new Html5QrcodeScanner("qr-scanner", {
			fps : 10,
			qrbox : 250
		});

		html5QrcodeScanner.render(onScanSuccess);
	}
</script>
</head>
<body onload="scanQR();">
	<div class="header">
		<div class="logo">
			<a href="index.jsp">EtherVac E-Certificate System</a>
		</div>
	</div>
	<div class="body">
		<div class="qr-container">
			<div class="qr-title">
				<span class="qr-title">Scan QR code to verify certificate.</span>
			</div>
			<div class="qr-message">
				<span class="qr-message" id="span-message"></span>
			</div>
			<div class="qr-scan-box" id="qr-scanner"></div>
			<!-- 			<div class="qr-footer"> -->
			<!-- 				<span>Unable to scan QR code? Enter the certificate ID below.</span> <br> -->
			<!-- 				<input type="text"> -->
			<!-- 				<button>Verify</button> -->
			<!-- 			</div> -->
		</div>
	</div>
</body>
</html>