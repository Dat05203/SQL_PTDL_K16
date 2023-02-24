use master
go

--Xóa csdl cùng tên
if(exists(select * from sysdatabases where Name = 'QLbanhang'))
   drop database QLbanhang
go

--Tạo csdl mới 
create database QLbanhang
go
--Sử dụng csdl
use QLbanhang
go

--Tạo bảng
create table CongTy(
   MaCongTy   nvarchar(4) not null primary key,
   TenCongTy  nvarchar(30) not null,
   DiaChi     nvarchar(50) not null
)
create table SanPham(
   MaSanPham  nvarchar(4) not null primary key,
   TenSanPham nvarchar(30) not null,
   SoLuongCo  int not null,
   GiaBan     money not null
)
create table CungUng(
   MaCongTy  nvarchar(4) not null foreign key(MaCongTy) references CongTy(MaCongTy)
   on update cascade on delete cascade,
   MaSanPham nvarchar(4) not null foreign key(MaSanPham) references SanPham(MaSanPham)
   on update cascade on delete cascade,
   SoLuongCungUng int not null,
   NgayCungUng  char(10) not null
)
--Nhập dữ liệu
insert into CongTy
values ('S001',N'CT Trường Hai',N'Số 5, đường Ngũ Lão'),
       ('S002',N'CT Mạnh Chiến',N'Số 7, đường Chiến Thắng'),
	   ('S003',N'CT Hải Mạnh',N'Số 10, đường Giải Phóng')
select * from CongTy

insert into SanPham
values('aaa',N'Máy lạnh',15,400000),
      ('bbb',N'Tivi',50,300000),
	  ('ccc',N'Quạt trần',30,800000)
select * from SanPham

insert into CungUng
values ('S001','ccc',10,'2010-12-10'),
       ('S002','aaa',30,'2012-5-10'),
	   ('S003','bbb',15,'2021-12-01'),
	   ('S002','aaa',5,'2022-01-03'),
	   ('S001','ccc',20,'2019-02-15')
select * from CungUng

--Cau2:
go
create function fn_SanPham(@NgayCungUng char(10))
returns @DSSanPham table (TenSanPham nvarchar(30),
                           SoLuong int, GiaBan money)
as
  begin 
      insert into @DSSanPham
	  select TenSanPham, SoLuongCo, GiaBan from SanPham
	  inner join CungUng
	  on SanPham.MaSanPham = CungUng.MaSanPham
	  where NgayCungUng = @NgayCungUng
	  return
  end
go
--Test
select * from fn_SanPham ('2019-02-15')
--Cau3:
go
create proc SP_AddCongTy (@MaCongTy nvarchar(4), @TenCongTy nvarchar(30), @DiaChi nvarchar(50), @KQ INT OUTPUT)
as
  begin
       if(exists(select MaCongTy from CongTy where MaCongTy = @MaCongTy))
	      set @KQ = 1
	   else 
	      update CongTy
		  set MaCongTy = @MaCongTy,
		      TenCongTy = @TenCongTy,
			  DiaChi = @DiaChi,
			  @KQ = 0
		return @KQ
	end    
go
--Test
declare @ERROR INT
exec SP_AddCongTy 'S006',N'Nhà phân phối Hoàng Long', N'Thành phố Ninh Bình', @ERROR OUTPUT
select @ERROR as N'KiemTra'
select * from CongTy