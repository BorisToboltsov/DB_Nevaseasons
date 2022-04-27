

DROP DATABASE IF EXISTS supplier_relations_department;
CREATE DATABASE supplier_relations_department;
USE supplier_relations_department;

DROP TABLE IF EXISTS catalog_name;
CREATE TABLE catalog_name (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Название справочников';

DROP TABLE IF EXISTS catalog_data;
CREATE TABLE catalog_data (
	id SERIAL PRIMARY KEY,
	value VARCHAR(255),
	`sequence` BIGINT UNSIGNED,
	catalog_name_id BIGINT UNSIGNED,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (catalog_name_id) REFERENCES catalog_name(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT = 'Данные справочника';	

DROP TABLE IF EXISTS registry_sending_travel_agency;
CREATE TABLE registry_sending_travel_agency (
	id SERIAL PRIMARY KEY,
	name_organization VARCHAR(255) NOT NULL COMMENT 'Название организации',
	account_number BIGINT UNSIGNED NOT NULL UNIQUE COMMENT 'Номер счета',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	KEY index_name_organization(name_organization)
) COMMENT = 'Реестр отправляющих компаний' ;

DROP TABLE IF EXISTS registry_transport_organizations;
CREATE TABLE registry_transport_organizations (
	id SERIAL PRIMARY KEY,
	name_organization VARCHAR(255) NOT NULL COMMENT 'Название организации',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	KEY index_name_organization(name_organization)
) COMMENT = 'Реестр транспортных организаций';

DROP TABLE IF EXISTS catalog_data_registry_transport_organizations;
CREATE TABLE catalog_data_registry_transport_organizations (
	catalog_data_id BIGINT UNSIGNED NOT NULL,
	registry_transport_organizations_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (catalog_data_id, registry_transport_organizations_id),
	FOREIGN KEY (catalog_data_id) REFERENCES catalog_data(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_transport_organizations_id) REFERENCES registry_transport_organizations(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Каталог дата - Реестр транспортных организаций организаций'; -- 'Автобусы', 'Флот', 'Л\А'. В разных сочетаниях

DROP TABLE IF EXISTS registry_food_organizations;
CREATE TABLE registry_food_organizations (
	id SERIAL PRIMARY KEY,
	name_organization VARCHAR(255) NOT NULL COMMENT 'Название организации',
	legal_name_organization VARCHAR(255) NOT NULL COMMENT 'Юр. название организации',
	operating_mode VARCHAR(255) COMMENT 'Режим работы', -- могут быть разные варианты (08:00 - 20:00, круглосуточно, 10:00 - 23:00 (11:00 - 23:00 выходные) и т.д.)
	сapacity SMALLINT UNSIGNED COMMENT 'Вместимость',
	capacity_comment VARCHAR(255) COMMENT 'Комментарий к вместимости',
	positive_rating TINYINT UNSIGNED COMMENT 'Положительный рейтинг',
	negative_rating TINYINT UNSIGNED COMMENT 'Отрицательный рейтинг',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	KEY index_name_organization(name_organization)
) COMMENT = 'Реестр организаций по питанию';

DROP TABLE IF EXISTS catalog_data_registry_food_organization;
CREATE TABLE catalog_data_registry_food_organization (
	catalog_data_id BIGINT UNSIGNED NOT NULL,
	registry_food_organizations_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (catalog_data_id, registry_food_organizations_id),
	FOREIGN KEY (catalog_data_id) REFERENCES catalog_data(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_food_organizations_id) REFERENCES registry_food_organizations(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Каталог дата - Реестр организаций по питанию' ; -- Варианты кухни (Европейская, Русская, Итальянская, Немецкая, Индийская, нет данных и т.д.) Могут быть в различных сочетаниях

DROP TABLE IF EXISTS registry_hotels;
CREATE TABLE registry_hotels (
	id SERIAL PRIMARY KEY,
	name_organization VARCHAR(255) NOT NULL COMMENT 'Название отеля',
	number_stars_id BIGINT UNSIGNED COMMENT 'Количество звёзд',
	location VARCHAR(255) COMMENT 'Локация',
	number_room SMALLINT UNSIGNED COMMENT 'Количество номеров',
	official_website VARCHAR(100) COMMENT 'Официальный веб сайт',
	parking VARCHAR(255) COMMENT 'Наличие и стоимость парковки', -- !!!!!!!!!!!!!!!!!!!!!
	extra_space VARCHAR(255) COMMENT 'Вожномсть до места, какое доп. место', -- !!!!!!!!!!!!!!!!!!
	early_check_in VARCHAR(255) COMMENT 'Стоимость раннего заезда',
	late_check_out VARCHAR(255) COMMENT 'Стоимость позднего выезда',
	conference_room VARCHAR(255) COMMENT 'Характеристики конференц зала + стоимость',
	children VARCHAR(255) COMMENT 'До скольки лет бесплатно дети',
	disabled_people VARCHAR(255) COMMENT 'Размещение инвалидов, количество номеров',
	animals VARCHAR(255) COMMENT 'Размещение с животными',
	restaurant VARCHAR(255) COMMENT 'Накрытие или шведский стол. Возможность заказа обедов\ужинов',
	breakfast_time VARCHAR(255) COMMENT 'Время завтраков', -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	luggage_storage VARCHAR(255) COMMENT 'Камера хранения',
	registration_fee VARCHAR(255) COMMENT 'Рег. сбор',
	`connect` VARCHAR(255) COMMENT 'Коннекты',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (number_stars_id) REFERENCES catalog_data(id) ON DELETE SET NULL ON UPDATE CASCADE, -- ('2', '3', '4', '5', 'без звезд'),
	KEY index_name_organization(name_organization),
	KEY index_number_stars_id(number_stars_id),
	KEY index_location(location)
) COMMENT = 'Реестр отелей';

DROP TABLE IF EXISTS registry_museum;
CREATE TABLE registry_museum (
	id SERIAL PRIMARY KEY,
	name_organization VARCHAR(255) NOT NULL COMMENT 'Название музея',
	online_ticket VARCHAR(255) COMMENT 'Онлайн билет',
	order_adult VARCHAR(255) COMMENT 'Взрослый наряд',
	order_school VARCHAR(255) COMMENT 'Школьный наряд',
	number_group VARCHAR(255) COMMENT 'Количество человек в группе',
	working_hours VARCHAR(255) COMMENT 'Время работы',
	weekend VARCHAR(255) COMMENT 'Выходные',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	KEY index_name_organization(name_organization)
) COMMENT = 'Реестр музеев';

DROP TABLE IF EXISTS catalog_data_registry_museum;
CREATE TABLE catalog_data_registry_museum (
	catalog_data_id BIGINT UNSIGNED NOT NULL,
	registry_museum_id BIGINT UNSIGNED NOT NULL,
	cost_tickets INT UNSIGNED,
	PRIMARY KEY (catalog_data_id, registry_museum_id),
	FOREIGN KEY (catalog_data_id) REFERENCES catalog_data(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_museum_id) REFERENCES registry_museum(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м - м связь Каталог дата - реестр музеев тип билета + цена на билет';

DROP TABLE IF EXISTS employee_data;
CREATE TABLE employee_data (
	id SERIAL PRIMARY KEY,
	fio VARCHAR(255) NOT NULL COMMENT 'ФИО',
	post_employee_id BIGINT UNSIGNED COMMENT 'Должность',
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (post_employee_id) REFERENCES catalog_data(id) ON DELETE SET NULL ON UPDATE CASCADE, -- (Гиды, менеджеры)
	KEY index_fio(fio)
) COMMENT = 'Данные сотрудников';		   

DROP TABLE IF EXISTS contact;
CREATE TABLE contact (
	id SERIAL PRIMARY KEY,
	fio VARCHAR(255) COMMENT 'ФИО контакта',
	post VARCHAR(255) COMMENT 'Должность контакта',
	organization VARCHAR(255) COMMENT 'Наименование организации',
	department VARCHAR(255) COMMENT 'Отдел',
	phone_number BIGINT UNSIGNED COMMENT 'Номер телефона',
	id_telegramm BIGINT UNSIGNED COMMENT 'id телеграмма',
	email VARCHAR(255),
	actual_address VARCHAR(255) COMMENT 'Адрес фактический',
	official_address VARCHAR(255) COMMENT 'Адрес Юридический',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Каталог контактов';

DROP TABLE IF EXISTS contact_registry_hotels;
CREATE TABLE contact_registry_hotels (
	contact_id BIGINT UNSIGNED NOT NULL,
	registry_hotels_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, registry_hotels_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_hotels_id) REFERENCES registry_hotels(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Реестр отелей';

DROP TABLE IF EXISTS contact_registry_museum;
CREATE TABLE contact_registry_museum (
	contact_id BIGINT UNSIGNED NOT NULL,
	registry_museum_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, registry_museum_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_museum_id) REFERENCES registry_museum(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Реестр музеев';

DROP TABLE IF EXISTS contact_registry_food_organizations;
CREATE TABLE contact_registry_food_organizations (
	contact_id BIGINT UNSIGNED NOT NULL,
	registry_food_organizations_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, registry_food_organizations_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_food_organizations_id) REFERENCES registry_food_organizations(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Реестр организаций по питанию';

DROP TABLE IF EXISTS contact_registry_transport_organizations;
CREATE TABLE contact_registry_transport_organizations (
	contact_id BIGINT UNSIGNED NOT NULL,
	registry_transport_organizations_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, registry_transport_organizations_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_transport_organizations_id) REFERENCES registry_transport_organizations(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Реестр транспортных организаций';

DROP TABLE IF EXISTS contact_registry_sending_travel_agency;
CREATE TABLE contact_registry_sending_travel_agency (
	contact_id BIGINT UNSIGNED NOT NULL,
	registry_sending_travel_agency_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, registry_sending_travel_agency_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (registry_sending_travel_agency_id) REFERENCES registry_sending_travel_agency(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Реестр турагенств';

DROP TABLE IF EXISTS contact_employee_data;
CREATE TABLE contact_employee_data (
	contact_id BIGINT UNSIGNED NOT NULL,
	employee_data_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (contact_id, employee_data_id),
	FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (employee_data_id) REFERENCES employee_data(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'м-м связь Контакты - Сотрудники';


DROP TABLE IF EXISTS `group`;
CREATE TABLE `group` (
	id SERIAL PRIMARY KEY,
	name_group VARCHAR (255) COMMENT 'Название группы',
	number_people INT COMMENT 'Количество человек в группе',
	school_id BIGINT UNSIGNED COMMENT 'Школьная группа',
	paid_status TINYINT UNSIGNED COMMENT 'Статус оплаты TRUE FALSE',
	registry_sending_travel_agency_id BIGINT UNSIGNED COMMENT 'Компания отправитель',
	arrival_date DATE COMMENT 'Дата прибытия',
	departure_date DATE COMMENT 'Дата отъезда',
	manager_id BIGINT UNSIGNED COMMENT 'Менеджер',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (registry_sending_travel_agency_id) REFERENCES registry_sending_travel_agency(id) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES employee_data(id) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (school_id) REFERENCES catalog_data(id),
	KEY index_name_group(name_group)
) COMMENT = 'Группа';

DROP TABLE IF EXISTS group_museum;
CREATE TABLE group_museum (
	id SERIAL PRIMARY KEY,
	group_id BIGINT UNSIGNED COMMENT 'Группа',
	guide_id BIGINT UNSIGNED COMMENT 'Гид',
	registry_museum_id BIGINT UNSIGNED COMMENT 'Музей',
	`date` DATETIME COMMENT 'Дата + время',
	comment VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (group_id) REFERENCES `group`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (guide_id) REFERENCES employee_data(id) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (registry_museum_id) REFERENCES registry_museum(id) ON DELETE SET NULL ON UPDATE CASCADE,
	KEY _index_date(`date`)
) COMMENT = 'Музеи группы';

DROP TABLE IF EXISTS group_hotel;
CREATE TABLE group_hotel (
	id SERIAL PRIMARY KEY,
	group_id BIGINT UNSIGNED COMMENT 'Группа',
	registry_hotels_id BIGINT UNSIGNED COMMENT 'Отель',
	arrival_date DATE COMMENT 'Дата заезда',
	departure_date DATE COMMENT 'Дата выезда',
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (group_id) REFERENCES `group`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (registry_hotels_id) REFERENCES registry_hotels(id) ON DELETE SET NULL ON UPDATE CASCADE,
	KEY index_arrival_date(arrival_date)
) COMMENT = 'Отели группы';

DROP TABLE IF EXISTS group_transport;
CREATE TABLE group_transport (
	id SERIAL PRIMARY KEY,
	group_id BIGINT UNSIGNED COMMENT 'Группа',
	registry_transport_organizations_id BIGINT UNSIGNED COMMENT 'Транспортная организация',
	type_tk_id BIGINT UNSIGNED COMMENT 'Тип транспорта',
	submission_address VARCHAR (255) COMMENT 'Адрес подачи',
	submission_time DATETIME COMMENT 'Дата время подачи',
	completion_address VARCHAR (255) COMMENT 'Адрес завершения',
	completion_time DATETIME COMMENT 'Дата + время завершения',
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (group_id) REFERENCES `group`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (registry_transport_organizations_id) REFERENCES registry_transport_organizations(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (type_tk_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	KEY index_submission_address(submission_address)
) COMMENT = 'Транспорт группы';

DROP TABLE IF EXISTS group_food;
CREATE TABLE group_food (
	id SERIAL PRIMARY KEY,
	group_id BIGINT UNSIGNED COMMENT 'Группа',
	`date` DATETIME COMMENT 'Дата + время',
	registry_food_organizations_id BIGINT UNSIGNED COMMENT 'Организация по питанию',
	type_meal_id BIGINT UNSIGNED COMMENT 'Тип приема пищи', -- Завтра обед ужин
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (group_id) REFERENCES `group`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (registry_food_organizations_id) REFERENCES registry_food_organizations(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (type_meal_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	KEY index_date(`date`)
) COMMENT = 'Питание группы';
