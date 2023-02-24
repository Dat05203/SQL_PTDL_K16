use QLVT
go

---------------------------BÀI TẬP THỰC HÀNH SỐ 1-------------------------------------

/*BÀI TẬP 4: SỬ DỤNG CÂU LỆNH UPDATE, DELETE*/
--a. Cập nhật số điện thoại của nhà hàng có mã C01 thành 098473645
update NHaCC
set DienThoai = '098473645'
where MaNCC = 'C01'

select * from NHaCC

--b. Xóa các nhà cung cấp chưa có số điện thoại
delete from NHaCC
where DienThoai = 'Chua có'

--c. Các vật tư có số lượng xuất từ 3 trở lên thì giảm đơn giá đi 1.000.000
update CTPXuat
set DgXuat -= 1000000
where SlXuat >= 3

select * from CTPXuat

-----------------------------------BÀI TẬP THỰC HÀNH SỐ 4 -----------------------------------

/*BÀI 1: THỰC HÀNH TRUY VẤN VỚI GROUP BY*/
--1. Hiển thị mã vật tư và tổng số lượng đặt của từng vật tư 
select MaVT, sum(SlDat) as "Tổng số lượng đặt"
from CTDonDH 
group by MaVT
--2. Đưa ra số phiếu xuất đã xuất từ 3 vật tư trở lên
select SoPX from CTPXuat
where SlXuat >= 3
group by SoPX
--3. Hiển thị ngày xuất và số lượng phiếu xuất theo từng ngày sắp xếp theo chiều tăng dần của của số lượng phiếu xuất 
select 
    NgayXuat, count(CTPXuat.SoPX) as "Số lượng phiếu xuất"
from  
    PXuat
	inner join CTPXuat
	on PXuat.SoPX = CTPXuat.SoPX
group by NgayXuat
-- 4. Hiển thị mã vật tư và số lượng đặt lớn nhất của từng vật tư
select 
     MaVT, 
	 max(SlDat) "Số lượng đặt lớn nhất"
from 
     CTDonDH
group by 
     MaVT
--5. Hiển thị mã vật tư và số lượng phiếu nhập đã nhập các vật tư đó. 
select  
      MaVT,
	  count(SoPN) "Số lượng phiếu nhập"
from 
      CTPNhap
group by 
      MaVT
--6. Hiển thị các ngày nhập có số lượng đơn hàng từ 5 trở lên. 
select
      PNhap.NgayNhap
from
      PNhap
	  inner join CTPNhap
	  on PNhap.SoPN = CTPNhap.SoPN
group by PNhap.NgayNhap
having sum(CTPNhap.SLNhap) >= 5
--7. Hiển thị mã nhà cung cấp đã cung cấp ít nhất 2 đơn hàng trở lên. 
select 
       DonDH.MaNCC
from 
      DonDH
      inner join CTDonDH
	  on DonDH.SoDH = CTDonDH.SoDH
group by DonDH.MaNCC
having count(CTDonDH.SoDH) >= 2
--8. Hiển thị số hóa đơn và tổng số lượng đặt theo từng hóa đơn sắp xếp theo chiều giảm dần của số lượng đặt. 
select 
      SoDH,
	  sum(SlDat) "Tổng số lượng đặt"
from CTDonDH
group by SoDH
order by sum(SlDat) desc;
--9. Hiển thị mã vật tư, tổng số lượng nhập của những vật tư có đơn giá nhập nhỏ hơn 10. 
select 
      MaVT,
	  sum(SlNhap) as "Tổng số lượng nhập"
from CTPNhap
group by MaVT
having  sum(Dgnhap) < 10000000
--10.Hiển thị mã vật tư có tổng số lượng cuối từ 10 với 30
select
      MaVT
from 
      TonKho
group by 
      MaVT
having sum(SLCuoi) between 10 and 30

/*BÀI 2: THỰC HIỆN TRUY VẤN TRÊN NHIỀU BẢNG*/
--1. Hiển thị danh sách tên vật tư, đơn vị tính và số lượng cuối của vật tư sắp xếp theo thứ tự giảm dần của tên vật tư
select 
      TenVT,
	  DvTinh,
	  SlCuoi
from
      VatTu
	  inner join TonKho
	  on VatTu.MaVT = TonKho.MaVT
order by TenVT desc;
--2. Hiển thị danh sách các thông tin trong bảng CTPNHAP có thêm cột thành tiền biết Thành tiền= số lượng nhập* đơn giá nhập
select 
      *,
	  SLNhap*Dgnhap as "Thành tiền"
