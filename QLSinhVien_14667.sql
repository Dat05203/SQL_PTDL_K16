use master
go

if(exists(select * from sysdatabases where Name = 'QLSinhVien'))
   drop database QLSinhVien
go

create database QLSinhVien
go

use QLSinhVien
go

--Câu 1:
create table Khoa(
    MaKhoa   nvarchar(4)  primary key not null,
	TenKhoa  nvarchar(30) not null,
	DiaChi   nvarchar(50) not null,
	SoDT     char(12) not null,
	Email    char(30)
)
create table Lop(
    MaLop    nvarchar(4) primary key not null,
	TenLop   nvarchar(50) not null,
	SiSo     int,
	MaKhoa   nvarchar(4) not null foreign key (MaKhoa) references Khoa(MaKhoa)
	on update cascade on delete cascade,
	Phong    int
)
create table SinhVien(
    MaSV     char(10)   primary key not null,
	HoTen    nvarchar(50) not null,
	NgaySinh date not null,
	GioiTinh bit,
	MaLop    nvarchar(4) foreign key (MaLop) references Lop(MaLop)
	on update cascade on delete cascade
)
insert into Khoa
values('KTKT',N'Kế toán - Kiểm toán','ĐHCNHN','0865088965','ktkt@haui.edu.vn'),
      ('CNTT',N'Công nghệ thông tin','DHCNHN','0395668795','cntt@haui.edu.vn'),
	  ('QLKD',N'Quản lý kinh doanh','ĐHCNHN','0265125689','qlkd@haui.edu.vn')

select * from Khoa

insert into Lop
values ('QL1',N'Quản lý 1',65,'QLKD',1),
       ('PTDL',N'Phân tích dữ liệu',70,'KTKT',2),
	   ('OOP',N'Lập trình hướng đối tượng',75,'CNTT',3)

select * from Lop
   
insert into SinhVien
values ('2021601',N'Nguyễn Văn A','2003-12-01',1,'OOP'),
       ('2021602',N'Lê Thị B','2002-05-10',0,'PTDL'),
	   ('2021603',N'Nguyễn Mạnh C','2000-10-15',1,'QL1'),
	   ('2021604',N'Vũ Hải Y','2004-09-12',0,'PTDL'),
	   ('2021605',N'Trần Như Đ','2001-06-12',1,'OOP')

select * from SinhVien

--Câu 2:
go
create function fn_sinhVien (@TenKhoa nvarchar(30), @TenLop nvarchar(50))
returns @ttSinhVien table (MaSV char(10), HoTen nvarchar(50), Tuoi int)
as
  begin 
       insert into @ttSinhVien
	   select MaSV, HoTen, Year(getdate()) - Year(NgaySinh) as N'Tuổi'
	   from SinhVien inner join Lop
	   on SinhVien.MaLop = Lop.MaLop
	   inner join Khoa
	   on Khoa.MaKhoa = Lop.MaKhoa
	   where TenKhoa = @TenKhoa and TenLop = @TenLop
	   return
  end
go
--Test---
select * from dbo.fn_sinhVien (N'Công nghệ thông tin',N'Lập trình hướng đối tượng')

--Câu 3:
go
create proc SP_TimKiemSV ( @TuTuoi int, @DenTuoi int)
as
  begin
       select  MaSV, HoTen, NgaySinh, TenLop, TenKhoa, Year(getdate()) - Year(NgaySinh) as Tuoi
	   from SinhVien inner join Lop
	   on SinhVien.MaLop = Lop.MaLop
	   inner join Khoa
	   on Lop.MaKhoa = Khoa.MaKhoa
	   where Year(getdate()) - Year(NgaySinh) between @TuTuoi and @DenTuoi
   end
go
--Test--
exec SP_TimKiemSV '21','22'