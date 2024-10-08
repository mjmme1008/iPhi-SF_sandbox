USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_user_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_user_mapping]
AS
begin
	select p.party_id
	from tcf.dbo.party_role pr, tcf.dbo.party p
	where p.party_id = pr.party_id
	and pr.role_type_c = 20 and pr.role_status_c = 1
	and (p.loginid not like 'sf_%' AND p.loginid not like '%test%')
	and not exists (select 1 from sf_map_user map1 where map1.PartyId = p.party_id)
	order by 1

end

GO
