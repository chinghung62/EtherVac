package com.chinghung62.ethervac;

import org.web3j.tuples.generated.Tuple5;

public class Vaccine {
	private int count;
	private String barcode;
	private String name;
	private String purpose;
	private String manufacturer;
	private boolean ready;
	private boolean exist;

	public Vaccine(String barcode, Tuple5<String, String, String, Boolean, Boolean> vaccine) {
		this.barcode = barcode;
		this.name = vaccine.component1();
		this.purpose = vaccine.component2();
		this.manufacturer = vaccine.component3();
		this.ready = vaccine.component4();
		this.exist = vaccine.component5();
	}

	public Vaccine(int count, String barcode, Tuple5<String, String, String, Boolean, Boolean> vaccine) {
		this.count = count;
		this.barcode = barcode;
		this.name = vaccine.component1();
		this.purpose = vaccine.component2();
		this.manufacturer = vaccine.component3();
		this.ready = vaccine.component4();
		this.exist = vaccine.component5();
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public String getBarcode() {
		return barcode;
	}

	public void setBarcode(String barcode) {
		this.barcode = barcode;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPurpose() {
		return purpose;
	}

	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}

	public String getManufacturer() {
		return manufacturer;
	}

	public void setManufacturer(String manufacturer) {
		this.manufacturer = manufacturer;
	}

	public boolean isReady() {
		return ready;
	}

	public void setReady(boolean ready) {
		this.ready = ready;
	}

	public boolean isExist() {
		return exist;
	}

	public void setExist(boolean exist) {
		this.exist = exist;
	}
}
