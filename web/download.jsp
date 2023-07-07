<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.FileInputStream"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.chinghung62.ethervac.*"%>


<%
// define logic control variables
boolean execute = false;

// check session for patient
if (session.getAttribute("address") == null || !session.getAttribute("user_type").equals("patient")) {
	out.println("401 Unauthorized: Session not found or invalid session");
} else if (request.getParameter("id") == null) { // validate parameter 'id'
	out.println("400 Bad Request: Parameter 'id' is required");
} else if (request.getParameter("id").equals("")) {
	out.println("400 Bad Request: 'id' can't be empty");
} else {
	boolean parseUnsignedIntError;

	// try to parse 'id' into unsigned integer
	try {
		Integer.parseUnsignedInt((String) request.getParameter("id"));
		parseUnsignedIntError = false;
	} catch (NumberFormatException e) {
		parseUnsignedIntError = true;
	}

	if (parseUnsignedIntError) {
		out.println("400 Bad Request: 'id' must be an unsigned integer");
	} else if (Integer.parseUnsignedInt((String) request.getParameter("id")) > 16777215) {
		out.println("400 Bad Request: 'id' is out of range");
	} else {
		// permit execution
		execute = true;
	}
}

if (execute) {
	Patient u_patient = new Patient((String) session.getAttribute("address"));
	Certificate certificate = u_patient.getCertificate(Integer.parseUnsignedInt((String) request.getParameter("id")));

	if (certificate == null) {
		out.println("500 Internal Server Error: Smart Contract Error");
	} else if (!certificate.isExist()) {
		out.println("400 Bad Request: The certificate doesn't exist");
	} else if (!certificate.getPatientAddress().equals(session.getAttribute("address"))) {
		out.println("400 Bad Request: The certificate doesn't belong to current patient");
	} else if (certificate.getPatientSignature().equals("")) {
		out.println("400 Bad Request: The certificate haven't signed by patient");
	} else if (certificate.getClinicSignature().equals("")) {
		out.println("400 Bad Request: The certificate haven't signed by clinic");
	} else {
		boolean ok1 = u_patient.generateQRImage(certificate);
		boolean ok2 = u_patient.generateCertificatePDF(certificate);

		if (ok1 && ok2) {
	if (request.getParameter("no_download") != null) {
		out.println("200 OK: Certificate generated internally.");
	} else {
		String certFolderPath = "storage/certificates";

		response.setContentType("application/octet-stream");
		response.setHeader("Content-Disposition",
				"attachment; filename=\"EtherVac_" + certificate.getPatientName() + "_" + certificate.getDate()
						+ "_" + Integer.toString(certificate.getId()) + ".pdf\"");
		FileInputStream fileInputStream = new FileInputStream(certFolderPath + "/"
				+ certificate.getPatientAddress() + "/" + "EtherVac_" + certificate.getPatientName() + "_"
				+ certificate.getDate() + "_" + Integer.toString(certificate.getId()) + ".pdf");
		ServletOutputStream outStream = response.getOutputStream();

		byte[] outputByte = new byte[4096];

		while (fileInputStream.read(outputByte, 0, 4096) != -1) {
			outStream.write(outputByte, 0, 4096);
		}

		fileInputStream.close();
		outStream.flush();
		outStream.close();
	}
		} else {
	out.println("500 Internal Server Error: Certificate Generation Error");
		}
	}
}
%>