	CREATE TABLE clientes(
		clienteId int IDENTITY(1,1) NOT NULL,
		nome varchar(60) NULL,
		endereco varchar(60) null,
		cidade varchar(50) null,
		bairro varchar(40) null,
		estado varchar(2) null,
		cep varchar(10) null,
		telefone varchar(14) null,  
		email varchar(100) null,
		dataNascimento datetime null
		PRIMARY KEY (clienteId),
	)