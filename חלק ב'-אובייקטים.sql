--חלק ב 
use tasksProject

--תרגיל 1
--פונקציה לזיהוי משתמש
go
create function isValueUser (@userName nvarchar(10),@password nvarchar(20)) returns int
as
begin
	--אם השם לא קים מחזיר 0
	if @userName not in(select Username from Users)
		return 0
	--אם השם קים והסיסמה שגויה מחזיר 1
	if @password !=(select Passwords
	   from Users 
	   where Username=@userName)
	   return -1
	--אחרת מחזיר את מזהה המשתמש
	return (select UserId
			from Users
			where @password=Passwords)
end

--זימון 1
select dbo.isValueUser('yossi','123456')

--תרגיל 2
--פונקציה לשליפת עובדים כפופים
create function UnderEmployees (@userId int) 
returns @tbl table(userId int,username nvarchar(20),ManagerId int)
as
begin 
--רקורסיה למציאת כל העובדים הכפופים
with employeeCTE
as
(
	select UserId,Username,ManagerId
	from Users
	where UserId=@userId
	union all
	select Users.UserId,Users.Username,Users.ManagerId
	from Users join employeeCTE on Users.ManagerId=employeeCTE.UserId
)
insert into @tbl
select *
from employeeCTE
return 
end

--זימון 2
select *
from dbo.UnderEmployees(1)

--תרגיל 3
--פונקציה לשליפת משימה וכל תתי המשימה שלה
create function taskUnder (@taskId int) 
returns @tbl table(taskId int,taskContent nvarchar(100),parentId int)
as
begin 
--רקורסיה
with taskCTE
as
(
	select taskId,taskContent,parentId
	from task
	where taskId=@taskId
	union all
	select task.TaskId,task.TaskContent,task.ParentId
	from task join taskCTE on task.ParentId=taskCTE.TaskId
)
insert into @tbl
select*
from taskCTE
return 
end

--זימון 3
select* from dbo.taskUnder(1)

--תרגיל 4
--פונקציה לשליפת אבות משימה
create function parentTask (@taskId int)
returns @tbl table (idOfTask int,contentOfTask nvarchar(100),idOfParent int)
as
begin 
--רקורסיה
with taskParentCTE
as
(
	select TaskId,TaskContent,ParentId
	from task
	where @taskId=TaskId
	union all
	select task.TaskId,task.TaskContent,task.ParentId
	from task join taskParentCTE on task.TaskId=taskParentCTE.ParentId
)
insert into @tbl
select *
from taskParentCTE
return 
end

--זימון 4
select*
from dbo.parentTask(5)

--תרגיל 5
--פרוצדורת שינוי סטטוס משימה
create proc changeStatus @taskId int,@statusId int
as
  --שינוי סטטוס
  update task
  set StatusId=@statusId,ChangeStatusDate=getdate()
  from task
  where TaskId=@taskId

--זימון 5
exec changeStatus 2,3

--תרגיל 6
--טריגר עידכון סטטוס למשימה
create trigger updateStatus
on task
after update 
as
begin
	--יצירת משתנה המכיל את מזהה האב משימה
	declare @parentId int=(select ParentId from inserted)
	--אם השינוי הינו לסטטוס בוצע
	 if(select StatusId from inserted)=3
	 begin
		--אם כל הילדים הינם בעלי סטטוס בוצע
		if 3=all(select StatusId
				 from task
				 where ParentId=@parentId)
		--ניתן לשנות אאת הסטטוס
		exec changeStatus @parentId,3
	 end
end

--זימון 6
exec changeStatus 4,3


--תרגיל 7
--פרוצדורת הוספה לטבלת משימות
create proc addTask @creationDate date,@taskContent nvarchar(100),@creatotId int,@doId int,@parentId int
as
  --אם המשתמש אינו כפוף
  if(@doId=@creatotId)
   	 insert into task values(@creationDate,@taskContent,@creatotId,@doId,1,getdate(),@parentId)  
   else if(@doId not in (select UserId from Users where ManagerId=@creatotId))
	throw 500001,'you can not add this task',1
		else  
			--אם המשתמש כפוף אז מוסיף משימה לטבלת משימות
			 insert into task values(@creationDate,@taskContent,@creatotId,@doId,1,getdate(),@parentId)  


