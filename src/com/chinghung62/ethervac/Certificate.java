package com.chinghung62.ethervac;

import org.web3j.tuples.generated.Tuple15;

public class Certificate {
	private int id;
	private String patientAddress;
	private String icNo;
	private String patientName;
	private String gender;
	private String nationality;
	private String clinicAddress;
	private String clinicName;
	private String barcode;
	private String vaccineName;
	private String manufacturer;
	private String batchNo;
	private String date;
	private String patientSignature;
	private String clinicSignature;
	private boolean exist;

	public Certificate(int id,
			Tuple15<String, String, String, String, String, String, String, String, String, String, String, String, String, String, Boolean> certificate) {
		this.id = id;
		this.patientAddress = certificate.component1();
		this.icNo = certificate.component2();
		this.patientName = certificate.component3();
		this.gender = certificate.component4();
		this.nationality = certificate.component5();
		this.clinicAddress = certificate.component6();
		this.clinicName = certificate.component7();
		this.barcode = certificate.component8();
		this.vaccineName = certificate.component9();
		this.manufacturer = certificate.component10();
		this.batchNo = certificate.component11();
		this.date = certificate.component12();
		this.patientSignature = certificate.component13();
		this.clinicSignature = certificate.component14();
		this.exist = certificate.component15();
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getPatientAddress() {
		return patientAddress;
	}

	public void setPatientAddress(String patientAddress) {
		this.patientAddress = patientAddress;
	}

	public String getIcNo() {
		return icNo;
	}

	public void setIcNo(String icNo) {
		this.icNo = icNo;
	}

	public String getPatientName() {
		return patientName;
	}

	public void setPatientName(String patientName) {
		this.patientName = patientName;
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

	public String getClinicAddress() {
		return clinicAddress;
	}

	public void setClinicAddress(String clinicAddress) {
		this.clinicAddress = clinicAddress;
	}

	public String getClinicName() {
		return clinicName;
	}

	public void setClinicName(String clinicName) {
		this.clinicName = clinicName;
	}

	public String getBarcode() {
		return barcode;
	}

	public void setBarcode(String barcode) {
		this.barcode = barcode;
	}

	public String getVaccineName() {
		return vaccineName;
	}

	public void setVaccineName(String vaccineName) {
		this.vaccineName = vaccineName;
	}

	public String getManufacturer() {
		return manufacturer;
	}

	public void setManufacturer(String manufacturer) {
		this.manufacturer = manufacturer;
	}

	public String getBatchNo() {
		return batchNo;
	}

	public void setBatchNo(String batchNo) {
		this.batchNo = batchNo;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public String getPatientSignature() {
		return patientSignature;
	}

	public void setPatientSignature(String patientSignature) {
		this.patientSignature = patientSignature;
	}

	public String getClinicSignature() {
		return clinicSignature;
	}

	public void setClinicSignature(String clinicSignature) {
		this.clinicSignature = clinicSignature;
	}

	public boolean isExist() {
		return exist;
	}

	public void setExist(boolean exist) {
		this.exist = exist;
	}
}
