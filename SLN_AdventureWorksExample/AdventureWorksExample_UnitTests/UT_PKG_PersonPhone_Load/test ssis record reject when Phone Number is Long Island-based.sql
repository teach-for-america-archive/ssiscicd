CREATE PROCEDURE [UT_PKG_PersonPhone_Load].[test ssis record reject when Phone Number is Long Island-based]
AS
BEGIN

/**********************************************************/
/* Setup parameters required for running the SSIS Package */
/**********************************************************/

-- Package Details
DECLARE @package_name nvarchar(200) = N'PKG_PersonPhone_Load.dtsx';
DECLARE @project_name nvarchar(200) = N'AdventureWorksExample';
DECLARE @folder_name nvarchar(200) = N'TestProjectFolder';

-- SSIS Execution Parameters
DECLARE @execution_id bigint;
DECLARE @reference_id smallint = null;

-- SSIS Catalog Variables (object_type = 50)
DECLARE @logging_level smallint = 3;
DECLARE @is_synchronized smallint = 1;

-- Project Variables (object_type = 20)
DECLARE @AW_SRC_InitialCatalog nvarchar(100) = N'AdventureWorksSrc';
DECLARE @AW_SRC_ServerName nvarchar(100) = N'.';
DECLARE @AW_SRC_ConnectionString nvarchar(500) = N'Data Source=.;Initial Catalog=AdventureWorksSrc;Provider=SQLNCLI11.1;Persist Security Info=False;Auto Translate=True;Integrated Security=SSPI;';
DECLARE @AW_TGT_InitialCatalog nvarchar(100) = N'AdventureWorksTgt';
DECLARE @AW_TGT_ServerName nvarchar(100) = N'.';
DECLARE @AW_TGT_ConnectionString nvarchar(500) = N'Data Source=.;Initial Catalog=AdventureWorksTgt;Provider=SQLNCLI11.1;Persist Security Info=False;Auto Translate=True;Integrated Security=SSPI;';

-- Package Variables (object_type = 30)
-- N/A

/******************************************************************/
/* Fake Src and Tgt tables, insert test data, setup expected data */
/******************************************************************/

exec [AdventureWorksSrc].tSQLt.faketable 'Person.PersonPhone', @Identity = 1;
exec [AdventureWorksTgt].tSQLt.faketable 'Person.PersonPhone', @Identity = 1;

INSERT INTO [AdventureWorksSrc].Person.PersonPhone (
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate]
	) 
VALUES	(1, '207-111-2222', 1, '2018-12-20 00:00:00'),
		(2, '641-112-2223', 2, '2018-12-21 00:00:00'),
		(3, '207-654-3223', 3, '2018-12-22 00:00:00'),
		(4, '864-222-3333', 4, '2018-12-23 00:00:00'),
		(5, '207-243-3051', 1, '2018-12-24 00:00:00'),
		(6, '516-676-5115', 2, '2018-12-25 00:00:00'), --Long Island
		(7, '212-279-2080', 2, '2018-12-25 00:00:00')


CREATE TABLE #expected
(
	[BusinessEntityID] [int] NOT NULL,
	[PhoneNumber] nvarchar(25) NOT NULL,
	[PhoneNumberTypeID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)

INSERT INTO #expected (
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate]
	) 
VALUES	(2, '641-112-2223', 2, '2018-12-21 00:00:00'),
	(4, '864-222-3333', 4, '2018-12-23 00:00:00'),
	(7, '212-279-2080', 2, '2018-12-25 00:00:00')

/**********************************************************/
/* Run the SSIS Package						              */
/**********************************************************/

EXEC [SSISDB].[catalog].[create_execution] @package_name=@package_name, @execution_id=@execution_id OUTPUT, @folder_name=@folder_name, @project_name=@project_name, @use32bitruntime=False, @reference_id=@reference_id;

EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@logging_level;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 50, @parameter_name=N'SYNCHRONIZED', @parameter_value=@is_synchronized;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksSrc_Conn_InitialCatalog', @parameter_value=@AW_SRC_InitialCatalog;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksSrc_Conn_ServerName', @parameter_value=@AW_SRC_ServerName;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksSrc_Conn_ConnectionString', @parameter_value=@AW_SRC_ConnectionString;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksTgt_Conn_InitialCatalog', @parameter_value=@AW_TGT_InitialCatalog;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksTgt_Conn_ServerName', @parameter_value=@AW_TGT_ServerName;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 20, @parameter_name=N'AdventureWorksTgt_Conn_ConnectionString', @parameter_value=@AW_TGT_ConnectionString;

EXEC [SSISDB].[catalog].[start_execution] @execution_id;

/**********************************************************/
/* Check the results						              */
/**********************************************************/
SELECT 
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate]
INTO #actual
  FROM [AdventureWorksTgt].Person.PersonPhone;

EXEC tSQLt.AssertEqualsTable #expected, #actual;

end
