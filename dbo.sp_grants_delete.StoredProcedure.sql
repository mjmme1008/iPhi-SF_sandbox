USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_grants_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_grants_delete]
AS
begin
	--grants to delete from the maping tables and salesforce
	select Id, SfId from sf_map_grants
	where SfId is not null
	and not exists (select 1 	FROM tcf.dbo.grantee g
									left outer join tcf.dbo.applicant a on a.applic_id = g.applic_id
									and cast(g.grantee_id as varchar(20)) = sf_map_grants.Id)

end
GO
