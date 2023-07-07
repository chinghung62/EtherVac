package com.chinghung62.ethervac;

import java.io.File;
import java.math.BigInteger;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.PDPageContentStream.AppendMode;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

public class User {
	private final String WRAPPER_NAME = "EtherVac";
	protected EtherVac etherVacContract;

	public User() {
		this.etherVacContract = (EtherVac) new ContractHandler().load(WRAPPER_NAME);
	}

	public static String generateUUID() {
		UUID uuid = UUID.randomUUID();
		return uuid.toString();
	}

	public static boolean verifyAddress(String address) {
		String regex = "^(0x)?[0-9A-Fa-f]{40}$";
		return Pattern.compile(regex).matcher(address).matches();
	}

	public static boolean verifySignature(String signature) {
		String regex = "^(0x)?[0-9A-Fa-f]{130}$";
		return Pattern.compile(regex).matcher(signature).matches();
	}

	public static boolean verifyEmail(String email) {
		String regex = "^[A-z0-9_-]+(\\.[A-z0-9_-]+)*@([A-z0-9-]+\\.)+[A-z]{2,7}$";
		return Pattern.compile(regex).matcher(email).matches();
	}

	public static boolean verifyDate(String dateStr) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		sdf.setLenient(true);
		boolean sdfParseOK = false;

		try {
			String parsedDateStr = sdf.format(sdf.parse(dateStr));

			if (dateStr.equals(parsedDateStr))
				sdfParseOK = true;
		} catch (ParseException e) {
			System.out.println("Error! User.verifyDate(): " + e);
		}

		return sdfParseOK;
	}

	public boolean checkExistence(String userType, String address) {
		try {
			if (userType.equals("admin")) {
				Admin admin = new Admin(address, this.etherVacContract.admins(address).send());

				if (admin.isExist()) {
					return admin.isExist();
				}
			} else if (userType.equals("clinic")) {
				Clinic clinic = new Clinic(address, this.etherVacContract.clinics(address).send());

				if (clinic.isExist()) {
					return clinic.isExist();
				}
			} else if (userType.equals("patient")) {
				Patient patient = new Patient(address, this.etherVacContract.patients(address).send());

				if (patient.isExist()) {
					return patient.isExist();
				}
			}
		} catch (Exception e) {
			System.out.println("Error! User.checkExistence(): " + e);
		}

		return false;
	}

	public ArrayList<Vaccine> getRecentVaccines() {
		ArrayList<Vaccine> vaccines = new ArrayList<Vaccine>();

		try {
			int vaccineCount = this.etherVacContract.vaccineCount().send().intValue();

			for (int i = vaccineCount - 1; i >= 0; i--) {
				String barcode = this.etherVacContract.vaccineRegistry(BigInteger.valueOf(i)).send();
				Vaccine vaccine = new Vaccine(barcode, this.etherVacContract.vaccines(barcode).send());

				if (vaccine.isExist())
					vaccines.add(vaccine);
			}
		} catch (Exception e) {
			System.out.println("Error! User.getVaccines(): " + e);
		}

		return vaccines;
	}

	public Certificate getCertificate(int id) {
		try {
			return new Certificate(id, this.etherVacContract.certificates(BigInteger.valueOf(id)).send());
		} catch (Exception e) {
			System.out.println("Error! User.getCertificate(): " + e);
		}

		return null;
	}

	@SuppressWarnings("deprecation")
	public boolean generateQRImage(Certificate certificate) {
		String folderPath = "storage/qr/";
		String data = Integer.toString(certificate.getId()) + "/" + certificate.getPatientAddress() + "/"
				+ certificate.getPatientSignature() + "/" + certificate.getClinicAddress() + "/"
				+ certificate.getClinicSignature();

		try {
			Map<EncodeHintType, Object> hintMap = new HashMap<EncodeHintType, Object>();
//			hintMap.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.L);
			hintMap.put(EncodeHintType.MARGIN, 0);

			BitMatrix bitMatrix = new QRCodeWriter().encode(data, BarcodeFormat.QR_CODE, 1000, 1000, hintMap);
			MatrixToImageWriter.writeToFile(bitMatrix, "png", new File(folderPath + certificate.getId() + ".png"));

			return true;
		} catch (Exception e) {
			System.out.println("Error! User.generateQRImage(): " + e);
		}

		return false;
	}

	public boolean generateCertificatePDF(Certificate certificate) {
		String certFolderPath = "storage/certificates";
		String qrFolderPath = "storage/qr";

		try {
			File patientFolder = new File(certFolderPath + "/" + certificate.getPatientAddress() + "/");
			if (!patientFolder.exists())
				patientFolder.mkdir();

			File pdfFile = new File(certFolderPath + "/cert-template.pdf");
			PDDocument pdfDocument = PDDocument.load(pdfFile);
			PDPage pdfPage1 = pdfDocument.getPage(0);
			PDPageContentStream pdfStream = new PDPageContentStream(pdfDocument, pdfPage1, AppendMode.APPEND, false);
			pdfStream.beginText();
			pdfStream.setFont(PDType1Font.COURIER_BOLD, 13);
			pdfStream.setLeading(13f);
			pdfStream.newLineAtOffset(42, 710);
			pdfStream.showText(certificate.getPatientName());
			pdfStream.newLineAtOffset(0, -39);
			pdfStream.showText(certificate.getPatientAddress());
			pdfStream.newLineAtOffset(0, -39);
			pdfStream.showText(certificate.getNationality());
			pdfStream.newLineAtOffset(251, 0);
			pdfStream.showText(certificate.getIcNo());
			pdfStream.newLineAtOffset(-251, -39);
			pdfStream.showText(certificate.getGender());
			pdfStream.newLineAtOffset(0, -88);
			pdfStream.showText(certificate.getClinicName());
			pdfStream.newLineAtOffset(0, -39);
			pdfStream.showText(certificate.getClinicAddress());
			pdfStream.newLineAtOffset(0, -39);
			pdfStream.showText(certificate.getVaccineName());
			pdfStream.newLineAtOffset(251, 0);
			pdfStream.showText(certificate.getBarcode());
			pdfStream.newLineAtOffset(-251, -39);
			pdfStream.showText(certificate.getManufacturer());
			pdfStream.newLineAtOffset(251, 0);
			pdfStream.showText(certificate.getBatchNo());
			pdfStream.newLineAtOffset(-251, -39);
			pdfStream.showText(certificate.getDate());
			pdfStream.endText();
			PDImageXObject pdfImageQR = PDImageXObject.createFromFile(qrFolderPath + "/" + certificate.getId() + ".png",
					pdfDocument);
			pdfStream.drawImage(pdfImageQR, 53, 123, 165, 165);
			pdfStream.close();
			pdfDocument.save(certFolderPath + "/" + certificate.getPatientAddress() + "/" + "EtherVac_"
					+ certificate.getPatientName() + "_" + certificate.getDate() + "_"
					+ Integer.toString(certificate.getId()) + ".pdf");
			pdfDocument.close();

			return true;
		} catch (Exception e) {
			System.out.println("Error! User.generateCertificatePDF(): " + e);
		}

		return false;
	}
}
