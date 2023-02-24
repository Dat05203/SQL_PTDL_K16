USE QLVT
GO
/*a. Tạo view có tên vw_DMVT bao gồm các thông tin sau: mã vật tư, tên vật tư. View 
này dùng để liệt kê danh sách các vật tư hiện có trong bảng VATTU. */
CREATE VIEW VW_DMVT
AS
SELECT MaVT, TenVT
FROM VatTu
--hiển thị view
SELECT * FROM VW_DMVT
/*b. Tạo view có tên vw_DonDH_TongSLDatNhap bao gồm các thông tin sau: số đặt 
hàng, tổng số lượng đặt, tổng số lượng nhập. View này được dùng để thống kê những 
đơn đặt hàng nào đã được nhập hàng đầy đủ. */
CREATE VIEW VW_DONDH_TONGSLDATNHAP
AS
SELECT  PNhap.SoDH, SUM(SLDat) AS TSLDAT, SUM(SLNhap) AS TSLNHAP
FROM    CTDonDH INNER JOIN PNhap ON CTDonDH.SoDH=PNhap.SoDH
		INNER JOIN CTPNhap ON PNhap.SoPN=CTPNhap.SoPN
WHERE CTDonDH.MaVT=CTPNhap.MaVT
GROUP BY PNhap.SoDH
     --HIỂN THỊ VIEW                    
SELECT * FROM VW_DONDH_TONGSLDATNHAP
/*c. Tạo view có tên vw_DonDH_DaNhapDu bao gồm các thông tin sau: số đặt hàng, đã 
nhập đủ trong đó cột đã nhập đủ sẽ có 2 giá trị là “Đã nhập đủ” nếu đơn đặt hàng đó đã 
nhập đủ hoặc “Chưa nhập đủ” nếu đơn đặt hàng đó chưa nhập đủ.*/
CREATE VIEW VW_DONDH_DANHAPDU
AS
SELECT SODH, CASE
WHEN TSLDAT=TSLNHAP THEN N'ĐÃ NHẬP ĐỦ'
ELSE N'CHƯA NHẬP ĐỦ'
END AS TrangThai
FROM VW_DONDH_TONGSLDATNHAP
--hiển thị View
SELECT * FROM VW_DONDH_DANHAPDU
/*d. Tạo view có tên vw_TongNhap bao gồm các thông tin sau: năm tháng, mã vật tư, 
tổng số lượng nhập. View này dùng để thống kê số lượng nhập của các vật tư trong từng 
năm tháng tương ứng. Chú ý: không sử dụng bảng TONKHO. */
CREATE VIEW VW_TONGNHAP
AS
SELECT MONTH(PNhap.NgayNhap) AS THANG, YEAR(PNhap.NgayNhap) AS NAM, MaVT, SUM(CTPNhap.SLNhap) AS TSLNHAP
FROM  CTPNhap INNER JOIN PNhap ON CTPNhap.SoPN = PNhap.SoPN
GROUP BY MONTH(PNhap.NgayNhap), YEAR(PNhap.NgayNhap),MaVT
--hiển thị View
SELECT * FROM VW_TONGNHAP
SELECT * FROM CTDonDH INNER JOIN PNhap ON PNhap.SoDH=CTDonDH.SoDH
INNER JOIN CTPNhap ON PNhap.SoPN=CTPNhap.SoPN
/*e. Tạo view có tên vw_TongXuat bao gồm các thông tin sau: năm tháng, mã vật tư, tổng 
số lượng xuất. View này dùng để thống kê số lượng xuất của vật tư trong từng năm 
tháng tương ứng. Chú ý: không sử dụng bảng TONKHO. */
ALTER VIEW VW_TONGXUAT
AS 
SELECT MONTH(NgayXuat) AS Thang, YEAR(NgayXuat) AS Nam, MaVT, SUM(SLXuat) AS TSLXUAT
FROM CTPXuat INNER JOIN PXuat ON CTPXuat.SoPX=PXuat.SoPX
GROUP BY MONTH(NgayXuat), YEAR(NgayXuat), MaVT
--Hiển thị View
SELECT * FROM VW_TONGXUAT
/*f. Tạo view có tên vw_DonDH_MaVTu_TongSLNhap bao gồm các thông tin sau: số
đặt hàng, ngày đặt hàng, mã vật tư, tên vật tư, số lượng đặt, tổng số lượng đã nhập hàng */
CREATE VIEW VW_DONDH_MAVTU_TONGSLNHAP
AS
SELECT CTDonDH.SoDH, NgayNhap,VatTu.MaVT, TenVT, SUM(SLDat) AS TSLDAT, SUM(SLNhap) AS TSLNHAP
FROM  VatTu INNER JOIN CTPNhap ON CTPNhap.MaVT = VatTu.MaVT 
			INNER JOIN CTDonDH ON VatTu.MaVT = CTDonDH.MaVT 
			INNER JOIN PNhap ON CTPNhap.SoPN = PNhap.SoPN
