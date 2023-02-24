use master
go

if(exists( select * from sysdatabases where Name = 'QLSinhVien'))
   drop database QLSinhVien

create database QLSinhVien
go

use QLSinhVien
go

--create table
create table Khoa(
   MaKhoa  nvarchar(10)  not null primary key,
   TenKhoa nvarchar(30)  not null,
   NgayThanhLap date not null
)
create table Lop(
   MaLop   char(10) not null primary key,
   TenLop  nvarchar(20) not null,
   SiSo    int,
   MaKhoa  nvarchar(10) not null foreign key (MaKhoa) references Khoa(MaKhoa)
   on update cascade on delete cascade
)
create table SinhVien(
   MaSV     char(10) not null primary key,
   HoTen    nvarchar(50) not null,
   NgaySinh date,
   MaLop    char(10) foreign key(MaLop) references Lop(MaLop)
   on update cascade on delete cascade
)
go
--insert data
insert into Khoa values('K1', N'Công Nghệ Thông Tin', '12/12/1999'),
						('K2', N'Kế toán', '12/12/1999'),
						('K3', N'Ngoại Ngữ', '12/12/1999')
insert into Lop values('KTPM', N'Kỹ Thuật Phần Mềm', 2, 'K1'),
					  ('KT1', N'Kế toán 1', 2, 'K2'),
					  ('N1', N'Tiếng Nhật cơ bản', 1, 'K3')
insert into SinhVien values('SV1', N'Lê Lý Thị Lan', '01/01/2000', 'KT1'),
							('SV2', N'Nguyễn Bá Nguyên', '10/02/2000', 'KTPM'),
							('SV3', N'Cao Đại La', '10/14/2000', 'KT1'),
							('SV4', N'Ngô Văn Sang', '08/09/2000', 'N1'),
							('SV5', N'Đào Thiên Ý', '07/16/2000', 'KTPM')
go
--test
select * from Khoa
select * from Lop
select * from SinhVien
go

/*CAU 2:*/
go
create view v_demSV
as
  select count(*) as N'Số lượng sv học kế' from SinhVien
  where MaLop = 'KT1'
go
--test
select * from v_demSV

/*CAU 3:*/
go
create function fn_SinhVien (@TenKhoa nvarchar(30), @TenLop nvarchar(20))
returns @ttSinhVien table(MaSV char(10), HoTen nvarchar(50), Tuoi int)
as
   begin
        insert into @ttSinhVien
		select MaSV, HoTen, DATEDIFF(year,NgaySinh,getdate()) as Tuoi
		from SinhVien
		     inner join Lop on SinhVien.MaLop = Lop.MaLop
			 inner join Khoa on Khoa.MaKhoa = Lop.MaKhoa
		where TenKhoa = @TenKhoa and TenLop = @TenLop
		return
	end
go
--test
select * from dbo.fn_SinhVien(N'Công Nghệ Thông Tin',N'Kỹ Thuật Phần Mềm')

/*Câu 4 */
go
create proc SP_Lop(@TenKhoa nvarchar(30), @SoX int)
as
  begin
       if(not exists(select * from Lop where SiSo > @SoX and MaKhoa in (select MaKhoa from Khoa where TenKhoa = @TenKhoa)))
	     begin
	          print N'Không tồn tại lớp cần tìm'
		 end
	   else
       select MaLop, TenLop, SiSo from Lop
	   where MaKhoa in (select MaKhoa from Khoa where TenKhoa = @TenKhoa) and SiSo > @SoX
  end
go
drop proc SP_Lop
--test
go
exec SP_Lop N'Kế toán',1
--test lỗi
exec SP_Lop N'Kế toán',3
go