<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonSyntaxException"%>
<%@ page import="com.google.gson.reflect.TypeToken"%>
<%@ page import="com.chinghung62.ethervac.*"%>


<%
// create Gson object (for JSON)
Gson gson = new Gson();

// create a HashMap of data ($d)
HashMap<String, Object> d = new HashMap<String, Object>();

// create a HashMap of response content ($rc)
HashMap<String, Object> rc = new HashMap<String, Object>();
rc.put("ok", false);

// define logic control variables
boolean validate = false;
boolean execute = false;

if (!request.getMethod().equals("POST")) { // check whether request method is 'POST'
	rc.put("error_code", 405);
	rc.put("description", "Method Not Allowed: No POST request was received");
} else if (request.getContentType() == null) { // check the existence of Content-Type header
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Bad POST Request: Undefined content-type");
} else if (!request.getContentType().equals("application/json")) { // check whether Content-Type is 'application/json'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Bad POST Request: Unsupported content-type");
} else {
	// read raw data from the request body
	BufferedReader br = request.getReader();
	String reqBody = br.readLine();
	br.close();

	if (reqBody == null) { // check whether request body is not null
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: Bad POST Request: Content is empty");
	} else {
		boolean JSONError;

		// try JSON parsing request body and convert into HashMap $d
		try {
	d = gson.fromJson(reqBody, new TypeToken<HashMap<String, Object>>() {
	}.getType());
	JSONError = false;
		} catch (JsonSyntaxException e) {
	JSONError = true;
		}

		// check whether there are no error in JSON parsing
		if (JSONError) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Bad POST Request: Can't parse JSON object");
		} else {
	// perform parameter validation
	validate = true;
		}
	}
}

// parameter validation
if (validate) {
	// check session for admin
	if (!session.getAttribute("user_type").equals("admin") || session.getAttribute("address") == null) {
		rc.put("redirect", "index.jsp");
		rc.put("error_code", 401);
		rc.put("description", "Unauthorized: Session not found or invalid session");
	} else if (!d.containsKey("count")) { // validate parameter 'count'
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: Parameter 'count' is required");
	} else if (d.get("count").equals("")) {
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: 'count' can't be empty");
	} else {
		boolean parseUnsignedIntError;

		// try to parse 'count' into unsigned integer
		try {
	Integer.parseUnsignedInt((String) d.get("count"));
	parseUnsignedIntError = false;
		} catch (NumberFormatException e) {
	parseUnsignedIntError = true;
		}

		if (parseUnsignedIntError) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'count' must be an unsigned integer");
		} else if (Integer.parseUnsignedInt((String) d.get("count")) > 16777215) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'count' is out of range");
		} else if (!d.containsKey("address")) { // validate parameter 'address'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'address' is required");
		} else if (d.get("address").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'address' can't be empty");
		} else if (!User.verifyAddress((String) d.get("address"))) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Invalid value for 'address'");
		} else if (!d.containsKey("name")) { // validate parameter 'name'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'name' is required");
		} else if (d.get("name").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'name' can't be empty");
		} else if (((String) d.get("name")).length() > 50) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'name' length can't be more than 50");
		} else if (!d.containsKey("phone_no")) { // validate parameter 'phone_no'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'phone_no' is required");
		} else if (d.get("phone_no").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'phone_no' can't be empty");
		} else if (((String) d.get("phone_no")).length() > 15) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'phone_no' length can't be more than 15");
		} else if (!d.containsKey("email")) { // validate parameter 'email'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'email' is required");
		} else if (d.get("email").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'email' can't be empty");
		} else if (((String) d.get("email")).length() > 50) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'email' length can't be more than 50");
		} else if (!User.verifyEmail((String) d.get("email"))) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Invalid value for 'email'");
		} else if (!d.containsKey("signature")) { // validate parameter 'signature'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'signature' is required");
		} else if (d.get("signature").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'signature' can't be empty");
		} else if (!User.verifySignature((String) d.get("signature"))) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Invalid value for 'signature'");
		} else {
	// permit execution
	execute = true;
		}
	}
}

// execution
if (execute) {
	String uuid = session.getAttribute("uuid") != null ? (String) session.getAttribute("uuid") : "";
	String message = "Welcome to EtherVac!\n\nYou're about to update an existing admin.\n\nWallet address:\n"
	+ (String) session.getAttribute("address") + "\n\nNonce:\n" + uuid;

	if (!EthereumSignature.verifySignature((String) d.get("signature"), message,
	(String) session.getAttribute("address"))) {
		rc.put("error_code", 400);
		rc.put("message", "Invalid signature or incorrect account used.");
		rc.put("description", "Bad Request: Invalid message signature");
	} else {
		Admin u_admin = new Admin((String) session.getAttribute("address"));
		Admin admin = u_admin.getAdmin((String) d.get("address"));

		if (admin != null) {
	if (admin.isExist()) {
		boolean ok = u_admin.updateAdmin(Integer.parseUnsignedInt((String) d.get("count")),
				(String) d.get("address"), (String) d.get("name"), (String) d.get("phone_no"),
				(String) d.get("email"));

		if (ok) {
			rc.put("ok", true);
		} else {
			rc.put("error_code", 500);
			rc.put("description", "Internal Server Error: Smart Contract Error");
		}
	} else {
		rc.put("error_code", 400);
		rc.put("message", "The admin doesn't exist.");
		rc.put("description", "Bad Request: The admin doesn't exist");
	}
		} else {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Smart Contract Error");
		}
	}

	session.removeAttribute("uuid");
}

// check unknown error
if ((boolean) rc.get("ok") == false && rc.get("description") == null) {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Unknown error found");
}

// echo JSON string of response content ($rc) 
out.println(gson.toJson(rc));
%>