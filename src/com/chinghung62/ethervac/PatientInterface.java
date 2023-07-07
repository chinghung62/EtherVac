package com.chinghung62.ethervac;

import java.util.ArrayList;

public interface PatientInterface {
	public Patient getPatient();

	public boolean updatePatient(String icNo, String name, String gender, String nationality, String phoneNo,
			String email);

	public ArrayList<Certificate> getCertificates();

	public boolean signCertificate(int id, String patientSignature);
}
