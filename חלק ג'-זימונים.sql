--��� �'

--����� 1
select dbo.isValueUser('yossi','123456')

--����� 2
select *
from dbo.UnderEmployees(1)

--����� 3
select* from dbo.taskUnder(1)

--����� 4
select*
from dbo.parentTask(5)

--����� 5
exec changeStatus 2,3

--����� 6
exec changeStatus 4,3
--����� 7 
exec addTask '2024-03-27','���� �� ����� ���� ���',1,1,null
exec addTask '2024-03-27','����� �� �������',1,2,12
exec addTask '2024-03-27','����� �� ������',1,5,12
exec addTask '2024-03-27','����� �� ����� ���',1,4,null
exec addTask '2024-03-27','����� ���',4,5,15
exec addtask '2024-03-27','���� �� �� ������',1,2,null

--�����  8
exec addGeneralTask 1,'����� �����'

--����� 9
exec addtask '2024-03-27','���� �� �� ������',1,1,null
insert into task values('2024-03-27','������ ���� ������',1,4,3,getdate(),null)

--����� 11
select*
from dbo.tasksForUser ('manager','12#6#5')