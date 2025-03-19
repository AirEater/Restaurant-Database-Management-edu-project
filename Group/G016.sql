
/*
COURSE CODE: UCCD2303
PROGRAMME (IA/IB/CS)/DE: CS
GROUP NUMBER e.g. G001: G016
GROUP LEADER NAME & EMAIL: yeechung016@1utar.my
MEMBER 2 NAME: Ang Chin Siang
MEMBER 3 NAME: Lee Jia Jie
MEMBER 4 NAME: Liu Zhi Hui
Submission date and time (DD-MON-YY): 19-APR-24
*/

DROP TABLE Restaurant CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Res_Table CASCADE CONSTRAINTS;
DROP TABLE Waiter CASCADE CONSTRAINTS;
DROP TABLE Chef CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Reservation CASCADE CONSTRAINTS;
DROP TABLE Ordering CASCADE CONSTRAINTS;
DROP TABLE Dine_In CASCADE CONSTRAINTS;
DROP TABLE Take_Away CASCADE CONSTRAINTS;
DROP TABLE Ingredient CASCADE CONSTRAINTS;
DROP TABLE IngredientRecords CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;

DROP ROLE c##admins_role;
DROP ROLE c##manager_role;
DROP ROLE c##customer_role;
DROP ROLE c##waiter_role;
DROP ROLE c##chef_role;

CREATE TABLE Restaurant(
    ResID VARCHAR2(4) PRIMARY KEY,
    Res_Name VARCHAR2(50) NOT NULL,
    Res_Phone VARCHAR2(12) NOT NULL,
    Cuisine VARCHAR2(50) NOT NULL
);

CREATE TABLE Employee(
    EmpID VARCHAR2(4) PRIMARY KEY,
    ResID VARCHAR2(4),
    FName VARCHAR2(20) NOT NULL,
    LName VARCHAR2(20),
    Gender CHAR(1) DEFAULT 'M' NOT NULL CONSTRAINT Employee_Gender_cc CHECK ((Gender = 'M') OR (Gender = 'F')),
    DOB DATE NOT NULL,
    Salary NUMBER(5) NOT NULL CONSTRAINT Employee_Salary_cc CHECK (Salary >= 0),
    Phone VARCHAR2(12),
    City VARCHAR2(20) NOT NULL,
    Emp_State VARCHAR2(20),
    CONSTRAINT Employee_ResID_fk FOREIGN KEY (ResID) REFERENCES Restaurant(ResID)
);


CREATE TABLE Res_Table(
    TabID VARCHAR2(4) PRIMARY KEY,
    TabStatus VARCHAR2(20) DEFAULT 'Available' NOT NULL CONSTRAINT Res_Table_TabStatus_cc CHECK ((TabStatus = 'Available') OR (TabStatus = 'Reserved')),
    Tab_Size VARCHAR2(20)  DEFAULT 'Small' NOT NULL CONSTRAINT Res_Table_Tab_Size_cc CHECK ((Tab_Size = 'Small') OR (Tab_Size = 'Medium') OR (Tab_Size = 'Large')),
    ResID VARCHAR2(4),
    CONSTRAINT Res_Table_ResID_fk FOREIGN KEY (ResID) REFERENCES Restaurant(ResID) ON DELETE CASCADE 
);

CREATE TABLE Waiter(
    EmpID VARCHAR2(4),
    Experience NUMBER(2) NOT NULL,
    -- Employee's ID typically don't change if an employee leaves
    -- When a new employee is hired, they should be assigned a new unique ID
    CONSTRAINT Waiter_EmpID_fk FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
);

CREATE TABLE Chef(
    EmpID VARCHAR2(4),
    Specialization VARCHAR2(50),
    Experience NUMBER(2) NOT NULL,
    -- Employee's ID typically don't change if an employee leaves
    -- When a new employee is hired, they should be assigned a new unique ID
    CONSTRAINT Chef_EmpID_fk FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
);

CREATE TABLE Customer(
    CustID VARCHAR2(4) PRIMARY KEY,
    CustFName VARCHAR2(20) NOT NULL,
    CustLName VARCHAR2(20),
    Gender CHAR(1) DEFAULT 'M' NOT NULL  CHECK (Gender IN ('M', 'F')),
    Phone VARCHAR2(12)
);

