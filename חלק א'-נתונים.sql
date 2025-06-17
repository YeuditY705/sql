 create database tasksProject
 use [tasksProject]

 --טבלת משתמשים
 create table Users(
 UserId int primary key identity (1,1),
 Username nvarchar(30)not null ,
 Passwords nvarchar(10)not null unique,
 ManagerId int foreign key references Users(UserId)
 )

 --טבלת משימות
 create table task(
 TaskId int primary key identity (1,1),
 CreationDate date not null default getdate(),
 TaskContent nvarchar(100)not null,
 CreatorId int foreign key references Users(UserId)not null,
 DoId int foreign key references Users(UserId)not null,
 StatusId int foreign key references TaskStatus(StatusId)not null,
 ChangeStatusDate date  not null ,
 ParentId int  foreign key references task(TaskId)
 )

 --טבלת סטאטוס
 create table TaskStatus(
 StatusId int primary key identity(1,1),
 StatusName nvarchar(40)not null ,
 )

 --הכנסת נתונים לטבלת משתמשים
insert into Users values(1,'manager','12#6#5',null)
insert into Users values(2,'yossi','123456',1)
insert into Users values(3,'meir','Aa22',4)
insert into Users values(4,'david','dddd',2)

 --הכנסת נתונים לטבלת סטאטוס
insert into TaskStatus values('ממתין לטיפןל')
insert into TaskStatus values('בטיפול')
insert into TaskStatus values('בוצע')
insert into TaskStatus values('בוטל')

--הכנסת נתונים לטבלת משימות
insert into task values('2024-03-01','להתקשר לעובדים שעזבו',1,2,3,'2024-03-11',null)
insert into task values('2024-03-02','להתקשר ליוסי',1,2,3,'2024-03-10',1)
insert into task values('2024-03-02','להתקשר לדני',2,2,3,'2024-03-11',1)
insert into task values('2024-03-02','להתקשר למרים',1,2,2,'2024-03-10',1)
insert into task values('2024-03-09','להשיג מספר טלפון של מרים',2,4,3,'2024-03-09',4)
insert into task values('2024-03-20','לארגן מסיבת פורים',2,4,3,'2024-03-26',null)
insert into task values('2024-03-20','לדאוג לכיבוד',4,4,3,'2024-03-26',6)
insert into task values('2024-03-20','להדפיס הזמנות',4,3,1,'2024-03-25',6)
insert into task values('2024-03-22','להזמין קייטרינג',4,3,1,'2024-03-26',7)

 

