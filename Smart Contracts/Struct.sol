// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 .0;

/**
 * @title Struct
 * @author Tan Ching Hung
 * @notice This contract is only for educational purposes. All rights reserved.
 * @dev Library that provides the struct of roles and objects.
 */

library Struct {
    struct Admin {
        string name;
        string phoneNo;
        string email;
        bool exist;
    }

    struct Clinic {
        string name;
        string phoneNo;
        string email;
        string location;
        bool exist;
    }

    struct Patient {
        string icNo;
        string name;
        string gender;
        string nationality;
        string phoneNo;
        string email;
        bool exist;
    }

    struct Vaccine {
        string name;
        string purpose;
        string manufacturer;
        bool status;
        bool exist;
    }

    struct Certificate {
        address patient;
        string icNo;
        string patientName;
        string gender;
        string nationality;
        address clinic;
        string clinicName;
        string barcode;
        string vaccineName;
        string manufacturer;
        string batchNo;
        string date;
        string patientSign;
        string clinicSign;
        bool exist;
    }
}
