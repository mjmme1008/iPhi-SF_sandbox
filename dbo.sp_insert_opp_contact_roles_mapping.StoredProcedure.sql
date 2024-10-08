SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_insert_opp_contact_roles_mapping]
AS
begin

	select 
 --   cast(ip.acct_id as varchar(10)) + '-' + cast(ip.seq_num as varchar(3)) as Id
   cast(ip.acct_id as varchar(10)) + '-' + cast(ip.party_id as varchar(10)) as Id
	FROM tcf.dbo.trans_action ta,
		tcf.dbo.interested_party ip, 
		tcf.dbo.contribution c,
		tcf.dbo.party p,
		sf_control_table
	WHERE ip.acct_id = c.contrib_id 
	and ta.parent_obj_id = c.contrib_id
	and ip.party_id = p.party_id 
	and p.party_typ_c = 1
	and ta.trans_status_c <> 7 --exclude cancels
	and ta.trans_type_c <> 611 --skipping multi allocation gifts because there are so few. 
	and sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_opp_contact_roles map1 where map1.Id = cast(ip.acct_id as varchar(20)) + '-' + cast(ip.seq_num as varchar(3)))
	order by 1

end

GO
