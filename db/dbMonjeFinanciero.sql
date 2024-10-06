-- Crear base de datos
CREATE DATABASE dbMonjeFinanciero;

-- Seleccionar base de datos
USE dbMonjeFinanciero;

-- Crear tabla Users
CREATE TABLE Users (
    id VARCHAR(36) PRIMARY KEY,                     -- Unique identifier for the user
    name VARCHAR(100) NOT NULL,                      -- Name of the user
    email VARCHAR(100) NOT NULL UNIQUE,              -- User's email address
    password VARCHAR(255) NOT NULL,                  -- User's password (hashed)
    date_of_birth DATE NOT NULL,                     -- User's date of birth
    profile_image_url VARCHAR(255)                   -- URL of the user's profile image
);

INSERT INTO Users (id, name, email, password, date_of_birth, profile_image_url) VALUES
('1', 'Flavio Villanueva', 'flavio@example.com', 'hashedpassword1', '1990-01-01', 'https://example.com/image1.jpg'),
('2', 'Carlos Perez', 'carlos@example.com', 'hashedpassword2', '1992-02-02', 'https://example.com/image2.jpg'),
('3', 'Maria Lopez', 'maria@example.com', 'hashedpassword3', '1993-03-03', 'https://example.com/image3.jpg'),
('4', 'Ana Garcia', 'ana@example.com', 'hashedpassword4', '1988-04-04', 'https://example.com/image4.jpg'),
('5', 'Jose Martinez', 'jose@example.com', 'hashedpassword5', '1985-05-05', 'https://example.com/image5.jpg'),
('6', 'Laura Sanchez', 'laura@example.com', 'hashedpassword6', '1991-06-06', 'https://example.com/image6.jpg'),
('7', 'Ricardo Torres', 'ricardo@example.com', 'hashedpassword7', '1987-07-07', 'https://example.com/image7.jpg'),
('8', 'Patricia Jimenez', 'patricia@example.com', 'hashedpassword8', '1994-08-08', 'https://example.com/image8.jpg'),
('9', 'Luis Ramirez', 'luis@example.com', 'hashedpassword9', '1995-09-09', 'https://example.com/image9.jpg'),
('10', 'Sofia Gonzalez', 'sofia@example.com', 'hashedpassword10', '1996-10-10', 'https://example.com/image10.jpg');

-- Crear tabla Categories
CREATE TABLE Categories (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the category
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the category (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the category
    color VARCHAR(7) NOT NULL,                       -- Color associated with the category (e.g., HEX code)
    icon_url VARCHAR(255)                            -- URL of the category icon
);

INSERT INTO Categories (id, user_id, name, color, icon_url) VALUES
('1', '1', 'Alimentación', '#FF5733', 'https://example.com/icon1.png'),
('2', '1', 'Transporte', '#33FF57', 'https://example.com/icon2.png'),
('3', '1', 'Entretenimiento', '#3357FF', 'https://example.com/icon3.png'),
('4', '1', 'Salud', '#F5FF33', 'https://example.com/icon4.png'),
('5', '1', 'Hogar', '#FF33B5', 'https://example.com/icon5.png'),
('6', '1', 'Educación', '#33FFED', 'https://example.com/icon6.png'),
('7', '1', 'Compras', '#B533FF', 'https://example.com/icon7.png'),
('8', '1', 'Trabajo', '#FF33A1', 'https://example.com/icon8.png'),
('9', '1', 'Viajes', '#FFC300', 'https://example.com/icon9.png'),
('10', '1', 'Tecnología', '#C70039', 'https://example.com/icon10.png');

-- Crear tabla Expenses
CREATE TABLE Expenses (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the expense
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the expense (Foreign Key)
    description VARCHAR(255) NOT NULL,               -- Description of the expense
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0), -- Amount of the expense
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the expense (Foreign Key)
    date DATE NOT NULL,                              -- Date of the expense
    is_recurring BOOLEAN NOT NULL,                    -- Indicates if the expense is recurring
    FOREIGN KEY (user_id) REFERENCES Users(id),     -- Foreign key constraint
    FOREIGN KEY (category_id) REFERENCES Categories(id)  -- Foreign key constraint
);

INSERT INTO Expenses (id, user_id, description, amount, category_id, date, is_recurring) VALUES
('1', '1', 'Compra de frutas', 20.00, '1', '2024-01-15', FALSE),
('2', '1', 'Pasajes de bus', 5.00, '2', '2024-01-16', TRUE),
('3', '1', 'Cine con amigos', 15.00, '3', '2024-01-17', FALSE),
('4', '1', 'Medicinas', 30.00, '4', '2024-01-18', FALSE),
('5', '1', 'Compra de muebles', 200.00, '5', '2024-01-19', FALSE),
('6', '1', 'Libros de texto', 50.00, '6', '2024-01-20', FALSE),
('7', '1', 'Ropa nueva', 100.00, '7', '2024-01-21', TRUE),
('8', '1', 'Gastos de oficina', 75.00, '8', '2024-01-22', FALSE),
('9', '1', 'Hotel durante el viaje', 300.00, '9', '2024-01-23', FALSE),
('10', '1', 'Nuevo ordenador', 800.00, '10', '2024-01-24', FALSE);

