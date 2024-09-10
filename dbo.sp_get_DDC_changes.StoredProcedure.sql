SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
 -- GO
 -- SET QUOTED_IDENTIFIER ON
 -- GO

CREATE procedure [dbo].[sp_get_ddc_changes]
  AS
begin

	select
	left('DDC'+cast(h.id as varchar(20)),20) as id,
	left('DDC'+cast(h.id as varchar(20)),20) as ExtSysIdGift__c, 
	--cast(c.contrib_id as varchar(20)) as ExtSysIdGift1__c,	
	coalesce((select SfId from sf_map_org_account where sf_map_org_account.PartyId = h.party_id ),(select SfId from sf_map_hh_account where sf_map_hh_account.PartyId = h.party_id)) as AccountId,
	h.trgt_amount as Amount,
	cast(coalesce(h.trgt_date_d,'12/31/2024') as date) as CloseDate,
	cast(h.name as varchar(20)) as Name,
	'Donation' as RecordTypeId,
	-- get current DDC  step
	(select replace(stepname,'Identification','Prospecting') as stepname from (
   select h.ddc_template_header_id,d.header_id , d.name stepname  
   , d.due_d, d.sequence_step,
		row_number() over(partition by header_id order by sequence_step desc) as rn
		from tcf..ddc_detail d
        inner join tcf..ddc_header h on d.header_id = h.id
		where 
		ddc_status_c = 
		case when h.ddc_header_status_c = 3 then 3 else 1 end 	--processing
		and subtask_f=0	--main task 
        and h.ddc_template_header_id = 15		--using Advancement Prospect template only to match stages that are set up in SF
        ) ddc_step
        where rn=1 and  ddc_step.header_id = h.id)  as StageName,
	-- 'Cultivation' as StageName,
	1 as npe01__Do_Not_Automatically_Create__Payment__c,
	NULL as npsp_Honoree_Name__c,
	NULL as InMemoryOf__c,
	NULL as NumberOfShares__c,
	NULL as PricePerShare__c,
	NULL as SettlementDate__c,
	'false' as Anonymous__c,
	-- (select SfId from sf_map_contact where sf_map_contact.PartyId = h.party_id) as npsp__Primary_Contact__c,
	coalesce(case when convert(varchar(10),h.officer_party_id) = 'jaguar1' OR h.officer_party_id = '6942' then '0054P000009tKZEQA2' else (select sfid from sf_map_user where sf_map_user.PartyId = h.officer_party_id) end ,'0054P000009tKZEQA2') as OwnerId,
	'DDC' as Description,
	--FimsG.GiftTypeDescr as GiftType__c,
	--FimsG.PurDescr as GiftPurpose__c,
	--FimsG.SolName as Solicitor__c,
	--FimsG.PledgeNum,
	--FimsG.SouDescr as Source__c,
	h.comment as Comments__c,
	--'' as FundName__c, --concatenate from fundid field.
	--substring(coalesce(AckSalutation,'') + ' ' + coalesce(AckName,'') + ' ' + coalesce(AckTitle,'') + ' ' + coalesce(AckAddress1,'') + ' ' + coalesce(AckAddress2,'') + ' ' + coalesce(AckCityStZip,''),1,255) as ReceiptAddress__c,
	--fims_sf_map_gift.SfId,
	'Gift Upsert' as sf_object
	FROM 
    tcf..ddc_header h,
	sf_control_table,
	sf_map_ddc
	WHERE 
	isnull(h.trgt_amount,0)<>0
	and h.ddc_template_header_id = 15 
	and h.ddc_header_status_c in (1,3) --current, completed
	--comment out dates when running full load
	and ((dbo.Fn_stampdatetime(h.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(h.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = h.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	and sf_control_table.source_object = 'IPHISync'
	and left('DDC'+cast(h.id as varchar(20)),20)= sf_map_ddc.HeaderId

	order by 1

end

GO
