DROP DATABASE IF EXISTS  L3;
CREATE DATABASE L3;
USE L3;
CREATE TABLE `manuf` (
`IDM` int PRIMARY KEY,  
`name` varchar(20),  
`city` varchar(20));
INSERT INTO `manuf` VALUES 
(1,'Intel','Santa Clara'),
(2,'AMD','Santa Clara'),
(3,'WD','San Jose'),
(4,'seagete','Cupertino'),
(5,'Asus','Taipei'),
(6,'Dell','Round Rock');
CREATE TABLE `cpu` (
`IDC` int PRIMARY KEY ,
`IDM` int,
`Name` varchar(20),
`clock` decimal(5,2));
INSERT INTO `cpu` VALUES 
(1,1,'i5',3.20),
(2,1,'i7',4.70),
(3,2,'Ryzen 5',3.20),
(4,2,'Ryzen 7',4.70),
(5,NULL,'Power9',3.50);
CREATE TABLE `hdisk` (
`IDD` int PRIMARY KEY,
`IDM` int,
`Name` varchar(20),
`type` varchar(20),
`size` int);
INSERT INTO `hdisk` VALUES 
(1,3,'Green','hdd',1000),
(2,3,'Black','ssd',256),
(3,1,'6000p','ssd',256),
(4,1,'Optane','ssd',16);
CREATE TABLE `nb` (
`IDN` int PRIMARY KEY,
`IDM` int,
`Name` varchar(20),
`IDC` int,
`IDD` int);
INSERT INTO `nb` VALUES 
(1,5,'Zenbook',2,2),
(2,6,'XPS',2,2),
(3,9,'Pavilion',2,2),
(4,6,'Inspiron',3,4),
(5,5,'Vivobook',1,1),
(6,6,'XPS',4,1);

-- 3	Соединить таблицы Manuf и CPU через запятую без условия (Неявное соединение таблиц)
-- Решение:

SELECT * FROM manuf, cpu;

-- 4	Соединить таблицы Manuf и CPU через запятую с условием (Неявное соединение таблиц)
-- Решение:

SELECT * FROM manuf, cpu
WHERE manuf.IDM = cpu.IDM;

-- 5	Соединить таблицы Manuf и CPU используя  INNER JOIN
-- Решение:

SELECT manuf.name, manuf.city, cpu.IDC, cpu.name, cpu.clock
FROM manuf 
JOIN cpu ON manuf.IDM = cpu.IDM; 

-- 6	Соединить таблицы Manuf и CPU используя  LEFT JOIN
-- Решение:

SELECT manuf.name, manuf.city, cpu.IDC, cpu.name, cpu.clock
FROM manuf 
LEFT JOIN cpu ON manuf.IDM = cpu.IDM;

-- 7	Соединить таблицы Manuf и CPU используя  RIGHT JOIN
-- Решение:

SELECT manuf.name, manuf.city, cpu.IDC, cpu.name, cpu.clock
FROM manuf 
RIGHT JOIN cpu ON manuf.IDM = cpu.IDM;

-- 8	Соединить таблицы Manuf и CPU используя  CROSS  JOIN
-- Решение:

SELECT manuf.name, manuf.city, cpu.IDC, cpu.name, cpu.clock
FROM manuf 
CROSS JOIN cpu ON manuf.IDM = cpu.IDM;

-- 8а Провести анализ  результатов соединения таблиц 3-8 заданий?

-- 9	Вывести название фирмы и модель диска. Список не должен содержать пустых значений (NULL)
-- Решение:

SELECT manuf.name, hdisk.Name
FROM manuf 
RIGHT JOIN hdisk ON manuf.IDM = hdisk.IDM;

-- 10	Вывести модель процессора и, если есть информация в БД, название фирмы
-- Решение:

SELECT manuf.name,  cpu.name
FROM manuf 
RIGHT JOIN cpu ON manuf.IDM = cpu.IDM;

-- 11	Вывести модели ноутбуков, у которых нет информации в базе данных о фирме изготовителе
-- Решение:

SELECT  nb.name
FROM manuf 
RIGHT JOIN nb ON manuf.IDM = nb.IDM
WHERE manuf.name  IS NULL;

-- 12	Вывести модель ноутбука и название производителя ноутбука, название модели процессора, название модели диска
-- Решение:

SELECT manuf.name, nb.name, cpu.name, hdisk.name 
FROM nb 
LEFT JOIN manuf ON manuf.IDM = nb.IDM
LEFT JOIN cpu ON cpu.IDC = nb.IDC
LEFT JOIN hdisk ON hdisk.IDD = nb.IDD;

-- 13	Вывести модель ноутбука, фирму производителя ноутбука, а также для этой модели:	модель и название фирмы производителя процессора, модель и название фирмы производителя диска
-- Решение:

select nb.Name as NB, manuf.name as NB_MANUF,CPU,CPU_MANUF,HDISK, HDISK_MANUF from nb
left join manuf  ON nb.IDM=Manuf.IDM
left join (select cpu.name as CPU,manuf.name as CPU_MANUF,cpu.idc from manuf left join cpu on manuf.IDM=cpu.IDM)as CPUM on nb.IDC=CPUM.IDC 
left join (select hdisk.name as HDISK ,manuf.name as HDISK_MANUF,hdisk.idd from manuf left join hdisk on manuf.IDM=hdisk.IDM) as HDISKM on nb.IDD=HDISKM.IDD;

-- 14	Вывести абсолютно все названия фирм в первом поле и все моделей процессоров во втором
-- Решение:

SELECT manuf.name, cpu.name
FROM cpu 
RIGHT JOIN manuf ON cpu.IDM = manuf.IDM
UNION ALL 
SELECT manuf.name, cpu.name
FROM cpu 
LEFT JOIN manuf ON cpu.IDM = manuf.IDM;

-- 15	Вывести название фирмы, которая производит несколько типов товаров
-- Решение:

SELECT DISTINCT manuf_title
FROM (SELECT DISTINCT manuf.Name AS manuf_title, cpu.Name AS cpu_Name, hdisk.Name AS hdisk_Name, nb.Name AS nb_Name FROM manuf LEFT JOIN cpu USING (IDM) LEFT JOIN hdisk USING (IDM) LEFT JOIN nb USING (IDM)) AS manuf_prod
WHERE (cpu_Name IS NOT NULL AND hdisk_Name IS NOT NULL) OR (cpu_Name IS NOT NULL AND nb_Name IS NOT NULL) OR (nb_Name IS NOT NULL AND hdisk_Name IS NOT NULL);
