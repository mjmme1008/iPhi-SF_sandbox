SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
 -- GO
 -- SET QUOTED_IDENTIFIER ON
 -- GO

create procedure [dbo].[sp_get_gift_changes]
  AS
begin

	select 
	ta.party_id,
	cast(ta.tran_id as varchar(20)) as ExtSysIdGift__c, 
	--cast(c.contrib_id as varchar(20)) as ExtSysIdGift1__c,	
	coalesce((select SfId from sf_map_org_account where sf_map_org_account.PartyId = ta.party_id ),(select SfId from sf_map_hh_account where sf_map_hh_account.PartyId = ta.party_id)) as AccountId,
	coalesce(ct.pmt_amount,t.trade_total_a) as TotalAmountReceived__c,
	coalesce(ct.pmt_amount,t.trade_total_a) as Amount,
	cast(ta.effective_d as date) as CloseDate,
	cast(c.contrib_id as varchar(20)) as Name,
	'Donation' as RecordTypeId,
	'Closed Won' as StageName,
	1 as npe01__Do_Not_Automatically_Create__Payment__c,
    (select at.name from tcf..acct_type_c at where at.code = a.acct_type_c) as Fund_Type__c,    
    (select SfId from sf_map_fund where AcctId = a.acct_id) as Fund__c, 
	case when ltrim(rtrim(c.honorarium_txt))='' then NULL else c.honorarium_txt end as npsp_Honoree_Name__c,
	case when ltrim(rtrim(c.memorial_txt))='' then NULL else c.memorial_txt end as InMemoryOf__c,
	--(select SfId from sf_map_contact where sf_map_contact.PartyId = ta.party_id) as npsp__Primary_Contact__c,
	CASE WHEN c.anonymous_contributor_f = 'Y' THEN 'true' ELSE 'false' END as Anonymous__c,
	(SELECT i.long_nm FROM tcf.dbo.instrument i where i.instr_id = t.instr_id) as Description,
	t.req_units_q as NumberOfShares__c,
	t.unit_price_a as PricePerShare__c,
	cast(t.settle_d as date) as SettlementDate__c,
	--FimsG.GiftTypeDescr as GiftType__c,
	--FimsG.PurDescr as GiftPurpose__c,
	--FimsG.SolName as Solicitor__c,
	--FimsG.PledgeNum,
	--FimsG.SouDescr as Source__c,
	ta.combine_pmt_f as Comments__c,
	--'' as FundName__c, --concatenate from fundid field.
	--substring(coalesce(AckSalutation,'') + ' ' + coalesce(AckName,'') + ' ' + coalesce(AckTitle,'') + ' ' + coalesce(AckAddress1,'') + ' ' + coalesce(AckAddress2,'') + ' ' + coalesce(AckCityStZip,''),1,255) as ReceiptAddress__c,
	--fims_sf_map_gift.SfId,
	'Gift Upsert' as sf_object
	FROM 
    tcf.dbo.trans_action ta 
	left join tcf.dbo.cash_trans ct on ta.tran_id = ct.tran_id
	left join tcf.dbo.trade t on ta.tran_id = t.tran_id
    left join tcf.dbo.account a on ta.acct_id = a.acct_id,
	tcf.dbo.trans_type_c tt,
	tcf.dbo.contribution c,
	sf_control_table,
	sf_map_gifts
	WHERE ta.trans_type_c = tt.code 
    	and ta.parent_obj_id = c.contrib_id 
    	and tt.name like '%Contr%'
	and ta.trans_status_c <> 7 --exclude cancels
	and ta.trans_type_c <> 611 --skipping multi allocation gifts because there are so few.
	and ((dbo.Fn_stampdatetime(ta.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(ta.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = ta.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	and sf_control_table.source_object = 'IPHISync'
	and ta.tran_id = sf_map_gifts.TranId

	order by ta.party_id

end

GO
