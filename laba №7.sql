-- ??? - Что такое транзакция? Как работает транзакция? Когда и для чего используют транзакции?
/*
- Что такое транзакция?

Транзакция — это архив для запросов к базе. Он защищает ваши данные благодаря принципу «всё, или ничего».
Если говорить по-научному, то транзакция — упорядоченное множество операций, переводящих базу данных из одного согласованного состояния в другое. Согласованное состояние — это состояние,
которое подходит под бизнес-логику системы. То есть у нас не остается отрицательный баланс после перевода денег, номер счета не «зависает в воздухе», не привязанный к человеку, и тому подобное.
 
- Как работает транзакция?

Чтобы обратиться к базе данных, сначала надо открыть соединение с ней. Это называется коннект. Коннект — это просто труба, по которой мы посылаем запросы
Чтобы сгруппировать запросы в одну атомарную пачку, используем транзакцию. Транзакцию надо:
  1  Открыть. (START TRANSACTION;)
  2  Выполнить все операции внутри.
  3 Закрыть. (COMMIT, ROLLBACK)
  
 - Когда и для чего используют транзакции?
 
 Например, для бухгалтерии. Потерял один файлик? Значит, допустил ошибку в отчете для налоговой. Значит, огребешь штраф и большие проблемы! Нет, спасибо, лучше файлы не терять!
И получается, что тебе надо уточнять у отправителя:
		— Ты мне сколько файлов посылал?
		— 10
		— Да? У меня только 9... Давай искать, какой продолбался.
		И сидите, сравниваете по названиям. А если файликов 100 и потеряно 2 штуки? А названия у них вовсе не «Отчет 1», «Отчет 2» и так далее, 
		а «hfdslafebx63542437457822nfhgeopjgrev0000444666589.xml» и подобные... Уж лучше использовать архив! Тогда ты или точно всё получил, или не получил ничего 
        и делаешь повторную попытку отправки.

-- ??? - Что такое индексы? Как работают индексы? Какие бывают индексы?

- Что такое индексы?

Индексы – это специальные таблицы, которые могут быть использованы поисковым двигателем базы данных (далее – БД), для ускорения получения данных. Необходимо просто добавить 
указатель индекса в таблицу. Индекс в БД крайне схож с индексом в конце книги.
Допустим, мы хотим иметь ссылку на все страницы книги, которые касаются определённой темы (например, Наследование в книге по программированию на языке Java). Для этого, 
мы в первую очередь ссылаемся на индекс, который указан в конце книге и переходим на любую из страниц, которая относится к необходимой теме.
Индекс помогает ускорить запросы на получение данных (SELECT [WHERE]), но замедляет процесс добавления и изменения записей (INSERT, UPDATE). 
Индексы могут быть добавлены или удалены без влияния на сами данные.

- Как работают индексы?

Для того, чтобы добавить индекс, нам необходимо использовать команду CREATE INDEX, что позволит нам указать имя индекса и определить таблицу и колонку 
или индекс колонки и определить используется ли индекс по возрастанию или по убыванию.

- Какие бывают индексы?

Индекса также могут быть уникальными, так же как и констрейнт UNIQUE. В этом случае индекс предотвращает добавление повторяющихся данных в колонку или комбинацию колонок, 
на которые указывает индекс.

*/


CREATE DATABASE IF NOT EXISTS LR7;
USE LR7;
USE LR6ADD;
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№1	Привести пример использования транзакции. Транзакция должна завершиться успешно. */
-- Решение:


CREATE TABLE Goods(
ProductId INT,
ProductName VARCHAR(100) NOT NULL,
Price INT
); 

INSERT INTO GOODS (ProductId, ProductName, Price)
VALUE ( 1, 'Системный блок', 50), (2, 'Клавиатура', 30), (3, 'Монитор', 100);

SELECT ProductId, ProductName, Price
FROM GOODS;

START TRANSACTION;

   UPDATE Goods SET Price = 70
   WHERE ProductId = 1;
   UPDATE Goods SET Price = 40
   WHERE ProductId = 2;

   COMMIT; 

   SELECT ProductId, ProductName, Price
   FROM Goods;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№2	Привести пример использования транзакции. Транзакция должна должна быть отклонена. */
