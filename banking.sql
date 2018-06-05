/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2018/06/05 0:10:02                           */
/*==============================================================*/
drop database if exists bank;
create database bank;
use bank;

drop table if exists 储蓄账户;

drop table if exists 员工;

drop table if exists 客户;

drop table if exists 客户_贷款;

drop table if exists 账户;

drop table if exists 支付;

drop table if exists 支票账户;

drop table if exists 支行;

drop table if exists 贷款;

drop table if exists 部门;

/*==============================================================*/
/* Table: 储蓄账户                                                  */
/*==============================================================*/
create table 储蓄账户
(
      ID    int auto_increment,
   支行名字                 char(40) not null,
   账户号码                 int not null,
   客户身份证                char(18) not null,
   储蓄账户利率               real not null,
   储蓄账户货币类型             char(3) not null,
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
   员工客户关系               char(25) check(员工客户关系 in ('贷款负责人', '银行账户负责人')),
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
/* Table: 账户                                                    */
/*==============================================================*/
create table 账户
(
   ID  int auto_increment,
   UM_账户号码 int,
   账户开户日期               datetime not null,
   账户最近访问日期             datetime not null,
   账户余额                 float(8,2) not null,
   unique (UM_账户号码),
   primary key(ID)
);

delimiter $$
create or replace trigger account_id
before insert on 账户
for each row
begin
      declare next_id int;
      set next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='账户');
      set new.UM_账户号码 = next_id;
end;
$$
delimiter ;

/*==============================================================*/
/* Table: 支付                                                    */
/*==============================================================*/
create table 支付
(  
   ID int auto_increment,
   UM_支付号                  int,
   贷款号                  int,
   支付日期                 datetime not null,
   支付金额                 float(8,2) not null,
   unique (UM_支付号),
   primary key(ID)
);

delimiter $$
create or replace trigger payment_id
before insert on 支付
for each row
begin
      declare next_id int;
      set next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='支付');
      set new.UM_支付号 = next_id;
end;
$$
create or replace trigger payment_update
after insert on 支付
for each row
begin
      if (select sum(支付金额) from 支付 where 贷款号=new.贷款号) < (select 贷款金额 from 贷款 where UM_贷款号=new.贷款号) then
            update 贷款 set UM_状态='发放中' where UM_贷款号=new.贷款号;
      else
            update 贷款 set UM_状态='已全部发放' where UM_贷款号=new.贷款号;
      end if;
end;
$$
delimiter ;

/*==============================================================*/
/* Table: 支票账户                                                  */
/*==============================================================*/
create table 支票账户
(
   ID int auto_increment,
   支行名字                 char(40) not null,
   客户身份证                char(18) not null,
   账户号码                 int not null,
   支票账户透支额              float(8,2) not null,
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
   UM_贷款号               int,
   支行名字                 char(40),
   贷款金额                 float(8,2) not null,
   UM_状态                 char(10),
   unique(UM_贷款号),
   primary key (ID)
);

delimiter $$
create or replace trigger credit_id
before insert on 贷款
for each row
begin
      declare next_id int;
      set next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='贷款');
      set new.UM_贷款号 = next_id;
      set new.UM_状态 = '未支付';
end;
$$

create or replace trigger credit_del_id
before delete on 贷款
for each row
begin
      if old.UM_状态='发放中' then
            signal sqlstate '25252'
            set message_text = '发放中贷款记录不能删除';
      end if;
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

alter table 储蓄账户 add constraint FK_储蓄账户 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 储蓄账户 add constraint FK_储蓄账户2 foreign key (账户号码)
      references 账户 (UM_账户号码) on delete restrict on update restrict;

alter table 储蓄账户 add constraint FK_储蓄账户3 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 员工 add constraint FK_任职 foreign key (部门号)
      references 部门 (部门号) on delete restrict on update restrict;

alter table 客户 add constraint FK_员工_客户 foreign key (员工身份证号)
      references 员工 (员工身份证号) on delete restrict on update restrict;

alter table 客户_贷款 add constraint FK_客户_贷款 foreign key (贷款号)
      references 贷款 (UM_贷款号) on delete restrict on update restrict;

alter table 客户_贷款 add constraint FK_客户_贷款2 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 支付 add constraint FK_贷款_支付 foreign key (贷款号)
      references 贷款 (UM_贷款号) on delete restrict on update restrict;

alter table 支票账户 add constraint FK_支票账户 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 支票账户 add constraint FK_支票账户2 foreign key (客户身份证)
      references 客户 (客户身份证) on delete restrict on update restrict;

alter table 支票账户 add constraint FK_支票账户3 foreign key (账户号码)
      references 账户 (UM_账户号码) on delete restrict on update restrict;

alter table 贷款 add constraint FK_支行_贷款 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 部门 add constraint FK_支行_部门 foreign key (支行名字)
      references 支行 (支行名字) on delete restrict on update restrict;

alter table 部门 add constraint FK_经理 foreign key (经理身份证号)
      references 员工 (员工身份证号) on delete restrict on update restrict;

