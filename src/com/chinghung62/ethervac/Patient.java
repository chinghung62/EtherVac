package com.chinghung62.ethervac;

import java.math.BigInteger;
import java.util.ArrayList;

import org.web3j.tuples.generated.Tuple7;

public class Patient extends User implements PatientInterface {
	private String callerAddress;
	private String address;
	private String icNo;
	private String name;
	private String gender;
	private String nationality;
	private String phoneNo;
	private String email;
	private boolean exist;

	public Patient(String address, Tuple7<String, String, String, String, String, String, Boolean> patient) {
		this.address = address;
		this.icNo = patient.component1();
		this.name = patient.component2();
		this.gender = patient.component3();
		this.nationality = patient.component4();
		this.phoneNo = patient.component5();
		this.email = patient.component6();
		this.exist = patient.component7();
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getIcNo() {
		return icNo;
	}

	public void setIcNo(String icNo) {
		this.icNo = icNo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getNationality() {
		return nationality;
	}

	public void setNationality(String nationality) {
		this.nationality = nationality;
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

	public boolean isExist() {
		return exist;
	}

	public void setExist(boolean exist) {
		this.exist = exist;
	}

	public Patient(String callerAddress) {
		this.callerAddress = callerAddress;
	}

	@Override
	public Patient getPatient() {
		try {
			return new Patient(this.callerAddress, this.etherVacContract.patients(this.callerAddress).send());
		} catch (Exception e) {
			System.out.println("Error! Patient.getPatient(): " + e);
		}

		return null;
	}

	@Override
	public boolean updatePatient(String icNo, String name, String gender, String nationality, String phoneNo,
			String email) {
		try {
			return this.etherVacContract
					.updatePatient(this.callerAddress, icNo, name, gender, nationality, phoneNo, email).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Patient.updatePatient(): " + e);
		}

		return false;
	}

	@Override
	public ArrayList<Certificate> getCertificates() {
		ArrayList<Certificate> certificates = new ArrayList<Certificate>();

		try {
			int certificateCount = this.etherVacContract.getPatientCertificateCount(this.callerAddress).send()
					.intValue();

			for (int i = certificateCount - 1; i >= 0; i--) {
				int certificateId = this.etherVacContract.patientCertificates(this.callerAddress, BigInteger.valueOf(i))
						.send().intValue();
				Certificate certificate = new Certificate(certificateId,
						this.etherVacContract.certificates(BigInteger.valueOf(certificateId)).send());

				if (certificate.isExist() && certificate.getPatientAddress().equals(this.callerAddress))
					certificates.add(certificate);
			}
		} catch (Exception e) {
			System.out.println("Error! Patient.getCertificates(): " + e);
		}

		return certificates;
	}

	@Override
	public boolean signCertificate(int id, String patientSignature) {
		try {
			return this.etherVacContract
					.patientSignCertificate(this.callerAddress, BigInteger.valueOf(id), patientSignature).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Patient.signCertificate(): " + e);
		}

		return false;
	}
}
