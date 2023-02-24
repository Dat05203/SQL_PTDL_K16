USE master
GO

if(exists(select * from sysdatabases where Name = 'QLSV'))
   drop database QLSV
go

create database QLSV
go

use QLSV
go

create table Lop(
     MaLop   int  not null identity primary key,
	 TenLop  char(2)  not null,
	 Phong   int  not null
)
create table SinhVien (
     MaSV    int not null identity primary key,
	 TenSV   char(2)  not null,
	 MaLop   int not null ,
	 foreign key (MaLop) references Lop(MaLop)
	 on update cascade on delete cascade
)

insert into Lop
values ('CD',1),('DH',2),('LT',2),('XY',4)
select * from Lop

insert into SinhVien
values ('A',1),('B',2),('C',1),('D',3)
select * from SinhVien

/*BÀI 1*/
--1. Viet ham thong ke xem moi lop co bao nhieu sinh vien voi malop la tham so truyen.
go
create function fn_countsinhvien(@MaLop int)
returns int 
as 
begin 
     declare @tong int
	 set @tong = (select count(*) from SinhVien where MaLop = @MaLop)
	 return @tong
end
go
select dbo.fn_countsinhvien(1) as "Số sinh viên trong lớp"
--2. Dua ra ds sinh vien(masv,tensv) hoc lop voi tenlop duoc truyen vao tu ham
go
create function fn_dsSinhVientheoLop (@TenLop char(2))
returns @DS_SinhVien Table (MaSV int, TenSV char(2))
AS
  begin
       insert into @DS_SinhVien
	   select MaSV, TenSV from SinhVien inner join Lop on SinhVien.MaLop = Lop.MaLop where TenLop = @TenLop
       return
  end
go
select * from fn_dsSinhVientheoLop('DH')
--3. Dua ra ham thong ke sv: malop,tenlop,soluong sinh vien trong lop cua 
--lop voi ten lop duoc nhap tu ban phim. Neu lop do chua ton tai thi thong 
--ke tat ca cac lop, nguoc lai neu lop do da ton tai thi chi thong ke moi lop do thoi.
go
create function fn_thongKeSinhVien(@TenLop char(2))
returns @ThongKe table (MaLop int, TenLop char(2), SoLuongSinhVien int)
as
  begin
       if(not exists(select MaLop from Lop where TenLop = @TenLop))
	   begin 
	        insert into @ThongKe
			select Lop.MaLop, TenLop, count(*) from SinhVien
			                              inner join Lop on SinhVien.MaLop = Lop.MaLop
			group by Lop.MaLop, TenLop
		end
		else
		    begin
			     insert into @ThongKe
				 select Lop.MaLop, TenLop, count(*) 
				 from SinhVien inner join Lop
				 on SinhVien.MaLop = Lop.MaLop
				 where TenLop = @TenLop
				 group by Lop.MaLop, TenLop
			end
			return
	end
go
select * from fn_thongKeSinhVien('EG')
--4. Dua ra phong hoc cua ten sinh vien nhap tu ham
go
create function fn_phongHocSV(@TenSV char(2))
returns int 
as
  begin
       declare @SoPhong int
	   set @SoPhong = (select Phong from Lop inner join SinhVien
	                                 on Lop.MaLop = SinhVien.MaLop
									 where TenSV = @TenSV)
		return @SoPhong
	end
go
select dbo.fn_phongHocSV('D') as "Phòng học"
--5. Dua ra thong ke masv,tensv, tenlop voi tham bien la phong. Neu 
--phong khong ton tai thi dua ra tat ca cac sinh vien va cac phong. Neu 
--phong ton tai thi dua ra cac sinh vien cua cac lop hoc phong do (Nhieu lop hoc cung phong).
go
create function fn_SVHocPhong (@Phong int)
returns @dsSinhVien table(MaSV int, TenSV char(2), TenLop char(2))
as
  begin
       if(not exists(select * from Lop where Phong = @Phong))
	   begin
	        insert into @dsSinhVien
			select MaSV, TenSV, TenLop from SinhVien inner join Lop
			                           on SinhVien.MaLop = Lop.MaLop
	    end
		else
		    begin
			     insert into @dsSinhVien
				 select MaSV, TenSV, TenLop from SinhVien inner join Lop
				                             on SinhVien.MaLop = Lop.MaLop
				 where Phong = @Phong
			end
		return
	end
go
select * from fn_SVHocPhong(2) 
--6. Viet ham thong ke xem moi phong co bao nhieu lop hoc. Neu phong khong ton tai tra ve gia tri 0
go
create function fn_thongkephong (@Phong int)
returns int 
as
  begin 
       declare @dem int
	   if(exists(select * from Lop where Phong = @Phong))
	     set @dem = (select count(*) from Lop where Phong = @Phong)
	   else
	      set @dem = 0
	   return @dem
   end
go
select dbo.fn_thongkephong(2) as N'Số lớp học'