package com.chinghung62.ethervac;

import java.math.BigInteger;
import java.util.ArrayList;

import org.web3j.tuples.generated.Tuple5;

public class Clinic extends User implements ClinicInterface {
	private String callerAddress;
	private int count;
	private String address;
	private String name;
	private String phoneNo;
	private String email;
	private String location;
	private boolean exist;

	public Clinic(String address, Tuple5<String, String, String, String, Boolean> clinic) {
		this.address = address;
		this.name = clinic.component1();
		this.phoneNo = clinic.component2();
		this.email = clinic.component3();
		this.location = clinic.component4();
		this.exist = clinic.component5();
	}

	public Clinic(int count, String address, Tuple5<String, String, String, String, Boolean> clinic) {
		this.count = count;
		this.address = address;
		this.name = clinic.component1();
		this.phoneNo = clinic.component2();
		this.email = clinic.component3();
		this.location = clinic.component4();
		this.exist = clinic.component5();
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPhoneNo() {
		return phoneNo;
	}

	public void setPhoneNo(String phoneNo) {
		this.phoneNo = phoneNo;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public boolean isExist() {
		return exist;
	}

	public void setExist(boolean exist) {
		this.exist = exist;
	}

	public Clinic(String callerAddress) {
		this.callerAddress = callerAddress;
	}

	@Override
	public int getVaccinationCount() {
		int count = 0;

		try {
			int certificateCount = this.etherVacContract.getClinicCertificateCount(this.callerAddress).send()
					.intValue();

			for (int i = 0; i < certificateCount; i++) {
				int certificateId = this.etherVacContract.clinicCertificates(this.callerAddress, BigInteger.valueOf(i))
						.send().intValue();
				Certificate certificate = new Certificate(certificateId,
						this.etherVacContract.certificates(BigInteger.valueOf(certificateId)).send());

				if (certificate.isExist() && certificate.getClinicAddress().equals(this.callerAddress)
						&& !certificate.getClinicSignature().equals(""))
					count++;
			}

			return count;
		} catch (Exception e) {
			System.out.println("Error! Clinic.getCertificateCount(): " + e);
		}

		return -1;
	}

	@Override
	public Clinic getClinic() {
		try {
			return new Clinic(this.callerAddress, this.etherVacContract.clinics(this.callerAddress).send());
		} catch (Exception e) {
			System.out.println("Error! Clinic.getClinic(): " + e);
		}

		return null;
	}

	@Override
	public Patient getPatient(String address) {
		try {
			return new Patient(address, this.etherVacContract.patients(address).send());
		} catch (Exception e) {
			System.out.println("Error! Clinic.getPatient(): " + e);
		}

		return null;
	}

	@Override
	public ArrayList<Certificate> getCertificates() {
		ArrayList<Certificate> certificates = new ArrayList<Certificate>();

		try {
			int certificateCount = this.etherVacContract.getClinicCertificateCount(this.callerAddress).send()
					.intValue();

			for (int i = certificateCount - 1; i >= 0; i--) {
				int certificateId = this.etherVacContract.clinicCertificates(this.callerAddress, BigInteger.valueOf(i))
						.send().intValue();
				Certificate certificate = new Certificate(certificateId,
						this.etherVacContract.certificates(BigInteger.valueOf(certificateId)).send());

				if (certificate.isExist() && certificate.getClinicAddress().equals(this.callerAddress))
					certificates.add(certificate);
			}
		} catch (Exception e) {
			System.out.println("Error! Clinic.getCertificates(): " + e);
		}

		return certificates;
	}

	@Override
	public boolean addCertificate(String patientAddress, String icNo, String patientName, String gender,
			String nationality, String clinicName, String barcode, String vaccineName, String manufacturer,
			String batchNo, String date) {
		try {
			return this.etherVacContract.addCertificate(this.callerAddress, patientAddress, icNo, patientName, gender,
					nationality, clinicName, barcode, vaccineName, manufacturer, batchNo, date).send().isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Clinic.addCertificate(): " + e);
		}

		return false;
	}

	@Override
	public boolean deleteCertificate(int id) {
		try {
			return this.etherVacContract.removeCertificate(this.callerAddress, BigInteger.valueOf(id)).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Clinic.deleteCertificate(): " + e);
		}

		return false;
	}

	@Override
	public boolean signCertificate(int id, String clinicSignature) {
		try {
			return this.etherVacContract
					.clinicSignCertificate(this.callerAddress, BigInteger.valueOf(id), clinicSignature).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Clinic.signCertificate(): " + e);
		}

		return false;
	}
}