-- Crear tabla Budgets
CREATE TABLE Budgets (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the budget
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the budget (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the budget
    budget_limit DECIMAL(10, 2) NOT NULL CHECK (budget_limit >= 0), -- Limit amount of the budget
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the budget (Foreign Key)
    period ENUM('weekly', 'monthly', 'yearly') NOT NULL, -- Budget period
    FOREIGN KEY (user_id) REFERENCES Users(id),     -- Foreign key constraint
    FOREIGN KEY (category_id) REFERENCES Categories(id)  -- Foreign key constraint
);

INSERT INTO Budgets (id, user_id, name, budget_limit, category_id, period) VALUES
('1', '1', 'Ahorros Mensuales', 500.00, '1', 'monthly'),
('2', '1', 'Gastos de Comida', 300.00, '2', 'monthly'),
('3', '1', 'Viajes', 1500.00, '9', 'yearly'),
('4', '1', 'Educación', 600.00, '6', 'monthly'),
('5', '1', 'Entretenimiento', 200.00, '3', 'monthly'),
('6', '1', 'Salud', 250.00, '4', 'monthly'),
('7', '1', 'Hogar', 800.00, '5', 'monthly'),
('8', '1', 'Tecnología', 1200.00, '10', 'yearly'),
('9', '1', 'Compras', 1000.00, '7', 'yearly'),
('10', '1', 'Gastos Varios', 400.00, '8', 'monthly');

-- Crear tabla Reports
CREATE TABLE Reports (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the report
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the report (Foreign Key)
    start_date DATE NOT NULL,                        -- Start date of the report
    end_date DATE NOT NULL,                          -- End date of the report
    total_expenses DECIMAL(10, 2) NOT NULL,         -- Total expenses in the report
    category_breakdown JSON NOT NULL,                -- Breakdown of expenses by category (JSON type)
    FOREIGN KEY (user_id) REFERENCES Users(id)      -- Foreign key constraint
);

INSERT INTO Reports (id, user_id, start_date, end_date, total_expenses, category_breakdown) VALUES
('1', '1', '2024-01-01', '2024-01-31', 500.00, '{"Alimentación": 200, "Transporte": 100, "Entretenimiento": 200}'),
('2', '1', '2024-02-01', '2024-02-29', 400.00, '{"Alimentación": 150, "Transporte": 150, "Entretenimiento": 100}'),
('3', '1', '2024-03-01', '2024-03-31', 800.00, '{"Alimentación": 300, "Transporte": 200, "Entretenimiento": 300}'),
('4', '1', '2024-04-01', '2024-04-30', 600.00, '{"Alimentación": 250, "Transporte": 200, "Entretenimiento": 150}'),
('5', '1', '2024-05-01', '2024-05-31', 700.00, '{"Alimentación": 300, "Transporte": 200, "Entretenimiento": 200}'),
('6', '1', '2024-06-01', '2024-06-30', 900.00, '{"Alimentación": 400, "Transporte": 300, "Entretenimiento": 200}'),
('7', '1', '2024-07-01', '2024-07-31', 300.00, '{"Alimentación": 100, "Transporte": 100, "Entretenimiento": 100}'),
('8', '1', '2024-08-01', '2024-08-31', 850.00, '{"Alimentación": 300, "Transporte": 250, "Entretenimiento": 300}'),
('9', '1', '2024-09-01', '2024-09-30', 700.00, '{"Alimentación": 350, "Transporte": 200, "Entretenimiento": 150}'),
('10', '1', '2024-10-01', '2024-10-31', 950.00, '{"Alimentación": 450, "Transporte": 350, "Entretenimiento": 150}');

-- Crear tabla Meta
CREATE TABLE Meta (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the meta
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the meta (Foreign Key)
    target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount >= 0), -- Target amount for savings or expenses
    achieved_amount DECIMAL(10, 2) NOT NULL CHECK (achieved_amount >= 0), -- Amount achieved towards the target
    deadline DATE NOT NULL,                          -- Deadline for achieving the target
    FOREIGN KEY (user_id) REFERENCES Users(id)      -- Foreign key constraint
);

INSERT INTO Meta (id, user_id, target_amount, achieved_amount, deadline) VALUES
('1', '1', 1000.00, 500.00, '2024-12-31'),
('2', '1', 1500.00, 750.00, '2025-01-31'),
('3', '1', 2000.00, 1000.00, '2025-02-28'),
('4', '1', 3000.00, 1500.00, '2025-03-31'),
('5', '1', 2500.00, 1200.00, '2025-04-30'),
('6', '1', 1800.00, 800.00, '2025-05-31'),
('7', '1', 2200.00, 1100.00, '2025-06-30'),
('8', '1', 2700.00, 1350.00, '2025-07-31'),
('9', '1', 3000.00, 1500.00, '2025-08-31'),
('10', '1', 3200.00, 1600.00, '2025-09-30');