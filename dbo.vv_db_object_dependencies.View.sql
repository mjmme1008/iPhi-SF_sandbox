USE [SFdb_sandbox]
GO
/****** Object:  View [dbo].[vv_db_object_dependencies]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vv_db_object_dependencies] as 
SELECT top 100 percent SCH.name + '.' + OBJ.name AS ObjectName 
      ,OBJ.type_desc AS ObjectType 
      ,obj.create_date
      ,obj.modify_date
      ,COL.name AS ColumnName 
      ,DEP.referenced_database_name AS ReferencedDatabase 
      ,REFSCH.name + '.' + REFOBJ.name AS ReferencedObjectName 
      ,REFOBJ.type_desc AS ReferencedObjectType 
      ,REFCOL.name AS ReferencedColumnName       
      ,DEP.referencing_class_desc AS ReferenceClass 
      ,DEP.is_schema_bound_reference AS IsSchemaBound 
FROM sys.sql_expression_dependencies AS DEP 
     INNER JOIN 
     sys.objects AS OBJ 
         ON DEP.referencing_id = OBJ.object_id 
     INNER JOIN 
     sys.schemas AS SCH 
         ON OBJ.schema_id = SCH.schema_id 
     LEFT JOIN sys.columns AS COL 
         ON DEP.referencing_id = COL.object_id 
            AND DEP.referencing_minor_id = COL.column_id 
     INNER JOIN sys.objects AS REFOBJ 
         ON DEP.referenced_id = REFOBJ.object_id 
     INNER JOIN sys.schemas AS REFSCH 
         ON REFOBJ.schema_id = REFSCH.schema_id 
     LEFT JOIN sys.columns AS REFCOL 
         ON DEP.referenced_class IN (0, 1) 
            AND DEP.referenced_minor_id = REFCOL.column_id 
            AND DEP.referenced_id = REFCOL.object_id 
--            where obj.name='vv_GLSummary_AFS-BS'
ORDER BY ObjectName 
        ,ReferencedObjectName 
        ,REFCOL.column_id 
        
        --select distinct name,referenced_entity_name,referenced_database_name,type_desc,create_date,modify_date
        -- from sys.sql_expression_dependencies 
        --inner join sys.objects on sql_expression_dependencies.referencing_id=objects.object_id
        --where referenced_database_name='rptprodcodes' order by name
        
        
        --select AccountTypeGroup,COUNT(*) as NbrAccts from Account01 
        --where AccountStatusID=1 and accounttypegroup is not null
        --group by AccountTypeGroup   order by AccountTypeGroup
        
        --select distinct accountstatusid,accountstatusname from Account01
GO
