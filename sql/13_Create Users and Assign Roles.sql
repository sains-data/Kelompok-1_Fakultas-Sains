-- Membuat Login Server
CREATE LOGIN dekan_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN kaprodi_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN staff_user WITH PASSWORD = 'StrongP@ssw0rd!';

-- Mapping User ke Database & Role
CREATE USER dekan_user FOR LOGIN dekan_user;
ALTER ROLE db_executive ADD MEMBER dekan_user;

CREATE USER kaprodi_user FOR LOGIN kaprodi_user;
ALTER ROLE db_analyst ADD MEMBER kaprodi_user;

CREATE USER staff_user FOR LOGIN staff_user;
ALTER ROLE db_viewer ADD MEMBER staff_user;
GO