-- Решение: 

START TRANSACTION;

   UPDATE Goods SET Price = 70
   WHERE ProductId = 1;
   UPDATE Goods SET Price = 'BSUIR'
   WHERE ProductId = 2;

   COMMIT; 

SELECT ProductId, ProductName, Price
FROM Goods;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№3 Создать таблицу "Buy", которая состоит из полей: ID - первичный ключ, авто заполняемое. IDB, IDU, TimeBuy
. Создать уникальный составной индекс для IDB, IDU. Создать обычный индекс TimeBuy, обратный порядок. 
*/
-- Решение:

CREATE TABLE Buy(
ID INT PRIMARY KEY AUTO_INCREMENT,
IDB INT,
IDU INT,
TimeBuy DATETIME
);

CREATE UNIQUE INDEX indexBookUser 
ON Buy (IDB, IDU);

CREATE INDEX indexTimeBuy
On Buy (TimeBuy);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№4  Модифицировать таблицу "Buy", добавить поле для хранения стоимости покупки "Cost".*/
-- Решение:

ALTER TABLE Buy 
ADD COLUMN Cost decimal(8,2);

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Создать хранимую процедуру для добавления записи о покупке книги и подсчета итоговой цены книги с учетом всех скидок и предложений. Полученная стоимость записывается в поле "Cost". }
-- Решение:

drop procedure addBuyRecord;

delimiter |
create procedure addBuyRecord(bookId int, userId int)
begin
declare disc double;
declare defPrice double;
set disc  = (select discount(IDU)from users where IDU = userId);
set defPrice = (select	case
						when price>bookPrice then bookPrice
						when bookPrice is null then price
						when price < bookPrice then price
						end as test from books
				left join bstock using(IDB)
				where IDB =bookId);
insert into Buy(IDB,IDU,Cost,TimeBuy) values (bookId,userId,defPrice-(defPrice*disc),now());
end |
delimiter ;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5	Изменить триггер для таблицы USERS, который теперь должен срабатывать при изменении адреса почтового ящика.*/ 
-- Решение:

CREATE TABLE users(
	IDU INT PRIMARY KEY,
    arusers_IDU INTEGER,
    mail VARCHAR(128),
    login VARCHAR(128),
	pass VARCHAR(128)
    );
