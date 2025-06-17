 create database tasksProject
 use [tasksProject]

 --���� �������
 create table Users(
 UserId int primary key identity (1,1),
 Username nvarchar(30)not null ,
 Passwords nvarchar(10)not null unique,
 ManagerId int foreign key references Users(UserId)
 )

 --���� ������
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

 --���� ������
 create table TaskStatus(
 StatusId int primary key identity(1,1),
 StatusName nvarchar(40)not null ,
 )

 --����� ������ ����� �������
insert into Users values(1,'manager','12#6#5',null)
insert into Users values(2,'yossi','123456',1)
insert into Users values(3,'meir','Aa22',4)
insert into Users values(4,'david','dddd',2)

 --����� ������ ����� ������
insert into TaskStatus values('����� ������')
insert into TaskStatus values('������')
insert into TaskStatus values('����')
insert into TaskStatus values('����')

--����� ������ ����� ������
insert into task values('2024-03-01','������ ������� �����',1,2,3,'2024-03-11',null)
insert into task values('2024-03-02','������ �����',1,2,3,'2024-03-10',1)
insert into task values('2024-03-02','������ ����',2,2,3,'2024-03-11',1)
insert into task values('2024-03-02','������ �����',1,2,2,'2024-03-10',1)
insert into task values('2024-03-09','����� ���� ����� �� ����',2,4,3,'2024-03-09',4)
insert into task values('2024-03-20','����� ����� �����',2,4,3,'2024-03-26',null)
insert into task values('2024-03-20','����� ������',4,4,3,'2024-03-26',6)
insert into task values('2024-03-20','������ ������',4,3,1,'2024-03-25',6)
insert into task values('2024-03-22','������ ��������',4,3,1,'2024-03-26',7)

 

