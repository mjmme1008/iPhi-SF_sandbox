SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_opportunity_contact_role_changes]
AS
begin

	
    select
--    cast(ip.acct_id as varchar(20)) + '-' + cast(ip.seq_num as varchar(3)) as ExtSysId__c, 	
    cast(ip.acct_id as varchar(10)) + '-' + cast(ip.party_id as varchar(10)) as ExtSysId__c, 	
	(select SfId from sf_map_contact where sf_map_contact.PartyId = ip.party_id) as ContactId,
	CASE WHEN ip.seq_num = 1 THEN 'true' ELSE 'false' END as IsPrimary,
	(select SfId from sf_map_gifts where sf_map_gifts.TranId = ta.tran_id) as OpportunityId, 
    --ta.tran_id as OpportunityId,
	'Donor' as Role,
	'Opportunity Role Upsert' as sf_object
	FROM tcf.dbo.trans_action ta,
		tcf.dbo.interested_party ip, 
		tcf.dbo.contribution c,
		tcf.dbo.party p,
		sf_control_table,
        sf_map_opp_contact_roles 
	WHERE ip.acct_id = c.contrib_id 
	and ta.parent_obj_id = c.contrib_id
	and ip.party_id = p.party_id 
	and p.party_typ_c = 1
	and ta.trans_status_c <> 7 --exclude cancels
	and not ta.trans_type_c in (612, 699) --Multi-Acct Contr, Complex Contrib , Recurring Contri
	and sf_control_table.source_object = 'IPHISync'
    and cast(ip.acct_id as varchar(10)) + '-' + cast(ip.party_id as varchar(10)) = sf_map_opp_contact_roles.Id
    and sf_map_opp_contact_roles.SfId is null
	and ((dbo.Fn_stampdatetime(ta.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(ta.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	order by 1, 3

end

GO