insert into users values (1, "Denis@rocketmail.com", "Denis", "98337"), (2, "Dunn@yahoo-inc.com", "Dunn", "43364"), (3, "Dora@bk.ru", "Dora", "32243"), (4, "Blasius@mail.ru", "Blasius", "87805"), (5, "Akulina@googlemail.com", "Akulina", "60848"), (6, "Aksinya@aol.com", "Aksinya", "37639"), (7, "Vlas@bk.ru", "Vlas", "96009"), (8, "Vytautas@ymail.com", "Vytautas", "56876"), (9, "Gelena@msn.com", "Gelena", "21102"), (10, "Aida@msn.com", "Aida", "83095"), (11, "Jeremiah@yahoo.com", "Jeremiah", "73250"), (12, "Autonoy@list.ru", "Autonoy", "75637"), (13, "Avdi@hotmail.com", "Avdi", "22980"), (14, "Gemma@googlemail.com", "Gemma", "57361"), (15, "Vilena@googlemail.com", "Vilena", "50639"), (16, "Vladimir@aol.com", "Vladimir", "39484"), (17, "Agathon@gmail.com", "Agathon", "39175"), (18, "Dorofei@ymail.com", "Dorofei", "51766"), (19, "Graph@yandex.ru", "Graph", "31467"), (20, "Gerasim@ymail.com", "Gerasim", "83847"), (21, "Vlastilina@list.ru", "Vlastilina", "90154"), (22, "Dayana@hotmail.com", "Dayana", "65514"), (23, "Vilen@rocketmail.com", "Vilen", "73746"), (24, "William@rocketmail.com", "William", "35367"), (25, "Alyona@ymail.com", "Alyona", "47902"), (26, "Beatrice@yandex.ru", "Beatrice", "34908"), (27, "Quiz@ymail.com", "Quiz", "92402"), (28, "Gayane@inbox.ru", "Gayane", "34491"), (29, "Aksen@gmail.com", "Aksen", "49911"), (30, "Juliet@inbox.ru", "Juliet", "26960"), (31, "Agap@yahoo.com", "Agap", "81821"), (32, "Vitali@inbox.ru", "Vitali", "28328"), (33, "Varlam@bk.ru", "Varlam", "62006"), (34, "Vaclav@googlemail.com", "Vaclav", "46375"), (35, "Alevtina@mail.ru", "Alevtina", "42239"), (36, "Venus@yahoo-inc.com", "Venus", "92929"), (37, "Velizar@list.ru", "Velizar", "62494"), (38, "Gerda@msn.com", "Gerda", "24776"), (39, "Adrian@ymail.com", "Adrian", "92149"), (40, "Hamlet@msn.com", "Hamlet", "20656"), (41, "Gaby@hotmail.com", "Gaby", "98170"), (42, "Vinetta@rambler.ru", "Vinetta", "53511"), (43, "Adelia@inbox.ru", "Adelia", "30114"), (44, "Dasha@yahoo-inc.com", "Dasha", "63693"), (45, "Jennifer@list.ru", "Jennifer", "88810"), (46, "Dynasia@ahoomail.com", "Dynasia", "85902"), (47, "Birgit@ahoomail.com", "Birgit", "75935"), (48, "Abigail@mail.ru", "Abigail", "35064"), (49, "Greta@yandex.ru", "Greta", "57079"), (50, "Agatha@inbox.ru", "Agatha", "86550"), (51, "Dobrynya@msn.com", "Dobrynya", "84845"), (52, "Valentine@rocketmail.com", "Valentine", "55195"), (53, "Woldemar@yahoo.com", "Woldemar", "31518"), (54, "Dilnaz@live.com", "Dilnaz", "70028"), (55, "Vsevolod@rocketmail.com", "Vsevolod", "74441"), (56, "Darius@aol.com", "Darius", "37969"), (57, "Agapia@ymail.com", "Agapia", "25414"), (58, "Dana@inbox.ru", "Dana", "39715"), (59, "Boris@aol.com", "Boris", "53810"), (60, "Darina@list.ru", "Darina", "87464"), (61, "Boyan@list.ru", "Boyan", "47782"), (62, "Glyceria@bk.ru", "Glyceria", "43119"), (63, "View@yahoo-inc.com", "View", "31708"), (64, "Benjamin@rambler.ru", "Benjamin", "41337"), (65, "Adele@aol.com", "Adele", "33657"), (66, "Dilya@aol.com", "Dilya", "57745"), (67, "Denmark@hotmail.com", "Denmark", "70323"), (68, "Albert@yahoo.com", "Albert", "28214"), (69, "Barlaam@bk.ru", "Barlaam", "54767"), (70, "Henrietta@inbox.ru", "Henrietta", "60453"), (71, "Aurora@list.ru", "Aurora", "31814"), (72, "Aliya@rocketmail.com", "Aliya", "45025"), (73, "Vladislav@bk.ru", "Vladislav", "96098"), (74, "Avvakum@googlemail.com", "Avvakum", "63394"), (75, "Adolf@live.com", "Adolf", "35509"), (76, "Bronislav@mail.ru", "Bronislav", "27674"), (77, "Vita@live.com", "Vita", "61380"), (78, "Aigerim@gmail.com", "Aigerim", "49661"), (79, "Galaktion@googlemail.com", "Galaktion", "76454"), (80, "Damien@rambler.ru", "Damien", "25425"), (81, "Adil@hotmail.com", "Adil", "93496"), (82, "Dita@bk.ru", "Dita", "85628"), (83, "Aizhan@bk.ru", "Aizhan", "65518"), (84, "Vesnyana@list.ru", "Vesnyana", "61846"), (85, "Avksentiy@bk.ru", "Avksentiy", "53459"), (86, "Alina@googlemail.com", "Alina", "89803"), (87, "Adrienne@msn.com", "Adrienne", "23074"), (88, "Danna@rambler.ru", "Danna", "96885"), (89, "Danyar@ymail.com", "Danyar", "73382"), (90, "Agatha@msn.com", "Agatha", "82825"), (91, "Abraham@rocketmail.com", "Abraham", "29601"), (92, "Alberta@msn.com", "Alberta", "60702"), (93, "Gohar@yahoo-inc.com", "Gohar", "63590"), (94, "Boniface@rocketmail.com", "Boniface", "95663"), (95, "Gella@gmail.com", "Gella", "89260"), (96, "Biruta@yandex.ru", "Biruta", "80050"), (97, "Bertha@bk.ru", "Bertha", "74818"), (98, "Hydrangea@googlemail.com", "Hydrangea", "32694"), (99, "Borislav@ymail.com", "Borislav", "82917"), (100, "Avaz@ahoomail.com", "Avaz", "59119"), (101, "Guzel@ymail.com", "Guzel", "45735"), (102, "Jamal@ymail.com", "Jamal", "69940"), (103, "Altzhin@live.com", "Altzhin", "82237"), (104, "Donatos@mail.ru", "Donatos", "25761"), (105, "Bazhena@rambler.ru", "Bazhena", "33941"), (106, "Gaspard@bk.ru", "Gaspard", "51365"), (107, "Alexander@live.com", "Alexander", "45929"), (108, "Verona@rocketmail.com", "Verona", "23149"), (109, "Alba@yahoo-inc.com", "Alba", "54289"), (110, "Agnes@gmail.com", "Agnes", "96535"), (111, "Vetta@ymail.com", "Vetta", "56215"), (112, "Avdotya@msn.com", "Avdotya", "82087"), (113, "Alevtin@yandex.ru", "Alevtin", "27777"), (114, "Dominica@msn.com", "Dominica", "38256"), (115, "Bruno@inbox.ru", "Bruno", "77716"), (116, "Bogdana@live.com", "Bogdana", "24029"), (117, "Gelianna@aol.com", "Gelianna", "32404"), (118, "Dinara@inbox.ru", "Dinara", "72090"), (119, "Violanta@rambler.ru", "Violanta", "64896"), (120, "Benedict@yahoo-inc.com", "Benedict", "68171"), (121, "Dmitriy@qip.ru", "Dmitriy", "42855"), (122, "Avdey@mail.ru", "Avdey", "48100"), (123, "Galina@bk.ru", "Galina", "22575"), (124, "Gunnhild@inbox.ru", "Gunnhild", "77879"), (125, "Dina@googlemail.com", "Dina", "32237"), (126, "Danila@hotmail.com", "Danila", "81820"), (127, "Gleb@rocketmail.com", "Gleb", "26699"), (128, "Gabriel@ymail.com", "Gabriel", "43551"), (129, "Alice@googlemail.com", "Alice", "41688"), (130, "Dahlia@yandex.ru", "Dahlia", "37080"), (131, "Alsou@live.com", "Alsou", "80509"), (132, "Gulmira@yandex.ru", "Gulmira", "82972"), (133, "Dan@bk.ru", "Dan", "39560"), (134, "Gulia@yandex.ru", "Gulia", "55898"), (135, "Akim@msn.com", "Akim", "77587"), (136, "Gelasius@bk.ru", "Gelasius", "41305"), (137, "Jordan@rambler.ru", "Jordan", "95965"), (138, "Spring@yandex.ru", "Spring", "77447"), (139, "August@googlemail.com", "August", "30720"), (140, "Adelphine@gmail.com", "Adelphine", "57222"), (141, "Gertrude@hotmail.com", "Gertrude", "93683"), (142, "Joan@yahoo.com", "Joan", "27124"), (143, "Disha@hotmail.com", "Disha", "64325"), (144, "Gevor@rocketmail.com", "Gevor", "93307"), (145, "Dick@hotmail.com", "Dick", "34601"), (146, "Benedict@live.com", "Benedict", "94287"), (147, "Gulnaz@hotmail.com", "Gulnaz", "75009"), (148, "Gift@list.ru", "Gift", "56946"), (149, "Herald@gmail.com", "Herald", "57051"), (150, "Guljan@gmail.com", "Guljan", "40046"), (151, "Jenna@list.ru", "Jenna", "33949"), (152, "Bulat@aol.com", "Bulat", "87364"), (153, "Avtandil@list.ru", "Avtandil", "44947"), (154, "Dinar@qip.ru", "Dinar", "36004"), (155, "Gustav@aol.com", "Gustav", "30471"), (156, "Vardan@rambler.ru", "Vardan", "29323"), (157, "Bozena@live.com", "Bozena", "55093"), (158, "Aigul@inbox.ru", "Aigul", "30719"), (159, "Augustine@yahoo.com", "Augustine", "87349"), (160, "Adeline@live.com", "Adeline", "43168"), (161, "Share@rambler.ru", "Share", "51032"), (162, "Damira@hotmail.com", "Damira", "30575"), (163, "Jam@live.com", "Jam", "81599"), (164, "Alira@rambler.ru", "Alira", "92380"), (165, "Vladlen@hotmail.com", "Vladlen", "59906"), (166, "Vincent@rambler.ru", "Vincent", "23329"), (167, "Grazyna@gmail.com", "Grazyna", "27022"), (168, "Velimir@hotmail.com", "Velimir", "63532"), (169, "Vassa@hotmail.com", "Vassa", "95273"), (170, "Hermogen@mail.ru", "Hermogen", "26833"), (171, "Daniel@rocketmail.com", "Daniel", "37716"), (172, "Agrippina@msn.com", "Agrippina", "20277"), (173, "Vlad@msn.com", "Vlad", "79812"), (174, "Jorge@googlemail.com", "Jorge", "40507"), (175, "Danislav@mail.ru", "Danislav", "50628"), (176, "Genius@rambler.ru", "Genius", "45023"), (177, "Aza@ymail.com", "Aza", "94025"), (178, "Veronica@live.com", "Veronica", "44515"), (179, "Adis@googlemail.com", "Adis", "24226"), (180, "Gelana@rambler.ru", "Gelana", "20454"), (181, "Alzhbet@msn.com", "Alzhbet", "52792"), (182, "Dilnara@rambler.ru", "Dilnara", "71795"), (183, "Valery@hotmail.com", "Valery", "68730"), (184, "Gaidar@googlemail.com", "Gaidar", "74037"), (185, "Harry@ymail.com", "Harry", "82880"), (186, "Vladislav@rocketmail.com", "Vladislav", "97072"), (187, "Jamila@yahoo-inc.com", "Jamila", "43638"), (188, "Govhar@bk.ru", "Govhar", "26377"), (189, "Gayas@yahoo.com", "Gayas", "91099"), (190, "Alik@rambler.ru", "Alik", "86758"), (191, "Akaki@googlemail.com", "Akaki", "55358"), (192, "Dilara@yahoo.com", "Dilara", "39766"), (193, "Alikhan@qip.ru", "Alikhan", "55843"), (194, "Bereslav@hotmail.com", "Bereslav", "36714"), (195, "Gennady@mail.ru", "Gennady", "94014"), (196, "Gury@yandex.ru", "Gury", "64000"), (197, "Adriana@rambler.ru", "Adriana", "83299"), (198, "Dionysius@bk.ru", "Dionysius", "56962"), (199, "Gulshat@rocketmail.com", "Gulshat", "67645"), (200, "Behaved@ahoomail.com", "Behaved", "51569"), (201, "Vilora@yahoo-inc.com", "Vilora", "96193"), (202, "Watslav@msn.com", "Watslav", "70124"), (203, "Gevorg@googlemail.com", "Gevorg", "88628"), (204, "Julia@yahoo-inc.com", "Julia", "96973"), (205, "Azalea@yahoo-inc.com", "Azalea", "98253"), (206, "Alesya@googlemail.com", "Alesya", "36453"), (207, "Vyacheslav@ymail.com", "Vyacheslav", "93264"), (208, "Adam@msn.com", "Adam", "81026"), (209, "Bronislava@gmail.com", "Bronislava", "77919"), (210, "Wendy@qip.ru", "Wendy", "33977"), (211, "Alexandra@mail.ru", "Alexandra", "77508"), (212, "Walter@live.com", "Walter", "65516"), (213, "Diana@mail.ru", "Diana", "79073"), (214, "Gulnara@msn.com", "Gulnara", "28725"), (215, "Aydar@list.ru", "Aydar", "96802"), (216, "Dimitri@googlemail.com", "Dimitri", "45732"), (217, "Alfia@rocketmail.com", "Alfia", "82995"), (218, "Alexandrina@googlemail.com", "Alexandrina", "67771"), (219, "Vida@live.com", "Vida", "52823"), (220, "Vlada@inbox.ru", "Vlada", "82341"), (221, "Vladlena@yahoo-inc.com", "Vladlena", "38671"), (222, "Violetta@rocketmail.com", "Violetta", "74511"), (223, "Jennifer@gmail.com", "Jennifer", "36427"), (224, "Alima@googlemail.com", "Alima", "61377"), (225, "Joseph@hotmail.com", "Joseph", "54846"), (226, "Daniela@yahoo.com", "Daniela", "79971"), (227, "Versavia@qip.ru", "Versavia", "74904"), (228, "Guy@hotmail.com", "Guy", "65243"), (229, "Gabriele@yandex.ru", "Gabriele", "30802"), (230, "Gradimir@bk.ru", "Gradimir", "31879"), (231, "Darerka@ymail.com", "Darerka", "94772"), (232, "Benedict@msn.com", "Benedict", "41784"), (233, "Veta@bk.ru", "Veta", "22942"), (234, "Azamat@inbox.ru", "Azamat", "69628"), (235, "Bella@yahoo-inc.com", "Bella", "89624"), (236, "Demian@rambler.ru", "Demian", "94031"), (237, "Glafira@qip.ru", "Glafira", "95054"), (238, "Gorislav@msn.com", "Gorislav", "83470"), (239, "Aglaia@rambler.ru", "Aglaia", "80354"), (240, "Alain@qip.ru", "Alain", "97736"), (241, "Diodorus@aol.com", "Diodorus", "39046"), (242, "Gavril@aol.com", "Gavril", "27999"), (243, "Willy@rambler.ru", "Willy", "51736"), (244, "Vera@yandex.ru", "Vera", "35477"), (245, "Agneta@msn.com", "Agneta", "33604"), (246, "Dara@googlemail.com", "Dara", "66716"), (247, "Vasilisa@ymail.com", "Vasilisa", "87038"), (248, "Dinora@hotmail.com", "Dinora", "21451"), (249, "Virginia@gmail.com", "Virginia", "75533"), (250, "Hermann@rocketmail.com", "Hermann", "25842"), (251, "Albina@list.ru", "Albina", "21661"), (252, "Bogolyub@mail.ru", "Bogolyub", "23669"), (253, "Hera@aol.com", "Hera", "89653"), (254, "Victor@gmail.com", "Victor", "61714"), (255, "Gabriella@ymail.com", "Gabriella", "19607"), (256, "Dolores@list.ru", "Dolores", "37908"), (257, "Bogdan@yahoo-inc.com", "Bogdan", "73579"), (258, "Gaston@inbox.ru", "Gaston", "57972"), (259, "Victoria@yahoo-inc.com", "Victoria", "59241"), (260, "Augustine@yahoo.com", "Augustine", "46014"), (261, "Donald@aol.com", "Donald", "66968"), (262, "Alvian@yahoo.com", "Alvian", "33150"), (263, "Aldona@live.com", "Aldona", "47681"), (264, "Gregory@msn.com", "Gregory", "69526"), (265, "Damir@googlemail.com", "Damir", "67809"), (266, "Witold@yandex.ru", "Witold", "82506"), (267, "Auror@aol.com", "Auror", "88543"), (268, "Alexy@yahoo-inc.com", "Alexy", "22553"), (269, "Gloria@rocketmail.com", "Gloria", "76841"), (270, "Danuta@hotmail.com", "Danuta", "23666"), (271, "Hell@rocketmail.com", "Hell", "55851"), (272, "Vadim@yahoo-inc.com", "Vadim", "76901"), (273, "Alan@mail.ru", "Alan", "67094"), (274, "Agnes@live.com", "Agnes", "77111"), (275, "Bahram@ymail.com", "Bahram", "55738"), (276, "Ainagul@hotmail.com", "Ainagul", "87922"), (277, "Augusta@list.ru", "Augusta", "20335"), (278, "Beata@mail.ru", "Beata", "24253"), (279, "Volodar@mail.ru", "Volodar", "70728"), (280, "Bartholomew@inbox.ru", "Bartholomew", "83807"), (281, "Borislav@qip.ru", "Borislav", "94607"), (282, "Veselina@rambler.ru", "Veselina", "34951"), (283, "Demid@bk.ru", "Demid", "94446"), (284, "Belinda@ymail.com", "Belinda", "39542"), (285, "Vitalina@ymail.com", "Vitalina", "54773"), (286, "Davyd@mail.ru", "Davyd", "92115"), (287, "Aliko@msn.com", "Aliko", "31151"), (288, "Valentine@yahoo-inc.com", "Valentine", "24503"), (289, "Diomede@hotmail.com", "Diomede", "34113"), (290, "Dementy@googlemail.com", "Dementy", "52139"), (291, "Velor@googlemail.com", "Velor", "64587"), (292, "Aziza@yahoo.com", "Aziza", "71298"), (293, "Alois@qip.ru", "Alois", "26542"), (294, "Alla@rocketmail.com", "Alla", "91676"), (295, "Aggay@googlemail.com", "Aggay", "19664"), (296, "David@live.com", "David", "27037"), (297, "Dinah@ahoomail.com", "Dinah", "54567"), (298, "George@bk.ru", "George", "53631"), (299, "Guzel@yahoo-inc.com", "Guzel", "19626"), (300, "Virinea@qip.ru", "Virinea", "35995"), (301, "Boleslav@qip.ru", "Boleslav", "23597"), (302, "Dean@mail.ru", "Dean", "58880"), (303, "James@mail.ru", "James", "88082"), (304, "Wanda@aol.com", "Wanda", "57919"), (305, "Henry@rocketmail.com", "Henry", "67182"), (306, "Aileen@aol.com", "Aileen", "62490"), (307, "Gordon@mail.ru", "Gordon", "42213"), (308, "Agnia@yahoo.com", "Agnia", "43832"), (309, "Proud@ahoomail.com", "Proud", "53256"), (310, "Agunda@inbox.ru", "Agunda", "57503"), (311, "Donut@rocketmail.com", "Donut", "29336"), (312, "Vanessa@yahoo.com", "Vanessa", "46143"), (313, "Aaron@list.ru", "Aaron", "46085"), (314, "Abram@ahoomail.com", "Abram", "54540"), (315, "Diamond@ymail.com", "Diamond", "19672"), (316, "Henry@inbox.ru", "Henry", "48768"), (317, "Azarius@bk.ru", "Azarius", "45316"), (318, "Deborah@hotmail.com", "Deborah", "21356"), (319, "Vasilina@hotmail.com", "Vasilina", "97004"), (320, "Varvara@googlemail.com", "Varvara", "53518"), (321, "Democrat@yahoo.com", "Democrat", "46200"), (322, "Ali@live.com", "Ali", "70917"), (323, "Vasiliy@gmail.com", "Vasiliy", "88619"), (324, "Vesta@qip.ru", "Vesta", "37717"), (325, "Berek@qip.ru", "Berek", "98375"), (326, "Dahlia@live.com", "Dahlia", "32003"), (327, "Alana@qip.ru", "Alana", "44108"), (328, "Ayganim@mail.ru", "Ayganim", "76283"), (329, "Valeria@yandex.ru", "Valeria", "49003"), (330, "Adelaide@ahoomail.com", "Adelaide", "95798"), (331, "Daryana@bk.ru", "Daryana", "44602"), (332, "Gorica@list.ru", "Gorica", "59862"), (333, "Galia@inbox.ru", "Galia", "45924"), (334, "Didim@rambler.ru", "Didim", "47926"), (335, "Boreslav@rocketmail.com", "Boreslav", "59796"), (336, "Alvina@ahoomail.com", "Alvina", "60549"), (337, "Bernard@hotmail.com", "Bernard", "33031"), (338, "Vissarion@yahoo-inc.com", "Vissarion", "64733"), (339, "Waldemar@yandex.ru", "Waldemar", "69701"), (340, "Airat@bk.ru", "Airat", "55921"), (341, "Valerian@aol.com", "Valerian", "47465"), (342, "Davlat@list.ru", "Davlat", "83564"), (343, "Alexey@yahoo.com", "Alexey", "82248"), (344, "Jessica@rocketmail.com", "Jessica", "69082"), (345, "Aynur@rocketmail.com", "Aynur", "76464"), (346, "Janet@ymail.com", "Janet", "55090"), (347, "Azat@mail.ru", "Azat", "89463"), (348, "Diamond@bk.ru", "Diamond", "28935"), (349, "Daria@rambler.ru", "Daria", "89728");

