
USE gametest;

-- 1. 테이블 생성
CREATE TABLE IF NOT EXISTS `players` (
    `player_id` INT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL DEFAULT '0',
    `email` VARCHAR(50) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    `last_login` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`player_id`),
    UNIQUE INDEX `username` (`username`),
    UNIQUE INDEX `email` (`email`)
)
COLLATE='utf8mb4_0900_ai_ci';


-- 2. 플레이어 데이터 삽입
INSERT IGNORE INTO players(username, email, password_hash)
VALUES ('hero123', 'hero123@gmail.com', 'hashed_password1');

SELECT * FROM `gametest`.`players` LIMIT 1000;


-- 3. 여러 개 플레이어 데이터 삽입
INSERT IGNORE INTO players(username, email, password_hash) VALUES
('hero423', 'hero323@gmail.com', 'hashed_password3'),
('hero523', 'hero423@gmail.com', 'hashed_password4'),
('hero623', 'hero523@gmail.com', 'hashed_password5'),
('hero723', 'hero623@gmail.com', 'hashed_password6'),
('hero823', 'hero723@gmail.com', 'hashed_password7');


-- 4. 유저 이름 기준으로 최근 로그인 여부 확인
SELECT username, last_login FROM players;


-- 5. 특정 플레이어의 정보 업데이트
UPDATE players
SET last_login = CURRENT_TIMESTAMP
WHERE username = 'hero123';


-- 6. 조건에 맞는 플레이어 검색
SELECT username, email
FROM players
WHERE username LIKE '%hero%';


-- 7. 플레이어 삭제
DELETE FROM players WHERE username = 'hero123';

SELECT * FROM `gametest`.`players` LIMIT 1000;


-- 8. 플레이어 테이블에 새 열 추가
-- level 열이 이미 있다면 추가하지 않음
SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE players ADD COLUMN `level` INT DEFAULT 1',
        'SELECT ''level already exists'' AS message'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'players'
    AND COLUMN_NAME = 'level'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- 9. 모든 플레이어의 레벨을 1 증가
UPDATE players SET `level` = `level` + 1;


-- 10. 가장 level이 높은 플레이어 조회하기
SELECT username, `level`
FROM players
ORDER BY `level` DESC LIMIT 1;


-- 아이템 설계 및 제작
CREATE TABLE IF NOT EXISTS items(
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    VALUE INT DEFAULT 0
);


-- 아이템 데이터 삽입
INSERT INTO items(NAME, DESCRIPTION, VALUE)
SELECT '검', '기 본 무 기', 10
WHERE NOT EXISTS (
    SELECT 1 FROM items WHERE NAME = '검'
);

INSERT INTO items(NAME, DESCRIPTION, VALUE)
SELECT '방 패', '기 본 방 어 구', 15
WHERE NOT EXISTS (
    SELECT 1 FROM items WHERE NAME = '방 패'
);

INSERT INTO items(NAME, DESCRIPTION, VALUE)
SELECT '물 약', '체 력 을 회 복', 5
WHERE NOT EXISTS (
    SELECT 1 FROM items WHERE NAME = '물 약'
);


SELECT * FROM items;


-- 플레이어 인벤토리 테이블 생성
CREATE TABLE IF NOT EXISTS inventories(
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    item_id INT,
    quantity INT DEFAULT 1,
    FOREIGN KEY(player_id) REFERENCES players(player_id),
    FOREIGN KEY(item_id) REFERENCES items(item_id)
);


-- 인벤토리에 아이템 추가
-- hero823 플레이어에게 검 1개
INSERT INTO inventories(player_id, item_id, quantity)
SELECT p.player_id, i.item_id, 1
FROM players p
JOIN items i ON i.item_id = (
    SELECT MIN(item_id) FROM items WHERE NAME = '검'
)
WHERE p.username = 'hero823'
AND NOT EXISTS (
    SELECT 1 FROM inventories inv
    WHERE inv.player_id = p.player_id
    AND inv.item_id = i.item_id
);


-- hero623 플레이어에게 방패 5개
INSERT INTO inventories(player_id, item_id, quantity)
SELECT p.player_id, i.item_id, 5
FROM players p
JOIN items i ON i.item_id = (
    SELECT MIN(item_id) FROM items WHERE NAME = '방 패'
)
WHERE p.username = 'hero623'
AND NOT EXISTS (
    SELECT 1 FROM inventories inv
    WHERE inv.player_id = p.player_id
    AND inv.item_id = i.item_id
);


