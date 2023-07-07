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
	if (!d.containsKey("data")) { // validate paramater 'data'
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: Parameter 'data' is required");
	} else if (d.get("data").equals("")) {
		rc.put("error_code", 400);
		rc.put("description", "Bad Request: 'data' can't be empty");
	} else {
		// permit execution
		execute = true;
	}
}

// execution
if (execute) {
	String data = (String) d.get("data");
	String[] parsedData = data.split("/");

	if (parsedData.length != 5) {
		rc.put("error_code", 400);
		rc.put("message", "Invalid QR Code.");
		rc.put("description", "Bad Request: Invalid value for 'data'");
	} else {
		String id = parsedData[0];
		String patientAddress = parsedData[1];
		String patientSignature = parsedData[2];
		String clinicAddress = parsedData[3];
		String clinicSignature = parsedData[4];

		User u_user = new User();
		Certificate certificate = u_user.getCertificate(Integer.parseUnsignedInt(id));

		if (certificate != null) {
	if (certificate.isExist()) {
		String certificateMessage = "EtherVac Vaccination Certificate\n\n----- Patient Details -----\nAddress: "
				+ certificate.getPatientAddress() + "\nIC: " + certificate.getIcNo() + "\nName: "
				+ certificate.getPatientName() + "\nGender: " + certificate.getGender() + "\nNationality: "
				+ certificate.getNationality() + "\n\n----- Clinic Details -----\nAddress: "
				+ certificate.getClinicAddress() + "\nName: " + certificate.getClinicName()
				+ "\n\n----- Vaccine Details -----\nBarcode: " + certificate.getBarcode() + "\nName: "
				+ certificate.getVaccineName() + "\nManufacturer: " + certificate.getManufacturer()
				+ "\nBatch No: " + certificate.getBatchNo() + "\n\nDate: " + certificate.getDate();

		if (EthereumSignature.verifySignature(patientSignature, certificateMessage, patientAddress)
				&& EthereumSignature.verifySignature(clinicSignature, certificateMessage, clinicAddress)) {
			rc.put("ok", true);
			rc.put("message", "The certificate is valid.");
		} else {
			rc.put("error_code", 400);
			rc.put("message", "The certificate is not valid.");
			rc.put("description", "Bad Request: The received data doesn't represent a valid certificate");
		}
	} else {
		rc.put("error_code", 400);
		rc.put("message", "The certificate doesn't exist.");
		rc.put("description", "Bad Request: The certificate doesn't exist");
	}
		} else {
	rc.put("error_code", 500);
	rc.put("description", "Internal Server Error: Smart Contract Error");
		}
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