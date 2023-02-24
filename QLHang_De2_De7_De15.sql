use master
go

if(exists(select * from sysdatabases where Name = 'QLHang'))
    drop database QLHang

create database QLHang
go

use QLHang
go

--Create table
create table Hang(
     MaHang   nvarchar(10)  not null primary key,
	 TenHang  nvarchar(50)  not null,
	 DVTinh   nvarchar(20),
	 SLTon    int  default 0
)
create table HDBan(
     MaHD     nvarchar(10)  not null primary key,
	 NgayBan  date          not null,
	 HoTenKhach  nvarchar(30)
)
create table HangBan(
     MaHD     nvarchar(10)  not null foreign key(MaHD) references HDBan(MaHD)
	 on update cascade on delete cascade,
	 MaHang   nvarchar(10)  not null foreign key(MaHang) references Hang(MaHang)
	 on update cascade on delete cascade,
	 DonGia   money  default 0,
	 SoLuong  int    default 0,
	 primary key(MaHD, MaHang)
)
go

--Insert data
insert into Hang values('H001', N'Nước rửa tay sát khuẩn', N'Lọ', 22230),
						('H002', N'Khẩu trang y tế', N'Cái', 521230)
insert into HDBan values('HD001', '05-14-2020', N'Công Nghệ Thông Tin 5'),
						('HD002', '05-15-2020', N'Khoa Học Máy Tính')
insert into HangBan values('HD001', 'H001', 35000, 80),
							('HD001', 'H002', 5000, 80),
							('HD002', 'H001', 35000, 79),
							('HD002', 'H002', 5500, 79)
go

select * from Hang
select * from HDBan
select * from HangBan
go

----------------------------/*           */-----------------------------
----------------------------/*   ĐỀ 2    */-----------------------------
----------------------------/*           */-----------------------------

--Câu 2:
go
create view vw_TienHangBan
as
  select 
       HDBan.MaHD, NgayBan, sum(SoLuong*DonGia) as N'Tổng tiền'
  from
       HDBan
	   inner join HangBan
	   on HDBan.MaHD = HangBan.MaHD
  group by HDBan.MaHD, NgayBan
go
--test
select * from vw_TienHangBan
go

----------------------------/*           */-----------------------------
----------------------------/*   ĐỀ 7    */-----------------------------
----------------------------/*           */-----------------------------

--Câu 2:
go 
create view vw_ttHoaDon
as
  select MaHD, count(*) as N'Số mặt hàng'
  from HangBan
  where MaHD in (select MaHD from HDBan)
  group by MaHD
  having count(*) > 1
go
--test
select * from vw_ttHoaDon
go

--Câu 3:
go
create function fn_tongTienTheoNam(@Nam int)
returns money
as
  begin 
       DECLARE @tong money
       select @tong = sum(DonGia*SoLuong)
	   from HangBan inner join HDBan
	   on HangBan.MaHD = HDBan.MaHD
	   where YEAR(NgayBan) = @Nam
	   return @tong
  end
go
--test
select dbo.fn_tongTienTheoNam ('2020') as N'Tổng tiền'

--Câu 4:
go
create proc SP_searchHang (@Thang int, @Nam int)
as
  begin
       select Hang.MaHang, TenHang, NgayBan, SoLuong,
	    case DATEPART(DW, HDBan.NgayBan)
	       when 2 then N'Thứ hai'
		   when 3 then N'Thứ ba'
		   when 4 then N'Thứ tư'
		   when 5 then N'Thứ năm'
		   when 6 then N'Thứ sáu'
		   when 7 then N'Thứ bảy'
		   when 1 then N'Chủ nhật'
		   else 'False'
		  end as NgayThu
	    from Hang
	        inner join HangBan on Hang.MaHang = HangBan.MaHang
			inner join HDBan   on HDBan.MaHD = HangBan.MaHD
		where MONTH(NgayBan) = @Thang and YEAR(NgayBan) = @Nam
	end
go
---test
exec SP_searchHang 5, 2020

----------------------------/*           */-----------------------------
----------------------------/*   ĐỀ 15    */-----------------------------
----------------------------/*           */-----------------------------

--Câu 3:
go
create proc SP_DeleteMH (@MaHang nvarchar(10))
as
  begin
       if(not exists(select * from Hang where MaHang = @MaHang))
	      begin
		       print N'Không có mặt hàng trong CSDL'
		  end
		else
		  begin
		      delete from Hang where MaHang = @MaHang
		  end
	end
go
--test chạy được
exec SP_DeleteMH 'H001'
select * from Hang
select * from HangBan
--test error
exec SP_DeleteMH 'H005'
