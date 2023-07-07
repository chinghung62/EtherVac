package com.chinghung62.ethervac;

import java.util.ArrayList;

public interface ClinicInterface {
	public int getVaccinationCount();

	public Clinic getClinic();

	public Patient getPatient(String address);

	public ArrayList<Certificate> getCertificates();

	public boolean addCertificate(String patientAddress, String icNo, String patientName, String gender,
			String nationality, String clinicName, String barcode, String vaccineName, String manufacturer,
			String batchNo, String date);

	public boolean deleteCertificate(int id);

	public boolean signCertificate(int id, String clinicSignature);
}
