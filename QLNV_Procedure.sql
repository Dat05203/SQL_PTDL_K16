use master
go

if(exists(select 'True' from master.dbo.Sysdatabases where Name = 'QLNV'))
   DROP DATABASE QLNV
go

create database QLNV
go

use QLNV
go

create table tblChucvu(
	MaCV nvarchar(2) not null primary key,
	TenCV nvarchar(30)
)

create table tblNhanVien(
	MaNV nvarchar(4) not null primary key,
	MaCV nvarchar(2),
	TenNV nvarchar(30),
	NgaySinh datetime,
	LuongCanBan float,
	NgayCong int,
	PhuCap float,
	constraint fk_NV_CV foreign key(MaCV) references tblChucVu(MaCV)
)

--C. insert data
insert into tblChucVu values ('BV',N'Bảo Vệ'), ('GD',N'Giám Đốc'),
							('HC',N'Hành Chính'), ('KT',N'Kế Toán'),
							('TQ',N'Thủ Quỹ'), ('VS',N'Vệ Sinh')
insert into tblNhanVien values ('NV01', 'GD', N'Nguyễn Văn An', '12/12/1977 12:00:00', 700000, 25, 500000),
								('NV02', 'BV', N'Bùi Văn Tí', '10/10/1978 12:00:00', 400000, 24, 100000),
								('NV03', 'KT', N'Trần Thanh Nhật', '9/9/1977 12:00:00', 600000, 26, 400000),
								('NV04', 'VS', N'Nguyễn Thị Út', '10/10/1980 12:00:00', 300000, 26, 300000),
								('NV05', 'HC', N'Lê Thị Hà', '10/10/1979 12:00:00', 500000, 27, 200000)
go

select * from tblChucvu
select * from tblNhanVien

go
/*D. Yêu cầu:
a. Viết thủ tục SP_Them_Nhan_Vien, biết tham biến là MaNV, MaCV, 
TenNV,Ngaysinh,LuongCanBan,NgayCong,PhuCap. Kiểm tra MaCV 
có tồn tại trong bảng tblChucVu hay không, nếu có thì kiểm tra xem 
ngày công có <=30 hay không? nếu thảo mãn yêu cầu thì cho thêm nhân 
viên mới, nếu không thì đưa ra thông báo.*/
go
create proc SP_Them_Nhan_Vien (@MaNV nvarchar(4), @MaCV nvarchar(2), @TenNV nvarchar(100), @NgaySinh datetime, @LuongCanBan float, @NgayCong int, @PhuCap float)
as
  begin 
       if(not exists(select * from tblChucvu where MaCV = @MaCV))
	      print (N'Chức vụ không tồn tại trên hệ thống')
       else if (@NgayCong > 30)
	      print (N'Ngày công không hợp lệ')
	   else 
	      insert into tblNhanVien values(@MaNV, @MaCV, @TenNV, @NgaySinh, @LuongCanBan, @NgayCong, @PhuCap)
	end
go
exec SP_Them_Nhan_Vien 'HC', 'VS', N'Phan Văn Khôi', '2/9/1999', 120000,25, 100000
exec SP_Them_Nhan_Vien 'NV06', 'S', N'Phan Văn Khôi', '2/9/1999', 120000,36, 100000
select * from tblNhanVien
go

/*b. Viết thủ tục SP_CapNhat_Nhan_Vien ( không cập nhật mã), biết tham 
biến là MaNV, MaCV, TenNV,Ngaysinh,LuongCanBan,NgayCong,PhuCap. Kiểm tra MaCV 
có tồn tại trong bảng tblChucVu hay không, nếu có thì kiểm tra xem 
ngày công có <=30 hay không? nếu thỏa mãn yêu cầu thì cho cập nhật, 
nếu không thì đưa ra thông báo.*/
create proc SP_CapNhat_Nhan_Vien(@MaNV nvarchar(4), @MaCV nvarchar(4), @TenNV nvarchar(100), @NgaySinh datetime, @LuongCoBan float, @NgayCong int, @PhuCap float)
as
  begin
       if(not exists(select * from tblChucvu where MaCV = @MaCV))
          print(N'Chức vụ không hợp lệ')
	   else if(@NgayCong > 30)
	      print(N'Ngày công không hơp lệ')
	   else
	      update tblNhanVien set MaCV = @MaCV, TenNV = @TenNV, NgaySinh = @NgaySinh, LuongCanBan = @LuongCoBan, NgayCong = @NgayCong, PhuCap = @PhuCap 
		  where MaNV = @MaNV
  end