from 
      CTPNhap    
--3. Hiển thị số đơn hàng và danh sách các tên tất cả các nhà cung cấp kể cả các nhà cung cấp không cung cấp đơn hàng nào.
select 
      DonDH.SoDH,
	  TenNCC
from 
      NHaCC
	  left join DonDH 
	  on NHaCC.MaNCC = DonDH.MaNCC
--4. Đưa ra số đơn hàng, ngày lập đơn hàng và tên nhà cung cấp đã cung cấp các đơn hàng đó.
select 
      SoDH,
	  NgayDH,
	  TenNCC
from
      DonDH
	  inner join NHaCC
	  on DonDH.MaNCC = NHaCC.MaNCC
--5. Đưa ra tên vật tư, số đơn hàng và số lượng đặt của vật tư đó trong từng đơn hàng
select
      TenVT,
	  SoDH,
	  SLDat
from 
      VatTu
      inner join CTDonDH
	  on CTDonDH.MaVT = VatTu.MaVT
--6. Đưa ra tên vật tư và tổng số lượng đặt của vật tư đó đã được đặt
select 
      TenVT,
	  sum(SLDat) as "Tổng số lượng đặt"
from 
      VatTu
	  inner join CTDonDH
	  on VatTu.MaVT = CTDonDH.MaVT
group by TenVT
--7. Đưa ra tên vật tư, số phiếu nhập và số lượng nhập của vật tư đó trong từng phiếu
select 
      TenVT,
	  SoPN,
	  SLNhap
from 
      VatTu
	  inner join CTPNhap
	  on VatTu.MaVT = CTPNhap.MaVT
--8. Hiển thị số phiếu xuất và tên tât cả các vật tư, kể cả các vật tư không xuất hiện trong phiếu xuất nào.
select  
      PXuat.SoPX,
	  TenVT
from 
      PXuat
	  inner join CTPXuat
	  on PXuat.SoPX = CTPXuat.SoPX
	  right join VatTu
	  on CTPXuat.MaVT = VatTu.MaVT
--9. Hiển thị danh sách các phiếu xuất hàng gồm có các cột số phiếu xuất và tổng trị giá, trong đó sắp xếp theo thứ tự tổng trị giá giảm dần.
select
      PXuat.SoPX,
	  sum(DgXuat) "Tổng trị giá"
from 
      PXuat
	  inner join CTPXuat
	  on PXuat.SoPX = CTPXuat.SoPX
group by PXuat.SoPX
order by sum(DgXuat) desc;
--10. Liệt kê danh sách các đơn đặt hàng trong bảng DONDH bổ sung thêm cột hiển thị thứ trong tuần bằng tiếng việt của ngày đặt hàng.
select 
      *,
	  DATENAME(W,NgayDH) as Thứ
from 
     DonDH
--11. Giảm đơn giá của các hàng hóa bán ra trong tháng 01/2002 theo qui tắc sau: 
                       --Không giảm số lượng <4
                       --Giảm 5% nếu số lượng >=4 và số lượng <10
                       --Giảm 10% nếu số lượng>=10 và số lượng <=20
                       --Giảm 20% nếu số lượng >20.
update CTPXuat 
set 
    DgXuat = case
          when SlXuat >= 4 and SlXuat < 10 
		       then  DgXuat - DgXuat*0.05
	      when SlXuat >= 10 and SlXuat <= 20 
		       then DgXuat - DgXuat*0.1
	      when SlXuat > 20 
		       then DgXuat - DgXuat*0.2
	      else DgXuat-0
end 
select * from CTPXuat
--12. Đưa ra Tên vật tư có đơn giá nhập nhỏ nhất.
Select 
      TenVT,
	  CTPNhap.MaVT,
	  min(DgNhap) "Đơn giá nhập nhỏ nhất"
from 
      VatTu
	  inner join CTPNhap
	  on VatTu.MaVT = CTPNhap.MaVT
