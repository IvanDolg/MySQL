-- Переименовать название файла. Вместо "x" - номер группы. Фамилию указать латиницей. (shift + ctrl + S -> сохранить как)
-- Все решения должны быть оформлены в виде запросов, и записаны в этот текстовый файл (в том числе создание хранимых процедур, функций и т.д.).
-- Задания рекомендуется выполнять по порядку.  
-- Задания **{} - выполнять по желанию.
-- Проверить таблицу BUBuy, для поля IDU значения должны быть не более 350, для поля IDB около 1500. Если наоборот то выполнить запрос:
-- ALTER TABLE bubuy CHANGE COLUMN IDU IDB INT, CHANGE COLUMN IDB IDU INT;

-- ??? - Что такое представление (VIEW). Для решения каких задач применяется VIEW?
-- ??? - Что такое триггер, для каких задач его можно применять, какие ограничения применения есть в MySQL?
-- ??? - Какие функции бывают в  MySQL, как их применять?

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№1 Создать таблицу для хранения просмотров книг зарегистрированными пользователями. BUView - состоит из двух полей IDB, IDU. 
	При создании таблицы прописать FOREIGN KEY */
-- Решение:

USE LR6ADD;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№2 Создать таблицу для хранения закладок "BUMark", где пользователь может пометить страницу в купленной книге и оставить короткое 
	текстовое описание, важно также знать время создания закладки.		
    **{При создании таблицы прописать FOREIGN KEY к оптимальной таблице} */
-- Решение:

CREATE TABLE IF NOT EXISTS  BUMark(
	IDB INT,
    IDU INT,
    markpage INT NOT NULL,
    markcontext VARCHAR(128),
    datemark DATETIME,
    FOREIGN KEY (IDB) REFERENCES Books(IDB) ON DELETE CASCADE,
    FOREIGN KEY (IDU) REFERENCES Users(IDU) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать таблицу для специального предложения месяца "BStock".Таблица состоит из колонок: 
	Код книги, доступное количество книг по предложению, цена книги, месяц и год проведения предложения (формат дата)
    Первых этих 5 покупок будут по цене 99, скидки покупателя не влияют на цену.} */
-- Решение:

CREATE TABLE  IF NOT EXISTS  BStock(
	IDB	INT PRIMARY KEY,
    bookcount INT DEFAULT 5,
    bookprice DECIMAL DEFAULT 99,
    datestock DATE,
    FOREIGN KEY (IDB) REFERENCES Books(IDB) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------------------------

/*	№3 Создать хранимую процедуру для добавления записей в таблицу "BUMark".
	**{Предусмотреть защиту от появления ошибок при заполнения данных}*/
-- Решение:

drop procedure addmark;

delimiter $$
CREATE PROCEDURE addmark(bookid INT, userid INT, markpage INT, context VARCHAR(128))
BEGIN
	IF markpage > (SELECT pages FROM books WHERE IDB=bookid) OR (SELECT COUNT(*) FROM books WHERE IDB=bookid) <> 1 THEN SELECT "ERROR";
    ELSE INSERT INTO bumark VALUES(bookid, userid, markpage,context, now());
		 SELECT * FROM bumark;
	END IF;
END $$
delimiter ;

call addmark(33,3,1,'mark1');

/* ----------------------------------------------------------------------------------------------------------------------------------------
	№4 Добавить в таблицу "BUMark" по 3 записи для пользователей: 'Denis', 'Dunn', 'Dora'. */
-- Решение:



-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5 Для каждого покупателя посчитать скидку в зависимости от количества купленных книг:
	+------------------------+------+-------+-------+-------+-------+
	| Количество книг, более |	0   |	3	|	5	|	7	|	10	|
    +------------------------+------+-------+-------+-------+-------+
    | Скидка, %		    	 |	0	|	1	|	2	|	3	|	5	|
	+------------------------+------+-------+-------+-------+-------+
	Решение этой задачи должно быть таким, чтобы потом им можно было воспользоваться для подсчета стоимости при покупке книги.*/
-- Решение:

DROP FUNCTION IF EXISTS disc_count ;

delimiter $$
CREATE FUNCTION disc_count(userid INT)
RETURNS double
DETERMINISTIC

BEGIN
DECLARE disc DOUBLE;
SET disc = (
SELECT
CASE
WHEN buyed BETWEEN 0 AND 3 THEN 0
WHEN buyed BETWEEN 4 AND 5 THEN 0.01
WHEN buyed BETWEEN 6 AND 7 THEN 0.02
WHEN buyed BETWEEN 8 AND 10 THEN 0.03
WHEN buyed > 10 THEN 0.05
ELSE 0
END AS discount_of_user
FROM (
SELECT IDU, login, COUNT(*) as buyed
FROM users
INNER JOIN bubuy USING (IDU)
GROUP BY IDU
HAVING IDU = userid
) AS e1
);
IF disc IS NULL THEN RETURN 0; 
END IF;
RETURN disc;
END$$
delimiter ;



-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Предложить альтернативную идею или идеи для решения задачи №5.}
-- Решение:

