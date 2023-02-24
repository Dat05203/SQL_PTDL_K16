-- Chọn csdl muốn làm việc là csdl hệ thống
USE master
GO
--Xóa csdl QLVT
If  EXISTS(SELECT 'True' FROM master.dbo.SysDatabases WHERE Name = 'QLVT')
	DROP DATABASE QLVT
GO
-- Tạo csdl mới QLVT
CREATE DATABASE QLVT
GO
-- Chọn csdl muốn làm việc là csdl VT
USE QLVT
GO
--Tạo bảng Vật tư
CREATE TABLE VatTu(
	MaVT	char(4)	PRIMARY KEY,
	TenVT	nvarchar(100) UNIQUE,
	DvTinh	nvarchar(10) DEFAULT '" "',
	PhanTram	real CHECK(PhanTram >= 0 and PhanTram <= 100 ) )
--Tạo bảng Nhà cung cấp
CREATE TABLE NHaCC(
	MaNCC	char(3)	PRIMARY KEY,
	TenNCC	nvarchar(100)	 UNIQUE,
	DiaChi	nvarchar(200) UNIQUE,
	DienThoai	varchar(20) NOT NULL DEFAULT N'Chưa có' )
-- Tạo bảng đơn hàng
CREATE TABLE DonDH(
	SoDH	char(4) PRIMARY KEY,
	NgayDH	date DEFAULT GETDATE(),
	MaNCC		char(3) FOREIGN KEY (MaNCC) REFERENCES NHaCC(MaNCC) 
	ON UPDATE CASCADE ON DELETE CASCADE)
--Tạo bảng chi tiết đơn hàng
CREATE TABLE CTDonDH (
	SoDH	char(4),
	MaVT	char(4),
	SLDat int NOT NULL CHECK(SLDat > 0),
	PRIMARY KEY (SoDH, MaVT),
	FOREIGN KEY (SoDH) REFERENCES DonDH(SoDH) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (MaVT) REFERENCES VatTu(MaVT) ON UPDATE CASCADE ON DELETE CASCADE )
--tạo bảng Phiếu nhập
CREATE TABLE PNhap (
	SoPN	char(4) PRIMARY KEY,
	NgayNhap	date	NOT NULL,
	SoDH	char(4) FOREIGN KEY (SoDH) REFERENCES DonDH(SoDH)
					ON UPDATE CASCADE ON DELETE CASCADE )
