package com.chinghung62.ethervac;

import java.util.ArrayList;

public interface AdminInterface {
	public int getClinicCount();

	public int getVaccinationCount();

	public ArrayList<Admin> getAllAdmins();

	public Admin getAdmin();

	public Admin getAdmin(String address);

	public boolean addAdmin(String address, String name, String phoneNo, String email);

	public boolean updateAdmin(String name, String phoneNo, String email);

	public boolean updateAdmin(int count, String address, String name, String phoneNo, String email);

	public boolean deleteAdmin(int count, String address);

	public ArrayList<Clinic> getAllClinics();

	public Clinic getClinic(String address);

	public boolean addClinic(String address, String name, String phoneNo, String email, String location);

	public boolean updateClinic(int count, String address, String name, String phoneNo, String email, String location);

	public boolean deleteClinic(int count, String address);

	public ArrayList<Vaccine> getAllVaccines();

	public Vaccine getVaccine(String barcode);

	public boolean addVaccine(String barcode, String name, String purpose, String manufacturer);

	public boolean updateVaccine(int count, String barcode, String name, String purpose, String manufacturer);

	public boolean updateVaccineStatus(int count, String barcode, boolean ready);

	public boolean deleteVaccine(int count, String barcode);
}
