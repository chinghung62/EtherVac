// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 .0;

import "./Ownable.sol";
import "./Struct.sol";

/**
 * @title EtherVac
 * @author Tan Ching Hung
 * @notice This contract is only for educational purposes. All rights reserved.
 * @dev Contract that manages and stores the data of users, inventories and certificates.
 */

contract EtherVac is Ownable {
    using Struct for *;

    uint24 public adminCount;
    mapping(uint24 => address) public adminRegistry; // adminCount => adminAddress
    mapping(address => Struct.Admin) public admins; // adminAddress => Admin

    uint24 public clinicCount;
    mapping(uint24 => address) public clinicRegistry; // clinicCount => clinicAddress
    mapping(address => Struct.Clinic) public clinics; // clinicAddress => Clinic

    mapping(address => Struct.Patient) public patients; // patientAddress => Patient

    uint24 public vaccineCount;
    mapping(uint24 => string) public vaccineRegistry; // vaccineCount => barcode
    mapping(string => Struct.Vaccine) public vaccines; // barcode => Vaccine

    uint24 public certificateCount;
    mapping(uint24 => Struct.Certificate) public certificates; // certificateId => Certificate
    mapping(address => uint24[]) public patientCertificates; // patientAddress => certificateId[]
    mapping(address => uint24[]) public clinicCertificates; // clinicAddress => certificateId[]

    constructor() {
        adminRegistry[adminCount++] = msg.sender;
        admins[msg.sender] = Struct.Admin("CONTRACT_OWNER", "", "", true);
    }

    function addAdmin(
        address caller,
        address adminAddress,
        string memory name,
        string memory phoneNo,
        string memory email
    ) public onlyOwner onlyAdmin(caller) {
        require(
            !isClinic(adminAddress),
            "The address already exists as a Clinic."
        );
        require(!isAdmin(adminAddress), "The Admin already exists.");
        adminRegistry[adminCount++] = adminAddress;
        admins[adminAddress] = Struct.Admin(name, phoneNo, email, true);
    }

    function updateAdmin(
        address caller,
        uint24 count,
        address adminAddress,
        string memory name,
        string memory phoneNo,
        string memory email
    ) public onlyOwner onlyAdmin(caller) {
        require(
            adminRegistry[count] == adminAddress,
            "Count and address didn't match an entry."
        );
        require(isAdmin(adminAddress), "The Admin doesn't exist.");
        admins[adminAddress] = Struct.Admin(name, phoneNo, email, true);
    }

    function updateAdmin(
        address caller,
        string memory name,
        string memory phoneNo,
        string memory email
    ) public onlyOwner onlyAdmin(caller) {
        admins[caller] = Struct.Admin(name, phoneNo, email, true);
    }

    function removeAdmin(
        address caller,
        uint24 count,
        address adminAddress
    ) public onlyOwner onlyAdmin(caller) {
        require(count != 0, "Cannot remove CONTRACT OWNER.");
        require(
            adminRegistry[count] == adminAddress,
            "Count and address didn't match an entry."
        );
        require(
            caller != adminAddress,
            "Cannot remove the current calling Admin itself."
        );
        require(isAdmin(adminAddress), "The Admin doesn't exist.");
        delete adminRegistry[count];
        delete admins[adminAddress];
    }

    function addClinic(
        address caller,
        address clinicAddress,
        string memory name,
        string memory phoneNo,
        string memory email,
        string memory location
    ) public onlyOwner onlyAdmin(caller) {
        require(
            !isAdmin(clinicAddress),
            "The address already exists as an Admin."
        );
        require(!isClinic(clinicAddress), "The Clinic already exists.");
        clinicRegistry[clinicCount++] = clinicAddress;
        clinics[clinicAddress] = Struct.Clinic(
            name,
            phoneNo,
            email,
            location,
            true
        );
        clinicCertificates[clinicAddress];
    }

    function updateClinic(
        address caller,
        uint24 count,
        address clinicAddress,
        string memory name,
        string memory phoneNo,
        string memory email,
        string memory location
    ) public onlyOwner onlyAdmin(caller) {
        require(
            clinicRegistry[count] == clinicAddress,
            "Count and address didn't match an entry."
        );
        require(isClinic(clinicAddress), "The Clinic doesn't exist.");
        clinics[clinicAddress] = Struct.Clinic(
            name,
            phoneNo,
            email,
            location,
            true
        );
    }

    function removeClinic(
        address caller,
        uint24 count,
        address clinicAddress
    ) public onlyOwner onlyAdmin(caller) {
        require(
            clinicRegistry[count] == clinicAddress,
            "Count and address didn't match an entry."
        );
        require(isClinic(clinicAddress), "The Clinic doesn't exist.");
        delete clinicRegistry[count];
        delete clinics[clinicAddress];
    }

    function updatePatient(
        address caller,
        string memory icNo,
        string memory name,
        string memory gender,
        string memory nationality,
        string memory phoneNo,
        string memory email
    ) public onlyOwner {
        require(
            !isAdmin(caller),
            "The current caller already exists as an Admin."
        );
        require(
            !isClinic(caller),
            "The current caller already exists as a Clinic."
        );
        patients[caller] = Struct.Patient(
            icNo,
            name,
            gender,
            nationality,
            phoneNo,
            email,
            true
        );
        patientCertificates[caller];
    }

    function addVaccine(
        address caller,
        string memory barcode,
        string memory name,
        string memory purpose,
        string memory manufacturer
    ) public onlyOwner onlyAdmin(caller) {
        require(!vaccines[barcode].exist, "The Vaccine already exists.");
        vaccineRegistry[vaccineCount++] = barcode;
        vaccines[barcode] = Struct.Vaccine(
            name,
            purpose,
            manufacturer,
            false,
            true
        );
    }

    function updateVaccine(
        address caller,
        uint24 count,
        string memory barcode,
        string memory name,
        string memory purpose,
        string memory manufacturer
    ) public onlyOwner onlyAdmin(caller) {
        require(
            keccak256(abi.encodePacked(vaccineRegistry[count])) ==
                keccak256(abi.encodePacked(barcode)),
            "Count and barcode didn't match an entry."
        );
        require(vaccines[barcode].exist, "The Vaccine doesn't exist.");
        vaccines[barcode] = Struct.Vaccine(
            name,
            purpose,
            manufacturer,
            false,
            true
        );
    }

    function changeVaccineStatus(
        address caller,
        uint24 count,
        string memory barcode,
        bool status
    ) public onlyOwner onlyAdmin(caller) {
        require(
            keccak256(abi.encodePacked(vaccineRegistry[count])) ==
                keccak256(abi.encodePacked(barcode)),
            "Count and barcode didn't match an entry."
        );
        require(vaccines[barcode].exist, "The Vaccine doesn't exist.");
        vaccines[barcode].status = status;
    }

    function removeVaccine(
        address caller,
        uint24 count,
        string memory barcode
    ) public onlyOwner onlyAdmin(caller) {
        require(
            keccak256(abi.encodePacked(vaccineRegistry[count])) ==
                keccak256(abi.encodePacked(barcode)),
            "Count and barcode didn't match an entry."
        );
        require(vaccines[barcode].exist, "The Vaccine doesn't exist.");
        delete vaccineRegistry[count];
        delete vaccines[barcode];
    }

    function getClinicCertificateCount(address caller)
        public
        view
        onlyOwner
        onlyClinic(caller)
        returns (uint256)
    {
        return clinicCertificates[caller].length;
    }

    function getPatientCertificateCount(address caller)
        public
        view
        onlyOwner
        onlyPatient(caller)
        returns (uint256)
    {
        return patientCertificates[caller].length;
    }

    function addCertificate(
        address caller,
        address patient,
        string memory icNo,
        string memory patientName,
        string memory gender,
        string memory nationality,
        string memory clinicName,
        string memory barcode,
        string memory vaccineName,
        string memory manufacturer,
        string memory batchNo,
        string memory date
    ) public onlyOwner onlyClinic(caller) {
        require(isPatient(patient), "The Patient doesn't exist.");
        patientCertificates[patient].push() = certificateCount;
        clinicCertificates[caller].push() = certificateCount;
        certificates[certificateCount] = Struct.Certificate(
            patient,
            icNo,
            patientName,
            gender,
            nationality,
            caller,
            clinicName,
            barcode,
            vaccineName,
            manufacturer,
            batchNo,
            date,
            "",
            "",
            true
        );
        certificateCount++;
    }

    function removeCertificate(address caller, uint24 count)
        public
        onlyOwner
        onlyClinic(caller)
    {
        require(certificates[count].exist, "The Certificate doesn't exist.");
        require(
            caller == certificates[count].clinic,
            "The Certificate doesn't belong to the current calling Clinic."
        );
        require(
            bytes(certificates[count].clinicSign).length != 132,
            "The Certificate is already signed."
        );
        delete certificates[count];
    }

    function patientSignCertificate(
        address caller,
        uint24 count,
        string memory patientSign
    ) public onlyOwner onlyPatient(caller) {
        require(certificates[count].exist, "The Certificate doesn't exist.");
        require(
            caller == certificates[count].patient,
            "The Certificate doesn't belong to the current calling Patient."
        );
        require(
            bytes(certificates[count].patientSign).length != 132,
            "The Certificate is already signed."
        );
        certificates[count].patientSign = patientSign;
    }

    function clinicSignCertificate(
        address caller,
        uint24 count,
        string memory clinicSign
    ) public onlyOwner onlyClinic(caller) {
        require(certificates[count].exist, "The Certificate doesn't exist.");
        require(
            caller == certificates[count].clinic,
            "The Certificate doesn't belong to the current calling Clinic."
        );
        require(
            bytes(certificates[count].patientSign).length == 132,
            "The Certificate haven't signed by Patient yet."
        );
        require(
            bytes(certificates[count].clinicSign).length != 132,
            "The Certificate is already signed."
        );
        certificates[count].clinicSign = clinicSign;
    }

    modifier onlyAdmin(address addr) {
        require(isAdmin(addr), "Only Admin can use this function.");
        _;
    }

    function isAdmin(address addr) private view returns (bool) {
        return admins[addr].exist;
    }

    modifier onlyClinic(address addr) {
        require(isClinic(addr), "Only Clinic can use this function.");
        _;
    }

    function isClinic(address addr) private view returns (bool) {
        return clinics[addr].exist;
    }

    modifier onlyPatient(address addr) {
        require(isPatient(addr), "Only Patient can use this function.");
        _;
    }

    function isPatient(address addr) private view returns (bool) {
        return patients[addr].exist;
    }
}
