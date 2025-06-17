--��� � 
use tasksProject

--����� 1
--������� ������ �����
go
create function isValueUser (@userName nvarchar(10),@password nvarchar(20)) returns int
as
begin
	--�� ��� �� ��� ����� 0
	if @userName not in(select Username from Users)
		return 0
	--�� ��� ��� ������� ����� ����� 1
	if @password !=(select Passwords
	   from Users 
	   where Username=@userName)
	   return -1
	--���� ����� �� ���� ������
	return (select UserId
			from Users
			where @password=Passwords)
end

--����� 1
select dbo.isValueUser('yossi','123456')

--����� 2
--������� ������ ������ ������
create function UnderEmployees (@userId int) 
returns @tbl table(userId int,username nvarchar(20),ManagerId int)
as
begin 
--������� ������ �� ������� �������
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

--����� 2
select *
from dbo.UnderEmployees(1)

--����� 3
--������� ������ ����� ��� ��� ������ ���
create function taskUnder (@taskId int) 
returns @tbl table(taskId int,taskContent nvarchar(100),parentId int)
as
begin 
--�������
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

--����� 3
select* from dbo.taskUnder(1)

--����� 4
--������� ������ ���� �����
create function parentTask (@taskId int)
returns @tbl table (idOfTask int,contentOfTask nvarchar(100),idOfParent int)
as
begin 
--�������
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

--����� 4
select*
from dbo.parentTask(5)

--����� 5
--�������� ����� ����� �����
create proc changeStatus @taskId int,@statusId int
as
  --����� �����
  update task
  set StatusId=@statusId,ChangeStatusDate=getdate()
  from task
  where TaskId=@taskId

--����� 5
exec changeStatus 2,3

--����� 6
--����� ������ ����� ������
create trigger updateStatus
on task
after update 
as
begin
	--����� ����� ����� �� ���� ��� �����
	declare @parentId int=(select ParentId from inserted)
	--�� ������ ���� ������ ����
	 if(select StatusId from inserted)=3
	 begin
		--�� �� ������ ���� ���� ����� ����
		if 3=all(select StatusId
				 from task
				 where ParentId=@parentId)
		--���� ����� ��� ������
		exec changeStatus @parentId,3
	 end
end

--����� 6
exec changeStatus 4,3


--����� 7
--�������� ����� ����� ������
create proc addTask @creationDate date,@taskContent nvarchar(100),@creatotId int,@doId int,@parentId int
as
  --�� ������ ���� ����
  if(@doId=@creatotId)
   	 insert into task values(@creationDate,@taskContent,@creatotId,@doId,1,getdate(),@parentId)  
   else if(@doId not in (select UserId from Users where ManagerId=@creatotId))
	throw 500001,'you can not add this task',1
		else  
			--�� ������ ���� �� ����� ����� ����� ������
			 insert into task values(@creationDate,@taskContent,@creatotId,@doId,1,getdate(),@parentId)  


--����� 7
exec addTask '2024-03-26','����� �� ������ ���� ���',1,4,null
exec addTask '2024-03-26','����� �� �������',2,4,10

--����� 8
--�������� ����� ������ ������
create proc addGeneralTasks @managerId int,@taskContent nvarchar(100)
as
begin
	begin transaction
		begin try
			declare @id int 
			declare @date date=getdate()
			--����� ����
			declare addGTask cursor for
			--�� ������� �������
			select userid
			from users
			where @managerId=managerid
			--����� ����
			open addGTask
				fetch next from addGTask into @id
				while @@fetch_status=0
				begin
				--����� �����
					exec addTask @date,@taskContent,@managerId,@id,null
					fetch next from addGTask into @id
				end
			close addGTask
			deallocate addGTask
		end try
--�� �� ����� �� ����� ����� �� ������
begin catch
			close addGTask
			deallocate addGTask
			rollback
			print error_message()
end catch
commit
end



--�����  8
exec addGeneralTaskS 1,'����� ����� ������'
exec addGeneralTaskS 1 ,'���� �� ������'

--����� 9
--����� ������ ������ �����
create trigger deleteOldTask
on task
after insert 
as
begin
	--����� ����� �� ����� �����
	declare @doId int =(select DoId from inserted)
	begin
	--CTE ����� �� ���� ������� �� ���� ���� ���� ����� ���� ������� ������ �"� ����� ���� ����
	with cteTasksOnDo
	as(
		select *,ROW_NUMBER() over(order by CreationDate desc) as num
		from task
		where DoId=@doId and StatusId=3
	  )
	  --����� ����� �� �� ���� �-3 ������ ������ ����
	  delete
	  from task 
	  where TaskId in(select taskid
					  from cteTasksOnDo 
					  where num>3)
	end
end

--����� 10
--���� ����� ������ ��� ��������
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
--����� 9
exec addtask '2024-03-27','���� �� �� ������',1,1,null
insert into task values('2024-03-27','������ ���� ������',4,3,3,getdate(),null)


--����� 11
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
					  --�� ������ �����
					  when task.StatusId=3 then'V'
					  --�� ������ �����
					  when task.StatusId=4 then 'X'
					  --�� ������ ����� ������ �� ������ ����� ���� ������ ������
					  when (task.StatusId=1 or task.StatusId=2) and DATEDIFF(MONTH,task.CreationDate,getdate())>3 then '!!!'
					  --�� ������ ����� ������ �� ������ ����� ���� �����
					  when (task.StatusId=1 or task.StatusId=2) and DATEDIFF(MONTH,task.CreationDate,getdate())between 1 and 3 then '!'
					  end)
		from task join Users on task.DoId=Users.UserId
		where @password=Passwords 
return
end

--����� 11
select*
from dbo.tasksForUser ('manager','12#6#5')