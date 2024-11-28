-- Drop Data Base
-- DROP DATABASE IF EXISTS dbMonjeFinanciero;

-- Crear base de datos
-- CREATE DATABASE dbMonjeFinanciero;

-- Seleccionar base de datos
-- USE dbMonjeFinanciero;

-- Crear tabla Users
CREATE TABLE Users (
    id VARCHAR(36) PRIMARY KEY,                     -- Unique identifier for the user
    name VARCHAR(100) NOT NULL,                      -- Name of the user
    email VARCHAR(100) NOT NULL UNIQUE,              -- User's email address
    password VARCHAR(255) NOT NULL,                  -- User's password (hashed)
    date_of_birth DATE NOT NULL,                     -- User's date of birth
    profile_image_url VARCHAR(255)                   -- URL of the user's profile image
);

-- Crear tabla Categories
CREATE TABLE Categories (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the category
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the category (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the category
    color VARCHAR(7) NOT NULL,                       -- Color associated with the category (e.g., HEX code)
    icon_text VARCHAR(10),                           -- Text emoji for icon category
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Crear tabla Expenses
CREATE TABLE Expenses (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the expense
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the expense (Foreign Key)
    description VARCHAR(255) NOT NULL,               -- Description of the expense
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0), -- Amount of the expense
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the expense (Foreign Key)
    date DATE NOT NULL,                              -- Date of the expense
    is_recurring BOOLEAN NOT NULL,                    -- Indicates if the expense is recurring
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE
);

-- Crear tabla Budgets
CREATE TABLE Budgets (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the budget
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the budget (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the budget
    budget_limit DECIMAL(10, 2) NOT NULL CHECK (budget_limit >= 0), -- Limit amount of the budget
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the budget (Foreign Key)
    period ENUM('weekly', 'monthly', 'yearly') NOT NULL, -- Budget period
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE
);

-- Crear tabla Reports
CREATE TABLE Reports (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the report
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the report (Foreign Key)
    start_date DATE NOT NULL,                        -- Start date of the report
    end_date DATE NOT NULL,                          -- End date of the report
    total_expenses DECIMAL(10, 2) NOT NULL,         -- Total expenses in the report
    category_breakdown JSON NOT NULL,                -- Breakdown of expenses by category (JSON type)
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Crear tabla Meta
CREATE TABLE Meta (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the meta
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the meta (Foreign Key)
    target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount >= 0), -- Target amount for savings or expenses
    achieved_amount DECIMAL(10, 2) NOT NULL CHECK (achieved_amount >= 0), -- Amount achieved towards the target
    deadline DATE NOT NULL,                          -- Deadline for achieving the target
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Crear tabla UserTokens
CREATE TABLE UserTokens (
    id VARCHAR(36) PRIMARY KEY,        -- El mismo ID del usuario
    fcm_token VARCHAR(255) NOT NULL,   -- Token FCM del usuario
    created_at TIMESTAMP DEFAULT NOW() -- Fecha de creación
);

-- Crear tabla UserSettings
CREATE TABLE UserSettings (
    user_id VARCHAR(36) NOT NULL,
    notification_frequency VARCHAR(20) DEFAULT 'Diario',
    notifications_enabled BOOLEAN DEFAULT true,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Crear tabla NotificationSettings
CREATE TABLE NotificationSettings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    notification_frequency VARCHAR(20) NOT NULL, -- "Diario", "Semanal", "Mensual"
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    last_sent DATETIME, -- Para saber cuándo fue la última vez que se envió una notificación
    FOREIGN KEY (user_id) REFERENCES Users(id) -- Asumiendo que hay una tabla de usuarios
);

-- Test Data
INSERT INTO Users (id, name, email, password, date_of_birth, profile_image_url) VALUES
('US001', 'Flavio Villanueva', 'flavio@example.com', 'lavacalola', '1990-01-01', 'https://i.pravatar.cc/300'),
('US002', 'Carlos Perez', 'carlos@example.com', 'hashedpassword2', '1992-02-02', 'https://i.pravatar.cc/300'),
('US003', 'Maria Lopez', 'maria@example.com', 'hashedpassword3', '1993-03-03', 'https://i.pravatar.cc/300'),
('US004', 'Ana Garcia', 'ana@example.com', 'hashedpassword4', '1988-04-04', 'https://i.pravatar.cc/300'),
('US005', 'Jose Martinez', 'jose@example.com', 'hashedpassword5', '1985-05-05', 'https://i.pravatar.cc/300'),
('US006', 'Laura Sanchez', 'laura@example.com', 'hashedpassword6', '1991-06-06', 'https://i.pravatar.cc/300'),
('US007', 'Ricardo Torres', 'ricardo@example.com', 'hashedpassword7', '1987-07-07', 'https://i.pravatar.cc/300'),
('US008', 'Patricia Jimenez', 'patricia@example.com', 'hashedpassword8', '1994-08-08', 'https://i.pravatar.cc/300'),
('US009', 'Luis Ramirez', 'luis@example.com', 'hashedpassword9', '1995-09-09', 'https://i.pravatar.cc/300'),
('US010', 'Sofia Gonzalez', 'sofia@example.com', 'hashedpassword10', '1996-10-10', 'https://i.pravatar.cc/300');

INSERT INTO Categories (id, user_id, name, color, icon_text) VALUES
('CT001', 'US001', 'Alimentación', '#FF5733', '🍔'),
('CT002', 'US001', 'Transporte', '#33FF57', '🚗'),
('CT003', 'US001', 'Entretenimiento', '#3357FF', '🎬'),
('CT004', 'US001', 'Salud', '#F5FF33', '💊'),
('CT005', 'US001', 'Hogar', '#FF33B5', '🏠'),
('CT006', 'US001', 'Educación', '#33FFED', '📚'),
('CT007', 'US001', 'Compras', '#B533FF', '🛍️'),
('CT008', 'US001', 'Trabajo', '#FF33A1', '💼'),
('CT009', 'US001', 'Viajes', '#FFC300', '✈️'),
('CT010', 'US001', 'Tecnología', '#C70039', '💻');

INSERT INTO Expenses (id, user_id, description, amount, category_id, date, is_recurring) VALUES
('EP001', 'US001', 'Compra de frutas', 20.00, 'CT001', '2024-01-15', FALSE),
('EP002', 'US001', 'Pasajes de bus', 5.00, 'CT002', '2024-01-16', TRUE),
('EP003', 'US001', 'Cine con amigos', 15.00, 'CT003', '2024-01-17', FALSE),
('EP004', 'US001', 'Medicinas', 30.00, 'CT004', '2024-01-18', FALSE),
('EP005', 'US001', 'Compra de muebles', 200.00, 'CT005', '2024-01-19', FALSE),
('EP006', 'US001', 'Libros de texto', 50.00, 'CT006', '2024-01-20', FALSE),
('EP007', 'US001', 'Ropa nueva', 100.00, 'CT007', '2024-01-21', TRUE),
('EP008', 'US001', 'Gastos de oficina', 75.00, 'CT008', '2024-01-22', FALSE),
('EP009', 'US001', 'Hotel durante el viaje', 300.00, 'CT009', '2024-01-23', FALSE),
('EP010', 'US001', 'Nuevo ordenador', 800.00, 'CT010', '2024-01-24', FALSE);

INSERT INTO Budgets (id, user_id, name, budget_limit, category_id, period) VALUES
('BU001', 'US001', 'Ahorros Mensuales', 500.00, 'CT001', 'monthly'),
('BU002', 'US001', 'Gastos de Comida', 300.00, 'CT002', 'monthly'),
('BU003', 'US001', 'Viajes', 1500.00, 'CT009', 'yearly'),
('BU004', 'US001', 'Educación', 600.00, 'CT006', 'monthly'),
('BU005', 'US001', 'Entretenimiento', 200.00, 'CT003', 'monthly'),
('BU006', 'US001', 'Salud', 250.00, 'CT004', 'monthly'),
('BU007', 'US001', 'Hogar', 800.00, 'CT005', 'monthly'),
('BU008', 'US001', 'Tecnología', 1200.00, 'CT010', 'yearly'),
('BU009', 'US001', 'Compras', 1000.00, 'CT007', 'yearly'),
('BU010', 'US001', 'Gastos Varios', 400.00, 'CT008', 'monthly');

INSERT INTO Reports (id, user_id, start_date, end_date, total_expenses, category_breakdown) VALUES
('RP001', 'US001', '2024-01-01', '2024-01-31', 500.00, '{"Alimentación": 200, "Transporte": 100, "Entretenimiento": 200}'),
('RP002', 'US001', '2024-02-01', '2024-02-29', 400.00, '{"Alimentación": 150, "Transporte": 150, "Entretenimiento": 100}'),
('RP003', 'US001', '2024-03-01', '2024-03-31', 800.00, '{"Alimentación": 300, "Transporte": 200, "Entretenimiento": 300}'),
('RP004', 'US001', '2024-04-01', '2024-04-30', 600.00, '{"Alimentación": 250, "Transporte": 200, "Entretenimiento": 150}'),
('RP005', 'US001', '2024-05-01', '2024-05-31', 700.00, '{"Alimentación": 300, "Transporte": 200, "Entretenimiento": 200}'),
('RP006', 'US001', '2024-06-01', '2024-06-30', 900.00, '{"Alimentación": 400, "Transporte": 300, "Entretenimiento": 200}'),
('RP007', 'US001', '2024-07-01', '2024-07-31', 300.00, '{"Alimentación": 100, "Transporte": 100, "Entretenimiento": 100}'),
('RP008', 'US001', '2024-08-01', '2024-08-31', 850.00, '{"Alimentación": 300, "Transporte": 250, "Entretenimiento": 300}'),
('RP009', 'US001', '2024-09-01', '2024-09-30', 700.00, '{"Alimentación": 350, "Transporte": 200, "Entretenimiento": 150}'),
('RP010', 'US001', '2024-10-01', '2024-10-31', 950.00, '{"Alimentación": 450, "Transporte": 350, "Entretenimiento": 150}');

INSERT INTO Meta (id, user_id, target_amount, achieved_amount, deadline) VALUES
('MT001', 'US001', 1000.00, 500.00, '2024-12-31'),
('MT002', 'US001', 1500.00, 750.00, '2025-01-31'),
('MT003', 'US001', 2000.00, 1000.00, '2025-02-28'),
('MT004', 'US001', 3000.00, 1500.00, '2025-03-31'),
('MT005', 'US001', 2500.00, 1200.00, '2025-04-30'),
('MT006', 'US001', 1800.00, 800.00, '2025-05-31'),
('MT007', 'US001', 2200.00, 1100.00, '2025-06-30'),
('MT008', 'US001', 2700.00, 1350.00, '2025-07-31'),
('MT009', 'US001', 3000.00, 1500.00, '2025-08-31'),
('MT010', 'US001', 3200.00, 1600.00, '2025-09-30');

-- Procedures
-- -- User
DELIMITER //

CREATE PROCEDURE RegisterUser(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_date_of_birth DATE,
    IN p_profile_image_url VARCHAR(255)
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Verificar si el correo electrónico ya existe
    IF EXISTS (SELECT 1 FROM Users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists.';
    END IF;

    -- Verificar si el usuario tiene al menos 18 años
    IF DATE_ADD(p_date_of_birth, INTERVAL 18 YEAR) > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User must be at least 18 years old.';
    END IF;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Users ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay usuarios, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('US', LPAD(numeric_part, 3, '0'));

    -- Insertar el nuevo usuario
    INSERT INTO Users (id, name, email, password, date_of_birth, profile_image_url) 
    VALUES (new_id, p_name, p_email, p_password, p_date_of_birth, p_profile_image_url);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetUser(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Users WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE LoginUser(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    OUT p_user_id VARCHAR(36)
)
BEGIN
    DECLARE user_count INT;

    -- Verificamos si el usuario existe y la contraseña coincide
    SELECT id INTO p_user_id FROM Users WHERE email = p_email AND password = p_password;

    IF p_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email or password.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE UpdateUser(
    IN p_id VARCHAR(36),
    IN p_name VARCHAR(100),
    IN p_profile_image_url VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE id = p_id) THEN
        UPDATE Users
        SET name = p_name,
            profile_image_url = p_profile_image_url
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteUser(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE id = p_id) THEN
        DELETE FROM Users WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;
END //

DELIMITER ;

-- -- Category
DELIMITER //

CREATE PROCEDURE InsertCategory(
    IN p_user_id VARCHAR(36),
    IN p_name VARCHAR(100),
    IN p_color VARCHAR(7),
    IN p_icon_text VARCHAR(10)
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Verificar si el nombre de la categoría ya existe para este usuario
    IF EXISTS (SELECT 1 FROM Categories WHERE name = p_name AND user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category name already exists for this user.';
    END IF;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Categories ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay categorías, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('CT', LPAD(numeric_part, 3, '0'));

    -- Insertar la nueva categoría
    INSERT INTO Categories (id, user_id, name, color, icon_text)
    VALUES (new_id, p_user_id, p_name, p_color, p_icon_text);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetCategory(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Categories WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllCategories()
BEGIN
    SELECT * FROM Categories;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllCategoriesByUser(
    IN p_user_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Categories WHERE user_id = p_user_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE UpdateCategory(
    IN p_id VARCHAR(36),
    IN p_name VARCHAR(100),
    IN p_color VARCHAR(7),
    IN p_icon_text VARCHAR(10)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Categories WHERE id = p_id) THEN
        UPDATE Categories
        SET name = p_name,
            color = p_color,
            icon_text = p_icon_text
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteCategory(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Categories WHERE id = p_id) THEN
        DELETE FROM Categories WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category not found.';
    END IF;
END //

DELIMITER ;

-- -- Expense
DELIMITER //

CREATE PROCEDURE InsertExpense(
    IN p_user_id VARCHAR(36),
    IN p_description VARCHAR(255),
    IN p_amount DECIMAL(10, 2),
    IN p_category_id VARCHAR(36),
    IN p_date DATE,
    IN p_is_recurring BOOLEAN
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Expenses ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay gastos, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('EP', LPAD(numeric_part, 3, '0'));

    -- Insertar el nuevo gasto
    INSERT INTO Expenses (id, user_id, description, amount, category_id, date, is_recurring)
    VALUES (new_id, p_user_id, p_description, p_amount, p_category_id, p_date, p_is_recurring);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetExpense(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Expenses WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllExpenses()
BEGIN
    SELECT * FROM Expenses;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllExpensesByUser(
    IN p_user_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Expenses WHERE user_id = p_user_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE UpdateExpense(
    IN p_id VARCHAR(36),
    IN p_description VARCHAR(255),
    IN p_amount DECIMAL(10, 2),
    IN p_category_id VARCHAR(36),
    IN p_date DATE,
    IN p_is_recurring BOOLEAN
)
BEGIN
    IF EXISTS (SELECT 1 FROM Expenses WHERE id = p_id) THEN
        UPDATE Expenses
        SET description = p_description,
            amount = p_amount,
            category_id = p_category_id,
            date = p_date,
            is_recurring = p_is_recurring
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expense not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteExpense(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Expenses WHERE id = p_id) THEN
        DELETE FROM Expenses WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expense not found.';
    END IF;
END //

DELIMITER ;

-- -- Budget
DELIMITER //

CREATE PROCEDURE InsertBudget(
    IN p_user_id VARCHAR(36),
    IN p_name VARCHAR(100),
    IN p_budget_limit DECIMAL(10, 2),
    IN p_category_id VARCHAR(36),
    IN p_period ENUM('weekly', 'monthly', 'yearly')
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Budgets ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay presupuestos, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('BU', LPAD(numeric_part, 3, '0'));

    -- Insertar el nuevo presupuesto
    INSERT INTO Budgets (id, user_id, name, budget_limit, category_id, period)
    VALUES (new_id, p_user_id, p_name, p_budget_limit, p_category_id, p_period);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetBudget(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Budgets WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllBudgets()
BEGIN
    SELECT * FROM Budgets;
END //

DELIMITER ;

DELIMITER //

DELIMITER //

CREATE PROCEDURE GetAllBudgetsByUser(
    IN p_user_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Budgets WHERE user_id = p_user_id;
END //

DELIMITER ;

CREATE PROCEDURE UpdateBudget(
    IN p_id VARCHAR(36),
    IN p_name VARCHAR(100),
    IN p_budget_limit DECIMAL(10, 2),
    IN p_category_id VARCHAR(36),
    IN p_period ENUM('weekly', 'monthly', 'yearly')
)
BEGIN
    IF EXISTS (SELECT 1 FROM Budgets WHERE id = p_id) THEN
        UPDATE Budgets
        SET name = p_name,
            budget_limit = p_budget_limit,
            category_id = p_category_id,
            period = p_period
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Budget not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteBudget(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Budgets WHERE id = p_id) THEN
        DELETE FROM Budgets WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Budget not found.';
    END IF;
END //

DELIMITER ;

-- -- Report
DELIMITER //

CREATE PROCEDURE InsertReport(
    IN p_user_id VARCHAR(36),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_total_expenses DECIMAL(10, 2),
    IN p_category_breakdown JSON
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Reports ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay informes, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('RP', LPAD(numeric_part, 3, '0'));

    -- Insertar el nuevo informe
    INSERT INTO Reports (id, user_id, start_date, end_date, total_expenses, category_breakdown)
    VALUES (new_id, p_user_id, p_start_date, p_end_date, p_total_expenses, p_category_breakdown);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetReport(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Reports WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllReports()
BEGIN
    SELECT * FROM Reports;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE UpdateReport(
    IN p_id VARCHAR(36),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_total_expenses DECIMAL(10, 2),
    IN p_category_breakdown JSON
)
BEGIN
    IF EXISTS (SELECT 1 FROM Reports WHERE id = p_id) THEN
        UPDATE Reports
        SET start_date = p_start_date,
            end_date = p_end_date,
            total_expenses = p_total_expenses,
            category_breakdown = p_category_breakdown
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Report not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetReportsByDateRange(
    IN p_user_id VARCHAR(36),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT * 
    FROM Reports 
    WHERE user_id = p_user_id 
    AND start_date >= p_start_date 
    AND end_date <= p_end_date;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GenerateExpenseReport(
    IN p_user_id VARCHAR(36),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        c.name AS category_name, 
        SUM(e.amount) AS total_amount
    FROM 
        Expenses e
    INNER JOIN 
        Categories c ON e.category_id = c.id
    WHERE 
        e.user_id = p_user_id 
        AND e.date BETWEEN p_start_date AND p_end_date
    GROUP BY 
        c.name;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteReport(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Reports WHERE id = p_id) THEN
        DELETE FROM Reports WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Report not found.';
    END IF;
END //

DELIMITER ;

-- -- Meta
DELIMITER //

CREATE PROCEDURE InsertMeta(
    IN p_user_id VARCHAR(36),
    IN p_target_amount DECIMAL(10, 2),
    IN p_achieved_amount DECIMAL(10, 2),
    IN p_deadline DATE
)
BEGIN
    DECLARE new_id VARCHAR(10);
    DECLARE last_id VARCHAR(10);
    DECLARE numeric_part INT;

    -- Obtener el último ID
    SELECT id INTO last_id FROM Meta ORDER BY id DESC LIMIT 1;

    -- Extraer la parte numérica y aumentar en uno
    IF last_id IS NOT NULL THEN
        SET numeric_part = CAST(SUBSTRING(last_id, 3) AS UNSIGNED) + 1;
    ELSE
        SET numeric_part = 1; -- Si no hay metas, empezar desde 1
    END IF;

    -- Formatear el nuevo ID
    SET new_id = CONCAT('MT', LPAD(numeric_part, 3, '0'));

    -- Insertar la nueva meta
    INSERT INTO Meta (id, user_id, target_amount, achieved_amount, deadline)
    VALUES (new_id, p_user_id, p_target_amount, p_achieved_amount, p_deadline);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetMeta(
    IN p_id VARCHAR(36)
)
BEGIN
    SELECT * FROM Meta WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllMeta()
BEGIN
    SELECT * FROM Meta;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE UpdateMeta(
    IN p_id VARCHAR(36),
    IN p_target_amount DECIMAL(10, 2),
    IN p_achieved_amount DECIMAL(10, 2),
    IN p_deadline DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM Meta WHERE id = p_id) THEN
        UPDATE Meta
        SET target_amount = p_target_amount,
            achieved_amount = p_achieved_amount,
            deadline = p_deadline
        WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meta not found.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DeleteMeta(
    IN p_id VARCHAR(36)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Meta WHERE id = p_id) THEN
        DELETE FROM Meta WHERE id = p_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meta not found.';
    END IF;
END //

DELIMITER ;