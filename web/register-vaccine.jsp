<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionAdmin.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register Vaccine</title>
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
			XHRequest("getAllVaccines", JSON.stringify({}), {callback: "loadTable"});
		} else {
			clearTable();

			let r = mapJSON(rc["result"], encHTML);
			let tBody = $e("list").tBodies[0];
			let row, cell, span, button;

			for (i in r) {
				row = tBody.insertRow();

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
				span.innerHTML = r[i]["purpose"];
				span.setAttribute("title", r[i]["purpose"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["manufacturer"];
				span.setAttribute("title", r[i]["manufacturer"]);
				cell.appendChild(span);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = r[i]["status"] ? "Open" : "Closed";
				button.setAttribute("onclick", "changeStatus('" + r[i]["count"] + "', '" + r[i]["barcode"] + "', '" + (r[i]["status"] ? false : true) + "');");
				cell.appendChild(button);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = "Edit";
				button.setAttribute("onclick", "edit(this, '" + r[i]["count"] + "', '" + r[i]["barcode"] + "');");
				cell.appendChild(button);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = "Delete";
				button.setAttribute("onclick", "remove('" + r[i]["count"] + "', '" + r[i]["barcode"] + "');");
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

	async function add() {
		$e("input-barcode").style.borderColor = null;
		$e("input-name").style.borderColor = null;
		$e("input-purpose").style.borderColor = null;
		$e("input-manufacturer").style.borderColor = null;
		toggleDisabledTableButtons(true);

		let d = {};
		d["barcode"] = $e("input-barcode").value;
		d["name"] = $e("input-name").value;
		d["purpose"] = $e("input-purpose").value;
		d["manufacturer"] = $e("input-manufacturer").value;
		d["signature"] = null;

		if (d["barcode"] == "") {
			$e("span-message").innerHTML = "Please enter barcode.";
			$e("input-barcode").style.borderColor = "#ff0000";
			$e("input-barcode").focus();
		} else if (d["name"] == "") {
			$e("span-message").innerHTML = "Please enter name.";
			$e("input-name").style.borderColor = "#ff0000";
			$e("input-name").focus();
		} else if (d["purpose"] == "") {
			$e("span-message").innerHTML = "Please enter purpose.";
			$e("input-purpose").style.borderColor = "#ff0000";
			$e("input-purpose").focus();
		} else if (d["manufacturer"] == "") {
			$e("span-message").innerHTML = "Please enter manufacturer.";
			$e("input-manufacturer").style.borderColor = "#ff0000";
			$e("input-manufacturer").focus();
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to add a new vaccine.\n\nWallet address:\n"
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
				XHRequest("addVaccine", JSON.stringify(d), {callback: "afterAdd"});
				return;
			}
		}

		afterAdd();
	}

	function afterAdd(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "A new vaccine has been added.";
				loadTable();
				reset();
			}
		}

		toggleDisabledTableButtons(false);
	}

	async function update(element, count, barcode, name, purpose, manufacturer) {
		let row = element.parentNode.parentNode;
		row.cells[1].childNodes[1].style.borderColor = null;
		row.cells[2].childNodes[1].style.borderColor = null;
		row.cells[3].childNodes[1].style.borderColor = null;
		toggleDisabledTableButtons(true);

		let d = {};
		d["count"] = count;
		d["barcode"] = barcode;
		d["name"] = name;
		d["purpose"] = purpose;
		d["manufacturer"] = manufacturer;
		d["signature"] = null;

		if (d["count"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["barcode"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["name"] == "") {
			$e("span-message").innerHTML = "Please enter name.";
			row.cells[1].childNodes[1].style.borderColor = "#ff0000";
			row.cells[1].childNodes[1].focus();
		} else if (d["purpose"] == "") {
			$e("span-message").innerHTML = "Please enter purpose.";
			row.cells[2].childNodes[1].style.borderColor = "#ff0000";
			row.cells[2].childNodes[1].focus();
		} else if (d["manufacturer"] == "") {
			$e("span-message").innerHTML = "Please enter manufacturer.";
			row.cells[3].childNodes[1].style.borderColor = "#ff0000";
			row.cells[3].childNodes[1].focus();
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to update an existing vaccine.\n\nWallet address:\n"
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
				XHRequest("updateVaccine", JSON.stringify(d), {callback: "afterUpdate"});
				return;
			}
		}

		afterUpdate();
	}

	function afterUpdate(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The vaccine has been updated.";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	async function changeStatus(count, barcode, status) {
		toggleDisabledTableButtons(true);

		let d = {};
		d["count"] = count;
		d["barcode"] = barcode;
		d["status"] = status;
		d["signature"] = null;

		if (d["count"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["barcode"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["status"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to change the status of an existing vaccine.\n\nWallet address:\n"
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
				XHRequest("updateVaccineStatus", JSON.stringify(d), {callback: "afterChangeStatus"});
				return;
			}
		}

		afterChangeStatus();
	}

	function afterChangeStatus(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The vaccine status has been updated.";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	async function remove(count, barcode) {
		toggleDisabledTableButtons(true);

		let d = {};
		d["count"] = count;
		d["barcode"] = barcode;
		d["signature"] = null;

		if (d["count"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["barcode"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to delete an existing vaccine.\n\nWallet address:\n"
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
				XHRequest("deleteVaccine", JSON.stringify(d), {callback: "afterRemove"});
				return;
			}
		}

		afterRemove();
	}

	function afterRemove(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The vaccine has been deleted.";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	function edit(element, count, barcode) {
		let row = element.parentNode.parentNode;
		let cell, span, input, button;

		cell = row.cells[1];
		span = cell.childNodes[0];
		span.style.display = "none";
		input = document.createElement("input");
		input.type = "text";
		input.value = decHTML(span.innerHTML);
		input.maxLength = 50;
		cell.appendChild(input);

		cell = row.cells[2];
		span = cell.childNodes[0];
		span.style.display = "none";
		input = document.createElement("input");
		input.type = "text";
		input.value = decHTML(span.innerHTML);
		input.maxLength = 15;
		cell.appendChild(input);

		cell = row.cells[3];
		span = cell.childNodes[0];
		span.style.display = "none";
		input = document.createElement("input");
		input.type = "text";
		input.value = decHTML(span.innerHTML);
		input.maxLength = 50;
		cell.appendChild(input);

		cell = row.cells[5];
		button = cell.childNodes[0];
		button.innerHTML = "Save";
		button.setAttribute("onclick", "update(this, '" + count + "', '" + barcode
				+ "', this.parentNode.parentNode.cells[1].childNodes[1].value, this.parentNode.parentNode.cells[2].childNodes[1].value, this.parentNode.parentNode.cells[3].childNodes[1].value);");

		cell = row.cells[6];
		button = cell.childNodes[0];
		button.innerHTML = "Cancel";
		button.setAttribute("onclick", "cancelEdit(this, '" + count + "', '" + barcode + "');");
	}

	function cancelEdit(element, count, barcode) {
		let row = element.parentNode.parentNode;
		let cell, button;

		cell = row.cells[1];
		cell.childNodes[0].style.display = null;
		cell.removeChild(cell.childNodes[1]);

		cell = row.cells[2];
		cell.childNodes[0].style.display = null;
		cell.removeChild(cell.childNodes[1]);

		cell = row.cells[3];
		cell.childNodes[0].style.display = null;
		cell.removeChild(cell.childNodes[1]);

		cell = row.cells[5];
		button = cell.childNodes[0];
		button.innerHTML = "Edit";
		button.setAttribute("onclick", "edit(this, '" + count + "', '" + barcode + "');");

		cell = row.cells[6];
		button = cell.childNodes[0];
		button.innerHTML = "Delete";
		button.setAttribute("onclick", "remove('" + count + "', '" + barcode + "');");
	}

	function toggleDisabledTableButtons(bool) {
		let tBody = $e("list").tBodies[0];
		let row, cell;

		for (let i = 0; i < tBody.rows.length; i++) {
			row = tBody.rows[i];
			row.cells[4].childNodes[0].disabled = bool;
			row.cells[5].childNodes[0].disabled = bool;
			row.cells[6].childNodes[0].disabled = bool;
		}

		$e("button-add").disabled = bool;
		$e("button-clear").disabled = bool;
	}

	function reset() {
		$e("input-barcode").value = null;
		$e("input-name").value = null;
		$e("input-purpose").value = null;
		$e("input-manufacturer").value = null;
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
				<li><a class="selected" href="register-vaccine.jsp">Vaccine Registration</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="table-message">
				<span class="table-message" id="span-message"></span>
			</div>
			<table id="list">
				<colgroup>
					<col style="width: 14%;">
					<col style="width: 20%;">
					<col style="width: 20%;">
					<col style="width: 18%;">
					<col style="width: 9%;">
					<col style="width: 9%;">
					<col style="width: 10%;">
				</colgroup>
				<thead>
					<tr>
						<th>Barcode</th>
						<th>Name</th>
						<th>Purpose</th>
						<th>Manufacturer</th>
						<th>Status</th>
						<th>Edit</th>
						<th>Delete</th>
					</tr>
				</thead>
				<tbody></tbody>
				<tfoot>
					<tr>
						<td><input id="input-barcode" type="text" maxlength="13" autocomplete="off"></td>
						<td><input id="input-name" type="text" maxlength="50" autocomplete="off"></td>
						<td><input id="input-purpose" type="text" maxlength="200" autocomplete="off"></td>
						<td><input id="input-manufacturer" type="text" maxlength="50" autocomplete="off"></td>
						<td></td>
						<td><button id="button-add" onclick="add();">Add</button></td>
						<td><button id="button-clear" onclick="reset();">Clear</button></td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</body>
</html>