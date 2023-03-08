DROP DATABASE if exists открытия;
CREATE DATABASE открытия;
 
USE открытия;
 
CREATE TABLE Изобретатель
(
  Имя VARCHAR(20),
    Фамилия VARCHAR(20),
    Страна_рождения VARCHAR(20)
);

DROP TABLE Изобретатель;
DROP DATABASE открытия;

CREATE DATABASE открытия;
USE открытия;
CREATE TABLE  Изобретатель
(
  Имя VARCHAR(20),
    Фамилия VARCHAR(20),
    Страна_рождения VARCHAR(20)
);

CREATE TABLE Изобретение
(
Код INT primary key AUTO_INCREMENT, 
Название VARCHAR(20),
Дата_изобретения YEAR,
Описание VARCHAR(20)
);

ALTER TABLE Изобретатель
ADD код INT PRIMARY KEY AUTO_INCREMENT;

CREATE TABLE Изобретатель_изобретение
(
Код_изобретателя INT,
FOREIGN KEY (Код_изобретателя) REFERENCES Изобретатель (Код), 
Код_изобретения INT, 
FOREIGN KEY (Код_изобретения) REFERENCES Изобретение (Код)
);

ALTER TABLE Изобретатель
RENAME COLUMN Страна_рождения TO Страна;

ALTER TABLE Изобретение 
MODIFY COLUMN Описание MEDIUMTEXT;

ALTER TABLE Изобретение 
DROP COLUMN Дата_изобретения;