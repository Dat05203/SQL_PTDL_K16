use master
go

if(exists(select * from sysdatabases where Name = 'Quanlysinhvien'))
   drop database Quanlysinhvien

/*CÂU 1:*/
--a.
create database Quanlysinhvien
go

use Quanlysinhvien
go
--b. Create table
create table SinhVien(
   MaSV   char(5)   primary key,
   TenSV  nvarchar(50) not null,
   NgaySinh date not null,
   MaLop  char(5) not null
)
create table MonHoc(
   MaMH   char(5)  not null primary key,
   TenMH  nvarchar(50) not null,
   SoTC   int   not null
)
create table KetQua(
   MaSV   char(5)  references SinhVien(MaSV),
   MaMH   char(5)  references MonHoc(MaMH),
   DiemThi int default 0,
   primary key(MaMH, MaSV)
)
select GETDATE()
--c. Insert data
insert into SinhVien
values ('SV01',N'Nguyễn Thùy Chinh','2001-08-15','LH01'),
       ('SV02',N'Trần Minh Quang','2003-08-08','LH02'),
	   ('SV03',N'Hà Kiều Loan','2000-12-17','LH03')
insert into MonHoc
values('MH01',N'Cơ sở dữ liệu',3),
      ('MH02',N'Pháp luật đại cương',2),
      ('MH03',N'Lý thuyết thống kê',3),
	  ('MH04',N'Cầu lông',1)
insert into KetQua
values('SV01','MH01',5),
      ('SV01','MH02',7),
	  ('SV02','MH03',10),
	  ('SV02','MH02',8),
	  ('SV03','MH02',6),
	  ('SV03','MH03',4)
--Hiển thị dữ liệu
select * from SinhVien
select * from MonHoc
select * from KetQua

--d.
update MonHoc
set TenMH = N'Tư tưởng Hồ Chí Minh'
where SoTC = 2

select * from MonHoc
--e.
select 
    MaLop, TenSV
from 
    SinhVien
where
    MONTH(NgaySinh) = 8
order by MaSV desc

/*CÂU 2:*/
--a
select 
    SinhVien.TenSV, MonHoc.TenMH, KetQua.DiemThi
from 
    SinhVien
	inner join KetQua on SinhVien.MaSV = KetQua.MaSV
	inner join MonHoc on KetQua.MaMH = MonHoc.MaMH
where 
    MonHoc.TenMH like 'L%'

--b.
select 
   MonHoc.TenMH
from 
   MonHoc
   inner join KetQua on KetQua.MaMH = MonHoc.MaMH
   inner join SinhVien on KetQua.MaSV = SinhVien.MaSV
group by
   MonHoc.TenMH
having
   count(KetQua.MaSV) < 2

--c.
go
create view vw_DiemThi_XepLoai
as
  select 
      SinhVien.TenSV, 
      MonHoc.TenMH, 
	  KetQua.DiemThi,
  case 
      when DiemThi < 6 then N'Trung Bình'
	  when 6<= DiemThi and DiemThi < 8 then N'Tiên Tiến'
	  when 8<= DiemThi and DiemThi < 9 then N'Giỏi'
	  else N'Xuất sắc'
  end N'Xếp loại'
  from 
      SinhVien
	  inner join KetQua on SinhVien.MaSV = KetQua.MaSV
	  inner join MonHoc on KetQua.MaMH = MonHoc.MaMH
go
--test 
select * from vw_DiemThi_XepLoai