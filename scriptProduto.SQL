	CREATE TABLE produtos(
		produtoId int IDENTITY(1,1) NOT NULL,
		nome varchar(60) NULL,
		descricao varchar(255) null,
		valor decimal(18,5) default 0.00000 null,
		quantidade decimal(18,5) default 0.00000 null,
		categoriaId int null,
		PRIMARY KEY (produtoId),
		CONSTRAINT FK_ProdutosCategorias 
		FOREIGN KEY (categoriaId) references categorias(categoriaId)
	)