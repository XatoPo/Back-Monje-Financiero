-- Crear base de datos
CREATE DATABASE dbMonjeFinanciero;

-- Seleccionar base de datos
USE dbMonjeFinanciero;

-- Crear tabla
CREATE TABLE Users (
    id VARCHAR(36) PRIMARY KEY,                     -- Unique identifier for the user (UUID)
    name VARCHAR(100) NOT NULL,                      -- Name of the user
    email VARCHAR(100) NOT NULL UNIQUE,              -- User's email address
    password VARCHAR(255) NOT NULL,                  -- User's password (hashed)
    date_of_birth DATE NOT NULL,                     -- User's date of birth
    profile_image_url VARCHAR(255)                   -- URL of the user's profile image
);

CREATE INDEX idx_user_email ON Users(email);

CREATE TABLE Categories (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the category (UUID)
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the category (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the category
    color VARCHAR(7) NOT NULL,                       -- Color associated with the category (e.g., HEX code)
    icon_url VARCHAR(255)                            -- URL of the category icon
);

CREATE TABLE Expenses (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the expense (UUID)
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the expense (Foreign Key)
    description VARCHAR(255) NOT NULL,               -- Description of the expense
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0), -- Amount of the expense
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the expense (Foreign Key)
    date DATE NOT NULL,                              -- Date of the expense
    is_recurring BOOLEAN NOT NULL,                    -- Indicates if the expense is recurring
    FOREIGN KEY (user_id) REFERENCES Users(id),     -- Foreign key constraint
    FOREIGN KEY (category_id) REFERENCES Categories(id)  -- Foreign key constraint
);

CREATE INDEX idx_expenses_category ON Expenses(category_id);

CREATE TABLE Budgets (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the budget (UUID)
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the budget (Foreign Key)
    name VARCHAR(100) NOT NULL,                      -- Name of the budget
    budget_limit DECIMAL(10, 2) NOT NULL CHECK (budget_limit >= 0), -- Limit amount of the budget
    category_id VARCHAR(36) NOT NULL,                -- Category ID associated with the budget (Foreign Key)
    period ENUM('weekly', 'monthly', 'yearly') NOT NULL, -- Budget period
    FOREIGN KEY (user_id) REFERENCES Users(id),     -- Foreign key constraint
    FOREIGN KEY (category_id) REFERENCES Categories(id)  -- Foreign key constraint
);

CREATE INDEX idx_budgets_category ON Budgets(category_id);

CREATE TABLE Reports (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the report (UUID)
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the report (Foreign Key)
    start_date DATE NOT NULL,                        -- Start date of the report
    end_date DATE NOT NULL,                          -- End date of the report
    total_expenses DECIMAL(10, 2) NOT NULL,         -- Total expenses in the report
    category_breakdown JSON NOT NULL,                -- Breakdown of expenses by category (JSON type)
    FOREIGN KEY (user_id) REFERENCES Users(id)      -- Foreign key constraint
);

CREATE TABLE Meta (
    id VARCHAR(36) PRIMARY KEY,                      -- Unique identifier for the meta (UUID)
    user_id VARCHAR(36) NOT NULL,                    -- User ID associated with the meta (Foreign Key)
    target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount >= 0), -- Target amount for savings or expenses
    achieved_amount DECIMAL(10, 2) NOT NULL CHECK (achieved_amount >= 0), -- Amount achieved towards the target
    deadline DATE NOT NULL,                          -- Deadline for achieving the target
    FOREIGN KEY (user_id) REFERENCES Users(id)      -- Foreign key constraint
);