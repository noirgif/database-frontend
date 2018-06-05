/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2018/06/05 0:10:02                           */
/*==============================================================*/
create database if not exists bank;
use bank;

drop table if exists 储蓄帐户;

drop table if exists 员工;

drop table if exists 客户;

drop table if exists 客户_贷款;

drop table if exists 帐户;

drop table if exists 支付;

drop table if exists 支票帐户;

drop table if exists 支行;

drop table if exists 贷款;

drop table if exists 部门;

/*==============================================================*/
/* Table: 储蓄帐户                                                  */
/*==============================================================*/
create table 储蓄帐户
(
      ID    int auto_increment,
   支行名字                 char(40) not null,
   帐户号码                 int not null,
   客户身份证                char(18) not null,
   储蓄帐户利率               real not null,
   储蓄帐户货币类型             char(3) not null,
   primary key(ID),
   unique (支行名字, 客户身份证)
);

/*==============================================================*/
/* Table: 员工                                                    */
/*==============================================================*/
create table 员工
(
   ID int auto_increment,
   员工身份证号               char(18) not null unique,
   部门号                  numeric(8,0),
   员工姓名                 char(40) not null,
   员工电话                 varchar(20) not null,
   员工家庭地址               char(40) not null,
   员工开始工作日期             datetime not null,
   primary key (ID)
);

/*==============================================================*/
/* Table: 客户                                                    */
/*==============================================================*/
create table 客户
(
   ID int auto_increment,
   客户身份证                char(18) not null unique,
   员工身份证号               char(18) not null,
   客户姓名                 char(40) not null,
   客户手机号                varchar(20) not null,
   联系人姓名                char(40) not null,
   联系人手机号               char(40) not null,
   联系人邮箱                char(40) not null,
   联系人关系                char(40) not null,
   员工客户关系               char(40),
   primary key (ID)
);

/*==============================================================*/
/* Table: 客户_贷款                                                 */
/*==============================================================*/
create table 客户_贷款
(
      ID int auto_increment,
   贷款号                  int not null,
   客户身份证                char(18) not null,
   unique (贷款号, 客户身份证),
      primary key(ID)
);

/*==============================================================*/
/* Table: 帐户                                                    */
/*==============================================================*/
create table 帐户
(
   ID  int auto_increment,
   账户号码 int not null,
   帐户开户日期               datetime not null,
   帐户最近访问日期             datetime not null,
   帐户余额                 float(8,2) not null,
   unique (帐户号码),
   primary key(ID)
);

delimiter $$
create or replace trigger borrow_and_return_i
after insert on 账户
for each row
begin
    update 账户
            set 账户号码 = new.ID
            where ID = new.ID;
end;
$$
delimiter ;

/*==============================================================*/
/* Table: 支付                                                    */
/*==============================================================*/
create table 支付
(  
   ID int auto_increment,
   支付号                  int not null,
   贷款号                  int,
   支付日期                 datetime not null,
   支付金额                 float(8,2) not null,
   unique (支付号),
   primary key(ID)
);

delimiter $$
create or replace trigger borrow_and_return_i
after insert on 支付
for each row
begin
    update 支付
            set 支付号 = new.ID
            where ID = new.ID;
end;
$$
delimiter ;

/*==============================================================*/
/* Table: 支票帐户                                                  */
/*==============================================================*/
create table 支票帐户
(
   ID int auto_increment,
   支行名字                 char(40) not null,
   客户身份证                char(18) not null,
   帐户号码                 int not null,
   支票帐户透支额              float(8,2) not null,
unique (支行名字, 客户身份证),
primary key(ID)
);

/*==============================================================*/
/* Table: 支行                                                    */
/*==============================================================*/
create table 支行
(
   ID int auto_increment,
   支行名字                 char(40) not null,
   支行城市                 char(40) not null,
   支行资产                 float(8,2) not null,
   unique (支行名字),
   primary key(ID)
);

/*==============================================================*/
/* Table: 贷款                                                    */
/*==============================================================*/
create table 贷款
(
   ID                 int auto_increment,
   贷款号               int not null,
   支行名字                 char(40),
   贷款金额                 float(8,2) not null,
   primary key (ID)
);

delimiter $$
create or replace trigger borrow_and_return_i
after insert on 贷款
for each row
begin
    update 贷款
            set 贷款号 = new.ID
            where ID = new.ID;
end;
$$
delimiter ;

/*==============================================================*/
/* Table: 部门                                                    */
/*==============================================================*/
create table 部门
(
   ID int auto_increment,
   部门号                  numeric(8,0) not null,
   支行名字                 char(40),
   经理身份证号               char(18),
   部门名称                 char(40) not null,
   部门类型                 char(40) not null,
   unique (部门号),
   primary key(ID)
);

alter table 储蓄帐户 add constraint FK_储蓄帐户 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 储蓄帐户 add constraint FK_储蓄帐户2 foreign key (帐户号码)
      references 帐户 (帐户号码) on delete restrict on update restrict;

alter table 储蓄帐户 add constraint FK_储蓄帐户3 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 员工 add constraint FK_任职 foreign key (部门号)
      references 部门 (部门号) on delete restrict on update restrict;

alter table 客户 add constraint FK_员工_客户 foreign key (员工身份证号)
      references 员工 (员工身份证号) on delete restrict on update restrict;

alter table 客户_贷款 add constraint FK_客户_贷款 foreign key (贷款号)
      references 贷款 (贷款号) on delete restrict on update restrict;

alter table 客户_贷款 add constraint FK_客户_贷款2 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 支付 add constraint FK_贷款_支付 foreign key (贷款号)
      references 贷款 (贷款号) on delete restrict on update restrict;

alter table 支票帐户 add constraint FK_支票帐户 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 支票帐户 add constraint FK_支票帐户2 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 支票帐户 add constraint FK_支票帐户3 foreign key (帐户号码)
      references 帐户 (帐户号码) on delete restrict on update restrict;

alter table 贷款 add constraint FK_支行_贷款 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 部门 add constraint FK_支行_部门 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 部门 add constraint FK_经理 foreign key (经理身份证号)
      references 员工 (员工身份证号) on delete restrict on update restrict;

