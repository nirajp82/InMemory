USE master
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'InMemoryDB')
    DROP DATABASE [InMemoryDB]
GO
CREATE DATABASE InMemoryDB;
GO
USE InMemoryDB; 
GO
--Create a filegroup with memory_optimimized_data option
ALTER DATABASE InMemoryDB
ADD FILEGROUP InMemoryFG CONTAINS MEMORY_OPTIMIZED_DATA;
--Implement logical file to the group
ALTER DATABASE InMemoryDB 
ADD FILE (
    NAME=InMemoryFile, 
    FILENAME=N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\InMemoryOLTP\') 
TO FILEGROUP InMemoryFG;
--Create a table with memory_optimization options
CREATE TABLE ClaimIdMap
(
	ClaimId BIGINT NOT NULL, 
	ClaimHeaderId BIGINT NOT NULL IDENTITY (1,1)
	--Clustered indexes, which are the default for primary keys, are not supported with memory optimized tables. Specify a NONCLUSTERED index instead.
	CONSTRAINT pk_claim_id PRIMARY KEY NonClustered(ClaimId)
) WITH(Memory_Optimized = ON, DURABILITY = Schema_AND_DATA);
GO
--CREATE STORED Procedure to Insert Record into new In memory table.
DROP PROCEDURE IF EXISTS dbo.spiClaimIdMap;
GO
CREATE PROCEDURE spiClaimIdMap
(
	@ClaimId BIGINT,
	@ClaimHeaderId BIGINT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO ClaimIdMap(ClaimId) VALUES (@ClaimId);
	SELECT @ClaimHeaderId = SCOPE_IDENTITY();
END