SELECT login, COUNT(*) AS book_buyed
FROM users
INNER JOIN bubuy USING (IDU)
GROUP BY login;

SELECT login, disc_count(IDU) AS e
FROM users
ORDER BY e DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6 Создать представление, которое будет выводить список 10 самых покупаемых книг за предыдущий месяц 
(при одинаковом значении проданных книг, сортировать по алфавиту) */
-- Решение:

DROP VIEW IF EXISTS buyed_last_month;

CREATE VIEW buyed_last_month 
AS
SELECT Count(*) AS buyed, Title, IDB, month_buy
FROM(
SELECT MONTH(Datetime) AS month_buy, Title, IDB
FROM books
INNER JOIN bubuy USING (IDB)
WHERE MONTH(Datetime) = (SELECT CASE WHEN MONTH(NOW()) = 1 THEN 12 ELSE MONTH(NOW())-1 
END AS last_month)
) AS e1

GROUP BY IDB
ORDER BY buyed DESC, Title
LIMIT 10;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Сделать выборку по условию задачи №6 и добавить к решению нумерацию строк}
-- Решение:

SET @rowNumber = 0;
SELECT (@rowNumber:=@rowNumber+1) AS rowNumber, Title, IDB, buyed 
FROM buyed_last_month;


-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Заполнить таблицу "BStock" на текущий месяц. 10 записей из списка задачи №6, ручной ввод IDB не допускается.}
-- Решение:



-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№7 Написать хранимую процедуру. Для книг (если название и автор совпадает) вывести количество изданий, минимальную и максимальную стоимость. 
Отобразить только те записи, у которых есть несколько упоминаний.*/
-- Решение:
DROP PROCEDURE book_auth;
delimiter $$
CREATE PROCEDURE book_auth()
BEGIN
SELECT Title, Price, NameA, Count(*) AS amount, MAX(Price) AS maxprice, MIN(Price) AS minprice
FROM books
INNER JOIN ba USING (IDB)
GROUP BY Title, NameA
HAVING maxprice <> minprice
ORDER BY Title; 
END$$
delimiter ;

call book_auth();

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8 Создать триггер который будет копировать исходную строку в "новую архивную таблицу" при редактирование данных в таблице "USERS".	*/
-- Решение:

CREATE TABLE arusers(
	IDU INT PRIMARY KEY,
    mail VARCHAR(50),
    LOGIN VARCHAR(50),
    pass VARCHAR(50)
);

delimiter $$
CREATE TRIGGER arch_user
BEFORE UPDATE ON users FOR EACH ROW
BEGIN
INSERT INTO arusers SELECT * FROM users WHERE IDU = old.IDU;
END$$
delimiter ;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Написать триггер который будет поддерживать таблицу "BStock" в актуальном состоянии}  */
-- Решение:



-- ----------------------------------------------------------------------------------------------------------------------------------------
/* №9 Написать хранимую процедуру. Какая книга или книги, самая популярная как первая купленная.*/
-- Решение:
DROP PROCEDURE most_popular_first;

delimiter $$
CREATE PROCEDURE most_popular_first()
BEGIN
SELECT first_buyed, Title, IDB
FROM(
SELECT COUNT(*) AS first_buyed, Title, IDB
FROM(
SELECT login, Title, Datetime, IDB
FROM users
INNER JOIN bubuy USING (IDU)
INNER JOIN books USING (IDB)
INNER JOIN(
SELECT login AS lg1, MIN(Datetime) AS mdata
FROM users
INNER JOIN bubuy USING (IDU)
GROUP BY lg1) AS e0 ON Datetime=mdata AND login=e0.lg1
) as e1
GROUP BY Title
) AS e2
INNER JOIN 
(
SELECT MAX(first_buyed) AS maxmax
FROM (
SELECT COUNT(*) AS first_buyed, Title
FROM(
SELECT login, Title, Datetime
FROM users
INNER JOIN bubuy USING (IDU)
INNER JOIN books USING (IDB)
INNER JOIN(
SELECT login AS lg1, MIN(Datetime) AS mdata
FROM users
INNER JOIN bubuy USING (IDU)
GROUP BY lg1) AS e3 ON Datetime=mdata AND login=e3.lg1
) as e4
GROUP BY Title
) AS e5) AS e6 ON e6.maxmax = first_buyed;
END$$
delimiter ;

CALL most_popular_first();

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№10 Вывести пользователей которые не проявили никакой активности (не просматривали книги, ничего не покупали)*/
-- Решение:

SELECT * FROM users;

SELECT IDU, login
FROM users
LEFT JOIN bubuy USING (IDU)
LEFT JOIN buview USING (IDU)
WHERE Datetime IS NULL AND buview.IDB IS NULL;


-- ----------------------------------------------------------------------------------------------------------------------------------------