CREATE TABLE Reservation(
    RsvnID VARCHAR2(5) PRIMARY KEY,
    TabID VARCHAR2(4),
    EmpID VARCHAR2(4),
    CustID VARCHAR2(4),
    Rsvn_Date DATE NOT NULL,
    Rsvn_Status VARCHAR2(20) DEFAULT 'Processing' NOT NULL CHECK (Rsvn_Status IN ('Processing', 'Confirmed', 'Cancel')),
    Num_People NUMBER(3) CHECK (Num_People >= 1 AND Num_People <= 100),
    -- don't keep past reservations
    CONSTRAINT Reservation_TabID_fk FOREIGN KEY (TabID) REFERENCES Res_Table(TabID) ON DELETE CASCADE, --ON UPDATE CASCADE
    CONSTRAINT Reservation_EmpID_fk FOREIGN KEY (EmpID) REFERENCES Employee(EmpID), --ON UPDATE CASCADE
    CONSTRAINT Reservation_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID) ON DELETE CASCADE 
);

CREATE TABLE Ordering(
    OrderID VARCHAR2(4) PRIMARY KEY,
    CustID VARCHAR2(4),
    EmpID VARCHAR2(4),
    ResID VARCHAR2(4),
    Order_Date DATE NOT NULL,
    Amount NUMBER(8) NOT NULL CHECK (Amount >= 1 AND Amount < 100000),
    Order_Type VARCHAR2(20),
    CONSTRAINT Order_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID), --ON UPDATE CASCADE
    CONSTRAINT Order_EmpID_fk FOREIGN KEY (EmpID) REFERENCES Employee(EmpID), --ON UPDATE CASCADE
    CONSTRAINT Order_ResID_fk FOREIGN KEY (ResID) REFERENCES Restaurant(ResID) --ON UPDATE CASCADE
);

CREATE TABLE Dine_In(
    OrderID VARCHAR2(4),
    TabID VARCHAR2(4),
    Serv_Charge NUMBER(2,2) NOT NULL CHECK(Serv_Charge >= 0.05 AND Serv_Charge <= 0.3),
    Dinning_Env VARCHAR2(20) NOT NULL,
    CONSTRAINT Dine_In_OrderID_fk FOREIGN KEY (OrderID) REFERENCES Ordering(OrderID), --ON UPDATE CASCADE
    CONSTRAINT Dine_In_TabID_fk FOREIGN KEY (TabID) REFERENCES Res_Table(TabID) --ON UPDATE CASCADE
);

CREATE TABLE Take_Away(
    OrderID VARCHAR2(4),
    Delivery_Addr VARCHAR2(100) NOT NULL,
    FoodApp VARCHAR2(20) NOT NULL,
    CONSTRAINT Take_Away_OrderID_fk FOREIGN KEY (OrderID) REFERENCES Ordering(OrderID) --ON UPDATE CASCADE
);

CREATE TABLE Ingredient(
    IngredID VARCHAR2(5) PRIMARY KEY,
    IngredName VARCHAR2(50),
    IngredType VARCHAR2(20),
    Price NUMBER(7) CHECK (Price >= 1 AND Price < 10000),
    Stock NUMBER(6) CHECK (Stock > 0 AND Stock < 1000)
);

CREATE TABLE IngredientRecords(
    IngredID VARCHAR2(5),
    OrderID VARCHAR2(4),
    Quantity VARCHAR2(20),
    CONSTRAINT IngredientRecords_IngredID_fk FOREIGN KEY (IngredID) REFERENCES Ingredient(IngredID), --ON UPDATE CASCADE
    CONSTRAINT IngredientRecords_OrderID_fk FOREIGN KEY (OrderID) REFERENCES Ordering(OrderID) --ON UPDATE CASCADE
);

CREATE TABLE Payment(
    PaymID VARCHAR2(5) PRIMARY KEY,
    TabID VARCHAR2(4),
    OrderID VARCHAR2(4),
    Pay_Method VARCHAR2(50),
    CONSTRAINT Payment_TabID_fk FOREIGN KEY (TabID) REFERENCES Res_Table(TabID) ON DELETE CASCADE, --ON UPDATE CASCADE
    CONSTRAINT Payment_OrderID_fk FOREIGN KEY (OrderID) REFERENCES Ordering(OrderID) ON DELETE CASCADE --ON UPDATE CASCADE
);

--inserting into TABLE Restaurant
INSERT INTO Restaurant (ResID, Res_Name, Res_Phone, Cuisine) 
VALUES ('R001', 'Spice Bistro', '0124859632', 'Italian Food');

INSERT INTO Restaurant (ResID, Res_Name, Res_Phone, Cuisine) 
VALUES ('R002', 'Ghany Café', '01041426966', 'Malaysian Food');

INSERT INTO Restaurant (ResID, Res_Name, Res_Phone, Cuisine) 
VALUES ('R003', 'Sushi Eatery', '0118987563', 'Japanese Food');