group by TenVT, CTPNhap.MaVT          
--13. Hiển thị tên vật tư có tổng số lượng đặt từ 30 trở lên
--14. Hiển thị tên khách hàng nhận từ 3 vật tư trở lên
--15. Đưa ra số đơn hàng, tổng số lượng đặt của từng đơn hàng
--16. Đưa ra số đơn hàng, tổng số lượng nhập của từng đơn hàng.
--17. Hiển thị năm tháng, tên vật tư, tổng số lượng nhập của từng vật tư
--18. Hiển thị năm tháng, tên vật tư , tổng số lượng xuất của từng vật tư
--19. Hiển thị số đơn hàng, ngày đặt hàng, mã vật tư, tên vật tư, số lượng đặt và tổng số lượng đã nhập hàng.
--20. Hiển thị các phiếu đặt hàng chưa nhập được hàng.
--21. Hiển thị tên vật tư không bị tồn kho vào tháng 2 năm 2005
--22. Hiển thị tên các nhà cung cấp đã cung cấp đơn hàng từ tháng 2 tới tháng 3 năm 2005
--23. Hiển thị danh sách các phiếu nhập đơn hàng chưa nhập được hàng.
--24. Hiển thị tên vật tư có đơn giá xuất từ 2,000,000 và có tổng số lượng đã xuất từ 3 trở lên.
--25. Hiển thị tên vật tư có đơn giá nhập nhỏ hơn đơn giá nhập trung bình của tất cả các vật tư
--26. Hiển thị số lượng vật tư tồn kho theo năm, tháng
--27. Hiển thị số đơn hàng và số lượng phiếu nhập đã được lập để đáp ứng cho đơn hàng đó.
--28. Hiển thị số lượng đơn hàng đã được lập trong tháng 1 năm 2005
--29. Hiển thị số đơn hàng đã nhập dưới 5 loại vật tư
--30. Hiển thị các nhà cung cấp ở Hồ Chí Minh đã cung cấp từ 3 đơn hàng trở lên

-------------------------------BÀI THỰC HÀNH SỐ 5---------------------------------

/*BÀI 1: XÂY DỰNG CÁC VIEW SAU*/
--1. Tạo view có tên vw_DMVT bao gồm các thông tin sau: mã vật tư, tên vật tư. View này dùng để liệt kê danh sách các vật tư hiện có trong bảng VatTu.
go
create view vw_DMVT
as
  select 
         MaVT,
		 TenVT
  from  
         VatTu
go
select * from vw_DMVT
--2. Tạo view có tên vw_DonDH_TongSLDatNhap bao gồm các thông tin sau: số đặt hàng, tổng số lượng đặt, tổng số lượng nhập. View này được dùng để thống kế những đơn đặt hàng nào đã được nhập hàng đầy đủ.
go
create view vw_DonDH_TongSLDatNhap
as
select PNhap.SoDH, sum(SLNhap) as TSLN, sum(SLDat) as TSLD
from PNhap
     inner join CTDonDH on PNhap.SoDH = CTDonDH.SoDH
	 inner join CTPNhap on PNhap.SoPN = CTPNhap.SoPN
where CTDonDH.MaVT = CTPNhap.MaVT
group by PNhap.SoDH
go
select * from vw_DonDH_TongSLDatNhap
--3. Tạo view có tên vw_DonDH_DaNhapDu bao gồm các thông tin sau: số đặt hàng, 
--đã nhập đủ trong đó cột đã nhập đủ sẽ có hai giá trị là “Đã nhập đủ” nếu đơn hàng đó đã nhập đủ hoặc “Chưa nhập đủ” nếu đơn hàng đó chưa nhập đủ.
go
create view vw_DonDH_DaNhapDu
as
select vw_DonDH_TongSLDatNhap.SoDH,
case 
    when  TSLD = TSLN then N'Đã nhập đủ'
	else N'Chưa nhập đủ'
end "Trạng thái"
from vw_DonDH_TongSLDatNhap
go
select * from vw_DonDH_DaNhapDu
--4. Tạo view có tên vw_TongNhap bao gồm các thông tin sau: năm tháng, mã vật tư, tổng số lượng nhập. 
--View này dùng để thống kê số lượng nhập của các vạt tư trong từng năm tháng tương ứng. Chú ý: không sử dụng bảng TonKho.
go
create view vw_TongNhap
as
select 
      month(PNhap.NgayNhap) "Tháng",
	  year(PNhap.NgayNhap) "Năm", 
	  MaVT, 
	  sum(SLNhap) TSLN
from 
      PNhap
	  inner join CTPNhap
	  on PNhap.SoPN = CTPNhap.SoPN
