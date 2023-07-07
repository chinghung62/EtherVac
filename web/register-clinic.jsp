<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="checkSessionAdmin.jsp"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register Clinic</title>
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
			XHRequest("getAllClinics", JSON.stringify({}), {callback: "loadTable"});
		} else {
			clearTable();

			let r = mapJSON(rc["result"], encHTML);
			let tBody = $e("list").tBodies[0];
			let row, cell, span, button;

			for (i in r) {
				row = tBody.insertRow();

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["address"];
				span.setAttribute("title", r[i]["address"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["name"];
				span.setAttribute("title", r[i]["name"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["phone_no"];
				span.setAttribute("title", r[i]["phone_no"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["email"];
				span.setAttribute("title", r[i]["email"]);
				cell.appendChild(span);

				cell = row.insertCell();
				span = document.createElement("span");
				span.innerHTML = r[i]["location"];
				span.setAttribute("title", r[i]["location"]);
				cell.appendChild(span);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = "Edit";
				button.setAttribute("onclick", "edit(this, '" + r[i]["count"] + "', '" + r[i]["address"] + "');");
				cell.appendChild(button);

				cell = row.insertCell();
				button = document.createElement("button");
				button.innerHTML = "Delete";
				button.setAttribute("onclick", "remove('" + r[i]["count"] + "', '" + r[i]["address"] + "');");
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
		$e("input-address").style.borderColor = null;
		$e("input-name").style.borderColor = null;
		$e("input-phone-no").style.borderColor = null;
		$e("input-email").style.borderColor = null;
		$e("input-location").style.borderColor = null;
		toggleDisabledTableButtons(true);

		let d = {};
		d["address"] = $e("input-address").value;
		d["name"] = $e("input-name").value;
		d["phone_no"] = $e("input-phone-no").value;
		d["email"] = $e("input-email").value;
		d["location"] = $e("input-location").value;
		d["signature"] = null;

		if (d["address"] == "") {
			$e("span-message").innerHTML = "Please enter address.";
			$e("input-address").style.borderColor = "#ff0000";
			$e("input-address").focus();
		} else {
			let pattern = /^(0x)?[0-9A-Fa-f]{40}$/;

			if (!pattern.test(d["address"])) {
				$e("span-message").innerHTML = "Incorrect address format.";
				$e("input-address").style.borderColor = "#ff0000";
				$e("input-address").focus();
			} else if (d["name"] == "") {
				$e("span-message").innerHTML = "Please enter name.";
				$e("input-name").style.borderColor = "#ff0000";
				$e("input-name").focus();
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
				} else if (d["location"] == "") {
					$e("span-message").innerHTML = "Please enter location.";
					$e("input-location").style.borderColor = "#ff0000";
					$e("input-location").focus();
				} else {
					$e("span-message").innerHTML = "Connecting wallet...";

					await connectWallet().then(async (address) => {
						getNonce();
						let message = "Welcome to EtherVac!\n\nYou're about to add a new clinic.\n\nWallet address:\n"
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
						XHRequest("addClinic", JSON.stringify(d), {callback: "afterAdd"});
						return;
					}
				}
			}
		}

		afterAdd();
	}

	function afterAdd(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "A new clinic has been added.";
				loadTable();
				reset();
			}
		}

		toggleDisabledTableButtons(false);
	}

	async function update(element, count, address, name, phoneNo, email, location) {
		let row = element.parentNode.parentNode;
		row.cells[1].childNodes[1].style.borderColor = null;
		row.cells[2].childNodes[1].style.borderColor = null;
		row.cells[3].childNodes[1].style.borderColor = null;
		row.cells[4].childNodes[1].style.borderColor = null;
		toggleDisabledTableButtons(true);

		let d = {};
		d["count"] = count;
		d["address"] = address;
		d["name"] = name;
		d["phone_no"] = phoneNo;
		d["email"] = email;
		d["location"] = location;
		d["signature"] = null;

		if (d["count"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["address"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			let pattern = /^(0x)?[0-9A-Fa-f]{40}$/;

			if (!pattern.test(d["address"])) {
				$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
			} else if (d["name"] == "") {
				$e("span-message").innerHTML = "Please enter name.";
				row.cells[1].childNodes[1].style.borderColor = "#ff0000";
				row.cells[1].childNodes[1].focus();
			} else if (d["phone_no"] == "") {
				$e("span-message").innerHTML = "Please enter phone no.";
				row.cells[2].childNodes[1].style.borderColor = "#ff0000";
				row.cells[2].childNodes[1].focus();
			} else if (d["email"] == "") {
				$e("span-message").innerHTML = "Please enter email.";
				row.cells[3].childNodes[1].style.borderColor = "#ff0000";
				row.cells[3].childNodes[1].focus();
			} else {
				let pattern = /^[A-z0-9_-]+(\.[A-z0-9_-]+)*@([A-z0-9-]+\.)+[A-z]{2,7}$/;

				if (!pattern.test(d["email"])) {
					$e("span-message").innerHTML = "Incorrect email format.";
					row.cells[3].childNodes[1].style.borderColor = "#ff0000";
					row.cells[3].childNodes[1].focus();
				} else if (d["location"] == "") {
					$e("span-message").innerHTML = "Please enter location.";
					row.cells[4].childNodes[1].style.borderColor = "#ff0000";
					row.cells[4].childNodes[1].focus();
				} else {
					$e("span-message").innerHTML = "Connecting wallet...";

					await connectWallet().then(async (address) => {
						getNonce();
						let message = "Welcome to EtherVac!\n\nYou're about to update an existing clinic.\n\nWallet address:\n"
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
						XHRequest("updateClinic", JSON.stringify(d), {callback: "afterUpdate"});
						return;
					}
				}
			}
		}

		afterUpdate();
	}

	function afterUpdate(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The clinic has been updated.";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	async function remove(count, address) {
		toggleDisabledTableButtons(true);

		let d = {};
		d["count"] = count;
		d["address"] = address;
		d["signature"] = null;

		if (d["count"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else if (d["address"] == "") {
			$e("span-message").innerHTML = "Some error occurred. Please reload the page.";
		} else {
			$e("span-message").innerHTML = "Connecting wallet...";

			await connectWallet().then(async (address) => {
				getNonce();
				let message = "Welcome to EtherVac!\n\nYou're about to delete an existing clinic.\n\nWallet address:\n"
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
				XHRequest("deleteClinic", JSON.stringify(d), {callback: "afterRemove"});
				return;
			}
		}

		afterRemove();
	}

	function afterRemove(rc = null) {
		if (rc != null) {
			if (rc["ok"] === true) {
				$e("span-message").innerHTML = "The clinic has been deleted.";
				loadTable();
			}
		}

		toggleDisabledTableButtons(false);
	}

	function edit(element, count, address) {
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

		cell = row.cells[4];
		span = cell.childNodes[0];
		span.style.display = "none";
		input = document.createElement("input");
		input.type = "text";
		input.value = decHTML(span.innerHTML);
		input.maxLength = 200;
		cell.appendChild(input);

		cell = row.cells[5];
		button = cell.childNodes[0];
		button.innerHTML = "Save";
		button.setAttribute("onclick", "update(this, '" + count + "', '" + address
				+ "', this.parentNode.parentNode.cells[1].childNodes[1].value, this.parentNode.parentNode.cells[2].childNodes[1].value, this.parentNode.parentNode.cells[3].childNodes[1].value, this.parentNode.parentNode.cells[4].childNodes[1].value);");

		cell = row.cells[6];
		button = cell.childNodes[0];
		button.innerHTML = "Cancel";
		button.setAttribute("onclick", "cancelEdit(this, '" + count + "', '" + address + "');");
	}

	function cancelEdit(element, count, address) {
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

		cell = row.cells[4];
		cell.childNodes[0].style.display = null;
		cell.removeChild(cell.childNodes[1]);

		cell = row.cells[5];
		button = cell.childNodes[0];
		button.innerHTML = "Edit";
		button.setAttribute("onclick", "edit(this, '" + count + "', '" + address + "');");

		cell = row.cells[6];
		button = cell.childNodes[0];
		button.innerHTML = "Delete";
		button.setAttribute("onclick", "remove('" + count + "', '" + address + "');");
	}

	function toggleDisabledTableButtons(bool) {
		let tBody = $e("list").tBodies[0];
		let row, cell;

		for (let i = 0; i < tBody.rows.length; i++) {
			row = tBody.rows[i];
			row.cells[5].childNodes[0].disabled = bool;
			row.cells[6].childNodes[0].disabled = bool;
		}

		$e("button-add").disabled = bool;
		$e("button-clear").disabled = bool;
	}

	function reset() {
		$e("input-address").value = null;
		$e("input-name").value = null;
		$e("input-phone-no").value = null;
		$e("input-email").value = null;
		$e("input-location").value = null;
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
				<li><a class="selected" href="register-clinic.jsp">Clinic Registration</a></li>
			</ul>
			<ul>
				<li><a href="register-vaccine.jsp">Vaccine Registration</a></li>
			</ul>
		</div>
		<div class="content">
			<div class="table-message">
				<span class="table-message" id="span-message"></span>
			</div>
			<table id="list">
				<colgroup>
					<col style="width: 15%;">
					<col style="width: 18%;">
					<col style="width: 15%;">
					<col style="width: 15%;">
					<col style="width: 18%;">
					<col style="width: 9%;">
					<col style="width: 10%;">
				</colgroup>
				<thead>
					<tr>
						<th>Account Address</th>
						<th>Name</th>
						<th>Phone No</th>
						<th>Email</th>
						<th>Location</th>
						<th>Edit</th>
						<th>Delete</th>
					</tr>
				</thead>
				<tbody></tbody>
				<tfoot>
					<tr>
						<td><input id="input-address" type="text" maxlength="42" autocomplete="off"></td>
						<td><input id="input-name" type="text" maxlength="50" autocomplete="off"></td>
						<td><input id="input-phone-no" type="text" maxlength="15" autocomplete="off"></td>
						<td><input id="input-email" type="text" maxlength="50" autocomplete="off"></td>
						<td><input id="input-location" type="text" maxlength="200" autocomplete="off"></td>
						<td><button id="button-add" onclick="add();">Add</button></td>
						<td><button id="button-clear" onclick="reset();">Clear</button></td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</body>
</html>