-- Tạo bảng Chi tiết phiếu nhập
CREATE TABLE CTPNhap (
	SoPN	char(4),
	MaVT	char(4),
	SLNhap	int NOT NULL CHECK(SLNhap > 0),
	Dgnhap	money NOT NULL CHECK(Dgnhap > 0),
	PRIMARY KEY (SoPN, MaVT),
	FOREIGN KEY (SoPN) REFERENCES PNhap(SoPN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (MaVT) REFERENCES VatTu(MaVT) ON UPDATE CASCADE ON DELETE CASCADE)
-- Tạo bảng phiếu xuất
CREATE TABLE PXuat (
	SoPX	char(4)	PRIMARY KEY,
	NgayXuat	date	NOT NULL,
	TenKH	nvarchar(100)	NOT NULL )
--Tạo bảng chi tiết phiếu xuất
CREATE TABLE CTPXuat (
	SoPX	char(4),
	MaVT	char(4),
	SlXuat	int CHECK(SlXuat > 0)	NOT NULL,
	DgXuat	money CHECK(DgXuat > 0) NOT NULL,
	FOREIGN KEY (SoPX) REFERENCES PXuat(SoPX) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (MaVT) REFERENCES VatTu(MaVT) ON UPDATE CASCADE ON DELETE CASCADE )
--Tạo bảng tồn kho
CREATE TABLE TonKho (
	NamThang	char(6),
	MaVT	char(4),
	SLDau	int NOT NULL CHECK(SLDau >= 0)	DEFAULT 0,
	TongSLN	int NOT NULL CHECK(TongSLN >= 0)	DEFAULT 0,
	TongSLX	int NOT NULL CHECK(TongSLX >= 0)	DEFAULT 0,
	SLCuoi	int,
	PRIMARY KEY (NamThang, MaVT),
	FOREIGN KEY (MaVT) REFERENCES VatTu(MaVT) ON UPDATE CASCADE ON DELETE CASCADE )
--Chèn dữ liệu vào bảng
--chèn dữ liệu vào bảng Nhà cung cấp
INSERT INTO NHaCC	 VALUES 
						('C01',N'Lê Minh Trí', N'54 Hậu Giang Q6 HCM', '8781024'),
						('C02',N'Trần Minh Thạch', N'145 Hùng Vương Mỹ Tho', '7698154'),
						 ('C03',N'Hồng Phương', N'154/85 Lê Lai Q1 HCM', '9600125'),
						 ('C04',N'Nhật Thắng', N'198/40 Hương Lộ 14 QTB HCM', '8757757'),
						 ('C05',N'Lưu Nguyệt Quế', N'178 Nguyễn Văn Luông Đà Lạt', '7964251'),
						 ('C07',N'Cao Minh Trung', N'125 Lê Quang Sung Nha Trang',DEFAULT)
	SElECT * FROM NHaCC --hiển thị dữ liệu
-- chèn dữ liệu vào bảng vật tư
INSERT INTO VatTu VALUES ('DD01',N'Đầu DVD Hitachi 1 đĩa', N'Bộ', 40),
						 ('DD02',N'Đầu DVD Hitachi 3 đĩa', N'Bộ', 40),
						 ('TL15',N'Tủ lạnh Sanyo 150 lít', N'Cái', 25),
						 ('TL90',N'Tủ lạnh Sanyo 90 lít', N'Cái', 20),
						 ('TV14',N'Tivi Sony 14 inches', N'Cái', 15),
						 ('TV21',N'Tivi Sony 21 inches', N'Cái', 10),
						 ('TV29',N'Tivi Sony 29 inches', N'Cái', 10),
						 ('VD01',N'Đầu VCD Sony 1 đĩa', N'Bộ', 30),
						 ('VD02',N'Đầu VCD Sony 3 đĩa', N'Bộ', 30)
	SELECT * FROM VatTu
--chèn dữ liệu vào bảng đơn hàng
INSERT INTO DonDH  VALUES ('D001','01/15/2002', 'C03'),
						 ('D002','01/30/2002', 'C01'),
						 ('D003','02/10/2002', 'C02'),
						 ('D004','02/17/2002', 'C05'),
						 ('D005','03/01/2002', 'C02'),
						 ('D006','03/12/2002', 'C05')
SELECT * FROM DonDH
--bảng phiếu nhập
INSERT INTO PNhap VALUES ('N001','01/17/2002', 'D001'),
						('N002','01/20/2002', 'D001'),
						 ('N003','01/31/2002', 'D002'),
						 ('N004','02/15/2002', 'D003')
SELECT * FROM PNhap
--bảng chi tiết đơn hàng
INSERT INTO CTDonDH VALUES ('D001','DD01',10),
						   ('D001','DD02',15),
						   ('D002','VD02',30),
						   ('D003','TV14',10),
						   ('D003','TV29',20),
						   ('D004','TL90',10),
						   ('D005','TV14',10),
						   ('D005','TV29',20),
						   ('D006','TV14',10),
						   ('D006','TV29',20),
						   ('D006','VD01',20)
SELECT * FROM CTDonDH
--bảng chi tiết phiếu nhập
INSERT INTO CTPNhap VALUES ('N001','DD01',8, 2500000),
						   ('N001','DD02', 10, 3500000),
						   ('N002','DD01', 2, 2500000),
						   ('N002','DD02', 5, 3500000),
						   ('N003','VD02', 30, 2500000),
						   ('N004','TV14', 5, 2500000),
						   ('N004','TV29', 12, 3500000)
SELECT * FROM CTPNhap
--bảng phiếu xuất
INSERT INTO PXuat VALUES ('X001','01/17/2002', N'Nguyễn Ngọc Phương Nhi'),
						 ('X002','01/25/2002', N'Nguyễn Hồng Phương'),
						 ('X003','01/31/2002', N'Nguyễn Tuấn Tú')
SELECT * FROM PXuat
--bảng chi tiết phiếu xuất
INSERT INTO CTPXuat VALUES ('X001','DD01', 2, 3500000),
							('X002','DD01', 1, 3500000),
						   ('X002','DD02', 5, 4900000),
						   ('X003','DD01', 3, 3500000),
						   ('X003','DD02', 2, 4900000),
						   ('X003','VD02', 10, 3250000)
SELECT * FROM CTPXuat
--bảng tồn kho
INSERT INTO TonKho VALUES ('200201','DD01', 0, 10, 6, 4),
						   ('200201','DD02', 0, 15, 7, 8),
						  ('200201','VD02', 0, 30, 10, 20),
						  ('200202','DD01', 4, 0, 0, 4),
						  ('200202','DD02', 8, 0, 0, 8),
						  ('200202','VD02', 20, 0, 0, 20),
						  ('200202','TV14', 5, 0, 0, 5),
						  ('200202','TV29', 12, 0, 0, 12)
SELECT * FROM TonKho