GROUP BY CTDonDH.SoDH, NgayNhap, VatTu.MaVT, TenVT
SELECT * FROM VW_DONDH_MAVTU_TONGSLNHAP
--2. Kết hợp các view ở câu 1, thực hiện các truy vấn chọn lựa trả lời các câu hỏi sau: 
--a. Cho biết danh sách các phiếu đặt hàng chưa được nhập hàng. 
SELECT *
FROM DonDH WHERE SoDH NOT IN (SELECT SoDH FROM VW_DONDH_TONGSLDATNHAP)
--b. Cho biết danh sách các mặt hàng chưa được đặt hàng bao giờ. 
SELECT * 
FROM VatTu WHERE MaVT NOT IN (SELECT MaVT FROM CTDonDH)
--c. Cho biết nhà cung cấp nào có nhiều đơn đặt hàng nhất.
SELECT * FROM NHACC
WHERE MaNCC IN (SELECT MaNCC FROM DonDH
				GROUP BY MaNCC
				HAVING COUNT(SoDH) =(SELECT MAX(SLDH) FROM (SELECT COUNT(SODH) AS SLDH
											                FROM DonDH
											                GROUP BY MaNCC) AS BANGTAM))
--d. Cho biết vật tư nào có tổng số lượng xuất bán là nhiều nhất. 
SELECT *
FROM VatTu
WHERE MaVT IN (SELECT MaVT FROM VW_TONGXUAT WHERE TSLXUAT= (SELECT MAX(TSLXUAT) FROM VW_TONGXUAT))
--e. Cho biết đơn đặt hàng nào có nhiều mặt hàng nhất. 
SELECT * FROM DonDH WHERE SoDH IN ( SELECT SoDH FROM CTDonDH 
									GROUP BY SoDH
									HAVING COUNT(MaVT)= (SELECT MAX(SLVT)
															FROM (SELECT COUNT(MaVT) AS SLVT
																	FROM CTDonDH
																	GROUP BY SoDH)AS BT))								
--f. Cho biết tình hình nhập xuất của vật tư thông tin gồm: năm tháng, mã vật tư, tên vật 
--tư, tổng số lượng nhập, tổng số lượng xuất. 
SELECT VW_TONGNHAP.THANG, VW_TONGNHAP.NAM,VW_TONGXUAT.Thang, VW_TONGXUAT.Nam, VatTu.MaVT, TenVT, TSLNHAP, TSLXUAT
FROM VatTu INNER JOIN VW_TONGNHAP 
ON VatTu.MaVT=VW_TONGNHAP.MaVT
INNER JOIN VW_TONGXUAT
ON VatTu.MaVT=VW_TONGXUAT.MaVT
--g. Cho biết tình hình đặt và nhập hàng: đơn đặt hàng, mã vật tư, số lượng đặt, tổng số lượng nhập. 
SELECT CTDonDH.SoDH, MaVT, TSLDAT, TSLNHAP
FROM VW_DONDH_TONGSLDATNHAP INNER JOIN CTDonDH
ON VW_DONDH_TONGSLDATNHAP.SoDH=CTDonDH.SoDH
--h. Thông kê tình hình đặt hàng trong từng ngày: ngày đặt hàng, mã vật tư, tên vật tư, tổng số lượng đặt hàng. 
SELECT NgayDH, VatTu.MaVT, TenVT, SUM(SLDAT) AS TSLDATHANG
FROM DonDH INNER JOIN CTDonDH ON DonDH.SoDH=CTDonDH.SoDH
INNER JOIN VatTu ON VatTu.MaVT=CTDonDH.MaVT
GROUP BY NgayDH, VatTu.MaVT, TenVT
--i. Thống kê tình hình nhập hàng tương tự tình hình đặt hàng. 
SELECT NgayNhap, VatTu.MaVT, TenVT, SUM(SLNHAP) AS TSLNHAP
FROM PNhap INNER JOIN CTPNhap ON PNhap.SoPN=CTPNhap.SoPN
INNER JOIN VatTu ON VatTu.MaVT=CTPNhap.MaVT
GROUP BY NgayNhap, VatTu.MaVT, TenVT
--j. Thống kê những đơn đặt hàng nào chưa được nhập đủ số lượng hàng
SELECT * FROM DonDH
WHERE SoDH IN (SELECT SoDH FROM VW_DONDH_DANHAPDU WHERE TrangThai=N'CHƯA NHẬP ĐỦ')