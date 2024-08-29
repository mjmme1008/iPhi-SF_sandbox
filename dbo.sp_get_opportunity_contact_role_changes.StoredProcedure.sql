USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_opportunity_contact_role_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_get_opportunity_contact_role_changes]
AS
begin

	
    select
    cast(ip.acct_id as varchar(20)) + '-' + cast(ip.seq_num as varchar(3)) as ExtSysId__c, 	
	(select SfId from sf_map_contact where sf_map_contact.PartyId = ip.party_id) as ContactId,
	CASE WHEN ip.seq_num = 1 THEN 'true' ELSE 'false' END as IsPrimary,
	ta.tran_id as OpportunityId,
	'Donor' as Role,
	'Opportunity Role Upsert' as sf_object
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
	and ((dbo.Fn_stampdatetime(ta.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(ta.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	order by 1, 3

end

GO
