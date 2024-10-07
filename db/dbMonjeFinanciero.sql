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
('US001', 'Flavio Villanueva', 'flavio@example.com', 'hashedpassword1', '1990-01-01', 'https://example.com/image1.jpg'),
('US002', 'Carlos Perez', 'carlos@example.com', 'hashedpassword2', '1992-02-02', 'https://example.com/image2.jpg'),
('US003', 'Maria Lopez', 'maria@example.com', 'hashedpassword3', '1993-03-03', 'https://example.com/image3.jpg'),
('US004', 'Ana Garcia', 'ana@example.com', 'hashedpassword4', '1988-04-04', 'https://example.com/image4.jpg'),
('US005', 'Jose Martinez', 'jose@example.com', 'hashedpassword5', '1985-05-05', 'https://example.com/image5.jpg'),
('US006', 'Laura Sanchez', 'laura@example.com', 'hashedpassword6', '1991-06-06', 'https://example.com/image6.jpg'),
('US007', 'Ricardo Torres', 'ricardo@example.com', 'hashedpassword7', '1987-07-07', 'https://example.com/image7.jpg'),
('US008', 'Patricia Jimenez', 'patricia@example.com', 'hashedpassword8', '1994-08-08', 'https://example.com/image8.jpg'),
('US009', 'Luis Ramirez', 'luis@example.com', 'hashedpassword9', '1995-09-09', 'https://example.com/image9.jpg'),
('US010', 'Sofia Gonzalez', 'sofia@example.com', 'hashedpassword10', '1996-10-10', 'https://example.com/image10.jpg');

-- Crear tabla Categories
CREATE TABLE Categories (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the category
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the category (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the category
    color VARCHAR(7) NOT NULL,                       -- Color associated with the category (e.g., HEX code)
    icon_url VARCHAR(255)                            -- URL of the category icon
);

INSERT INTO Categories (id, user_id, name, color, icon_url) VALUES
('CT001', 'US001', 'Alimentación', '#FF5733', 'https://example.com/icon1.png'),
('CT002', 'US001', 'Transporte', '#33FF57', 'https://example.com/icon2.png'),
('CT003', 'US001', 'Entretenimiento', '#3357FF', 'https://example.com/icon3.png'),
('CT004', 'US001', 'Salud', '#F5FF33', 'https://example.com/icon4.png'),
('CT005', 'US001', 'Hogar', '#FF33B5', 'https://example.com/icon5.png'),
('CT006', 'US001', 'Educación', '#33FFED', 'https://example.com/icon6.png'),
('CT007', 'US001', 'Compras', '#B533FF', 'https://example.com/icon7.png'),
('CT008', 'US001', 'Trabajo', '#FF33A1', 'https://example.com/icon8.png'),
('CT009', 'US001', 'Viajes', '#FFC300', 'https://example.com/icon9.png'),
('CT010', 'US001', 'Tecnología', '#C70039', 'https://example.com/icon10.png');

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
('BU001', 'US001', 'Ahorros Mensuales', 500.00, 'CT001', 'monthly'),
('BU002', 'US001', 'Gastos de Comida', 300.00, 'CT002', 'monthly'),
('BU003', 'US001', 'Viajes', 1500.00, 'CT009', 'yearly'),
('BU004', 'US001', 'Educación', 600.00, 'CT006', 'monthly'),
('BU005', 'US001', 'Entretenimiento', 200.00, 'CT003', 'monthly'),
('BU006', 'US001', 'Salud', 250.00, 'CT004', 'monthly'),
('BU007', 'US001', 'Hogar', 800.00, 'CT005', 'monthly'),
('BU008', 'US001', 'Tecnología', 1200.00, 'CT0010', 'yearly'),
('BU009', 'US001', 'Compras', 1000.00, 'CT007', 'yearly'),
('BU010', 'US001', 'Gastos Varios', 400.00, 'CT008', 'monthly');

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