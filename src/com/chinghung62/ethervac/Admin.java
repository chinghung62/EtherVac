package com.chinghung62.ethervac;

import java.math.BigInteger;
import java.util.ArrayList;

import org.web3j.tuples.generated.Tuple4;

public class Admin extends User implements AdminInterface {
	private String callerAddress;
	private int count;
	private String address;
	private String name;
	private String phoneNo;
	private String email;
	private boolean exist;

	public Admin(String address, Tuple4<String, String, String, Boolean> admin) {
		this.address = address;
		this.name = admin.component1();
		this.phoneNo = admin.component2();
		this.email = admin.component3();
		this.exist = admin.component4();
	}

	public Admin(int count, String address, Tuple4<String, String, String, Boolean> admin) {
		this.count = count;
		this.address = address;
		this.name = admin.component1();
		this.phoneNo = admin.component2();
		this.email = admin.component3();
		this.exist = admin.component4();
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

	public boolean isExist() {
		return exist;
	}

	public void setExist(boolean exist) {
		this.exist = exist;
	}

	public Admin(String callerAddress) {
		this.callerAddress = callerAddress;
	}

	@Override
	public int getClinicCount() {
		int count = 0;

		try {
			int clinicCount = this.etherVacContract.clinicCount().send().intValue();

			for (int i = 0; i < clinicCount; i++) {
				String clinicAddress = this.etherVacContract.clinicRegistry(BigInteger.valueOf(i)).send();
				Clinic clinic = new Clinic(clinicAddress, this.etherVacContract.clinics(clinicAddress).send());

				if (clinic.isExist())
					count++;
			}

			return count;
		} catch (Exception e) {
			System.out.println("Error! Admin.getClinicCount(): " + e);
		}

		return -1;
	}

	@Override
	public int getVaccinationCount() {
		int count = 0;

		try {
			int certificateCount = this.etherVacContract.certificateCount().send().intValue();

			for (int i = 0; i < certificateCount; i++) {
				Certificate certificate = new Certificate(i,
						this.etherVacContract.certificates(BigInteger.valueOf(i)).send());

				if (certificate.isExist() && !certificate.getClinicSignature().equals(""))
					count++;
			}

			return count;
		} catch (Exception e) {
			System.out.println("Error! Admin.getVaccinationCount(): " + e);
		}

		return -1;
	}

	@Override
	public ArrayList<Admin> getAllAdmins() {
		ArrayList<Admin> admins = new ArrayList<Admin>();

		try {
			int adminCount = this.etherVacContract.adminCount().send().intValue();

			for (int i = 0; i < adminCount; i++) {
				String adminAddress = this.etherVacContract.adminRegistry(BigInteger.valueOf(i)).send();
				Admin admin = new Admin(i, adminAddress, this.etherVacContract.admins(adminAddress).send());

				if (admin.exist)
					admins.add(admin);
			}
		} catch (Exception e) {
			System.out.println("Error! Admin.getAllAdmins(): " + e);
			return null;
		}

		return admins;
	}

	@Override
	public Admin getAdmin() {
		try {
			return new Admin(this.callerAddress, this.etherVacContract.admins(this.callerAddress).send());
		} catch (Exception e) {
			System.out.println("Error! Admin.getAdmin(): " + e);
		}

		return null;
	}

	@Override
	public Admin getAdmin(String address) {
		try {
			return new Admin(address, this.etherVacContract.admins(address).send());
		} catch (Exception e) {
			System.out.println("Error! Admin.getAdmin(): " + e);
		}

		return null;
	}

	@Override
	public boolean addAdmin(String address, String name, String phoneNo, String email) {
		try {
			return this.etherVacContract.addAdmin(this.callerAddress, address, name, phoneNo, email).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.addAdmin(): " + e);
		}

		return false;
	}

	@Override
	public boolean updateAdmin(String name, String phoneNo, String email) {
		try {
			return this.etherVacContract.updateAdmin(this.callerAddress, name, phoneNo, email).send().isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.updateAdmin(): " + e);
		}

		return false;
	}

	@Override
	public boolean updateAdmin(int count, String address, String name, String phoneNo, String email) {
		try {
			return this.etherVacContract
					.updateAdmin(this.callerAddress, BigInteger.valueOf(count), address, name, phoneNo, email).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.updateAdmin(): " + e);
		}

		return false;
	}

	@Override
	public boolean deleteAdmin(int count, String address) {
		try {
			return this.etherVacContract.removeAdmin(this.callerAddress, BigInteger.valueOf(count), address).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.deleteAdmin(): " + e);
		}

		return false;
	}

	@Override
	public ArrayList<Clinic> getAllClinics() {
		ArrayList<Clinic> clinics = new ArrayList<Clinic>();

		try {
			int clinicCount = this.etherVacContract.clinicCount().send().intValue();

			for (int i = 0; i < clinicCount; i++) {
				String clinicAddress = this.etherVacContract.clinicRegistry(BigInteger.valueOf(i)).send();
				Clinic clinic = new Clinic(i, clinicAddress, this.etherVacContract.clinics(clinicAddress).send());

				if (clinic.isExist())
					clinics.add(clinic);
			}
		} catch (Exception e) {
			System.out.println("Error! Admin.getAllClinics(): " + e);
			return null;
		}

		return clinics;
	}

	@Override
	public Clinic getClinic(String address) {
		try {
			return new Clinic(address, this.etherVacContract.clinics(address).send());
		} catch (Exception e) {
			System.out.println("Error! Admin.getClinic(): " + e);
		}

		return null;
	}

	@Override
	public boolean addClinic(String address, String name, String phoneNo, String email, String location) {
		try {
			return this.etherVacContract.addClinic(this.callerAddress, address, name, phoneNo, email, location).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.addClinic(): " + e);
		}

		return false;
	}

	@Override
	public boolean updateClinic(int count, String address, String name, String phoneNo, String email, String location) {
		try {
			return this.etherVacContract.updateClinic(this.callerAddress, BigInteger.valueOf(count), address, name,
					phoneNo, email, location).send().isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.updateClinic(): " + e);
		}

		return false;
	}

	@Override
	public boolean deleteClinic(int count, String address) {
		try {
			return this.etherVacContract.removeClinic(this.callerAddress, BigInteger.valueOf(count), address).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.deleteClinic(): " + e);
		}

		return false;
	}

	@Override
	public ArrayList<Vaccine> getAllVaccines() {
		ArrayList<Vaccine> vaccines = new ArrayList<Vaccine>();

		try {
			int vaccineCount = this.etherVacContract.vaccineCount().send().intValue();

			for (int i = vaccineCount - 1; i >= 0; i--) {
				String isbn = this.etherVacContract.vaccineRegistry(BigInteger.valueOf(i)).send();
				Vaccine vaccine = new Vaccine(i, isbn, this.etherVacContract.vaccines(isbn).send());

				if (vaccine.isExist())
					vaccines.add(vaccine);
			}
		} catch (Exception e) {
			System.out.println("Error! Admin.getAllVaccines(): " + e);
			return null;
		}

		return vaccines;
	}

	@Override
	public Vaccine getVaccine(String barcode) {
		try {
			return new Vaccine(barcode, this.etherVacContract.vaccines(barcode).send());
		} catch (Exception e) {
			System.out.println("Error! Admin.getVaccine(): " + e);
		}

		return null;
	}

	@Override
	public boolean addVaccine(String barcode, String name, String purpose, String manufacturer) {
		try {
			return this.etherVacContract.addVaccine(this.callerAddress, barcode, name, purpose, manufacturer).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.addVaccine(): " + e);
		}

		return false;
	}

	@Override
	public boolean updateVaccine(int count, String barcode, String name, String purpose, String manufacturer) {
		try {
			return this.etherVacContract
					.updateVaccine(this.callerAddress, BigInteger.valueOf(count), barcode, name, purpose, manufacturer)
					.send().isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.updateVaccine(): " + e);
		}

		return false;
	}

	@Override
	public boolean updateVaccineStatus(int count, String barcode, boolean ready) {
		try {
			return this.etherVacContract
					.changeVaccineStatus(this.callerAddress, BigInteger.valueOf(count), barcode, ready).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.changeVaccineStatus(): " + e);
		}

		return false;
	}

	@Override
	public boolean deleteVaccine(int count, String barcode) {
		try {
			return this.etherVacContract.removeVaccine(this.callerAddress, BigInteger.valueOf(count), barcode).send()
					.isStatusOK();
		} catch (Exception e) {
			System.out.println("Error! Admin.deleteVaccine(): " + e);
		}

		return false;
	}
}
