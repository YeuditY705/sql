--חלק ג'

--זימון 1
select dbo.isValueUser('yossi','123456')

--זימון 2
select *
from dbo.UnderEmployees(1)

--זימון 3
select* from dbo.taskUnder(1)

--זימון 4
select*
from dbo.parentTask(5)

--זימון 5
exec changeStatus 2,3

--זימון 6
exec changeStatus 4,3
--זימון 7 
exec addTask '2024-03-27','לסדר את המשרד בסוף יום',1,1,null
exec addTask '2024-03-27','לכבות את המזגנים',1,2,12
exec addTask '2024-03-27','לכבות את האורות',1,5,12
exec addTask '2024-03-27','לתפעל את הפינת קפה',1,4,null
exec addTask '2024-03-27','לקנות חלב',4,5,15
exec addtask '2024-03-27','לצלם את כל הדוחות',1,2,null

--זימון  8
exec addGeneralTask 1,'להגיש דוחות'

--זימון 9
exec addtask '2024-03-27','לצלם את כל הדוחות',1,1,null
insert into task values('2024-03-27','להצמין דפים למדפסת',1,4,3,getdate(),null)

--זימון 11
select*
from dbo.tasksForUser ('manager','12#6#5')