group by month(PNhap.NgayNhap),year(PNhap.NgayNhap),MaVT
go
select * from vw_TongNhap
--5. Tạo view có tên vw_TongXuat bao gồm các thông tin sau: năm tháng, mã vật tư, tổng số lượng xuất. 
--View này dùng để thống kê số lượng xuất của vật tư trong từng năm tháng tương ứng. Chú ý: không sử dụng bảng TonKho.
go
create view vw_TongXuat
as
select 
      MONTH(PXuat.NgayXuat) Tháng,
	  YEAR(PXuat.NgayXuat) Năm,
	  MaVT,
	  sum(SLXuat) "Tổng số lượng xuất"
from 
      PXuat
	  inner join CTPXuat
	  on PXuat.SoPX = CTPXuat.SoPX
group by MONTH(PXuat.NgayXuat), YEAR(PXuat.NgayXuat), MaVT
go
select * from vw_TongXuat
--6. Tạo view có tên vw_DonDH_MaVTu_TongSLNhap bao gồm các thông tin sau: số đặt hàng, ngày đặt hàng, mã vật tư, tên vật tư, số lượng đặt, tổng số lượng nhập hàng.
go 
create view vw_DonDH_MaVTu_TongSLNhap
as
select 
       PNhap.SoDH,
	   DonDH.NgayDH,
	   VatTu.MaVT,
	   VatTu.TenVT,
	   sum(SLDat) " Tổng số lượng đặt hàng",
	   sum(SLNhap) "Tổng số lượng nhập hàng"
from 
       DonDH
	   inner join CTDonDH
	   on DonDH.SoDH = CTDonDH.SoDH
	   inner join CTPNhap
	   on CTPNhap.MaVT = CTDonDH.MaVT
	   inner join VatTu
	   on VatTu.MaVT = CTPNhap.MaVT
	   inner join PNhap
	   on DonDH.SoDH = PNhap.SoDH
group by 
       PNhap.SoDH,
	   DonDH.NgayDH,
	   VatTu.MaVT,
	   VatTu.TenVT
go
select * from vw_DonDH_MaVTu_TongSLNhap

/*BÀI 2: KẾT HỢP CÁC VIEW Ở BÀI 1, THỰC HIỆN CÁC LỆNH TRUY VẤN SAU*/
--1. Cho biết danh sách các phiếu đặt hàng chưa được nhập hàng.
select * 
from DonDH
where SoDH NOT IN (select SoDH from vw_DonDH_TongSLDatNhap)
--2. Cho biết danh sách các mặt hàng chưa được đặt bao giờ.
select * from VatTu
where MaVT not in (select MaVT from CTDonDH)
--3. Cho biết nhà cung cấp nào có nhiều đơn đặt hàng nhất.
select *
from NHaCC
where MaNCC in (select MaNCC from DonDH
                group by MaNCC
				having count(SoDH) = (select Max(SLDH) 
				                      from (select count(SoDH) as SLDH 
									        from DonDH group by MaNCC) as Bang_tam))
--4. Cho biết vật tư nào có tổng số lượng xuất bán là nhiều nhất.
select *
from VatTu
where MaVT in (select MaVT from vw_TongXuat
               where [Tổng số lượng xuất] = (Select Max([Tổng số lượng xuất]) from vw_TongXuat))
--5. Cho biết đơn đặt hàng nào có nhiều mặt hàng nhất.
--6. Cho biết tình hình nhập xuất của vật tư thông tin gồm: năm tháng, mã vật tư, tên vật tư, tổng số lượng nhập, tổng số lượng xuất.
--7. Cho biết tình hình đặt và nhập hàng: đơn đặt hàng, mã vật tư, tên vật tư, số lượng đặt, tổng số lượng nhập.
--8. Thống kê tình hình đặt hàng trong từng ngày: ngày đặt hàng, mã vật tư, tên vật tư, tổng số lượng đặt hàng.
--9. Thống kê tình hình nhập hàng tương tự tình hình đặt hàng.
--10. Thống kê những đơn đặt hàng nào chưa nhập đủ số lượng hàng.

/*BÀI 3: TẠO CÁC CHỈ SỐ SAU*/
--1. Thêm chỉ mục có tên I_TenVT cho cột Tên vật tư ở Bảng vật tư.
create index I_TenVT on VatTu(TenVT)
--2. Thêm chỉ mục theo thứ tự giảm dần có tên I_TenNCC cho cột Tên nhà cung cấp ở bảng nhà cung cấp.
create index I_TenNCC on NhaCC(TenNCC desc)