go
exec SP_CapNhat_Nhan_Vien 'GD', 'VS', N'Phan Văn Ánh', '2/9/1999', 100000,25, 100000
exec SP_CapNhat_Nhan_Vien 'NVO5', 'GD', N'Phan Văn Cường', '2/9/1999', 100000,25, 100000
select * from tblNhanVien

/*c. Viết thủ tục SP_LuongLN với Luong=LuongCanBan*NgayCong 
PhuCap, biết thủ tục trả về, không truyền tham biến*/
go
create proc SP_LuongLN 
as
  begin 
       select TenNV, LuongCanBan*NgayCong+PhuCap as N'Lương' from tblNhanVien 
  end
go

exec SP_LuongLN
go

/*d.Viết hàm nội tuyến tính lương trung bình của các nhân viên và thể 
hiện các thông tin sau MaNV,TenNV,TenCV,Luong với 
Luong=LuongCanBan*NgayCong + PhuCap
Nhưng nếu NgayCong>=25 thì số ngày dư ra được tính gấp đôi, kết quả 
trả về 1 bảng TB lương các nhân viên*/

/*1. Tạo thủ tục có tham số đưa vào là MaNV, MaCV, TenNV, 
NgaySinh, LuongCB, NgayCong, PhucCap. Trước khi chèn một bản 
ghi mới vào bảng NHANVIEN với danh sách giá trị là giá trị của các 
biến phải kiểm tra xem MaCV đã tồn tại bên bảng ChucVu chưa, nếu 
chưa trả ra 0.*/
GO
create proc SP_Them_Nhan_Vien_1(@MaNV nvarchar(4), @MaCV nvarchar(4), @TenNV nvarchar(100), @NgaySinh datetime, @LuongCoBan float, @NgayCong int, @PhuCap float, @KQ int output)
as
  begin
       if(not exists(select * from tblChucvu where MaCV = @MaCV))
	      set @KQ = 0
       else
	       if(not exists(select * from tblNhanVien where MaCV = @MaCV and MaNV = @MaNV and NgayCong = @NgayCong))
	          set @KQ = 0
		   else
		       insert into tblNhanVien
			   values (@MaNV, @MaCV, @TenNV, @NgaySinh,@LuongCoBan, @NgayCong,@PhuCap)
		return @KQ
	end
go
---TEST        
   DECLARE @ERROR INT
   EXEC SP_Them_Nhan_Vien_1 'NV007','VS',N'Phạm Chàm','2/9/1999', 120000,36, 100000,@ERROR OUTPUT
   SELECT @ERROR
GO

/*Tạo thủ tục có
Đầu vào: NgayCong1, NgayCong2
Đầu ra: tổng số nhân viên trong cơ quan có So ngay lam viec trong khoảng Ngaycong1 và NgayCong2.*/
create proc SP_Ngay_Cong (@NgayCong1 int, @NgayCong2 int, @TongNV int OUTPUT)
as
  begin
       SET @TongNV = (SELECT count(*) from tblNhanVien where NgayCong between @NgayCong1 and @NgayCong2)
	   return @TongNV
  end
go
--thực thi---
declare @error int
exec SP_Ngay_Cong 25, 30, @error output
select @error as N'Số nhân viên'

/*5. Tạo thủ tục có
Đầu vào: TenCV
Đầu ra: tổng số lượng nhân viên co chuc vu này.*/
go
create proc SP_CV_Nhan_Vien(@TenCV nvarchar(50), @Tong int output)
as 
  begin 
       set @Tong = (select count(*) from tblNhanVien inner join tblChucvu on tblNhanVien.MaCV = tblChucvu.MaCV
	                where TenCV = @TenCV)
	   return @Tong
   end
go
-- thực thi---
declare @ERROR int
exec SP_CV_Nhan_Vien N'Vệ Sinh', @ERROR OUTPUT
select @ERROR as So_luong
go

	   