drop table arusers;

CREATE TABLE arusers(
	IDU INT PRIMARY KEY,
    mail VARCHAR(128),
    LOGIN VARCHAR(128),
    pass VARCHAR(128)
);

drop trigger archive_users;

delimiter $$
create trigger archive_users before update on users
for each row
begin
	if new.mail <> old.mail then
		if old.idu in (select idu from arusers) then
			update arusers
			set arusers.mail = old.mail,
			arusers.login = old.login,
			arusers.pass = old.pass
			where old.IDU = IDU;
		else
			insert into arusers values (old.idu, old.mail, old.login, old.pass);
		end if;
	end if;
END $$
delimiter ;


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6	Для таблицы пользователей заменить пароль, который хранится в открытом виде, на тот же, но захешированный методом md5.*/
-- Решение:

select * from users;

alter table users 
modify pass char(32);
delete from arusers;
alter table arusers
modify pass char(32);

update users
set pass = md5(pass);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№7	Вывести количество и среднее значение стоимости книг, которые были просмотрены, но не разу не были куплены.*/
-- Решение:

select COUNT(*), avg(price) from books
right join BUView on BUView.IDB = books.IDB
where BUView.idb not in (select idb from bubuy);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8	Вывести количество купленных книг, а также суммарную их стоимость для тем с кодом с 1 по 6 включительно.*/
-- Решение:

