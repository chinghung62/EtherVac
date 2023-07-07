<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Collections"%>
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
	if (!d.containsKey("user_type")) { // validate paramater 'user_type'
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: Parameter 'user_type' is required");
	} else if (d.get("user_type").equals("")) {
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: 'user_type' can't be empty");
	} else {
		ArrayList<String> allowedUserTypes = new ArrayList<String>();
		Collections.addAll(allowedUserTypes, "admin", "clinic", "patient");

		if (!allowedUserTypes.contains(((String) d.get("user_type")).toLowerCase())) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Invalid value for 'user_type'");
		} else if (!d.containsKey("address")) { // validate parameter 'address'
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Parameter 'address' is required");
		} else if (d.get("address").equals("")) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: 'address' can't be empty");
		} else if (!User.verifyAddress((String) d.get("address"))) {
	rc.put("error_code", 400);
	rc.put("description", "Bad Request: Invalid value for 'address'");
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
	String loginMessage = "Welcome to EtherVac!\n\nYou're about to log in as '"
	+ ((String) d.get("user_type")).toLowerCase() + "'.\n\nWallet address:\n" + (String) d.get("address")
	+ "\n\nNonce:\n" + uuid;

	if (!EthereumSignature.verifySignature((String) d.get("signature"), loginMessage, (String) d.get("address"))) {
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: Invalid message signature");
	} else {
		User u_user = new User();

		if (d.get("user_type").equals("patient")) {
	if (!u_user.checkExistence("admin", (String) d.get("address"))
			&& !u_user.checkExistence("clinic", (String) d.get("address"))) {
		session.setAttribute("user_type", ((String) d.get("user_type")).toLowerCase());
		session.setAttribute("address", (String) d.get("address"));
		session.setMaxInactiveInterval(1800);

		if (!u_user.checkExistence("patient", (String) d.get("address"))) {
			rc.put("redirect", "register.jsp");
		} else {
			rc.put("redirect", "patient.jsp");
		}

		rc.put("message", "Login successful.");
		rc.put("ok", true);
	} else {
		rc.put("error_code", 401);
		rc.put("message", "This account is already registered as admin or clinic.");
		rc.put("description", "Unauthorized: Account already registered as admin or clinic");
	}
		} else {
	if (u_user.checkExistence(((String) d.get("user_type")).toLowerCase(), (String) d.get("address"))) {
		session.setAttribute("user_type", ((String) d.get("user_type")).toLowerCase());
		session.setAttribute("address", (String) d.get("address"));
		session.setMaxInactiveInterval(1800);
		rc.put("redirect", (String) d.get("user_type") + ".jsp");
		rc.put("message", "Login successful.");
		rc.put("ok", true);
	} else {
		rc.put("error_code", 401);
		rc.put("message", "This account is not registered as " + d.get("user_type") + ".");
		rc.put("description", "Unauthorized: Account not registered");
	}
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