-- hero723 플레이어에게 물약 2개
INSERT INTO inventories(player_id, item_id, quantity)
SELECT p.player_id, i.item_id, 2
FROM players p
JOIN items i ON i.item_id = (
    SELECT MIN(item_id) FROM items WHERE NAME = '물 약'
)
WHERE p.username = 'hero723'
AND NOT EXISTS (
    SELECT 1 FROM inventories inv
    WHERE inv.player_id = p.player_id
    AND inv.item_id = i.item_id
);


-- 플레이어의 인벤토리 조회
SELECT p.username, i.name, inv.quantity
FROM players p
JOIN inventories inv ON p.player_id = inv.player_id
JOIN items i ON inv.item_id = i.item_id;


-- 새로운 아이템 추가
INSERT INTO items(NAME, DESCRIPTION, VALUE)
SELECT '용 검', '용 기 본 무 기', 20
WHERE NOT EXISTS (
    SELECT 1 FROM items WHERE TRIM(NAME) = '용 검'
);


-- 특정 플레이어의 인벤토리에 새 아이템 추가
INSERT INTO inventories(player_id, item_id, quantity)
SELECT p.player_id, i.item_id, 2
FROM players p
JOIN items i ON i.item_id = (
    SELECT MIN(item_id) FROM items WHERE TRIM(NAME) = '용 검'
)
WHERE p.username = 'hero723'
AND NOT EXISTS (
    SELECT 1 FROM inventories inv
    WHERE inv.player_id = p.player_id
    AND inv.item_id = i.item_id
);


-- 가장 가치 있는 아이템 찾기 (ORDER BY value DESC)
SELECT NAME, VALUE
FROM items
ORDER BY VALUE DESC LIMIT 1;


-- 퀘스트 테이블 생성
CREATE TABLE IF NOT EXISTS quests(
    quest_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    reward_exp INT DEFAULT 0,
    reward_item_id INT,
    FOREIGN KEY (reward_item_id) REFERENCES items(item_id)
);


-- 퀘스트 데이터 삽입
INSERT INTO quests(title, DESCRIPTION, reward_exp, reward_item_id)
SELECT '초보자 퀘스트', '첫번째 퀘스트를 완료 하세요',
       100, (SELECT MIN(item_id) FROM items WHERE NAME = '물 약')
WHERE NOT EXISTS (
    SELECT 1 FROM quests WHERE title = '초보자 퀘스트'
);

INSERT INTO quests(title, DESCRIPTION, reward_exp, reward_item_id)
SELECT '용사의 검', '전설의 검을 찾아보세요',
       500, (SELECT MIN(item_id) FROM items WHERE NAME = '검')
WHERE NOT EXISTS (
    SELECT 1 FROM quests WHERE title = '용사의 검'
);


-- 플레이어 퀘스트 진행 상황 테이블
CREATE TABLE IF NOT EXISTS player_quests(
    player_id INT,
    quest_id INT,
    STATUS ENUM ('시 작 ', '진 행 중 ', '완 료 ') DEFAULT '시 작 ',
    start_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    completed_at TIMESTAMP NULL,
    PRIMARY KEY (player_id, quest_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (quest_id) REFERENCES quests(quest_id)
);


-- 플레이어에게 퀘스트 할당
-- hero623 플레이어에게 1번 퀘스트
INSERT IGNORE INTO player_quests(player_id, quest_id)
SELECT p.player_id, q.quest_id
FROM players p
JOIN quests q ON q.title = '초보자 퀘스트'
WHERE p.username = 'hero623';


-- hero723 플레이어에게 2번 퀘스트
INSERT IGNORE INTO player_quests(player_id, quest_id)
SELECT p.player_id, q.quest_id
FROM players p
JOIN quests q ON q.title = '용사의 검'
WHERE p.username = 'hero723';


-- 진행 중인 퀘스트 조회
SELECT p.username, q.title, pq.STATUS
FROM players p
JOIN player_quests pq ON p.player_id = pq.player_id
JOIN quests q ON pq.quest_id = q.quest_id
WHERE pq.STATUS != '완 료 ';


-- 전체 테이블 확인
SHOW TABLES;


-- 전체 플레이어 확인
SELECT * FROM players;


-- 전체 아이템 확인
SELECT * FROM items;


-- 전체 인벤토리 확인
SELECT * FROM inventories;


-- 전체 퀘스트 확인
SELECT * FROM quests;



-- 플레이어 인벤토리 조회
SELECT inv.item_id, inv.quantity
FROM inventories inv
JOIN items i ON inv.item_id = i.item_id
WHERE inv.player_id = 6;

-- 플레이어 퀘스트 조회
SELECT q.*, pq.`STATUS`
FROM player_quests pq
JOIN quests q ON pq.quest_id = q.quest_id
WHERE pq.player_id = 4;

