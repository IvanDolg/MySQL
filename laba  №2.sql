 DROP DATABASE IF EXISTS  laba№2;
 CREATE DATABASE laba№2;
 USE  laba№2;
 
 CREATE TABLE star
 (
the_code INT PRIMARY KEY, 
star_name VARCHAR(20),
constellation VARCHAR(20),
spectrum_class VARCHAR(20),
temperature INT,
Weight INT,
Radius INT,
Distance_to_the_star INT,
absolute_stellar_magnitude DOUBLE(3,2),
apparent_stellar_magnitude DOUBLE(3,2)
 );
 
-- 2 Добавить следующую  запись в таблицу:
--  решение 

INSERT star (the_code, star_name, constellation, spectrum_class, temperature,
Weight, Radius, Distance_to_the_star, absolute_stellar_magnitude, apparent_stellar_magnitude)
VALUES (1, 'Aldebaran', 'Taurus', 'M', 3500, 5, 45, 68, -0.63, 0.85); 

-- 3  Вывести содержимое таблицы (select…)
--  решение 

SELECT * FROM star;

-- 4  Добавить записи в таблицу  за один запрос:
--  решение 

 INSERT star (the_code, star_name, constellation, spectrum_class, temperature,
Weight, Radius, Distance_to_the_star, absolute_stellar_magnitude, apparent_stellar_magnitude)
VALUES 
(2, 'Gacrux', 'South cross', 'M', 3400, 3, 113, 88, -0.56, 1.59),
(3, 'Polar', 'Ursa Minor', 'F', 7000, 6, 30, 430, -3.6, 1.97),
(4, 'Bellatrix', 'Orion', 'B', 22000, 8.4, 6, 240, -2.8, 1.64),
(5, 'Arcturus', 'Bootes', 'K', 4300, 1.25, 26, 37, -0.28, -0.05),
(6, 'Altair', 'Eagle', 'A', 8000, 1.7, 1.7, 360, 2.22, 0.77),
(7, 'Antares', 'Scorpio', 'K', 4000, 10, 880, 600,-5.28, 0.96),
(8, 'Rigel', 'Orion', 'B', 11000, 18, 75, 864,  -7.84, 0.12),
(9, 'Betelgeuse', 'Orion', 'M', 3100, 20, 900, 650, -5.14, 1.51);

-- 5 Добавить запись
--  решение 

INSERT star (the_code, star_name, constellation, spectrum_class, temperature,
Weight, Radius, Distance_to_the_star, absolute_stellar_magnitude, apparent_stellar_magnitude)
VALUES (10, 'Sirius', 'Big Dog', 'A', 9900, 2, 1.7, DEFAULT, DEFAULT, DEFAULT );

-- 6 Изменить запись. Для звезды с кодом = 10 уставить значение Видимой звёздной величины = 1,4
--  решение 

UPDATE star
SET apparent_stellar_magnitude = 1.4
WHERE the_code = 10;

-- 7 Удалить запись с кодом = 1.
--  решение 

DELETE FROM star 
WHERE the_code = 1;
SELECT * FROM star;

-- 8 Изменить запись одним запросом. Для звезды Сириус установить значение Абсолютной звёздной величины = -1,46 и Расстояние до звезды = 8,6 (для успешного выполнения должен быть выключен safe mode).
--  решение 

UPDATE star
SET absolute_stellar_magnitude = -1.46,
    Distance_to_the_star = 8.6
WHERE the_code = 10;


-- 9 Удалить запись, где название звезды Сириус (для успешного выполнения должен быть выключен safe mode).
--  решение 

DELETE FROM star 
WHERE star_name = 'Sirius';
SELECT * FROM star;

-- 10 Вывести поля: название звезды и температура, отсортировав по алфавиту “Название звезды”
--  решение 

SELECT DISTINCT star_name, temperature FROM star;
SELECT * FROM star
ORDER BY star_name;

-- 11 Вывести список звезд из созвездия Ориона
--  решение 

SELECT * FROM star
WHERE constellation IN ('Orion');

-- 12 Вывести список звезд спектрального класса В из созвездия Ориона
--  решение 

SELECT * FROM star
WHERE constellation IN ('Orion') and spectrum_class IN ('B');

-- 13 Вывести самую далекую звезду
--  решение 
 
 SELECT * FROM star
 ORDER BY Distance_to_the_star DESC
 LIMIT 1;

-- 14 Вывести звезду с наименьшим радиусом
--  решение 

SELECT * FROM star
ORDER BY Radius DESC
LIMIT 1;

-- 15 Вывести среднюю температуру для каждого класса спектра
--  решение 

SELECT AVG (temperature) FROM star
WHERE spectrum_class = 'M';
SELECT AVG (temperature) FROM star
WHERE spectrum_class  = 'F';
SELECT AVG (temperature) FROM star
WHERE spectrum_class  = 'B';
SELECT AVG (temperature) FROM star
WHERE spectrum_class  = 'K';
SELECT AVG (temperature) FROM star
WHERE spectrum_class  = 'A';

-- 16 Подсчитать количество звезд в каждом спектральном классе
--  решение
 
SELECT COUNT(*) FROM star
WHERE spectrum_class = 'M';
SELECT COUNT(*) FROM star
WHERE spectrum_class  = 'F';
SELECT COUNT(*) FROM star
WHERE spectrum_class  = 'B';
SELECT COUNT(*) FROM star
WHERE spectrum_class  = 'K';
SELECT COUNT(*) FROM star
WHERE spectrum_class  = 'A';

-- 17 Какая суммарная масса звезд в таблице
--  решение 

SELECT SUM(Weight) FROM star;

-- 18 Вывести минимальную температуру звезды спектрального класса “К”
--  решение 
 
SELECT MIN(temperature) FROM star
WHERE spectrum_class  = 'K';


