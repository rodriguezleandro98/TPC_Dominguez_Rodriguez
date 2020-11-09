use master
go
drop database RODRIGUEZ_DB
go
Create Database RODRIGUEZ_DB
go
Use RODRIGUEZ_DB
go
CREATE TABLE Usuarios(
	ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDTipodeusuario INT NOT NULL,
	NombreU VARCHAR(50) UNIQUE NOT NULL,
	Contraseña VARCHAR(50) NOT NULL,
	Nombres VARCHAR(50) NOT NULL,
	Apellidos VARCHAR(50) NOT NULL,
	Estado BIT NOT NULL,
)
GO
CREATE TABLE TipoUsuario(
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(50) NOT NULL
)
GO
CREATE TABLE Cliente(
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombres VARCHAR(50) NOT NULL,
	Apellidos VARCHAR(50) NOT NULL,
	Estado BIT NOT NULL,
	Direccion VARCHAR(100) NOT NULL,
	Telefono VARCHAR(20) NOT NULL,
	FechaReg date NOT NULL
)
GO
CREATE TABLE Solicitud(
	ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDCliente INT NOT NULL,
	IDUsuario BIGINT NOT NULL,
	IDSintoma INT NOT NULL,
	Titulo VARCHAR(100),
	Descripcion VARCHAR(500),
	IDEstado INT NOT NULL,
	FechaInicio date not null,
	FechaFin date null
)
GO
CREATE TABLE Comentarios(
	ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDSolicitud BIGINT NOT NULL,
	IDUsuario BIGINT NOT NULL,
	Comentario VARCHAR(500) NOT NULL
)
GO
CREATE TABLE EstadosdeS(
	ID INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	Nombre VARCHAR(50) NOT NULL
)
GO
CREATE TABLE Sintomas(
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(100) NOT NULL,
	Estado bit not null
)
GO

/* Restricciones */
-- Foreign Key
Alter Table Usuarios
Add constraint FK_TipoUsuario Foreign Key(IDTipodeusuario) references TipoUsuario(ID)
go
Alter Table Solicitud
Add constraint FK_Cliente Foreign Key(IDCliente) references Cliente(ID)
go
Alter Table Solicitud
Add constraint FK_Usuario Foreign Key(IDUsuario) references Usuarios(ID)
go
Alter Table Solicitud
Add constraint FK_Sintoma Foreign Key(IDSintoma) references Sintomas(ID)
go
Alter Table Solicitud
Add constraint FK_Estado Foreign Key(IDEstado) references EstadosdeS(ID)
go
Alter Table Comentarios
Add constraint FK_IDSolicitud Foreign Key(IDSolicitud) references Solicitud(ID)
go
Alter Table Comentarios
Add constraint FK_IDUsuario Foreign Key(IDUsuario) references Usuarios(ID)
go

/* Inserts */
Insert INTO Usuarios VALUES (1,'leanadmin','admin','leandro','rodriguez',1)

/* Vistas */

Create View VW_ListaUsuarios AS
Select U.*, TU.Nombre FROM Usuarios AS U
INNER JOIN TipoUsuario as TU ON TU.ID = U.IDTipodeusuario
GO

Create View VW_ListaClientes AS
Select * FROM Cliente
GO

Create View VW_ListaSolicitud AS
Select S.*, ES.Nombre FROM Solicitud AS S
INNER JOIN Cliente AS C ON C.ID = S.IDCliente
INNER JOIN Usuarios AS U ON U.ID = S.IDUsuario
INNER JOIN Sintomas AS SS ON SS.ID = S.IDSintoma
INNER JOIN EstadosdeS AS ES ON ES.ID = S.IDEstado
GO

/* STORE PROCEDURE */
CREATE PROCEDURE SP_Solicitud(
	@ID BIGINT
)
AS
BEGIN
SELECT S.ID, S.IDCliente, S.IDUsuario, S.IDSintoma, S.Titulo, S.Descripcion, S.IDEstado, S.FechaInicio , U.Nombres, U.Apellidos, ES.Nombre 
FROM Solicitud AS S
INNER JOIN Cliente AS C ON C.ID = S.IDCliente
INNER JOIN Usuarios AS U ON U.ID = S.IDUsuario
INNER JOIN Sintomas AS SS ON SS.ID = S.IDSintoma
INNER JOIN EstadosdeS AS ES ON ES.ID = S.IDEstado
WHERE S.ID = @ID
END
GO

Create procedure SP_ListaSolicitud_Abierta(
	@IDCliente INT
)
AS
BEGIN
Select S.ID, S.Titulo, S.FechaInicio, ES.Nombre, SI.Nombre FROM Solicitud as S
INNER JOIN EstadosdeS AS ES ON ES.ID = S.IDEstado
INNER JOIN Sintomas as SI ON SI.ID = S.IDSintoma
WHERE S.IDCliente = @IDCliente AND S.IDEstado between 1 and 2 
END
GO

