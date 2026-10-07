-- Boston Hospital Database System
-- Database Design and Implementation Coursework
-- Target DBMS: MySQL 8.0

DROP DATABASE IF EXISTS BostonHospital;
CREATE DATABASE BostonHospital CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE BostonHospital;


-- ----------------------------------------------------------------------
-- 1. Table Definitions & Foreign Key Constraints
-- ----------------------------------------------------------------------

-- Hospital departments
CREATE TABLE Departments (
    DepartmentNumber INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    TotalBeds INT NOT NULL CHECK (TotalBeds >= 0),
    TelephoneExtension VARCHAR(20) NOT NULL
);

-- Hospital staff members
CREATE TABLE Staff (
    StaffNumber VARCHAR(20) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    TelephoneNumber VARCHAR(30) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    NINumber VARCHAR(20) NOT NULL UNIQUE,
    Position VARCHAR(50) NOT NULL,
    CurrentSalary DECIMAL(10, 2) NOT NULL CHECK (CurrentSalary > 0),
    SalaryScale VARCHAR(20) NOT NULL,
    DepartmentNumber INT NULL,
    CONSTRAINT fk_staff_department FOREIGN KEY (DepartmentNumber) 
        REFERENCES Departments(DepartmentNumber) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Employment contracts for staff
CREATE TABLE StaffContracts (
    ContractID INT AUTO_INCREMENT PRIMARY KEY,
    StaffNumber VARCHAR(20) NOT NULL UNIQUE,
    HoursPerWeek DECIMAL(5, 2) NOT NULL CHECK (HoursPerWeek > 0),
    ContractType ENUM('Permanent', 'Temporary') NOT NULL,
    PaymentType ENUM('Weekly', 'Monthly') NOT NULL,
    StartDate DATE NOT NULL,
    CONSTRAINT fk_contracts_staff FOREIGN KEY (StaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Professional qualifications held by staff
CREATE TABLE StaffQualifications (
    QualificationID INT AUTO_INCREMENT PRIMARY KEY,
    StaffNumber VARCHAR(20) NOT NULL,
    QualificationType VARCHAR(100) NOT NULL,
    QualificationDate DATE NOT NULL,
    InstitutionName VARCHAR(150) NOT NULL,
    CONSTRAINT fk_qualifications_staff FOREIGN KEY (StaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Previous work history for staff members
CREATE TABLE StaffExperience (
    ExperienceID INT AUTO_INCREMENT PRIMARY KEY,
    StaffNumber VARCHAR(20) NOT NULL,
    OrganizationName VARCHAR(150) NOT NULL,
    Position VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    FinishDate DATE NOT NULL,
    CONSTRAINT fk_experience_staff FOREIGN KEY (StaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Weekly department shift allocations
CREATE TABLE DepartmentStaffRoster (
    RosterID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentNumber INT NOT NULL,
    StaffNumber VARCHAR(20) NOT NULL,
    WeekBeginning DATE NOT NULL,
    Shift ENUM('Early', 'Late', 'Night') NOT NULL,
    CONSTRAINT fk_roster_dept FOREIGN KEY (DepartmentNumber) 
        REFERENCES Departments(DepartmentNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_roster_staff FOREIGN KEY (StaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_roster_staff_week UNIQUE (StaffNumber, WeekBeginning)
);

-- External general practitioners
CREATE TABLE LocalDoctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    ClinicNumber VARCHAR(50) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    TelephoneNumber VARCHAR(30) NOT NULL
);

-- Patient records and next-of-kin contacts
CREATE TABLE Patients (
    PatientNumber VARCHAR(20) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    TelephoneNumber VARCHAR(30) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    MaritalStatus ENUM('Single', 'Married', 'Divorced', 'Widowed') NOT NULL,
    DateRegistered DATE NOT NULL,
    NOK_FullName VARCHAR(100) NOT NULL,
    NOK_Relationship VARCHAR(50) NOT NULL,
    NOK_Address VARCHAR(255) NOT NULL,
    NOK_TelephoneNumber VARCHAR(30) NOT NULL,
    DoctorID INT NOT NULL,
    CONSTRAINT fk_patients_doctor FOREIGN KEY (DoctorID) 
        REFERENCES LocalDoctors(DoctorID) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Initial consultant examination appointments
CREATE TABLE Appointments (
    AppointmentNumber INT AUTO_INCREMENT PRIMARY KEY,
    PatientNumber VARCHAR(20) NOT NULL,
    ConsultantStaffNumber VARCHAR(20) NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    ExaminationRoom VARCHAR(50) NOT NULL,
    Recommendation ENUM('Outpatient Clinic', 'Waiting List for Inpatient', 'Discharged') NOT NULL DEFAULT 'Outpatient Clinic',
    CONSTRAINT fk_appts_patient FOREIGN KEY (PatientNumber) 
        REFERENCES Patients(PatientNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_appts_consultant FOREIGN KEY (ConsultantStaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Outpatient clinic attendance
CREATE TABLE OutpatientAppointments (
    OutpatientID INT AUTO_INCREMENT PRIMARY KEY,
    PatientNumber VARCHAR(20) NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    ClinicRoom VARCHAR(50) NOT NULL,
    ChargeNurseStaffNumber VARCHAR(20) NULL,
    CONSTRAINT fk_outpatient_patient FOREIGN KEY (PatientNumber) 
        REFERENCES Patients(PatientNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_outpatient_nurse FOREIGN KEY (ChargeNurseStaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Inpatient ward admissions and waiting list
CREATE TABLE InpatientStays (
    InpatientStayID INT AUTO_INCREMENT PRIMARY KEY,
    PatientNumber VARCHAR(20) NOT NULL,
    DepartmentNumber INT NOT NULL,
    DateOnWaitingList DATE NOT NULL,
    ExpectedStayDays INT NOT NULL CHECK (ExpectedStayDays > 0),
    DatePlaced DATE NULL,
    ExpectedLeaveDate DATE NULL,
    ActualLeaveDate DATE NULL,
    BedNumber INT NULL,
    CONSTRAINT fk_inpatients_patient FOREIGN KEY (PatientNumber) 
        REFERENCES Patients(PatientNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_inpatients_dept FOREIGN KEY (DepartmentNumber) 
        REFERENCES Departments(DepartmentNumber) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Registered medical and stock suppliers
CREATE TABLE Suppliers (
    SupplierNumber INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(150) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    TelephoneNumber VARCHAR(30) NOT NULL,
    FaxNumber VARCHAR(30) NULL
);

-- Pharmaceutical inventory stock
CREATE TABLE PharmaceuticalSupplies (
    DrugNumber INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    MethodOfAdmin VARCHAR(50) NOT NULL,
    QuantityInStock INT NOT NULL CHECK (QuantityInStock >= 0),
    ReorderLevel INT NOT NULL CHECK (ReorderLevel >= 0),
    CostPerUnit DECIMAL(10, 2) NOT NULL CHECK (CostPerUnit >= 0),
    SupplierNumber INT NOT NULL,
    CONSTRAINT fk_pharma_supplier FOREIGN KEY (SupplierNumber) 
        REFERENCES Suppliers(SupplierNumber) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Surgical and general consumables
CREATE TABLE SurgicalSupplies (
    ItemNumber INT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    ItemType ENUM('Surgical', 'Non-Surgical') NOT NULL,
    Description TEXT NOT NULL,
    QuantityInStock INT NOT NULL CHECK (QuantityInStock >= 0),
    ReorderLevel INT NOT NULL CHECK (ReorderLevel >= 0),
    CostPerUnit DECIMAL(10, 2) NOT NULL CHECK (CostPerUnit >= 0),
    SupplierNumber INT NOT NULL,
    CONSTRAINT fk_surgical_supplier FOREIGN KEY (SupplierNumber) 
        REFERENCES Suppliers(SupplierNumber) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Medication prescribed to patients
CREATE TABLE PatientMedications (
    MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    PatientNumber VARCHAR(20) NOT NULL,
    DrugNumber INT NOT NULL,
    UnitsPerDay INT NOT NULL CHECK (UnitsPerDay > 0),
    MethodOfAdmin VARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    FinishDate DATE NOT NULL,
    CONSTRAINT fk_med_patient FOREIGN KEY (PatientNumber) 
        REFERENCES Patients(PatientNumber) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_med_drug FOREIGN KEY (DrugNumber) 
        REFERENCES PharmaceuticalSupplies(DrugNumber) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Department stock requisitions from central store
CREATE TABLE DepartmentRequisitions (
    RequisitionNumber VARCHAR(50) PRIMARY KEY,
    DepartmentNumber INT NOT NULL,
    StaffNumber VARCHAR(20) NOT NULL,
    RequisitionDate DATE NOT NULL,
    SupplyType ENUM('Pharmaceutical', 'Surgical/Non-Surgical') NOT NULL,
    DrugNumber INT NULL,
    ItemNumber INT NULL,
    ItemName VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Dosage VARCHAR(50) NULL,
    MethodOfAdmin VARCHAR(50) NULL,
    CostPerUnit DECIMAL(10, 2) NOT NULL CHECK (CostPerUnit >= 0),
    QuantityRequired INT NOT NULL CHECK (QuantityRequired > 0),
    ReceivedByStaffNumber VARCHAR(20) NULL,
    DateReceived DATE NULL,
    CONSTRAINT fk_req_dept FOREIGN KEY (DepartmentNumber) 
        REFERENCES Departments(DepartmentNumber) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_req_staff FOREIGN KEY (StaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_req_pharma FOREIGN KEY (DrugNumber) 
        REFERENCES PharmaceuticalSupplies(DrugNumber) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_req_surg FOREIGN KEY (ItemNumber) 
        REFERENCES SurgicalSupplies(ItemNumber) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_req_receiver FOREIGN KEY (ReceivedByStaffNumber) 
        REFERENCES Staff(StaffNumber) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Secondary indexes for frequent query lookups
CREATE INDEX idx_staff_position ON Staff(Position);
CREATE INDEX idx_staff_department ON Staff(DepartmentNumber);
CREATE INDEX idx_roster_dept_week ON DepartmentStaffRoster(DepartmentNumber, WeekBeginning);
CREATE INDEX idx_patients_doctor ON Patients(DoctorID);
CREATE INDEX idx_appointments_patient ON Appointments(PatientNumber);
CREATE INDEX idx_appointments_date ON Appointments(AppointmentDate);
CREATE INDEX idx_outpatient_date ON OutpatientAppointments(AppointmentDate);
CREATE INDEX idx_inpatients_dept_dates ON InpatientStays(DepartmentNumber, DatePlaced, ActualLeaveDate);
CREATE INDEX idx_patient_med_patient ON PatientMedications(PatientNumber);
CREATE INDEX idx_req_dept_date ON DepartmentRequisitions(DepartmentNumber, RequisitionDate);


-- ----------------------------------------------------------------------
-- 2. Sample Data Population
-- ----------------------------------------------------------------------

-- Departments
INSERT INTO Departments (DepartmentNumber, DepartmentName, Location, TotalBeds, TelephoneExtension) VALUES
(11, 'Orthopaedic', 'Block E', 50, 'Extn. 7711'),
(12, 'Cardiology', 'Block C', 45, 'Extn. 7712'),
(13, 'Geriatrics', 'Block A', 60, 'Extn. 7713'),
(14, 'Neurology', 'Block B', 40, 'Extn. 7714'),
(15, 'General Surgery', 'Block D', 45, 'Extn. 7715');

-- Staff members
INSERT INTO Staff (StaffNumber, FirstName, LastName, Address, TelephoneNumber, DateOfBirth, Gender, NINumber, Position, CurrentSalary, SalaryScale, DepartmentNumber) VALUES
('S001', 'James', 'Cunningham', '10 Royal Terrace, Edinburgh', '0131-222-1000', '1958-03-15', 'Male', 'WA112233B', 'Medical Director', 95000.00, 'DIR scale', 11),
('S002', 'Eleanor', 'Vance', '14 Charlotte Square, Edinburgh', '0131-222-2000', '1965-08-22', 'Female', 'WB223344C', 'Human Resource Director', 72000.00, 'DIR scale', 11),
('S011', 'Moira', 'Samuel', '49 School Road, Broxburn', '01506-45633', '1961-05-30', 'Female', 'WB123423D', 'Charge Nurse', 18760.00, '1C scale', 11),
('S098', 'Carol', 'Cummings', '15 High Street, Edinburgh', '0131-334-5677', '1982-11-04', 'Female', 'WC334455D', 'Staff Nurse', 14500.00, '2B scale', 11),
('S123', 'Morgan', 'Russell', '23A George Street, Broxburn', '01506-67676', '1988-02-18', 'Male', 'WD445566E', 'Nurse', 12800.00, '3A scale', 11),
('S167', 'Robin', 'Plevin', '7 Glen Terrace, Edinburgh', '0131-339-8123', '1979-09-12', 'Male', 'WE556677F', 'Staff Nurse', 15200.00, '2B scale', 11),
('S234', 'Amy', 'O\'Donnell', '234 Princes Street, Edinburgh', '0131-334-9099', '1990-06-25', 'Female', 'WF667788G', 'Nurse', 12500.00, '3A scale', 11),
('S344', 'Laurence', 'Burns', '1 Apple Drive, Edinburgh', '0131-334-9100', '1968-12-05', 'Male', 'WG778899H', 'Consultant', 68000.00, 'CON scale', 11);

-- Staff Contracts
INSERT INTO StaffContracts (StaffNumber, HoursPerWeek, ContractType, PaymentType, StartDate) VALUES
('S011', 37.5, 'Permanent', 'Monthly', '1994-06-01'),
('S098', 37.5, 'Permanent', 'Monthly', '2005-08-15'),
('S123', 20.0, 'Temporary', 'Weekly', '2012-01-10'),
('S167', 37.5, 'Permanent', 'Monthly', '2008-04-01'),
('S234', 37.5, 'Permanent', 'Weekly', '2013-09-01'),
('S344', 40.0, 'Permanent', 'Monthly', '2000-02-01');

-- Staff Qualifications
INSERT INTO StaffQualifications (StaffNumber, QualificationType, QualificationDate, InstitutionName) VALUES
('S011', 'BSc Nursing Studies', '1987-07-12', 'Edinburgh University'),
('S011', 'Diploma in Clinical Management', '1995-11-20', 'Glasgow Caledonian University'),
('S098', 'BSc Nursing', '2004-06-30', 'Napier University'),
('S344', 'MBChB Medicine', '1992-07-01', 'Edinburgh University'),
('S344', 'FRCS Orthopaedics', '1998-10-15', 'Royal College of Surgeons');

-- Staff Work Experience
INSERT INTO StaffExperience (StaffNumber, OrganizationName, Position, StartDate, FinishDate) VALUES
('S011', 'Western Hospital', 'Staff Nurse', '1990-01-23', '1993-05-01'),
('S011', 'St John\'s Hospital', 'Junior Sister', '1993-06-01', '1994-05-31'),
('S098', 'Royal Infirmary', 'Nurse', '2004-08-01', '2005-07-31'),
('S344', 'Glasgow Royal Infirmary', 'Registrar', '1993-08-01', '1998-09-30');

-- Department Shift Roster (Orthopaedic - Week Beginning 12-Jan-14)
INSERT INTO DepartmentStaffRoster (DepartmentNumber, StaffNumber, WeekBeginning, Shift) VALUES
(11, 'S098', '2014-01-12', 'Late'),
(11, 'S123', '2014-01-12', 'Late'),
(11, 'S167', '2014-01-12', 'Early'),
(11, 'S234', '2014-01-12', 'Night'),
(11, 'S344', '2014-01-12', 'Early');

-- Referring General Practitioners
INSERT INTO LocalDoctors (FullName, ClinicNumber, Address, TelephoneNumber) VALUES
('Dr Helen Pearson', 'E102', '22 Cannongate Way, Edinburgh, EH1 6TY', '0131-332-0012'),
('Dr Alistair Mackay', 'G204', '15 St Vincent Street, Glasgow, G2 5QF', '0141-248-7788'),
('Dr Fiona Campbell', 'E105', '88 Ferry Road, Edinburgh, EH6 4AE', '0131-554-3321');

-- Patients
INSERT INTO Patients (PatientNumber, FirstName, LastName, Address, TelephoneNumber, DateOfBirth, Gender, MaritalStatus, DateRegistered, NOK_FullName, NOK_Relationship, NOK_Address, NOK_TelephoneNumber, DoctorID) VALUES
('P10234', 'Anne', 'Phelps', '44 North Bridges, Cannonmills, Edinburgh, EH1 5GH', '0131-332-4111', '1933-12-12', 'Female', 'Single', '2009-02-21', 'James Phelps', 'Son', '145 Rowlands Street, Paisley, PA2 5FE', '0141-848-2211', 1),
('P10451', 'Robert', 'Drumtree', '12 Rose Street, Edinburgh, EH2 2PR', '0131-225-8899', '1942-04-18', 'Male', 'Married', '2010-05-14', 'Mary Drumtree', 'Wife', '12 Rose Street, Edinburgh, EH2 2PR', '0131-225-8899', 1),
('P10480', 'Steven', 'Parks', '56 Hanover Street, Edinburgh, EH2 2DX', '0131-226-1122', '1939-08-09', 'Male', 'Widowed', '2011-09-20', 'David Parks', 'Son', '8 Forth Street, Edinburgh, EH1 3LE', '0131-556-9900', 3),
('P10583', 'David', 'Black', '88 Morrison Street, Edinburgh, EH3 8BU', '0131-229-4455', '1945-11-23', 'Male', 'Married', '2012-03-11', 'Susan Black', 'Wife', '88 Morrison Street, Edinburgh, EH3 8BU', '0131-229-4455', 1),
('P10604', 'Ian', 'Thomson', '102 Dundee Street, Edinburgh, EH11 1BW', '0131-228-7744', '1936-01-30', 'Male', 'Single', '2012-07-19', 'Margaret Thomson', 'Sister', '14 Haymarket Terrace, Edinburgh', '0131-337-1234', 3),
('P10787', 'Peter', 'Smith', '45 Craigmillar Park, Edinburgh, EH16 5PE', '0131-667-5511', '1948-06-14', 'Male', 'Married', '2013-11-02', 'Helen Smith', 'Wife', '45 Craigmillar Park, Edinburgh', '0131-667-5511', 1),
('P10034', 'Robert', 'MacDonald', '27 Inverleith Row, Edinburgh, EH3 5QH', '0131-552-3344', '1935-09-17', 'Male', 'Married', '2008-11-15', 'Clara MacDonald', 'Wife', '27 Inverleith Row, Edinburgh', '0131-552-3344', 1);

-- Consultant Examinations
INSERT INTO Appointments (PatientNumber, ConsultantStaffNumber, AppointmentDate, AppointmentTime, ExaminationRoom, Recommendation) VALUES
('P10234', 'S344', '2014-01-08', '09:30:00', 'Room E252', 'Outpatient Clinic'),
('P10451', 'S344', '2014-01-10', '10:00:00', 'Room E252', 'Waiting List for Inpatient'),
('P10480', 'S344', '2014-01-11', '11:00:00', 'Room E252', 'Waiting List for Inpatient'),
('P10583', 'S344', '2014-01-12', '14:00:00', 'Room E252', 'Waiting List for Inpatient'),
('P10604', 'S344', '2014-01-13', '15:30:00', 'Room E252', 'Waiting List for Inpatient'),
('P10787', 'S344', '2014-01-16', '09:00:00', 'Room E252', 'Waiting List for Inpatient');

-- Outpatient Appointments
INSERT INTO OutpatientAppointments (PatientNumber, AppointmentDate, AppointmentTime, ClinicRoom, ChargeNurseStaffNumber) VALUES
('P10234', '2014-01-20', '10:30:00', 'Outpatient Suite 2', 'S011');

-- Inpatient Ward Admissions & Waiting List
INSERT INTO InpatientStays (PatientNumber, DepartmentNumber, DateOnWaitingList, ExpectedStayDays, DatePlaced, ExpectedLeaveDate, ActualLeaveDate, BedNumber) VALUES
('P10451', 11, '2014-01-12', 5, '2014-01-12', '2014-01-17', '2014-01-16', 84),
('P10480', 11, '2014-01-12', 4, '2014-01-14', '2014-01-18', '2014-01-18', 79),
('P10583', 11, '2014-01-13', 14, '2014-01-13', '2014-01-27', NULL, 80),
('P10604', 11, '2014-01-14', 10, '2014-01-15', '2014-01-25', NULL, 87),
('P10787', 11, '2014-01-17', 5, '2014-01-17', '2014-01-22', NULL, 84),
('P10034', 11, '2014-03-20', 30, '2014-03-24', '2014-05-02', NULL, 84);

-- Suppliers
INSERT INTO Suppliers (SupplierNumber, SupplierName, Address, Email, TelephoneNumber, FaxNumber) VALUES
(1, 'PharmaCare UK Ltd', '10 Science Park, Cambridge, CB4 0FQ', 'orders@pharmacare.co.uk', '01223-456789', '01223-456790'),
(2, 'Apex Surgical Solutions', '50 Industrial Estate, Leeds, LS10 1AB', 'sales@apexsurgical.co.uk', '0113-2345678', '0113-2345679'),
(3, 'MediStock Supplies', '24 Harbor Way, Glasgow, G51 1DH', 'info@medistock.co.uk', '0141-555-8900', '0141-555-8901');

-- Pharmaceutical Supplies
INSERT INTO PharmaceuticalSupplies (DrugNumber, Name, Description, Dosage, MethodOfAdmin, QuantityInStock, ReorderLevel, CostPerUnit, SupplierNumber) VALUES
(10223, 'Morphine', 'Controlled Analgesic / Pain Killer', '10mg/ml', 'Oral', 250, 50, 27.75, 1),
(10334, 'Tetracycline', 'Broad Spectrum Antibiotic', '0.5mg/ml', 'IV', 180, 40, 18.50, 1),
(10455, 'Paracetamol', 'Analgesic and Antipyretic', '500mg', 'Oral', 1500, 200, 2.50, 1),
(10567, 'Amoxicillin', 'Penicillin Antibiotic', '250mg', 'Oral', 600, 100, 9.20, 1);

-- Surgical and Non-Surgical Consumables
INSERT INTO SurgicalSupplies (ItemNumber, ItemName, ItemType, Description, QuantityInStock, ReorderLevel, CostPerUnit, SupplierNumber) VALUES
(20101, 'Sterile Syringes (10ml)', 'Surgical', 'Individually wrapped disposable sterile syringes', 1200, 300, 0.45, 2),
(20102, 'Sterile Gauze Dressings', 'Surgical', 'Pack of 10 sterile wound dressings', 800, 150, 3.20, 2),
(30101, 'Disposable Plastic Aprons', 'Non-Surgical', 'Roll of 100 polythene waterproof aprons', 50, 15, 12.00, 3),
(30102, 'Clinical Waste Bags', 'Non-Surgical', 'Heavy duty yellow biohazard waste bags', 400, 100, 0.80, 3);

-- Patient Prescriptions
INSERT INTO PatientMedications (PatientNumber, DrugNumber, UnitsPerDay, MethodOfAdmin, StartDate, FinishDate) VALUES
('P10034', 10223, 50, 'Oral', '2014-03-24', '2014-04-24'),
('P10034', 10334, 10, 'IV', '2014-03-24', '2014-04-17'),
('P10034', 10223, 10, 'Oral', '2014-04-25', '2014-05-02');

-- Department Supply Requisitions
INSERT INTO DepartmentRequisitions (RequisitionNumber, DepartmentNumber, StaffNumber, RequisitionDate, SupplyType, DrugNumber, ItemNumber, ItemName, Description, Dosage, MethodOfAdmin, CostPerUnit, QuantityRequired, ReceivedByStaffNumber, DateReceived) VALUES
('034567712', 11, 'S011', '2014-02-15', 'Pharmaceutical', 10223, NULL, 'Morphine', 'Pain killer', '10mg/ml', 'Oral', 27.75, 50, 'S011', '2014-02-18');


-- ----------------------------------------------------------------------
-- 3. Views for Hospital Reporting
-- ----------------------------------------------------------------------

-- Department staff roster and allocation (Figure 2 / Requirement c)
CREATE OR REPLACE VIEW vw_DepartmentStaffAllocation AS
SELECT 
    d.DepartmentNumber,
    d.DepartmentName,
    d.Location,
    d.TelephoneExtension,
    dsr.WeekBeginning,
    cn.StaffNumber AS ChargeNurseStaffNumber,
    CONCAT(cn.FirstName, ' ', cn.LastName) AS ChargeNurseName,
    s.StaffNumber,
    CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
    s.Address,
    s.TelephoneNumber,
    s.Position,
    dsr.Shift
FROM DepartmentStaffRoster dsr
JOIN Departments d ON dsr.DepartmentNumber = d.DepartmentNumber
JOIN Staff s ON dsr.StaffNumber = s.StaffNumber
LEFT JOIN Staff cn ON cn.DepartmentNumber = d.DepartmentNumber AND cn.Position = 'Charge Nurse';

-- Patient registration details with doctor information (Figure 3)
CREATE OR REPLACE VIEW vw_PatientRegistrationDetails AS
SELECT 
    p.PatientNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Address AS PatientAddress,
    p.Gender,
    p.TelephoneNumber AS PatientTelephone,
    p.DateOfBirth,
    p.MaritalStatus,
    p.DateRegistered,
    p.NOK_FullName AS NextOfKinName,
    p.NOK_Relationship AS NextOfKinRelationship,
    p.NOK_Address AS NextOfKinAddress,
    p.NOK_TelephoneNumber AS NextOfKinTelephone,
    ld.FullName AS LocalDoctorName,
    ld.ClinicNumber,
    ld.Address AS ClinicAddress,
    ld.TelephoneNumber AS DoctorTelephone
FROM Patients p
JOIN LocalDoctors ld ON p.DoctorID = ld.DoctorID;

-- Outpatient clinic referral report (Requirement f)
CREATE OR REPLACE VIEW vw_OutpatientClinicReport AS
SELECT 
    oa.OutpatientID,
    p.PatientNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Address,
    p.TelephoneNumber,
    p.DateOfBirth,
    p.Gender,
    oa.AppointmentDate,
    oa.AppointmentTime,
    oa.ClinicRoom,
    CONCAT(cn.FirstName, ' ', cn.LastName) AS SupervisingChargeNurse
FROM OutpatientAppointments oa
JOIN Patients p ON oa.PatientNumber = p.PatientNumber
LEFT JOIN Staff cn ON oa.ChargeNurseStaffNumber = cn.StaffNumber;

-- Current inpatients currently occupying beds (Figure 4 / Requirement h)
CREATE OR REPLACE VIEW vw_CurrentInpatientsByDepartment AS
SELECT 
    d.DepartmentNumber,
    d.DepartmentName,
    d.Location,
    d.TelephoneExtension,
    CONCAT(cn.FirstName, ' ', cn.LastName) AS ChargeNurseName,
    cn.StaffNumber AS ChargeNurseStaffNumber,
    inp.InpatientStayID,
    p.PatientNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    inp.DateOnWaitingList,
    inp.ExpectedStayDays,
    inp.DatePlaced,
    inp.ExpectedLeaveDate,
    inp.ActualLeaveDate,
    inp.BedNumber
FROM InpatientStays inp
JOIN Departments d ON inp.DepartmentNumber = d.DepartmentNumber
JOIN Patients p ON inp.PatientNumber = p.PatientNumber
LEFT JOIN Staff cn ON cn.DepartmentNumber = d.DepartmentNumber AND cn.Position = 'Charge Nurse'
WHERE inp.DatePlaced IS NOT NULL AND inp.ActualLeaveDate IS NULL;

-- Inpatient waiting list for departments (Requirement i)
CREATE OR REPLACE VIEW vw_DepartmentWaitingList AS
SELECT 
    d.DepartmentNumber,
    d.DepartmentName,
    inp.InpatientStayID,
    p.PatientNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Address,
    p.TelephoneNumber,
    p.DateOfBirth,
    p.Gender,
    p.MaritalStatus,
    p.NOK_FullName AS NextOfKinName,
    p.NOK_Relationship,
    p.NOK_TelephoneNumber,
    inp.DateOnWaitingList,
    inp.ExpectedStayDays
FROM InpatientStays inp
JOIN Departments d ON inp.DepartmentNumber = d.DepartmentNumber
JOIN Patients p ON inp.PatientNumber = p.PatientNumber
WHERE inp.DatePlaced IS NULL;

-- Patient medication profile report (Figure 5 / Requirement k)
CREATE OR REPLACE VIEW vw_PatientMedicationReport AS
SELECT 
    p.PatientNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
    d.DepartmentNumber,
    d.DepartmentName,
    inp.BedNumber,
    pm.MedicationID,
    ps.DrugNumber,
    ps.Name AS DrugName,
    ps.Description,
    ps.Dosage,
    pm.MethodOfAdmin,
    pm.UnitsPerDay,
    pm.StartDate,
    pm.FinishDate
FROM PatientMedications pm
JOIN Patients p ON pm.PatientNumber = p.PatientNumber
JOIN PharmaceuticalSupplies ps ON pm.DrugNumber = ps.DrugNumber
LEFT JOIN InpatientStays inp ON p.PatientNumber = inp.PatientNumber AND inp.ActualLeaveDate IS NULL
LEFT JOIN Departments d ON inp.DepartmentNumber = d.DepartmentNumber;

-- Department stock requisitions report (Figure 6 / Requirement n)
CREATE OR REPLACE VIEW vw_DepartmentRequisitionsReport AS
SELECT 
    dr.RequisitionNumber,
    d.DepartmentNumber,
    d.DepartmentName,
    CONCAT(s.FirstName, ' ', s.LastName) AS RequisitionedByName,
    dr.StaffNumber AS RequisitionedByStaffNumber,
    dr.RequisitionDate,
    dr.SupplyType,
    COALESCE(dr.DrugNumber, dr.ItemNumber) AS ItemOrDrugNumber,
    dr.ItemName,
    dr.Description,
    dr.Dosage,
    dr.MethodOfAdmin,
    dr.CostPerUnit,
    dr.QuantityRequired,
    (dr.CostPerUnit * dr.QuantityRequired) AS TotalCost,
    CONCAT(rec.FirstName, ' ', rec.LastName) AS ReceivedByName,
    dr.DateReceived
FROM DepartmentRequisitions dr
JOIN Departments d ON dr.DepartmentNumber = d.DepartmentNumber
JOIN Staff s ON dr.StaffNumber = s.StaffNumber
LEFT JOIN Staff rec ON dr.ReceivedByStaffNumber = rec.StaffNumber;


-- ----------------------------------------------------------------------
-- 4. Stored Procedures for System Transactions
-- ----------------------------------------------------------------------

DELIMITER $$

-- Transaction a: HR staff management
CREATE PROCEDURE sp_AddStaff(
    IN p_StaffNumber VARCHAR(20),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(255),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_DateOfBirth DATE,
    IN p_Gender VARCHAR(10),
    IN p_NINumber VARCHAR(20),
    IN p_Position VARCHAR(50),
    IN p_CurrentSalary DECIMAL(10,2),
    IN p_SalaryScale VARCHAR(20),
    IN p_DepartmentNumber INT
)
BEGIN
    INSERT INTO Staff (StaffNumber, FirstName, LastName, Address, TelephoneNumber, DateOfBirth, Gender, NINumber, Position, CurrentSalary, SalaryScale, DepartmentNumber)
    VALUES (p_StaffNumber, p_FirstName, p_LastName, p_Address, p_TelephoneNumber, p_DateOfBirth, p_Gender, p_NINumber, p_Position, p_CurrentSalary, p_SalaryScale, p_DepartmentNumber);
END$$

CREATE PROCEDURE sp_UpdateStaff(
    IN p_StaffNumber VARCHAR(20),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(255),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_Position VARCHAR(50),
    IN p_CurrentSalary DECIMAL(10,2),
    IN p_SalaryScale VARCHAR(20),
    IN p_DepartmentNumber INT
)
BEGIN
    UPDATE Staff
    SET FirstName = p_FirstName,
        LastName = p_LastName,
        Address = p_Address,
        TelephoneNumber = p_TelephoneNumber,
        Position = p_Position,
        CurrentSalary = p_CurrentSalary,
        SalaryScale = p_SalaryScale,
        DepartmentNumber = p_DepartmentNumber
    WHERE StaffNumber = p_StaffNumber;
END$$

CREATE PROCEDURE sp_DeleteStaff(
    IN p_StaffNumber VARCHAR(20)
)
BEGIN
    DELETE FROM Staff WHERE StaffNumber = p_StaffNumber;
END$$

CREATE PROCEDURE sp_AddStaffQualification(
    IN p_StaffNumber VARCHAR(20),
    IN p_QualificationType VARCHAR(100),
    IN p_QualificationDate DATE,
    IN p_InstitutionName VARCHAR(150)
)
BEGIN
    INSERT INTO StaffQualifications (StaffNumber, QualificationType, QualificationDate, InstitutionName)
    VALUES (p_StaffNumber, p_QualificationType, p_QualificationDate, p_InstitutionName);
END$$

CREATE PROCEDURE sp_AddStaffExperience(
    IN p_StaffNumber VARCHAR(20),
    IN p_OrganizationName VARCHAR(150),
    IN p_Position VARCHAR(100),
    IN p_StartDate DATE,
    IN p_FinishDate DATE
)
BEGIN
    INSERT INTO StaffExperience (StaffNumber, OrganizationName, Position, StartDate, FinishDate)
    VALUES (p_StaffNumber, p_OrganizationName, p_Position, p_StartDate, p_FinishDate);
END$$

CREATE PROCEDURE sp_SetStaffContract(
    IN p_StaffNumber VARCHAR(20),
    IN p_HoursPerWeek DECIMAL(5,2),
    IN p_ContractType VARCHAR(20),
    IN p_PaymentType VARCHAR(20),
    IN p_StartDate DATE
)
BEGIN
    INSERT INTO StaffContracts (StaffNumber, HoursPerWeek, ContractType, PaymentType, StartDate)
    VALUES (p_StaffNumber, p_HoursPerWeek, p_ContractType, p_PaymentType, p_StartDate)
    ON DUPLICATE KEY UPDATE 
        HoursPerWeek = p_HoursPerWeek, 
        ContractType = p_ContractType, 
        PaymentType = p_PaymentType,
        StartDate = p_StartDate;
END$$

-- Transaction b: Search staff qualifications and experience
CREATE PROCEDURE sp_SearchStaffByQualification(
    IN p_QualType VARCHAR(100)
)
BEGIN
    SELECT 
        s.StaffNumber,
        CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
        s.Position,
        d.DepartmentName,
        sq.QualificationType,
        sq.QualificationDate,
        sq.InstitutionName
    FROM Staff s
    JOIN StaffQualifications sq ON s.StaffNumber = sq.StaffNumber
    LEFT JOIN Departments d ON s.DepartmentNumber = d.DepartmentNumber
    WHERE sq.QualificationType LIKE CONCAT('%', p_QualType, '%');
END$$

CREATE PROCEDURE sp_SearchStaffByExperience(
    IN p_Position VARCHAR(100)
)
BEGIN
    SELECT 
        s.StaffNumber,
        CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
        s.Position AS CurrentPosition,
        se.OrganizationName,
        se.Position AS PreviousPosition,
        se.StartDate,
        se.FinishDate
    FROM Staff s
    JOIN StaffExperience se ON s.StaffNumber = se.StaffNumber
    WHERE se.Position LIKE CONCAT('%', p_Position, '%');
END$$

-- Transaction c: Shift assignment and roster reporting
CREATE PROCEDURE sp_AssignStaffShift(
    IN p_DepartmentNumber INT,
    IN p_StaffNumber VARCHAR(20),
    IN p_WeekBeginning DATE,
    IN p_Shift VARCHAR(10)
)
BEGIN
    INSERT INTO DepartmentStaffRoster (DepartmentNumber, StaffNumber, WeekBeginning, Shift)
    VALUES (p_DepartmentNumber, p_StaffNumber, p_WeekBeginning, p_Shift)
    ON DUPLICATE KEY UPDATE Shift = p_Shift;
END$$

CREATE PROCEDURE sp_GetDepartmentStaffReport(
    IN p_DepartmentNumber INT,
    IN p_WeekBeginning DATE
)
BEGIN
    SELECT * 
    FROM vw_DepartmentStaffAllocation
    WHERE DepartmentNumber = p_DepartmentNumber
      AND (p_WeekBeginning IS NULL OR WeekBeginning = p_WeekBeginning);
END$$

-- Transaction d: Patient registration and profile management
CREATE PROCEDURE sp_RegisterPatient(
    IN p_PatientNumber VARCHAR(20),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(255),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_DateOfBirth DATE,
    IN p_Gender VARCHAR(10),
    IN p_MaritalStatus VARCHAR(20),
    IN p_DateRegistered DATE,
    IN p_NOK_FullName VARCHAR(100),
    IN p_NOK_Relationship VARCHAR(50),
    IN p_NOK_Address VARCHAR(255),
    IN p_NOK_TelephoneNumber VARCHAR(30),
    IN p_DoctorID INT
)
BEGIN
    INSERT INTO Patients (PatientNumber, FirstName, LastName, Address, TelephoneNumber, DateOfBirth, Gender, MaritalStatus, DateRegistered, NOK_FullName, NOK_Relationship, NOK_Address, NOK_TelephoneNumber, DoctorID)
    VALUES (p_PatientNumber, p_FirstName, p_LastName, p_Address, p_TelephoneNumber, p_DateOfBirth, p_Gender, p_MaritalStatus, p_DateRegistered, p_NOK_FullName, p_NOK_Relationship, p_NOK_Address, p_NOK_TelephoneNumber, p_DoctorID);
END$$

CREATE PROCEDURE sp_UpdatePatient(
    IN p_PatientNumber VARCHAR(20),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(255),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_MaritalStatus VARCHAR(20),
    IN p_NOK_FullName VARCHAR(100),
    IN p_NOK_Relationship VARCHAR(50),
    IN p_NOK_Address VARCHAR(255),
    IN p_NOK_TelephoneNumber VARCHAR(30),
    IN p_DoctorID INT
)
BEGIN
    UPDATE Patients
    SET FirstName = p_FirstName,
        LastName = p_LastName,
        Address = p_Address,
        TelephoneNumber = p_TelephoneNumber,
        MaritalStatus = p_MaritalStatus,
        NOK_FullName = p_NOK_FullName,
        NOK_Relationship = p_NOK_Relationship,
        NOK_Address = p_NOK_Address,
        NOK_TelephoneNumber = p_NOK_TelephoneNumber,
        DoctorID = p_DoctorID
    WHERE PatientNumber = p_PatientNumber;
END$$

CREATE PROCEDURE sp_DeletePatient(
    IN p_PatientNumber VARCHAR(20)
)
BEGIN
    DELETE FROM Patients WHERE PatientNumber = p_PatientNumber;
END$$

-- Transactions e & f: Outpatient appointments and scheduling
CREATE PROCEDURE sp_ReferToOutpatientClinic(
    IN p_PatientNumber VARCHAR(20),
    IN p_AppointmentDate DATE,
    IN p_AppointmentTime TIME,
    IN p_ClinicRoom VARCHAR(50),
    IN p_ChargeNurseStaffNumber VARCHAR(20)
)
BEGIN
    INSERT INTO OutpatientAppointments (PatientNumber, AppointmentDate, AppointmentTime, ClinicRoom, ChargeNurseStaffNumber)
    VALUES (p_PatientNumber, p_AppointmentDate, p_AppointmentTime, p_ClinicRoom, p_ChargeNurseStaffNumber);
END$$

CREATE PROCEDURE sp_GetOutpatientReport(
    IN p_AppointmentDate DATE
)
BEGIN
    SELECT * 
    FROM vw_OutpatientClinicReport
    WHERE (p_AppointmentDate IS NULL OR AppointmentDate = p_AppointmentDate)
    ORDER BY AppointmentDate, AppointmentTime;
END$$

-- Transactions g, h, i: Inpatient stays, bed allocation, and discharges
CREATE PROCEDURE sp_ReferPatientToDepartment(
    IN p_PatientNumber VARCHAR(20),
    IN p_DepartmentNumber INT,
    IN p_DateOnWaitingList DATE,
    IN p_ExpectedStayDays INT
)
BEGIN
    INSERT INTO InpatientStays (PatientNumber, DepartmentNumber, DateOnWaitingList, ExpectedStayDays, DatePlaced, ExpectedLeaveDate, ActualLeaveDate, BedNumber)
    VALUES (p_PatientNumber, p_DepartmentNumber, p_DateOnWaitingList, p_ExpectedStayDays, NULL, NULL, NULL, NULL);
END$$

CREATE PROCEDURE sp_AllocateBedToPatient(
    IN p_InpatientStayID INT,
    IN p_DatePlaced DATE,
    IN p_ExpectedLeaveDate DATE,
    IN p_BedNumber INT
)
BEGIN
    UPDATE InpatientStays
    SET DatePlaced = p_DatePlaced,
        ExpectedLeaveDate = p_ExpectedLeaveDate,
        BedNumber = p_BedNumber
    WHERE InpatientStayID = p_InpatientStayID;
END$$

CREATE PROCEDURE sp_DischargePatient(
    IN p_InpatientStayID INT,
    IN p_ActualLeaveDate DATE
)
BEGIN
    UPDATE InpatientStays
    SET ActualLeaveDate = p_ActualLeaveDate
    WHERE InpatientStayID = p_InpatientStayID;
END$$

CREATE PROCEDURE sp_GetCurrentDepartmentPatients(
    IN p_DepartmentNumber INT
)
BEGIN
    SELECT * 
    FROM vw_CurrentInpatientsByDepartment
    WHERE DepartmentNumber = p_DepartmentNumber;
END$$

CREATE PROCEDURE sp_GetDepartmentWaitingList(
    IN p_DepartmentNumber INT
)
BEGIN
    SELECT * 
    FROM vw_DepartmentWaitingList
    WHERE DepartmentNumber = p_DepartmentNumber
    ORDER BY DateOnWaitingList ASC;
END$$

-- Transactions j & k: Prescriptions and medication logs
CREATE PROCEDURE sp_PrescribeMedication(
    IN p_PatientNumber VARCHAR(20),
    IN p_DrugNumber INT,
    IN p_UnitsPerDay INT,
    IN p_MethodOfAdmin VARCHAR(50),
    IN p_StartDate DATE,
    IN p_FinishDate DATE
)
BEGIN
    INSERT INTO PatientMedications (PatientNumber, DrugNumber, UnitsPerDay, MethodOfAdmin, StartDate, FinishDate)
    VALUES (p_PatientNumber, p_DrugNumber, p_UnitsPerDay, p_MethodOfAdmin, p_StartDate, p_FinishDate);
END$$

CREATE PROCEDURE sp_UpdateMedication(
    IN p_MedicationID INT,
    IN p_UnitsPerDay INT,
    IN p_MethodOfAdmin VARCHAR(50),
    IN p_FinishDate DATE
)
BEGIN
    UPDATE PatientMedications
    SET UnitsPerDay = p_UnitsPerDay,
        MethodOfAdmin = p_MethodOfAdmin,
        FinishDate = p_FinishDate
    WHERE MedicationID = p_MedicationID;
END$$

CREATE PROCEDURE sp_DiscontinueMedication(
    IN p_MedicationID INT
)
BEGIN
    DELETE FROM PatientMedications WHERE MedicationID = p_MedicationID;
END$$

CREATE PROCEDURE sp_GetPatientMedicationReport(
    IN p_PatientNumber VARCHAR(20)
)
BEGIN
    SELECT * 
    FROM vw_PatientMedicationReport
    WHERE PatientNumber = p_PatientNumber
    ORDER BY StartDate DESC;
END$$

-- Transaction l: Medical suppliers
CREATE PROCEDURE sp_AddSupplier(
    IN p_SupplierName VARCHAR(150),
    IN p_Address VARCHAR(255),
    IN p_Email VARCHAR(100),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_FaxNumber VARCHAR(30)
)
BEGIN
    INSERT INTO Suppliers (SupplierName, Address, Email, TelephoneNumber, FaxNumber)
    VALUES (p_SupplierName, p_Address, p_Email, p_TelephoneNumber, p_FaxNumber);
END$$

CREATE PROCEDURE sp_UpdateSupplier(
    IN p_SupplierNumber INT,
    IN p_SupplierName VARCHAR(150),
    IN p_Address VARCHAR(255),
    IN p_Email VARCHAR(100),
    IN p_TelephoneNumber VARCHAR(30),
    IN p_FaxNumber VARCHAR(30)
)
BEGIN
    UPDATE Suppliers
    SET SupplierName = p_SupplierName,
        Address = p_Address,
        Email = p_Email,
        TelephoneNumber = p_TelephoneNumber,
        FaxNumber = p_FaxNumber
    WHERE SupplierNumber = p_SupplierNumber;
END$$

CREATE PROCEDURE sp_DeleteSupplier(
    IN p_SupplierNumber INT
)
BEGIN
    DELETE FROM Suppliers WHERE SupplierNumber = p_SupplierNumber;
END$$

-- Transactions m & n: Department store requisitions
CREATE PROCEDURE sp_CreateRequisition(
    IN p_RequisitionNumber VARCHAR(50),
    IN p_DepartmentNumber INT,
    IN p_StaffNumber VARCHAR(20),
    IN p_RequisitionDate DATE,
    IN p_SupplyType VARCHAR(30),
    IN p_DrugNumber INT,
    IN p_ItemNumber INT,
    IN p_ItemName VARCHAR(100),
    IN p_Description TEXT,
    IN p_Dosage VARCHAR(50),
    IN p_MethodOfAdmin VARCHAR(50),
    IN p_CostPerUnit DECIMAL(10,2),
    IN p_QuantityRequired INT
)
BEGIN
    INSERT INTO DepartmentRequisitions (
        RequisitionNumber, DepartmentNumber, StaffNumber, RequisitionDate, SupplyType, 
        DrugNumber, ItemNumber, ItemName, Description, Dosage, MethodOfAdmin, 
        CostPerUnit, QuantityRequired, ReceivedByStaffNumber, DateReceived
    ) VALUES (
        p_RequisitionNumber, p_DepartmentNumber, p_StaffNumber, p_RequisitionDate, p_SupplyType,
        p_DrugNumber, p_ItemNumber, p_ItemName, p_Description, p_Dosage, p_MethodOfAdmin,
        p_CostPerUnit, p_QuantityRequired, NULL, NULL
    );
END$$

CREATE PROCEDURE sp_ReceiveRequisition(
    IN p_RequisitionNumber VARCHAR(50),
    IN p_ReceivedByStaffNumber VARCHAR(20),
    IN p_DateReceived DATE
)
BEGIN
    UPDATE DepartmentRequisitions
    SET ReceivedByStaffNumber = p_ReceivedByStaffNumber,
        DateReceived = p_DateReceived
    WHERE RequisitionNumber = p_RequisitionNumber;
END$$

CREATE PROCEDURE sp_GetDepartmentRequisitionsReport(
    IN p_DepartmentNumber INT
)
BEGIN
    SELECT * 
    FROM vw_DepartmentRequisitionsReport
    WHERE DepartmentNumber = p_DepartmentNumber
    ORDER BY RequisitionDate DESC;
END$$

DELIMITER ;


-- ----------------------------------------------------------------------
-- 5. Test Queries and Validation Checks
-- ----------------------------------------------------------------------

-- 1. Check reports against case study figures
SELECT * FROM vw_DepartmentStaffAllocation WHERE DepartmentNumber = 11;
SELECT * FROM vw_PatientRegistrationDetails WHERE PatientNumber = 'P10234';
SELECT * FROM vw_CurrentInpatientsByDepartment WHERE DepartmentNumber = 11;
SELECT * FROM vw_DepartmentWaitingList WHERE DepartmentNumber = 11;
SELECT * FROM vw_PatientMedicationReport WHERE PatientNumber = 'P10034';
SELECT * FROM vw_DepartmentRequisitionsReport WHERE DepartmentNumber = 11;

-- 2. Test Transaction a: add a new staff member with credentials
CALL sp_AddStaff('S401', 'Grace', 'Brown', '12 Waverley Bridge, Edinburgh', '0131-556-0123', '1985-04-12', 'Female', 'WH889900I', 'Nurse', 13000.00, '3A scale', 11);
CALL sp_AddStaffQualification('S401', 'BN Nursing', '2007-06-20', 'Queen Margaret University');
CALL sp_SetStaffContract('S401', 37.5, 'Permanent', 'Monthly', '2014-02-01');

-- 3. Test Transaction b: search staff by qualification and experience
CALL sp_SearchStaffByQualification('Nursing');
CALL sp_SearchStaffByExperience('Staff Nurse');

-- 4. Test Transaction c: assign shift and retrieve weekly roster
CALL sp_AssignStaffShift(11, 'S401', '2014-01-12', 'Early');
CALL sp_GetDepartmentStaffReport(11, '2014-01-12');

-- 5. Test Transaction d: register and update a patient
CALL sp_RegisterPatient('P10999', 'Nina', 'Johnson', '543 Spruce St, Townsville, EH12 9YZ', '0131-555-0987', '1950-07-22', 'Female', 'Married', '2014-02-01', 'Mark Johnson', 'Husband', '543 Spruce St', '0131-555-0987', 1);
CALL sp_UpdatePatient('P10999', 'Nina', 'Johnson-Smith', '543 Spruce St, Townsville, EH12 9YZ', '0131-555-0987', 'Married', 'Mark Johnson-Smith', 'Husband', '543 Spruce St', '0131-555-0987', 1);

-- 6. Test Transactions e & f: outpatient scheduling and report
CALL sp_ReferToOutpatientClinic('P10999', '2014-02-10', '11:00:00', 'Suite 1', 'S011');
CALL sp_GetOutpatientReport('2014-02-10');

-- 7. Test Transactions g, h, i: admission, bed allocation, and discharge
CALL sp_ReferPatientToDepartment('P10999', 11, '2014-02-02', 7);
CALL sp_GetDepartmentWaitingList(11);
CALL sp_AllocateBedToPatient(7, '2014-02-03', '2014-02-10', 88);
CALL sp_GetCurrentDepartmentPatients(11);
CALL sp_DischargePatient(7, '2014-02-09');

-- 8. Test Transactions j & k: prescribe medication and view medication report
CALL sp_PrescribeMedication('P10999', 10455, 4, 'Oral', '2014-02-03', '2014-02-09');
CALL sp_GetPatientMedicationReport('P10999');

-- 9. Test Transaction l: add new supplier
CALL sp_AddSupplier('BioHealth Supplies', '99 Innovation Way, Oxford, OX1 2JD', 'info@biohealth.co.uk', '01865-998877', '01865-998878');

-- 10. Test Transactions m & n: create, receive, and report requisition
CALL sp_CreateRequisition('034567799', 11, 'S011', '2014-02-20', 'Surgical/Non-Surgical', NULL, 20101, 'Sterile Syringes (10ml)', 'Individually wrapped disposable sterile syringes', NULL, NULL, 0.45, 100);
CALL sp_ReceiveRequisition('034567799', 'S011', '2014-02-22');
CALL sp_GetDepartmentRequisitionsReport(11);