INSERT INTO Restaurant (ResID, Res_Name, Res_Phone, Cuisine) 
VALUES ('R004', 'Dragon-I', '0121479632', 'Chinese Food');

INSERT INTO Restaurant (ResID, Res_Name, Res_Phone, Cuisine) 
VALUES ('R005', 'Pizza Fusion', '01095938288', 'Western Food');

--inserting into TABLE Employee
INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E001', 'R001', 'Patric', 'Evans', 'F', TO_DATE('10-Jan-2000', 'DD-Mon-YYYY'), 2300, '0112367 8454', 'Klang', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E002', 'R005', 'Michelle', 'Yong', 'F', TO_DATE('11-Nov-1988', 'DD-Mon-YYYY'), 4200, '0133454 4824', 'Petaling', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E003', 'R002', 'John', 'Moore', 'M', TO_DATE('15-Dec-1977', 'DD-Mon-YYYY'), 6000, '0146453 4923', 'Ipoh', 'Perak');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E004', 'R004', 'Luna', 'Taylor', 'F', TO_DATE('5-May-1975', 'DD-Mon-YYYY'), 6400, '0166345 3939', 'Cyberjaya', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E005', 'R004', 'Eric', 'Hershey', 'F', TO_DATE('31-May-1995', 'DD-Mon-YYYY'), 3300, '0182233 9900', 'Putrajaya', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E006', 'R003', 'Victoria', 'Ceasar', 'M', TO_DATE('20-Feb-2003', 'DD-Mon-YYYY'), 2300, '0134892 894', 'Kulai', 'Johor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E007', 'R001', 'Lee', 'Brandon', 'M', TO_DATE('11-Jan-1994', 'DD-Mon-YYYY'), 3900, '0113466 5545', 'Banting', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E008', 'R001', 'Siew Qin', 'Ng', 'F', TO_DATE('13-May-1988', 'DD-Mon-YYYY'), 5100, '0172326 7788', 'Shah Alam', 'Selangor');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E009', 'R002', 'Shao An', 'Leong', 'F', TO_DATE('6-Jun-2000', 'DD-Mon-YYYY'), 3300, '0194233 8856', 'Seremban', 'Sembilan');

INSERT INTO Employee (EmpID, ResID, FName, LName, Gender, DOB, Salary, Phone, City, Emp_State) 
VALUES ('E010', 'R005', 'Yong', 'Danish', 'M', TO_DATE('9-Oct-1999', 'DD-Mon-YYYY'), 2300, '0101239 1236', 'Bentong', 'Pahang');

-- inserting into TABLE Res_Table
INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T101', 'Small', 'Available', 'R002');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T102', 'Small', 'Reserved', 'R005');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T103', 'Medium', 'Reserved', 'R001');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T104', 'Medium', 'Reserved', 'R002');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T105', 'Large', 'Available', 'R004');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T106', 'Large', 'Reserved', 'R004');

INSERT INTO Res_Table (TabID, Tab_Size, TabStatus, ResID) 
VALUES ('T107', 'Large', 'Available', 'R003');

--inserting into TABLE Chef
INSERT INTO Chef (EmpID, Specialization, Experience) 
VALUES ('E002', 'Chinese Delicacy', 18);

INSERT INTO Chef (EmpID, Specialization, Experience) 
VALUES ('E003', 'Western Cuisine', 22);

INSERT INTO Chef (EmpID, Specialization, Experience) 
VALUES ('E004', 'Indian Delicacy', 25);

INSERT INTO Chef (EmpID, Specialization, Experience) 
VALUES ('E007', 'Western Cuisine', 12);

INSERT INTO Chef (EmpID, Specialization, Experience) 
VALUES ('E008', 'Chinese Delicacy', 20);

--inseting into TABLE Waiter
INSERT INTO Waiter (EmpID, Experience) 
VALUES ('E001', 7);

INSERT INTO Waiter (EmpID, Experience) 
VALUES ('E005', 6);

INSERT INTO Waiter (EmpID, Experience) 
VALUES ('E006', 5);

INSERT INTO Waiter (EmpID, Experience) 
VALUES ('E009', 5);

INSERT INTO Waiter (EmpID, Experience) 
VALUES ('E010', 7);

--inserting into TABLE Customer
INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C201', 'Adam', 'Smith', 'M', '0125837 7786');

INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C202', 'David', 'Johnson', 'M', '0136747 3383');

INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C203', 'Jessica', 'Williams', 'F', '0165566 8899');

INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C204', 'Ryan', 'Clark', 'M', '018289 4463');

INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C205', 'Justin', 'Lewis', 'F', '0124848 7788');

INSERT INTO Customer (CustID, CustFName, CustLName, Gender, Phone) 
VALUES ('C206', 'Elizabeth', 'Lee', 'F', '0110203 5566');

-- inserting into TABLE Reservation
INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1001', 'T105', 'E005', 'C201', TO_DATE('15-Jun-2024', 'DD-Mon-YYYY') , 'Processing', 2);

INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1002', 'T107', 'E006', 'C202', TO_DATE('15-May-2024', 'DD-Mon-YYYY') , 'Confirmed', 2);

INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1003', 'T104', 'E009', 'C203', TO_DATE('30-Apr-2024', 'DD-Mon-YYYY') , 'Cancel', 6);

INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1004', 'T103', 'E001', 'C204', TO_DATE('1-May-2024', 'DD-Mon-YYYY') , 'Confirmed', 5);

INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1005', 'T107', 'E006', 'C203', TO_DATE('7-Jul-2024', 'DD-Mon-YYYY') , 'Confirmed', 10);

INSERT INTO Reservation (RsvnID, TabID, EmpID, CustID, Rsvn_Date, Rsvn_Status, Num_People) 
VALUES ('R1006', 'T106', 'E005', 'C204', TO_DATE('31-Aug-2024', 'DD-Mon-YYYY') , 'Processing', 9);

--inserting into TABLE Ordering
INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O301', 'C201', 'E002', 'R005', TO_DATE('20-Feb-2024','DD-Mon-YYYY'), 139.90, 'Dine In');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O302', 'C202', 'E003', 'R002', TO_DATE('15-Jan-2024','DD-Mon-YYYY'), 149.90, 'Dine In');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O303', 'C206', 'E008', 'R001', TO_DATE('25-Dec-2023','DD-Mon-YYYY'), 69.90, 'Take Away');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O304', 'C204', 'E003', 'R002', TO_DATE('30-Mar-2024','DD-Mon-YYYY'), 359.90, 'Dine In');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O305', 'C203', 'E004', 'R004', TO_DATE('6-May-2024','DD-Mon-YYYY'), 899.90, 'Dine In');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O306', 'C204', 'E004', 'R004', TO_DATE('1-Mar-2024','DD-Mon-YYYY'), 1099.90, 'Dine In');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O307', 'C201', 'E007', 'R001', TO_DATE('14-Feb-2024','DD-Mon-YYYY'), 229.90, 'Take Away');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O308', 'C205', 'E008', 'R001', TO_DATE('3-Mar-2024','DD-Mon-YYYY'), 309.90, 'Take Away');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O309', 'C206', 'E002', 'R005', TO_DATE('1-Jan-2024','DD-Mon-YYYY'), 199.90, 'Take Away');

INSERT INTO Ordering (OrderID, CustID, EmpID, ResID, Order_Date, Amount, Order_Type) 
VALUES ('O310', 'C201', 'E007', 'R001', TO_DATE('24-Feb-2024','DD-Mon-YYYY'), 209.90, 'Take Away');

--inserting into TABLE Dine In
INSERT INTO Dine_In (OrderID, TabID, Serv_Charge, Dinning_Env) 
VALUES ('O301', 'T102', 0.05 , 'Ordinary');

INSERT INTO Dine_In (OrderID, TabID, Serv_Charge, Dinning_Env) 
VALUES ('O302', 'T101', 0.05 , 'Ordinary');

INSERT INTO Dine_In (OrderID, TabID, Serv_Charge, Dinning_Env) 
VALUES ('O304', 'T104', 0.1 , 'Premium');

INSERT INTO Dine_In (OrderID, TabID, Serv_Charge, Dinning_Env) 
VALUES ('O305', 'T105', 0.1 , 'Premium');

INSERT INTO Dine_In (OrderID, TabID, Serv_Charge, Dinning_Env) 
VALUES ('O306', 'T106', 0.1 , 'Premium');

--inserting into TABLE Take_Away
INSERT INTO Take_Away (OrderID, Delivery_Addr, FoodApp) 
VALUES ('O303', 'Jalan perak 100, 30000 Perak', 'Graby');

INSERT INTO Take_Away (OrderID, Delivery_Addr, FoodApp) 
VALUES ('O307', 'Taman perdana 2, 30000 Perak', 'Graby');

INSERT INTO Take_Away (OrderID, Delivery_Addr, FoodApp) 
VALUES ('O308', '3, Emas City, 40000, Kuala Lumpur', 'Speedy');