Create procedure SP_ListaSolicitud_Cerrada(
	@IDCliente INT
)
AS
BEGIN
Select S.ID, S.Titulo, S.FechaInicio, S.FechaFin, ES.Nombre, SI.Nombre FROM Solicitud as S
INNER JOIN EstadosdeS AS ES ON ES.ID = S.IDEstado
INNER JOIN Sintomas as SI ON SI.ID = S.IDSintoma
WHERE S.IDCliente = IDCliente AND S.IDEstado between 3 and 5
END
GO

Create procedure SP_Alta_Solicitud(
	@IDCliente int,
	@IDUsuario bigint,
	@IDSintoma int,
	@Titulo varchar(100),
	@Descripcion varchar(500),
	@IDEstado int,
	@FechaInicio date
)
AS 
BEGIN
INSERT INTO Solicitud VALUES (@IDCliente, @IDUsuario, @IDSintoma, @Titulo, @Descripcion, @IDEstado, @FechaInicio, null)
END
GO

EXEC SP_Alta_Solicitud 1,1,1,'ASD','ASD',1,'06/07/2020'

INSERT INTO Solicitud VALUES (1,1,1,'asd','asd',1,'6/07/2020', NULL)
go

CREATE PROCEDURE SP_Validar_Usuario(
	@NombreU varchar(50),
	@Contraseña varchar(50)
)
AS
BEGIN
SELECT U.*, TU.Nombre FROM Usuarios AS U
INNER JOIN TipoUsuario as TU ON TU.ID = U.IDTipodeusuario
WHERE NombreU = @NombreU AND Contraseña = @Contraseña
END
GO

CREATE PROCEDURE SP_Alta_Usuario(
	@IDTipodeusuario int,
	@NombreU varchar(50),
	@Contraseña varchar(50),
	@Nombres varchar(50),
	@Apellidos varchar(50),
	@Estado bit
)
AS
BEGIN
INSERT INTO Usuarios VALUES (@IDTipodeusuario, @NombreU, @Contraseña, @Nombres, @Apellidos, @Estado)
END
GO

CREATE PROCEDURE SP_Usuario_Inactivo(
	@ID BIGINT,
	@Estado bit
)
AS
BEGIN 
UPDATE Usuarios SET Estado = @Estado WHERE ID = @ID
END
GO

CREATE PROCEDURE SP_Modificar_Usuario(
	@ID BIGINT,
	@IDTipodeusuario int,
	@NombreU varchar(50),
	@Contraseña varchar(50),
	@Nombres varchar(50),
	@Apellidos varchar(50),
	@Estado bit
)
AS
BEGIN
UPDATE Usuarios SET IDTipodeusuario = @IDTipodeusuario, NombreU = @NombreU, Contraseña = @Contraseña, Nombres = @Nombres, Apellidos = @Apellidos, Estado = @Estado
WHERE ID = @ID
END
GO

CREATE PROCEDURE SP_Alta_Cliente(
	@Nombres varchar(50),
	@Apellidos varchar(50),
	@Estado bit,
	@Direccion varchar(100),
	@Telefono varchar(20),
	@FechaReg date
)
AS
BEGIN 
INSERT INTO Cliente VALUES (@Nombres, @Apellidos, @Estado, @Direccion, @Telefono, @FechaReg)
END
GO

CREATE PROCEDURE SP_Modificar_Cliente(
	@ID BIGINT,
	@Nombres varchar(50),
	@Apellidos varchar(50),
	@Estado bit,
	@Direccion varchar(100),
	@Telefono varchar(20),
	@FechaReg date
)
AS
BEGIN
UPDATE Cliente SET Nombres = @Nombres, Apellidos = @Apellidos, Estado = @Estado, Direccion = @Direccion, Telefono = @Telefono, FechaReg = @FechaReg
WHERE ID = @ID
END
GO

CREATE PROCEDURE SP_Cliente_Inactivo(
	@ID int,
	@Estado bit
)
AS
BEGIN 
UPDATE Cliente SET Estado = @Estado WHERE ID = @ID
END
GO

CREATE PROCEDURE SP_Alta_Comentario(
	@IDSolicitud bigint,
	@IDUsuario bigint,
	@Comentario varchar(500)
)
AS
BEGIN
INSERT INTO Comentarios VALUES (@IDSolicitud,@IDUsuario, @Comentario)
END
GO

Create procedure SP_Listar_Comentarios(
	@IDSolicitud BIGINT
)
AS
BEGIN
SELECT C.ID, C.IDUsuario, U.Nombres, U.Apellidos, C.Comentario
FROM Comentarios as C
INNER JOIN Usuarios AS U ON U.ID = C.IDUsuario
WHERE C.IDSolicitud = @IDSolicitud
END
GO

Select * from Usuarios 
Select * from Cliente



	
