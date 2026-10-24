CREATE DATABASE IF NOT EXISTS ai_customer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ai_customer;
DROP TABLE IF EXISTS operaciones;
DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes (
 id_cliente INT PRIMARY KEY,
 nombre VARCHAR(80) NOT NULL,
 ciudad VARCHAR(50) NOT NULL,
 antiguedad_meses INT NOT NULL,
 abandono TINYINT NOT NULL
);
CREATE TABLE operaciones (
 id_operacion INT PRIMARY KEY,
 id_cliente INT NOT NULL,
 fecha DATE NOT NULL,
 importe DECIMAL(10,2) NOT NULL,
 canal VARCHAR(30) NOT NULL,
 CONSTRAINT fk_operaciones_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);