--זימון 7
exec addTask '2024-03-26','לכבות את האורות בסוף יום',1,4,null
exec addTask '2024-03-26','לכבות את המזגנים',2,4,10

--תרגיל 8
--פרוצדורת הוספת משימות כלליות
create proc addGeneralTasks @managerId int,@taskContent nvarchar(100)
as
begin
	begin transaction
		begin try
			declare @id int 
			declare @date date=getdate()
			--יצירת הסמן
			declare addGTask cursor for
			--כל העובדים הישירים
			select userid
			from users
			where @managerId=managerid
			--פתיחת הסמן
			open addGTask
				fetch next from addGTask into @id
				while @@fetch_status=0
				begin
				--מוסיף משימה
					exec addTask @date,@taskContent,@managerId,@id,null
					fetch next from addGTask into @id
				end
			close addGTask
			deallocate addGTask
		end try
--אם לא הצליח אז יחזור ויציג את השגיאה
begin catch
			close addGTask
			deallocate addGTask
			rollback
			print error_message()
end catch
commit
end



--זימון  8
exec addGeneralTaskS 1,'להגיש טפסים חתומים'
exec addGeneralTaskS 1 ,'לשלם על המתנות'

--תרגיל 9
--טריגר למחיקת משימות ישנות
create trigger deleteOldTask
on task
after insert 
as
begin
	--משתנה שמכיל את המזהה המבצע
	declare @doId int =(select DoId from inserted)
	begin
	--CTE המכיל את פרטי המשימות של אותו מבצע בעלי סטטוס בוצע ומיספור השורות ע"פ תאריך בסדר הפוך
	with cteTasksOnDo
	as(
		select *,ROW_NUMBER() over(order by CreationDate desc) as num
		from task
		where DoId=@doId and StatusId=3
	  )
	  --מחיקת משימה אם יש יותר מ-3 משימות בסטטוס בוצע
	  delete
	  from task 
	  where TaskId in(select taskid
					  from cteTasksOnDo 
					  where num>3)
	end
end

--תרגיל 10
--הצגת סיכום משימות לפי סטשטוסים
create procedure partitionByStatus 
as
declare @status nvarchar(100)=''
select @status+='['+StatusName+'],'
from TaskStatus
set @status =left(@status,LEN(@status)-1)
print @status
declare @quary nvarchar(max)=
'select *
from (select Username,StatusName
	 from task join Users on task.DoId=users.UserId join TaskStatus on task.StatusId=TaskStatus.StatusId)as statuses
	 pivot
	 (
	 count(StatusName)
	 for StatusName in('+@status+'))as partitionStatus'
print @quary
exec(@quary)

exec partitionByStatus
--זימון 9
exec addtask '2024-03-27','לצלם את כל הדוחות',1,1,null
insert into task values('2024-03-27','להצמין דפים למדפסת',4,3,3,getdate(),null)


--תרגיל 11
create function tasksForUser (@userName nvarchar(20),@password nvarchar(20))
returns @tbl table(TaskId int ,
				   CreationDate date ,
				   TaskContent nvarchar(100),
				   CreatorId int ,
				   DoId int,
 				   StatusId int ,
				   ChangeStatusDate date  ,
				   ParentId int,
				   thinking varchar(4))
 as
 begin
	if((select dbo.isValueUser(@userName,@password))>0)
		insert into @tbl
		select task.*,(case 
					  --אם המשימה בוצעה
					  when task.StatusId=3 then'V'
					  --אם המשימה בוטלה
					  when task.StatusId=4 then 'X'
					  --אם בסטטוס ממתין לטיפול או בטיפול ועברו יותר משלושה חודשים
					  when (task.StatusId=1 or task.StatusId=2) and DATEDIFF(MONTH,task.CreationDate,getdate())>3 then '!!!'
					  --אם בסטטוס ממתין לטיפול או בטיפול ועברו יותר מחודש
					  when (task.StatusId=1 or task.StatusId=2) and DATEDIFF(MONTH,task.CreationDate,getdate())between 1 and 3 then '!'
					  end)
		from task join Users on task.DoId=Users.UserId
		where @password=Passwords 
return
end

--זימון 11
select*
from dbo.tasksForUser ('manager','12#6#5')