/*
JavaScript Helper 1.0.6
~~~~~~~~~~~~~~~~~~~~~~~

JavaScript Helper is written in JavaScript, specially designed for web
development project.
Contains Element Handler, AJAX Handler, HTML Entity Encoder and JSON Mapper.

Element Handler
		Allows getting one or more elements based on element id, class name,
		name and tag name quickly.

AJAX Handler
		Handles AJAX (Asynchronous JavaScript and XML) requests and responses
		for server API interaction.
		Send XML HTTP requests and supports Content-Type of application/json
		and Form-Data.
		Supports callback to user-defined function to receive and handle
		response data.
		Supports consecutive function-call upon receiving responses.
		Provides error handling, safely output the error message when error
		occurs.

HTML Entity Encoder
		Handles HTML entity encoding by encoding HTML reserved characters and
		special characters into entities to correctly display these characters
		as well as to prevent Cross-Site Scripting (XSS) attack.
		Provides a decoder to decode HTML entities into original characters.

JSON Mapper
		Provides mapping function to map each node while traversing all nodes
		in JSON object.


Basic usage:
````````````

... get the value of the element with id 'input-user-id':

	> var value = $e("input-user-id").value;

... or get the second element with tag name 'button':

	> var secondButton = $t("button")[1];

and

... send HTTP request to 'api/login.jsp':

	> XHRequest("login", jsonString);

... or send HTTP request to with callback:

	> function handlerFunction(responseContent) {};
	> XHRequest("sampleAPI", jsonString, {callback: "handlerFunction"});

... or send a Form-Data object through HTTP request asynchronously:

	> XHRFormData("upload", formData, {async: false});

and

... encode HTML reserved characters:

	> encHTML(text);

... or decode HTML entities:

	> decHTML(text);

and

... map a JSON object with a function:

	> mapJSON(JSONObj, myFunction);


Note: Please prepare a SPAN element with id 'span-message' in case to receive
	  response messages.


Version      : 1.0.6
Last updated : 09/06/2023, 03:02:54 UTC
Author       : Tan Ching Hung
GitHub       : chinghung62
Telegram     : @chinghung62
Email        : chinghung0602@gmail.com
*/

function $e(id) {
	return document.getElementById(id);
}


function $c(className) {
	return document.getElementsByClassName(className);
}


function $n(name) {
	return document.getElementsByName(name);
}


function $t(tagName) {
	return document.getElementsByTagName(tagName);
}


function XHRequest(APIMethod, jsonString, { async = true, callback = null, nextCall = null } = {}) {
	var xhttp = new XMLHttpRequest();
	xhttp.open("POST", "api/" + APIMethod + ".jsp", async);
	xhttp.setRequestHeader("Content-Type", "application/json");

	xhttp.onreadystatechange = function() {
		if (this.readyState === 4) {
			switch (this.status) {
				case 200:
					var rc = JSON.parse(this.responseText);

					if (rc["ok"] !== true) {
						if ("message" in rc) {
							$e("span-message").innerHTML = rc["message"];
						} else {
							$e("span-message").innerHTML = null;
							alert("Error " + rc["error_code"] + ": " + rc["description"]);
						}
					}

					if ("redirect" in rc) location.href = rc["redirect"];
					if (callback != null) window[callback](rc);

					break;
				case 404:
					$e("span-message").innerHTML = null;
					alert("Requested server file not found. Error code: " + this.status);
					break;
				default:
					$e("span-message").innerHTML = null;
					alert("Request failed. " + this.statusText + "Error Code: " + this.status);
			}

			if (nextCall != null) window[nextCall]();
		}
	}

	xhttp.send(jsonString);
}


function XHRFormData(APIHandler, formData, { async = true, callback = null, nextCall = null } = {}) {
	var xhttp = new XMLHttpRequest();
	xhttp.open("POST", "api/" + APIHandler + ".jsp", async);

	xhttp.onreadystatechange = function() {
		if (this.readyState === 4) {
			switch (this.status) {
				case 200:
					var rc = JSON.parse(this.responseText);

					if (rc["ok"] !== true) {
						if ("message" in rc) {
							$e("span-message").innerHTML = rc["message"];
						} else {
							$e("span-message").innerHTML = null;
							alert("Error " + rc["error_code"] + ": " + rc["description"]);
						}
					}

					if ("redirect" in rc) location.href = rc["redirect"];
					if (callback != null) window[callback](rc);

					break;
				case 404:
					alert("Requested server file not found. Error code: " + this.status);
					break;
				default:
					alert("Request failed. " + this.statusText + "Error Code: " + this.status);
			}

			if (nextCall != null) window[nextCall]();
		}
	}

	xhttp.send(formData);
}

function encHTML(text) {
	if (typeof (text) == "string") {
		text = text.replaceAll("&", "&amp;");
		text = text.replaceAll("\"", "&quot;");
		text = text.replaceAll("'", "&apos;");
		text = text.replaceAll("<", "&lt;");
		text = text.replaceAll(">", "&gt;");
		text = text.replace(/[\u00A0-\u9999]/, ((c) => `&#${c.charCodeAt(0)};`));
	}

	return text;
}

function decHTML(text) {
	if (typeof (text) == "string") {
		text = text.replaceAll("&amp;", "&");
		text = text.replaceAll("&quot;", "\"");
		text = text.replaceAll("&apos;", "'");
		text = text.replaceAll("&lt;", "<");
		text = text.replaceAll("&gt;", ">");
		text = text.replace(/&#(\d+);/, ((match, g1) => `${String.fromCharCode(g1)}`));
	}

	return text;
}

function mapJSON(JSONObj, func) {
	let outputObj = {};

	for (key in JSONObj) {
		if (JSONObj[key] !== null) {
			if (typeof (JSONObj[key]) == "object") {
				outputObj[key] = mapJSON(JSONObj[key], func);
			} else {
				outputObj[key] = func(JSONObj[key]);
			}
		}
	}

	return outputObj;
}