select IDT, count(*), sum(price) from books
join bubuy using(IDB)
join bt using (IDB)
join theme using(IDT)
where IDT between 1 and 6
group by IDT;


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№9	Вывести Название книги, Имя автора, Логин покупателя для книг, которые были куплены в период с июня по август 2018 года включительно, написаны
 в тематике 'фэнтези' и 'классика', при условии, что число страниц должно быть от 700 до 800 включительно и цена книги меньше 500.*/
-- Решение:

select Title, NameA, login from books
join ba using(IDB)
join bubuy using (IDB)
join users using(IDU)
join bt using(IDB)
join theme using(IDT)
where theme like '%фэнтези%'  or theme like '%классика%'
and price<500
and pages between 700 and 800
and year(Datetime) = 2018
and month(Datetime) between 1 and 6 ;


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать таблицу «Авторы», где бы хранились имена авторов без повторений (Варианты Толстой Лев, Толстой Л.Н. и др. считать уникальными) и его ID. }	*/
-- Решение:

select * from ba;

create table Author
(
	IDA int auto_increment  primary key,
    authorName varchar(50)
);

insert into Author(authorName)
select distinct NameA from ba;

select * from Author;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать новую таблицу «ВА» для связи таблиц «Книги» и «Авторы» через ID, и заполнить её.}	*/
-- Решение:

create table newBA
(
	IDB int,
    IDA int,
    primary key(IDA,IDB),
    foreign key (IDB) references books(IDB),
    foreign key (IDA) references author(IDA)
);

insert into newBA
select IDB,IDA from ba
join books using (IDB)
join Author on Author.authorName = ba.NameA;

select* from newBA;

-- ----------------------------------------------------------------------------------------------------------------------------------------
