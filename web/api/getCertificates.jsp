<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.util.ArrayList"%>
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
	// check session for clinic & patient
	if ((!session.getAttribute("user_type").equals("clinic") && !session.getAttribute("user_type").equals("patient"))
	|| session.getAttribute("address") == null) {
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
	ArrayList<HashMap<String, Object>> result = new ArrayList<HashMap<String, Object>>();
	HashMap<String, Object> certificateDict;
	ArrayList<Certificate> certificates = new ArrayList<Certificate>();

	if (session.getAttribute("user_type").equals("clinic")) {
		Clinic u_clinic = new Clinic((String) session.getAttribute("address"));
		certificates = u_clinic.getCertificates();

		for (Certificate certificate : certificates) {
	certificateDict = new HashMap<String, Object>();
	certificateDict.put("id", certificate.getId());
	certificateDict.put("patient_address", certificate.getPatientAddress());
	certificateDict.put("ic_no", certificate.getIcNo());
	certificateDict.put("patient_name", certificate.getPatientName());
	certificateDict.put("gender", certificate.getGender());
	certificateDict.put("nationality", certificate.getNationality());
	certificateDict.put("barcode", certificate.getBarcode());
	certificateDict.put("vaccine_name", certificate.getVaccineName());
	certificateDict.put("manufacturer", certificate.getManufacturer());
	certificateDict.put("batch_no", certificate.getBatchNo());
	certificateDict.put("date", certificate.getDate());
	certificateDict.put("patient_signed", !certificate.getPatientSignature().equals("") ? true : false);
	certificateDict.put("clinic_signed", !certificate.getClinicSignature().equals("") ? true : false);
	result.add(certificateDict);
		}
	} else if (session.getAttribute("user_type").equals("patient")) {
		Patient u_patient = new Patient((String) session.getAttribute("address"));
		certificates = u_patient.getCertificates();

		for (Certificate certificate : certificates) {
	certificateDict = new HashMap<String, Object>();
	certificateDict.put("id", certificate.getId());
	certificateDict.put("clinic_address", certificate.getClinicAddress());
	certificateDict.put("clinic_name", certificate.getClinicName());
	certificateDict.put("barcode", certificate.getBarcode());
	certificateDict.put("vaccine_name", certificate.getVaccineName());
	certificateDict.put("manufacturer", certificate.getManufacturer());
	certificateDict.put("batch_no", certificate.getBatchNo());
	certificateDict.put("date", certificate.getDate());
	certificateDict.put("patient_signed", !certificate.getPatientSignature().equals("") ? true : false);
	certificateDict.put("clinic_signed", !certificate.getClinicSignature().equals("") ? true : false);
	result.add(certificateDict);
		}
	}

	rc.put("result", result);
	rc.put("ok", true);
}

// check unknown error
if ((boolean) rc.get("ok") == false && rc.get("description") == null) {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Unknown error found");
}

// echo JSON string of response content ($rc)
out.println(gson.toJson(rc));
%>