INSERT INTO Take_Away (OrderID, Delivery_Addr, FoodApp) 
VALUES ('O309', '99, Bayu Emas, 45000, Klang', 'Speedy');

INSERT INTO Take_Away (OrderID, Delivery_Addr, FoodApp) 
VALUES ('O310', '888, Petaling Jaya, 50000, Selangor', 'Graby');


--inserting into TABLE Ingredient
INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3001', 'Ginger', 'Vegetable', 15, 10);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3002', 'Onion', 'Vegetable', 5.50, 20);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3003', 'Garlie', 'Vegetable', 8.90, 20);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3004', 'Black Pepper Seed', 'Spices', 33.90, 8);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3005', 'Flour', 'Wholemeal', 2.90, 20);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3006', 'Curry Powder', 'Spices', 29.90, 10);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3007', 'Chicken Breast', 'Meat', 18.90, 50);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3008', 'Fish', 'Meat', 19.90, 50);

INSERT INTO Ingredient (IngredID, IngredName, IngredType, Price, Stock) 
VALUES ('I3009', 'Beef', 'Meat', 22.90, 50);

--inserting into TABLE IngredientRecords
INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3001', 'O301', '1 Pcs');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3002', 'O302', '0.5 Pcs');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3004', 'O304', '1 Little');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3002', 'O301', '2 Pcs');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3006', 'O302', '150 Grams');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3005', 'O304', '300 Grams');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3007', 'O301', '1 Pcs');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3008', 'O302', '1 Pcs');

INSERT INTO IngredientRecords (IngredID, OrderID, Quantity) 
VALUES ('I3009', 'O304', '1 Pcs');

--inserting into TABLE Payment
INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay01', 'T102', 'O301', 'Ewallet');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay02', 'T101', 'O302', 'Cash');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay03', 'T104', 'O304', 'Cash');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay04', 'T105', 'O305', 'Bank Transfer');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay05', 'T106', 'O306', 'Cash');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay06', NULL, 'O303', 'Ewallet');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay07', NULL, 'O307', 'Bank Transfer');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay08', NULL, 'O308', 'Bank Transfer');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay09', NULL, 'O309', 'Ewallet');

INSERT INTO Payment (PaymID, TabID, OrderID, Pay_Method) 
VALUES ('Pay10', NULL, 'O310', 'Ewallet');

-- Creating Roles

-- Role for Administrator and Permission
CREATE ROLE c##admins_role;
GRANT CREATE SESSION TO admins; --allows to connect to database
GRANT CREATE USER, ALTER USER, DROP USER TO admins; --allows to manage user
GRANT CREATE ROLE, ALTER ROLE, DROP ROLE TO admins;  -- Allow role management
GRANT CREATE ANY TABLE, DROP ANY TABLE TO admins; -- allows creating and dropping any table in the database
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ANY TABLE TO admins WITH GRANT OPTION; -- allow to perform most common operations and grant permissions to other role if needed

-- Role for manager and permission
CREATE ROLE c##manager_role; 
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ANY TABLE TO c##manager_role; -- allows manager to manage any TABLES


-- Role for customer and permission
CREATE ROLE c##customer_role;
GRANT SELECT, UPDATE ON Customer TO c##customer_role; -- allows customer to view and update their information
GRANT SELECT ON Restaurant(Cuisine) TO c##customer_role; -- allows customer to view available restaurants cuisine
GRANT SELECT ON Ordering TO c##customer_role; -- allows customer to view the order
GRANT SELECT ON Payment TO c##customer_role; -- allows customer to view their payment

-- Role for waiter and permission
CREATE ROLE c##waiter_role;
GRANT SELECT ON Restaurant, Res_Table; -- view available restaurants and tables
GRANT UPDATE ON Res_Table(TabStatus, Tab_Size); -- allows waiter to modify table status
GRANT SELECT, INSERT, DELETE, UPDATE, EXECUTE ON Reservation, Ordering, Dine_In, Take_Away TO c##waiter_role; -- allows waiter to manage reservations, orders, dine_in order, take away orders
GRANT SELECT, INSERT, UPDATE, EXECUTE ON Payment TO c##waiter_role; -- allows waiter to manage Payment but not delete any records of customer payment

-- Role for chef and permission
CREATE ROLE c##chef_role;
GRANT SELECT ON Ordering TO c##chef_role;
GRANT SELECT, UPDATE ON IngredientRecords TO c##chef_role;
GRANT SELECT ON Ingredient TO c##chef_role;

COMMIT;


