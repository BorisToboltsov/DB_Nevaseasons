-- 6, 7, 8 задание

USE supplier_relations_department;

/*
6. Скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);

6.1 График загрузки отелей в этом месяце
*/

SELECT rh.name_organization as 'Отель', gh.arrival_date as 'Дата заезда', gh.departure_date 'Дата выезда', g.name_group 'Группа', g.number_people 'Количество человек'
FROM group_hotel gh
JOIN registry_hotels rh ON rh.id = gh.registry_hotels_id 
JOIN `group` g ON g.id = gh.group_id
WHERE SUBSTRING(gh.arrival_date, 6, 2) = MONTH(CURRENT_TIMESTAMP())
ORDER BY gh.arrival_date, rh.name_organization;


/*
6.2 Пять самых популярных организаций по питанию у групп в текущем месяце
*/

SELECT rfo.name_organization as 'Название организации', COUNT(*) as 'Количество групп'
FROM group_food gf
JOIN registry_food_organizations rfo ON rfo.id = gf.registry_food_organizations_id 
WHERE SUBSTRING(gf.`date`, 6, 2) = MONTH(CURRENT_TIMESTAMP())
GROUP BY gf.registry_food_organizations_id
ORDER BY COUNT(*) DESC
LIMIT 5;



/*
6.3 Посчитать количество групп состоящих из школьников или взрослых за текущий месяц
*/

SELECT cd.value as 'Группы', COUNT(*) as 'Количество' 
FROM `group` g
JOIN catalog_data cd ON cd.id = g.school_id
WHERE SUBSTRING(g.arrival_date, 6, 2) = MONTH(CURRENT_TIMESTAMP())
GROUP BY g.school_id;

/*
6.4 Какое количество автобусов и микроавтобусов использовали группы в текущем месяце
*/

SELECT cd.value as 'Тип транспорта', COUNT(*) as 'Количество'
FROM group_transport gt 
JOIN catalog_data cd ON cd.id = gt.type_tk_id 
WHERE (cd.value = 'Автобусы' OR cd.value = 'Микроавтобусы') AND SUBSTRING(gt.submission_time, 6, 2) = MONTH(CURRENT_TIMESTAMP())
GROUP BY gt.type_tk_id;

 
/*
6.5 График загрузки гидов за месяц, применил LEFT JOIN потому что гид может быть не назначен группе
*/

SELECT ed.fio as 'Гид', gm.`date` as 'Дата', rm.name_organization as 'Музей', g.name_group as 'Группа'
FROM group_museum gm 
LEFT JOIN employee_data ed ON ed.id = gm.guide_id
LEFT JOIN `group` g ON g.id = gm.group_id
LEFT JOIN registry_museum rm ON rm.id = gm.registry_museum_id
WHERE SUBSTRING(gm.`date`, 6, 2) = MONTH(CURRENT_TIMESTAMP())
ORDER BY ed.fio, gm.`date`;

/*
6.6 Количество групп у менеджеров за текущий год
*/

SELECT ed.fio as 'Менеджер', COUNT(*) as 'Количество групп'
FROM `group`g
JOIN employee_data ed ON ed.id = g.manager_id
WHERE SUBSTRING(g.arrival_date, 1, 4) = YEAR(CURRENT_TIMESTAMP())
GROUP BY ed.fio;



/*
7. Представления (минимум 2);

7.1 Сводная таблица посещения музеев группами за текущий месяц. (Какие группы в какое время идут в музеи в текущем месяце)
*/
CREATE OR REPLACE VIEW v_summary_museum (museum, `group`, `date`)
AS SELECT rm.name_organization, g.name_group, gm.`date`
FROM registry_museum rm
JOIN group_museum gm ON gm.registry_museum_id = rm.id
JOIN `group` g ON g.id = gm.group_id
WHERE SUBSTRING(gm.`date`, 6, 2) = MONTH(CURRENT_TIMESTAMP())
ORDER BY `date`, name_organization;

SELECT museum as Музей, `group` as Группа, `date` as Дата FROM v_summary_museum


/*
7.2 Контакты организаций по питанию, применил LEFT JOIN если вдруг контактов не будет.
*/
CREATE OR REPLACE VIEW v_food_organization_contact (name_organization, fio, post, phone_number, email)
AS SELECT rfo.name_organization, c.fio, c.post, c.phone_number, c.email 
FROM registry_food_organizations rfo 
LEFT JOIN contact_registry_food_organizations crfo ON crfo.registry_food_organizations_id = rfo.id 
LEFT JOIN contact c ON c.id = crfo.contact_id
ORDER BY rfo.name_organization;

SELECT name_organization as 'Название организации', fio as 'ФИО', post as 'Должность', phone_number as 'Номер телефона', email FROM v_food_organization_contact


/*
8. Хранимые процедуры / триггеры;

Триггер
8.1 Дата заезда не может быть позже даты выезда
*/
DROP TRIGGER IF EXISTS check_value_arrival_date;
DELIMITER //
CREATE TRIGGER check_value_arrival_date
BEFORE INSERT 
ON `group` FOR EACH ROW
BEGIN
	IF NEW.departure_date < NEW.arrival_date THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя присвоить дату заезда меньше даты выезда';
	END IF;
END//
DELIMITER ;

