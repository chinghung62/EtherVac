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
	// check session for all user types
	if (session.getAttribute("user_type") == null || session.getAttribute("address") == null) {
		rc.put("redirect", "index.jsp");
		rc.put("error_code", 401);
		rc.put("description", "Unauthorized: Session not found or invalid session");
	} else {
		// permit execution
		execute = true;
	}
}

// execution
if (execute) {
	if (session.getAttribute("user_type").equals("admin")) {
		Admin u_admin = new Admin((String) session.getAttribute("address"));
		Admin admin = u_admin.getAdmin((String) session.getAttribute("address"));

		if (admin != null) {
	rc.put("address", admin.getAddress());
	rc.put("name", admin.getName());
	rc.put("ok", true);
		} else {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Smart Contract Error");
		}
	} else if (session.getAttribute("user_type").equals("clinic")) {
		Clinic u_clinic = new Clinic((String) session.getAttribute("address"));
		Clinic clinic = u_clinic.getClinic();

		if (clinic != null) {
	rc.put("address", clinic.getAddress());
	rc.put("name", clinic.getName());
	rc.put("ok", true);
		} else {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Smart Contract Error");
		}
	} else if (session.getAttribute("user_type").equals("patient")) {
		Patient u_patient = new Patient((String) session.getAttribute("address"));
		Patient patient = u_patient.getPatient();

		if (patient != null) {
	rc.put("address", patient.getAddress());
	rc.put("name", patient.getName());
	rc.put("ok", true);
		} else {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Smart Contract Error");
		}
	} else {
		rc.put("redirect", "index.jsp");
		rc.put("error_code", 401);
		rc.put("description", "Unauthorized: Session not found or invalid session");
	}
}

// check unknown error
if ((boolean) rc.get("ok") == false && rc.get("description") == null) {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Unknown error found");
}

// echo JSON string of response content ($rc)
out.println(gson.toJson(rc));
%>