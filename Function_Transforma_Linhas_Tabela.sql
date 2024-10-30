CREATE FUNCTION dbo.fnSinvalPereira (@TextoOriginal NVARCHAR(MAX), @Separador CHAR(1))
RETURNS TABLE
AS
RETURN
(
    WITH Sequencial AS (
		--Trecho usado para garantir uma sequencia de numeros.
		--Nada nativo me veio a mente para gerar essa sequencia.
		--LEN(@String) especifica o n�mero m�ximo de sequencia a serem geradas de acordo com o comprimento da string, assim, evita-se gerar n�meros desnecess�rios.
		--ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) gera um incremento de n�meros (1,2,3, ...), que ser�o usados como �ndices para acessar as posi��es da variavel @TextoOriginal.
		--sys.all_objects � uma das tabelas de sistema que cont�m informa��es sobre todos os objetos no banco de dados, como tabelas, views, etc. 
		--Ela � usada aqui apenas para gerar um conjunto de linhas que o ROW_NUMBER() transformar� em uma sequ�ncia num�rica.
        SELECT TOP (LEN(@TextoOriginal)) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS seq
        FROM sys.all_objects
    ),
    SeparaPosicoes AS (
        SELECT 
            seq AS InicioPosicoes,
            ISNULL(NULLIF(CHARINDEX(@Separador, @TextoOriginal + @Separador, seq), 0), LEN(@TextoOriginal) + 1) AS FimPosicoes
        FROM Sequencial
        WHERE seq = 1 OR SUBSTRING(@TextoOriginal, seq - 1, 1) = @Separador
    )
    SELECT 
        Item = SUBSTRING(@TextoOriginal, InicioPosicoes, FimPosicoes - InicioPosicoes)
    FROM SeparaPosicoes
    WHERE InicioPosicoes < FimPosicoes
);