-- Пример с датой заезда позже даты выезда
INSERT INTO `group` (name_group, number_people, school_id, paid_status, registry_sending_travel_agency_id, arrival_date, departure_date, manager_id) VALUES
	('Группа 11', 17, 31, 1, 1, '2021-07-25', '2021-07-24', 1);




/*
Триггер
8.2 Нельзя поставить группе в которой больше 18 человек тип транспорта микроавтобус
*/

DROP TRIGGER IF EXISTS check_number_people_type_tk;
DELIMITER //
CREATE TRIGGER check_number_people_type_tk
BEFORE INSERT
ON group_transport FOR EACH ROW
BEGIN
	SET @number_people = (SELECT g.number_people FROM `group` g WHERE g.id = NEW.group_id);

	IF NEW.type_tk_id = 2 AND @number_people > 18 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя присвоить тип транспорта микроавтобус т.к. количество человек в группе больше 18';
	END IF;
END//
DELIMITER ;

-- Пример добавление с количеством человек 17 и типом транспорта микроавтобус
INSERT INTO `group` (name_group, number_people, school_id, paid_status, registry_sending_travel_agency_id, arrival_date, departure_date, manager_id) VALUES
	('Группа 11', 17, 31, 1, 1, '2021-07-17', '2021-07-24', 1);
INSERT INTO group_transport (group_id, registry_transport_organizations_id, type_tk_id, submission_address, submission_time, completion_address, completion_time) 
VALUES
	(11, 1, 2, 'Заневский проспект д.4', '2021-07-17 08:00:00', 'Невский проспект д.1', '2021-07-17 22:00:00');

-- Пример добавление с количеством человек 35 и типом транспорта микроавтобус
INSERT INTO `group` (name_group, number_people, school_id, paid_status, registry_sending_travel_agency_id, arrival_date, departure_date, manager_id) VALUES
	('Группа 12', 35, 31, 1, 1, '2021-07-17', '2021-07-24', 1);
INSERT INTO group_transport (group_id, registry_transport_organizations_id, type_tk_id, submission_address, submission_time, completion_address, completion_time) 
VALUES
	(12, 1, 2, 'Заневский проспект д.4', '2021-07-17 08:00:00', 'Невский проспект д.1', '2021-07-17 22:00:00');




/*
Хранимая процедура
8.3 Какое процентное соотношение у транспортных компаний в этом мясяце
*/
DROP PROCEDURE IF EXISTS sp_transport_percent;
DELIMITER //
CREATE PROCEDURE sp_transport_percent()
BEGIN
SET @col = 
(SELECT COUNT(*) 
FROM 
	(SELECT registry_transport_organizations_id
	FROM group_transport gt 
	WHERE SUBSTRING(gt.submission_time, 6, 2) = MONTH(CURRENT_TIMESTAMP())
	GROUP BY registry_transport_organizations_id) as new_table);

SELECT rto.name_organization as 'Транспортная организация', CONCAT(ROUND((COUNT(*) / @col) * 100), '%') as 'Процентное соотношение'
FROM registry_transport_organizations rto 
JOIN group_transport gt ON gt.registry_transport_organizations_id = rto.id
WHERE SUBSTRING(gt.submission_time , 6, 2) = MONTH(CURRENT_TIMESTAMP())
GROUP BY rto.name_organization;
END//
DELIMITER ;

CALL sp_transport_percent();



/*
Хранимая процедура
8.4 Программа группы на день
*/

DROP PROCEDURE IF EXISTS sp_group_program_day;
DELIMITER //
CREATE PROCEDURE sp_group_program_day(IN group_id BIGINT UNSIGNED, date_group DATE)
BEGIN
	SET @x = group_id;
	SET @y = date_group;
	SELECT name_group as 'Группа', name_organization as 'Название организации', submission_time as 'Дата'
	FROM (
		SELECT g.name_group, rto.name_organization, gt.submission_time
		FROM `group` g
		JOIN group_transport gt ON gt.group_id = g.id
		JOIN registry_transport_organizations rto ON rto.id = gt.registry_transport_organizations_id
		WHERE @y = SUBSTRING(gt.submission_time, 1, 10) AND @x = g.id
		UNION
		SELECT g.name_group, rfo.name_organization, gf.`date`
		FROM `group` g
		JOIN group_food gf ON gf.group_id = g.id
		JOIN registry_food_organizations rfo ON rfo.id = gf.registry_food_organizations_id 
		WHERE @y = SUBSTRING(gf.`date`, 1, 10) AND @x = g.id
		UNION 
		SELECT g.name_group, rm.name_organization, gm.`date`
		FROM `group` g
		JOIN group_museum gm ON gm.group_id = g.id 
		JOIN registry_museum rm ON rm.id = gm.registry_museum_id
		WHERE @y = SUBSTRING(gm.`date`, 1, 10) AND @x = g.id
		UNION 
		SELECT g.name_group, rh.name_organization, @y
		FROM `group` g
		JOIN group_hotel gh ON gh.group_id = g.id
		JOIN registry_hotels rh ON rh.id = gh.registry_hotels_id
		WHERE (@y BETWEEN gh.arrival_date AND gh.departure_date) AND @x = g.id) as new_table
	ORDER BY submission_time;
END//
DELIMITER ;

CALL sp_group_program_day(10, '2021-06-18');

CALL sp_group_program_day(10, '2021-06-19');

CALL sp_group_program_day(6, '2021-06-10');
