use master
go

if(exists(select * from sysdatabases where Name = 'Quanlynhanvien'))
   drop database Quanlynhanvien
go

create database Quanlynhanvien
go

use Quanlynhanvien
go

--create table
create table NhanVien(
   MaNV     char(5)  not null primary key,
   TenNV    nvarchar(50) not null,
   TrinhDo  nvarchar(30) ,
   ChucVu   nvarchar(30)
)
create table KhoaHoc(
   MaKH     char(5)  not null primary key,
   TenKH    nvarchar(50) not null,
   DiaDiem  nvarchar(30)
)
create table ThamGia(
   MaNV       char(5)  not null references NhanVien(MaNV),
   MaKH       char(5)  not null references KhoaHoc(MaKH),
   SoBuoiNghi int      not null default 0 ,
   KetQua     nvarchar(30)
)
go
Alter Table ThamGia
add primary key (MaNV, MaKH)
go
--insert data
insert into NhanVien
values ('NV01',N'Trần Văn Ước',N'Đại học',N'Nhân viên'),
       ('NV02',N'Hoàng Văn Huy',N'Đại học',N'Trưởng phòng'),
	   ('NV03',N'Nguyễn Thị Chính',N'Cao Đẳng',N'Nhân viên')
insert into KhoaHoc
values ('KH01',N'Giao tiếp cơ bản',N'Hà Nội'),
       ('KH02',N'Giao tiếp nâng cao',N'Hà Nội'),
	   ('KH03',N'Phân tích số liệu',N'Hồ Chí Minh')
insert into ThamGia
values ('NV01',N'KH01',1,N'Khá'),
       ('NV01',N'KH02',2,N'Khá'),
	   ('NV02',N'KH01',default,N'Giỏi'),
	   ('NV02',N'KH02',1,N'Khá'),
	   ('NV02',N'KH03',1,N'Trung bình'),
	   ('NV03',N'KH01',4,N'Trung bình')
go
--test
select * from NhanVien
select * from KhoaHoc
select * from ThamGia

--d.
update KhoaHoc
set DiaDiem = N'Hải Phòng'
where MaKH = 'KH03'

--e.
select TenKH, DiaDiem
from KhoaHoc
where TenKH like N'%giao tiếp%'
order by DiaDiem

/*CÂU 2:*/
--a.
select 
     NhanVien.MaNV, 
	 NhanVien.TenNV, 
	 sum(ThamGia.SoBuoiNghi) as SoBuoiNghi
from 
     NhanVien
	 inner join ThamGia on NhanVien.MaNV = ThamGia.MaNV
where
     ThamGia.KetQua = N'Khá'
group by 
     NhanVien.MaNV, NhanVien.TenNV

--b.
select 
    KhoaHoc.MaKH, 
	KhoaHoc.TenKH
from
    KhoaHoc
	inner join ThamGia on KhoaHoc.MaKH = ThamGia.MaKH
group by 
    KhoaHoc.MaKH, KhoaHoc.TenKH
having
    count(ThamGia.MaNV) >= 2

--c.
go
create proc SP_InsertData (@MaNV char(5), @TenNV nvarchar(50), @TrinhDo nvarchar(30), @ChucVu nvarchar(30))
as
  begin 
       if(exists(select * from NhanVien where MaNV = @MaNV))
	      begin
		      print N'Đã tồn tại nhân viên'
		  end
	   else
	      begin
		      insert into NhanVien
	          values(@MaNV, @TenNV, @TrinhDo, @ChucVu)
          end
  end
go
--test
exec SP_InsertData 'NV05',N'Vũ Hải Yến',N'Đại học',N'Thư ký'
select * from NhanVien